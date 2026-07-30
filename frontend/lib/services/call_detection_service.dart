import 'dart:async';
import 'package:flutter/services.dart';
import 'package:phone_state/phone_state.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';

import '../engine/rule_engine.dart';
import '../engine/models/risk_level.dart';
import '../models/call_entity.dart';
import '../repositories/call_repository.dart';
import 'number_reputation_service.dart';

class CallDetectionService {
  final CallRepository _repository;
  final NumberReputationService _reputationService;
  StreamSubscription<PhoneState>? _subscription;

  CallDetectionService(this._repository, this._reputationService);

  Future<void> initialize() async {
    // Request basic telephony permissions
    await Permission.phone.request();
    await Permission.contacts.request();
    
    final overlayGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!overlayGranted) {
      await FlutterOverlayWindow.requestPermission();
    }

    _subscription = PhoneState.stream.listen((event) {
      _handlePhoneState(event);
    });
  }

  void _handlePhoneState(PhoneState event) async {
    final phoneNumber = event.number;
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    if (event.status == PhoneStateStatus.CALL_INCOMING) {
      // 1. Fetch reputation
      final reputation = await _reputationService.getReputationScore(phoneNumber);
      final isKnown = false; // Mock, in reality use contacts plugin

      // 2. Offline analysis
      final result = RuleEngine.analyzeCall(phoneNumber, reputation, isKnownContact: isKnown);

      // 3. Trigger overlay if needed (< 500ms)
      if (result.riskLevel == RiskLevel.high || result.riskLevel == RiskLevel.critical) {
        _showWarningOverlay(phoneNumber, result.riskLevel.name, result.reason);
      }

    } else if (event.status == PhoneStateStatus.CALL_ENDED) {
      // Hide overlay
      FlutterOverlayWindow.closeOverlay();
      
      // Save Call Entity
      final callEntity = CallEntity(
        phoneNumber: phoneNumber,
        callType: 'incoming',
        timestamp: DateTime.now(),
        durationSeconds: 0, // Mock, needs CallLog info for real duration
        isKnownContact: false,
        riskLevel: RiskLevel.safe, // Need to re-trigger offline engine or fetch from cache
      );
      await _repository.saveCall(callEntity);
      
      // Future: Trigger Backend Gemini Explainer in AlertEngine
    }
  }

  void _showWarningOverlay(String number, String riskLevel, String reason) async {
     // Triggering the flutter_overlay_window natively
     if (await FlutterOverlayWindow.isPermissionGranted()) {
        FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Rakshak Scam Alert",
          overlayContent: "Suspicious Call: $number",
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.none,
        );
     }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
