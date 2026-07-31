import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

import '../engine/models/detection_result.dart';
import '../engine/models/risk_level.dart';
import '../engine/models/scam_category.dart';

/// On-device ONNX BERT scam classifier.
///
/// Loads `model_int8.onnx` and `tokenizer.json` from Flutter assets and runs
/// inference entirely on the device — no network required.
///
/// The model is a BertForSequenceClassification (BERT-small, 12 layers,
/// hidden_size 384) fine-tuned for binary classification: safe (0) / scam (1).
/// Scam sub-categories are resolved via keyword matching (same logic as the
/// backend `_classify_category`).
class OnnxService {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------
  OnnxService._();
  static final OnnxService instance = OnnxService._();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------
  static const String _modelAsset = 'assets/model/model_int8.onnx';
  static const String _tokenizerAsset = 'assets/model/tokenizer.json';

  static const int _maxLength = 128;
  static const int _padTokenId = 1;
  static const int _clsTokenId = 0; // <s>
  static const int _sepTokenId = 2; // </s>

  static const int _labelSafe = 0;
  static const int _labelScam = 1;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  OrtSession? _session;
  Map<String, int>? _vocab;
  List<List<String>>? _merges;
  bool _isInitializing = false;
  bool _isReady = false;

  bool get isReady => _isReady;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Loads model + tokenizer. Safe to call multiple times (idempotent).
  Future<void> initialize() async {
    if (_isReady || _isInitializing) return;
    _isInitializing = true;

    try {
      // Load tokenizer vocab & merges from the HuggingFace tokenizer.json
      await _loadTokenizer();

      // Load ONNX model
      final ort = OnnxRuntime();
      _session = await ort.createSessionFromAsset(_modelAsset);

      _isReady = true;
      developer.log('OnnxService: Model and tokenizer loaded successfully.');
    } catch (e, st) {
      developer.log('OnnxService: Failed to initialize', error: e, stackTrace: st);
      _isReady = false;
    } finally {
      _isInitializing = false;
    }
  }

  /// Parses the HuggingFace `tokenizer.json` to extract BPE vocab and merges.
  Future<void> _loadTokenizer() async {
    final raw = await rootBundle.loadString(_tokenizerAsset);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    // Extract vocab: { "token": id, ... }
    final model = json['model'] as Map<String, dynamic>;
    final vocabRaw = model['vocab'] as Map<String, dynamic>;
    _vocab = vocabRaw.map((key, value) => MapEntry(key, value as int));

    // Extract merges: ["a b", "c d", ...]
    final mergesRaw = model['merges'] as List<dynamic>;
    _merges = mergesRaw.map((m) {
      final parts = (m as String).split(' ');
      return parts;
    }).toList();

    developer.log('OnnxService: Tokenizer loaded — vocab size: ${_vocab!.length}, merges: ${_merges!.length}');
  }

  // ---------------------------------------------------------------------------
  // Prediction
  // ---------------------------------------------------------------------------

