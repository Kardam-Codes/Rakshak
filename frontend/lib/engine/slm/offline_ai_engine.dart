import 'package:flutter/foundation.dart';
import 'package:mediapipe_genai/mediapipe_genai.dart';
import 'dart:async';

class OfflineAiEngine {
  static final OfflineAiEngine _instance = OfflineAiEngine._internal();
  factory OfflineAiEngine() => _instance;
  OfflineAiEngine._internal();

  bool _isModelLoaded = false;
  
  LlmInferenceEngine? _llmInference;
  Future<void> _inferenceLock = Future.value();
  
  Future<T> _synchronized<T>(Future<T> Function() action) async {
    final previousLock = _inferenceLock;
    final completer = Completer<void>();
    _inferenceLock = completer.future;
    try { await previousLock; } catch (_) {}
    try { return await action(); } finally { completer.complete(); }
  }
  
  Future<void> initializeLocalSLM(String modelPath) async {
    try {
      _llmInference = LlmInferenceEngine(LlmInferenceOptions.gpu(
        modelPath: modelPath,
        sequenceBatchSize: 1,
        maxTokens: 512,
        temperature: 0.1,
        topK: 1,
      ));
      _isModelLoaded = true;
      debugPrint('Local SLM ($modelPath) Loaded Securely into Memory.');
    } catch (e) {
      debugPrint('Failed to initialize local SLM via MediaPipe: $e');
    }
  }
  
  Future<String?> analyzeTranscriptOffline(String transcript) async {
    if (!_isModelLoaded) {
      debugPrint('SLM not loaded natively. Aborting inference.');
      return null;
    }
    
    final prompt = '''
Analyze the following phone call transcript for scams (OTP theft, impersonation, bank fraud).
Respond strictly with "SCAM: YES" or "SCAM: NO" followed by a 1-sentence reason.
Transcript: "$transcript"
''';

    return _synchronized(() async {
      try {
        if (_llmInference == null) return null;
        final responseStream = _llmInference!.generateResponse(prompt).timeout(const Duration(seconds: 15));
        final buffer = StringBuffer();
        await for (final chunk in responseStream) {
          buffer.write(chunk);
        }
        return buffer.toString();
      } catch (e) {
        debugPrint('Offline SLM inference exception: $e');
        return null;
      }
    });
  }

  Future<String?> generateExplanation(String contextData) async {
    if (!_isModelLoaded) {
      return 'Offline AI Disabled: The zero-knowledge privacy engine was unable to load the security weights.';
    }

    final prompt = '''
You are a cybersecurity expert. Summarize the danger of the following threat context in 2 short sentences.
Context: "$contextData"
''';

    return _synchronized(() async {
      try {
        if (_llmInference == null) return null;
        final responseStream = _llmInference!.generateResponse(prompt).timeout(const Duration(seconds: 15));
        final buffer = StringBuffer();
        await for (final chunk in responseStream) {
          buffer.write(chunk);
        }
        return buffer.toString();
      } catch (e) {
        debugPrint('SLM Explainability exception: $e');
        return 'Could not generate explanation due to an on-device error.';
      }
    });
  }
  
  Future<void> destroySLM() async {
    _llmInference?.dispose();
    _isModelLoaded = false;
  }
}
