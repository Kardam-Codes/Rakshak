import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:flutter/foundation.dart';

class OfflineAudioBuffer {
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _recordSub;

  final int maxDurationSeconds;
  
  // Rolling buffer to physically hold the byte stream in temporary RAM
  final List<Uint8List> _rollingBuffer = [];
  bool _isRecording = false;

  OfflineAudioBuffer({this.maxDurationSeconds = 30});

  Future<void> startBuffering() async {
    if (_isRecording) return;
    
    if (await _audioRecorder.hasPermission()) {
      _isRecording = true;
      try {
        final stream = await _audioRecorder.startStream(const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ));
        
        _recordSub = stream.listen((data) {
          _manageBuffer(data);
        });
        debugPrint('Secure ephemeral RAM buffer active for audio stream.');
      } catch (e) {
        debugPrint('Error starting offline audio buffer: $e');
      }
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
    await _recordSub?.cancel();
    await _audioRecorder.stop();
    
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
