import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../models/scan_entity.dart';
import '../repositories/scan_repository.dart';
import '../services/scan_analytics_service.dart';
import '../services/ocr_service.dart';
import '../engine/scan_engine.dart';
import 'database_provider.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ScanRepository(db);
});

final scanAnalyticsServiceProvider = Provider<ScanAnalyticsService>((ref) {
  final analytics = ScanAnalyticsService();
  analytics.init();
  return analytics;
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  final ocr = OcrService();
  ref.onDispose(() => ocr.dispose());
  return ocr;
});

final scanEngineProvider = Provider<ScanEngine>((ref) {
  final repository = ref.watch(scanRepositoryProvider);
  final analytics = ref.watch(scanAnalyticsServiceProvider);
  return ScanEngine(
    scanRepository: repository,
    analyticsService: analytics,
  );
});

final scanHistoryStreamProvider = StreamProvider<List<ScanResultEntity>>((ref) {
  final repository = ref.watch(scanRepositoryProvider);
  return repository.watchScans();
});

class ScanState {
  final bool isScanning;
  final String? statusMessage;
  final ScanResultEntity? lastResult;
  final String? errorMessage;

  const ScanState({
    this.isScanning = false,
    this.statusMessage,
    this.lastResult,
    this.errorMessage,
  });

  ScanState copyWith({
    bool? isScanning,
    String? statusMessage,
    ScanResultEntity? lastResult,
    String? errorMessage,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      statusMessage: statusMessage ?? this.statusMessage,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ScanController extends StateNotifier<ScanState> {
  final ScanEngine _scanEngine;

  ScanController(this._scanEngine) : super(const ScanState());

  Future<ScanResultEntity?> executeScan({
    required String rawContent,
    required ScanType scanType,
  }) async {
    state = state.copyWith(
      isScanning: true,
      statusMessage: 'Analyzing content with Rakshak Rule Engine...',
      errorMessage: null,
    );

    try {
      final result = await _scanEngine.processScan(
        rawContent: rawContent,
        scanType: scanType,
      );
      state = state.copyWith(
        isScanning: false,
        statusMessage: null,
        lastResult: result,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        statusMessage: null,
        errorMessage: 'Scan processing failed: ${e.toString()}',
      );
      return null;
    }
  }

  void clearLastResult() {
    state = state.copyWith(lastResult: null, errorMessage: null);
  }
}

final scanControllerProvider = StateNotifierProvider<ScanController, ScanState>((ref) {
  final engine = ref.watch(scanEngineProvider);
  return ScanController(engine);
});
