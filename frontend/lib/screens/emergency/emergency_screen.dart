import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/recovery_action_card.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/trusted_family_provider.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  final String? suspiciousMessage;
  
  const EmergencyScreen({super.key, this.suspiciousMessage});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleNotifyTrustedContact() async {
    final repository = ref.read(trustedFamilyRepositoryProvider);
    final recoveryService = ref.read(recoveryServiceProvider);
    final msg = widget.suspiciousMessage ?? "Suspicious activity detected on my account.";

    final contacts = await repository.getAllContacts();

    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a contact in Trusted Family settings first.')),
        );
      }
      return;
    }

    if (contacts.length == 1) {
      await recoveryService.notifyTrustedContact(contacts.first.phoneNumber, msg);
      return;
    }

    if (mounted) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Trusted Contact',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Icon(Icons.person, color: Colors.green[800]),
                        ),
                        title: Text(contact.name),
                        subtitle: Text('${contact.relationship} • ${contact.phoneNumber}'),
                        onTap: () async {
                          Navigator.pop(context);
                          await recoveryService.notifyTrustedContact(contact.phoneNumber, msg);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _showInstructionsDialog(String title, String instructions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(instructions),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recoveryService = ref.read(recoveryServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Recovery'),
        backgroundColor: Colors.red[50],
        foregroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Immediate Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            RecoveryActionCard(
              icon: Icons.account_balance,
              iconColor: Colors.blue[700],
              title: 'Contact Bank',
              subtitle: 'Dial RBI Helpline (14440) to report unauthorized transactions.',
              buttonText: 'Dial Now',
              onPressed: () => recoveryService.contactBank(),
            ),
            RecoveryActionCard(
              icon: Icons.security,
              iconColor: Colors.red[700],
              title: 'Report Cyber Crime',
              subtitle: 'File a complaint on the official government portal (cybercrime.gov.in).',
              buttonText: 'Report',
              onPressed: () => recoveryService.reportCyberCrime(),
            ),
            RecoveryActionCard(
              icon: Icons.block,
              iconColor: Colors.orange[700],
              title: 'Block Number',
              subtitle: 'Manually block the suspicious contact from your phone dialer.',
              buttonText: 'Show Instructions',
              onPressed: () {
                _showInstructionsDialog(
                  'How to Block a Number',
                  '1. Open your phone app (dialer).\n2. Go to your recent calls or contacts.\n3. Tap on the suspicious number.\n4. Select "Block" or "Report spam".',
                );
              },
            ),
            RecoveryActionCard(
              icon: Icons.people,
              iconColor: Colors.green[700],
              title: 'Notify Trusted Contact',
              subtitle: 'Send an alert message to a trusted family member or friend.',
              buttonText: 'Send Alert',
              onPressed: _handleNotifyTrustedContact,
            ),
            RecoveryActionCard(
              icon: Icons.save,
              iconColor: Colors.purple[700],
              title: 'Save Evidence',
              subtitle: 'Securely save the details of this incident locally for future reference.',
              buttonText: 'Save',
              onPressed: () async {
                final success = await recoveryService.saveEvidence(
                  widget.suspiciousMessage ?? 'General suspicious activity',
                  'Emergency Screen Action',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Evidence saved successfully.' : 'Failed to save evidence.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
