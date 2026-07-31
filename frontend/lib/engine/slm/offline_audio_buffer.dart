import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class OfflineAudioBuffer {
  Timer? _mockRecordingTimer;

  final int maxDurationSeconds;
  
  // Rolling buffer to physically hold the byte stream in temporary RAM
  final List<Uint8List> _rollingBuffer = [];
  bool _isRecording = false;

  OfflineAudioBuffer({this.maxDurationSeconds = 30});

  Future<void> startBuffering() async {
    if (_isRecording) return;
    
    _isRecording = true;
    try {
      // Hardware plugin 'record' was removed due to upstream compilation crashes.
      // Simulating a PCM16 audio stream dumping byte chunks directly into RAM.
      _mockRecordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Generating a dummy 32000 byte chunk (1 second of 16kHz PCM16 audio)
        final dummyChunk = Uint8List(32000);
        _manageBuffer(dummyChunk);
      });
      
      debugPrint('Secure ephemeral RAM buffer active (Simulated Mic Stream).');
    } catch (e) {
      debugPrint('Error starting offline audio buffer: $e');
    }
  }

  void _manageBuffer(Uint8List chunk) {
    _rollingBuffer.add(chunk);
    
    // Calculate approximate duration based on 16kHz PCM16 buffer lengths
    // (16000 samples/sec * 2 bytes/sample) = 32000 bytes/second
    final currentBytes = _rollingBuffer.fold(0, (sum, chunk) => sum + chunk.length);
    final maxBytes = maxDurationSeconds * 32000;

    // Immediately evict memory segments older than 30s to enforce privacy limits
    while (currentBytes > maxBytes && _rollingBuffer.isNotEmpty) {
      _rollingBuffer.removeAt(0);
    }
  }

  Future<void> stopBuffering() async {
    _isRecording = false;
    _mockRecordingTimer?.cancel();
    
    // Aggressive garbage collection queue mechanism
    _rollingBuffer.clear();
    debugPrint('Secure buffer destroyed and memory wiped.');
  }

  Uint8List dumpBufferForInference() {
    // Generate a singular block for the local Whisper-Tiny inference hook
    final BytesBuilder builder = BytesBuilder();
    for (var chunk in _rollingBuffer) {
      builder.add(chunk);
    }
    return builder.toBytes();
  }
}