  /// Runs scam/safe prediction on [text] using the on-device ONNX model.
  ///
  /// Returns `null` if the model isn't ready (caller should fallback to
  /// the rule engine).
  Future<DetectionResult?> predict(String text) async {
    if (!_isReady) {
      await initialize();
      if (!_isReady) return null;
    }

    try {
      // 1. Tokenize
      final tokenIds = _tokenize(text);

      // 2. Build model inputs — truncate to _maxLength - 2 (room for CLS/SEP)
      final truncated = tokenIds.length > (_maxLength - 2)
          ? tokenIds.sublist(0, _maxLength - 2)
          : tokenIds;

      // [CLS] tokens [SEP]
      final inputIds = <int>[_clsTokenId, ...truncated, _sepTokenId];
      final attentionMask = List<int>.filled(inputIds.length, 1);
      final tokenTypeIds = List<int>.filled(inputIds.length, 0);

      // Pad to _maxLength
      final padLength = _maxLength - inputIds.length;
      if (padLength > 0) {
        inputIds.addAll(List<int>.filled(padLength, _padTokenId));
        attentionMask.addAll(List<int>.filled(padLength, 0));
        tokenTypeIds.addAll(List<int>.filled(padLength, 0));
      }

      // 3. Create OrtValue tensors — shape [1, _maxLength]
      final inputIdsTensor = await OrtValue.fromList(
        inputIds,
        [1, _maxLength],
      );
      final attentionMaskTensor = await OrtValue.fromList(
        attentionMask,
        [1, _maxLength],
      );
      final tokenTypeIdsTensor = await OrtValue.fromList(
        tokenTypeIds,
        [1, _maxLength],
      );

      // 4. Run inference
      final feeds = {
        'input_ids': inputIdsTensor,
        'attention_mask': attentionMaskTensor,
        'token_type_ids': tokenTypeIdsTensor,
      };

      final outputs = await _session!.run(feeds);

      // Dispose input tensors
      inputIdsTensor.dispose();
      attentionMaskTensor.dispose();
      tokenTypeIdsTensor.dispose();

      // 5. Parse logits output
      final logitsValue = outputs.values.first!;
      final logitsList = await logitsValue.asList();
      // logitsList is [[safe_logit, scam_logit]]  (shape [1, 2])
      final List<double> logits;
      if (logitsList.first is List) {
        logits = (logitsList.first as List).cast<double>();
      } else {
        logits = logitsList.cast<double>();
      }

      // Dispose output tensors
      for (final v in outputs.values) {
        v?.dispose();
      }

      // 6. Softmax
      final probabilities = _softmax(logits);
      final safeProbability = probabilities[_labelSafe];
      final scamProbability = probabilities[_labelScam];

      final labelId = scamProbability > safeProbability ? _labelScam : _labelSafe;
      final isScam = labelId == _labelScam;

      // 7. Risk + Category
      final risk = _riskFromPrediction(labelId, scamProbability);
      final category = isScam ? _classifyCategory(text) : ScamCategory.unknown;
      final confidence = isScam ? scamProbability : safeProbability;

      return DetectionResult(
        riskLevel: risk,
        confidence: confidence,
        category: category,
        matchedRules: const ['ONNX_BERT_SCAM_CLASSIFIER'],
        reason: 'Rakshak ML model classified this text as '
            '${isScam ? "a likely scam" : "likely safe"} '
            'with ${(confidence * 100).toStringAsFixed(1)}% confidence.',
        recommendedAction: isScam
            ? 'Do not click links, share OTPs, enter PINs, or send money until you verify through the official app or bank.'
            : 'No immediate risk detected. Continue with normal caution.',
        timestamp: DateTime.now(),
      );
    } catch (e, st) {
      developer.log('OnnxService: Prediction failed', error: e, stackTrace: st);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // BPE Tokenizer (pure Dart, HuggingFace-compatible)
  // ---------------------------------------------------------------------------

  /// Tokenises [text] into a list of integer token IDs using BPE.
  List<int> _tokenize(String text) {
    if (_vocab == null || _merges == null) return [];

    // Pre-tokenize: lowercase + split on whitespace and punctuation boundaries
    // This mirrors the XLM-RoBERTa pre-tokenizer (ByteLevel)
    final normalizedText = text.toLowerCase();

    // Split into words (roughly matching the pre-tokenizer behaviour).
    // We add the SentencePiece-style leading space marker "▁" (U+2581) before
    // each space-separated word, because the XLM-R tokenizer uses that convention.
    final words = <String>[];
    final parts = normalizedText.split(RegExp(r'\s+'));
    for (var i = 0; i < parts.length; i++) {
      final part = parts[i].trim();
      if (part.isEmpty) continue;
      // SentencePiece convention: prepend ▁ to each word
      words.add('▁$part');
    }

    // Tokenise each word with BPE, collect IDs
    final ids = <int>[];
    for (final word in words) {
      final wordIds = _bpeEncode(word);
      ids.addAll(wordIds);
    }

    return ids;
  }

  /// BPE-encodes a single word into token IDs.
  List<int> _bpeEncode(String word) {
    if (word.isEmpty) return [];

    // Check if the whole word is in vocab (common for short words)
    if (_vocab!.containsKey(word)) {
      return [_vocab![word]!];
    }

    // Start with individual characters
    var symbols = word.split('');

    // Apply BPE merges greedily
    for (final merge in _merges!) {
      if (symbols.length <= 1) break;

      final first = merge[0];
      final second = merge[1];

      var i = 0;
      final newSymbols = <String>[];
      while (i < symbols.length) {
        if (i < symbols.length - 1 && symbols[i] == first && symbols[i + 1] == second) {
          newSymbols.add('$first$second');
          i += 2;
        } else {
          newSymbols.add(symbols[i]);
          i += 1;
        }
      }
      symbols = newSymbols;
    }

    // Convert subword tokens to IDs
    final ids = <int>[];
    for (final token in symbols) {
      final id = _vocab![token];
      if (id != null) {
        ids.add(id);
      } else {
        // Unknown token → <unk> (id=3)
        ids.add(3);
      }
    }
    return ids;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Numerically stable softmax.
  List<double> _softmax(List<double> logits) {
    final maxVal = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxVal)).toList();
    final sumExp = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExp).toList();
  }

  /// Maps model output to a [RiskLevel].
  RiskLevel _riskFromPrediction(int labelId, double scamProbability) {
    if (labelId == _labelSafe) {
      return scamProbability < 0.35 ? RiskLevel.safe : RiskLevel.low;
    }
    if (scamProbability >= 0.95) return RiskLevel.critical;
    if (scamProbability >= 0.80) return RiskLevel.high;
    return RiskLevel.medium;
  }

  /// Keyword-based sub-category classification (mirrors backend logic).
  ScamCategory _classifyCategory(String text) {
    final lower = text.toLowerCase();
    if (_anyMatch(lower, ['otp', 'one time password', 'verification code', 'pin'])) {
      return ScamCategory.otpScam;
    }
    if (lower.contains('kyc')) return ScamCategory.kycScam;
    if (_anyMatch(lower, ['lottery', 'prize', 'winner', 'won '])) {
      return ScamCategory.lotteryScam;
    }
    if (_anyMatch(lower, ['refund', 'cashback', 'reversal'])) {
      return ScamCategory.refundScam;
    }
    if (_anyMatch(lower, ['upi', 'collect request', '@ybl', '@ok', '@paytm', 'enter pin'])) {
      return ScamCategory.collectRequest;
    }
    if (_anyMatch(lower, ['http://', 'https://', 'bit.ly', 'tinyurl', 'click link'])) {
      return ScamCategory.phishingWebsite;
    }
    if (_anyMatch(lower, ['loan', 'pre-approved', 'processing fee'])) {
      return ScamCategory.fakeLoan;
    }
    if (_anyMatch(lower, ['investment', 'double money', 'guaranteed return'])) {
      return ScamCategory.investmentScam;
    }
    return ScamCategory.unknown;
  }

  bool _anyMatch(String text, List<String> terms) {
    return terms.any((t) => text.contains(t));
  }

  /// Release model resources.
  Future<void> dispose() async {
    if (_session != null) {
      await _session!.close();
      _session = null;
    }
    _isReady = false;
  }
}
