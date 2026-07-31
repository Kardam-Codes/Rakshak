import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'offline_audio_buffer.dart';
import 'offline_ai_engine.dart';

class OfflineCallProcessor {
  final OfflineAudioBuffer audioBuffer;
  final OfflineAiEngine aiEngine;
  
  bool _isProcessingSessionActive = false;

  OfflineCallProcessor({
    required this.audioBuffer,
    required this.aiEngine,
  });

  /// Starts the privacy-first interception pipeline
  Future<void> startLocalMonitoring() async {
    if (_isProcessingSessionActive) return;
    _isProcessingSessionActive = true;
    
    debugPrint('Initializing Offline Transcript Processor (F-009 Zero Knowledge)...');
    await aiEngine.initializeLocalSLM('models/llama3_8b_quantized.bin');
    await audioBuffer.startBuffering();
    
    // Begin continuous asynchronous screening
    _runContinuousInferenceLoop();
  }
  
  void _runContinuousInferenceLoop() async {
    while (_isProcessingSessionActive) {
      await Future.delayed(const Duration(seconds: 15)); // Polling lock strategy
      
      if (!_isProcessingSessionActive) break;
      
      // 1. Flush memory block for inference
      final audioBlock = audioBuffer.dumpBufferForInference();
      if (audioBlock.isEmpty) continue;
      
      // 2. Perform local Speech-to-Text inference (Native TFLite execution)
      final transcript = await _mockLocalSTTInference(audioBlock);
      
      if (transcript.isNotEmpty) {
        // 3. Keyword Heuristic Gate (Prevents engaging the heavy SLM unecessarily to block thermal throttling)
        if (_containsRiskKeywords(transcript)) {
           // 4. Pass transcript directly to the Offline SLM
           final riskAnalysis = await aiEngine.analyzeTranscriptOffline(transcript);
           
           if (riskAnalysis != null && riskAnalysis.contains('SCAM: YES')) {
             _triggerEmergencyOverlay(riskAnalysis);
           }
        }
      }
    }
  }

  Future<String> _mockLocalSTTInference(Uint8List audioBinary) async {
    // Native Speech-to-Text acoustic inference hook via TFLite
    // Simulating conversion of raw PCM16 bytes into text locally
    await Future.delayed(const Duration(milliseconds: 300));
    return "Hi, we are calling from the bank. Please download AnyDesk to prevent your account closure.";
  }

  bool _containsRiskKeywords(String text) {
    final lower = text.toLowerCase();
    const riskKeywords = ['anydesk', 'otp', 'remote', 'bank', 'blocked', 'account', 'verify', 'customs', 'arrest'];
    return riskKeywords.any((word) => lower.contains(word));
  }

  void _triggerEmergencyOverlay(String riskReport) {
    debugPrint('!!! ZERO-KNOWLEDGE LOCAL SCAM OVERLAY TRIGGERED !!!');
    debugPrint('Contextual Risk: $riskReport');
    // Integration point with FlutterOverlayWindow (F008)
  }

  Future<void> stopLocalMonitoring() async {
    _isProcessingSessionActive = false;
    await audioBuffer.stopBuffering();
    await aiEngine.destroySLM();
    debugPrint('Offline monitoring terminated. RAM buffers permanently erased.');
  }
}
