import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../models/scan_entity.dart';
import '../../providers/scan_provider.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/models/scam_category.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (mounted) {
        setState(() {
          _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }

  Future<void> _handleQrScan() async {
    final String? result = await context.push<String>('/scan/qr');
    if (result != null && result.isNotEmpty && mounted) {
      _executeScan(result, ScanType.qr);
    }
  }

  Future<void> _handleUrlInput() async {
    final TextEditingController urlController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan Website URL',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Paste or type the website link you want to check for phishing or malicious patterns.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.s16),
              TextField(
                controller: urlController,
                keyboardType: TextInputType.url,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Website URL',
                  hintText: 'https://example.com',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final text = urlController.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context);
                      _executeScan(text, ScanType.url);
                    }
                  },
                  icon: const Icon(Icons.shield_outlined),
                  label: const Text('Analyze URL Safety'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleImagePick(ScanType type) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Extracting text from image via ML Kit OCR...')),
      );

      final ocrService = ref.read(ocrServiceProvider);
      final extractedText = await ocrService.processImage(File(image.path));

      if (extractedText.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No readable text found in image. Scanning file reference.')),
        );
        _executeScan(image.name, type);
      } else {
        _executeScan(extractedText, type);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image processing error: ${e.toString()}')),
      );
    }
  }

  Future<void> _executeScan(String content, ScanType type) async {
    final controller = ref.read(scanControllerProvider.notifier);
    final result = await controller.executeScan(rawContent: content, scanType: type);
    if (result != null && mounted) {
      context.push('/scan/result', extra: result);
    }
  }

  void _showScanOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose what you want Rakshak to check.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 28),
                title: const Text('Scan QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Text('Scan QR codes instantly.'),
                onTap: () {
                  Navigator.pop(context);
                  _handleQrScan();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: AppColors.success, size: 28),
                title: const Text('Upload Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Text('Upload an image or screenshot.'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImagePick(ScanType.image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppColors.info, size: 28),
                title: const Text('Paste Website Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Text('Check website links or UPI links.'),
                onTap: () {
                  Navigator.pop(context);
                  _handleUrlInput();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanControllerProvider);
    final historyAsync = ref.watch(scanHistoryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Scan', semanticsLabel: 'Safe Scan Dashboard'),
        centerTitle: false,
      ),
      body: scanState.isScanning
          ? _buildLoadingState(scanState.statusMessage ?? 'Analyzing...')
          : RefreshIndicator(
              onRefresh: _checkConnectivity,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  // Offline / Online Status Indicator
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_isOnline),
                      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isOnline ? AppColors.success.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isOnline ? AppColors.success.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                            color: _isOnline ? AppColors.success : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isOnline 
                                ? 'Online Verification Enabled' 
                                : 'Protected using Rakshak Offline Security Engine.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isOnline ? AppColors.success : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hero Header Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.shield_rounded, size: 48, color: AppColors.primary),
                      const SizedBox(height: AppSpacing.s16),
                      const Text(
                        'Safe Scan',
                        style: TextStyle(
                          color: AppColors.textPrimaryLight,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      const Text(
                        'Check QR codes, links and images before interacting.',
                        style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s32),

                      // Large Primary Trigger Scan Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _showScanOptionsBottomSheet,
                          child: const Text(
                            'Scan Now',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.s32),

                // Recent Scans Section
                Text(
                  'Recent Scans',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.s8),
                historyAsync.when(
                  data: (scans) {
                    if (scans.isEmpty) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AppColors.dividerLight),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.s16),
                          child: Text(
                            'No recent scans yet. Use any method above to check safety.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondaryLight),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: scans.take(5).map((scan) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: scan.riskLevel == RiskLevel.safe
                                  ? AppColors.success.withOpacity(0.1)
                                  : scan.riskLevel == RiskLevel.medium
                                      ? AppColors.warning.withOpacity(0.1)
                                      : AppColors.danger.withOpacity(0.1),
                              child: Icon(
                                scan.riskLevel == RiskLevel.safe
                                    ? Icons.check
                                    : Icons.priority_high,
                                color: scan.riskLevel == RiskLevel.safe
                                    ? AppColors.success
                                    : scan.riskLevel == RiskLevel.medium
                                        ? AppColors.warning
                                        : AppColors.danger,
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    scan.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM d, h:mm a').format(scan.timestamp),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '${scan.scanType.displayName} • ${scan.evidence.isNotEmpty ? scan.evidence.first.reason : scan.offlineReason}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            trailing: Text(
                              scan.riskLevel.name.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: scan.riskLevel == RiskLevel.safe
                                    ? AppColors.success
                                    : scan.riskLevel == RiskLevel.medium
                                        ? AppColors.warning
                                        : AppColors.danger,
                              ),
                            ),
                            onTap: () => context.push('/scan/result', extra: scan),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error loading history: $err'),
                ),

                const SizedBox(height: AppSpacing.s24),

                // Safety Tips Section
                Card(
                  color: AppColors.info.withOpacity(0.08),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.info.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppColors.info),
                            SizedBox(width: 8),
                            Text(
                              'Safe Scanning Tips',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('• Never enter your UPI PIN when scanning a QR code to RECEIVE money.'),
                        Text('• Double check domain names for subtle misspellings like paytmm.com.'),
                        Text('• Rakshak analyzes content locally to ensure maximum privacy.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppSpacing.s16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s8),
          const Text(
            'Running local rule engine checks and AI explainability analysis...',
            style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

