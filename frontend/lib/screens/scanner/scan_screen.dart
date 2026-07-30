import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanControllerProvider);
    final historyAsync = ref.watch(scanHistoryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Scan'),
        centerTitle: false,
      ),
      body: scanState.isScanning
          ? _buildLoadingState(scanState.statusMessage ?? 'Analyzing...')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.s16),
              children: [
                // Hero Header Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.shield_rounded, size: 48, color: Colors.white),
                      const SizedBox(height: AppSpacing.s8),
                      const Text(
                        'Unified Security Scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      const Text(
                        'Scan QR codes, links, images, or screenshots before interacting to protect your money.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s16),

                      // Large Primary Trigger Scan Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _handleQrScan,
                        icon: const Icon(Icons.qr_code_scanner, size: 24),
                        label: const Text(
                          'Scan QR Code Now',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.s24),

                // Four Scan Methods Grid
                Text(
                  'Four Scan Methods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.s12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _ScanMethodCard(
                      icon: Icons.qr_code_2_rounded,
                      title: 'QR Code',
                      subtitle: 'Camera scan',
                      color: AppColors.primary,
                      onTap: _handleQrScan,
                    ),
                    _ScanMethodCard(
                      icon: Icons.link_rounded,
                      title: 'Website URL',
                      subtitle: 'Check link safety',
                      color: AppColors.info,
                      onTap: _handleUrlInput,
                    ),
                    _ScanMethodCard(
                      icon: Icons.image_outlined,
                      title: 'Gallery Image',
                      subtitle: 'OCR Text Scan',
                      color: AppColors.success,
                      onTap: () => _handleImagePick(ScanType.image),
                    ),
                    _ScanMethodCard(
                      icon: Icons.screenshot_outlined,
                      title: 'Screenshot',
                      subtitle: 'Scan receipt or SMS',
                      color: AppColors.warning,
                      onTap: () => _handleImagePick(ScanType.screenshot),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.s24),

                // Recent Scans Section
                Text(
                  'Recent Scans',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                            title: Text(
                              scan.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('${scan.scanType.displayName} • ${scan.category.displayName}'),
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

class _ScanMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ScanMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
