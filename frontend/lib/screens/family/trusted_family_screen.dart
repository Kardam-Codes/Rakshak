import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../models/trusted_contact.dart';
import '../../providers/trusted_family_provider.dart';
import '../../providers/database_provider.dart';
import 'widgets/add_edit_contact_dialog.dart';
import 'widgets/privacy_consent_dialog.dart';

class TrustedFamilyScreen extends ConsumerWidget {
  const TrustedFamilyScreen({super.key});

  void _showAddContactDialog(BuildContext context, WidgetRef ref) {
    final repository = ref.read(trustedFamilyRepositoryProvider);

    showDialog(
      context: context,
      builder: (context) => AddEditContactDialog(
        onSave: (contact) async {
          try {
            await repository.addContact(contact);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added ${contact.name} to trusted network.')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
              );
            }
          }
        },
      ),
    );
  }

  void _showPrivacyNotice(BuildContext context, WidgetRef ref) {
    final repository = ref.read(trustedFamilyRepositoryProvider);
    showDialog(
      context: context,
      builder: (context) => PrivacyConsentDialog(
        onAccept: () async {
          await repository.setPrivacyConsent(true);
          Navigator.of(context).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trusted Family Mode enabled with full privacy protections.')),
            );
          }
        },
        onDecline: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(trustedContactsStreamProvider);
    final historyAsync = ref.watch(familyHistoryStreamProvider);
    final repository = ref.watch(trustedFamilyRepositoryProvider);

    final isEnabled = repository.isFeatureEnabled && repository.hasPrivacyConsent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Family Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            onPressed: () => _showPrivacyNotice(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          // 1. Protection Status Banner Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEnabled
                    ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
                    : [const Color(0xFFE65100), const Color(0xFFBF360C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  isEnabled ? Icons.family_restroom_rounded : Icons.shield_outlined,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  isEnabled ? 'Trusted Family Shield Active' : 'Shield Inactive (Consent Required)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  isEnabled
                      ? 'During high-risk scam events, emergency alerts will be dispatched to your trusted contacts after a 10s countdown.'
                      : 'Review privacy notice and enable consent to activate emergency family alerts.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isEnabled ? AppColors.success : AppColors.warning,
                  ),
                  onPressed: () => _showPrivacyNotice(context, ref),
                  icon: Icon(isEnabled ? Icons.settings : Icons.lock_outline),
                  label: Text(isEnabled ? 'Manage Consent & Privacy' : 'Enable Family Shield'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s24),

          // 2. Trusted Contacts Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trusted Contacts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                   minimumSize: Size.zero,
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () => _showAddContactDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Contact'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),

          contactsAsync.when(
            data: (contacts) {
              if (contacts.isEmpty) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.dividerLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s20),
                    child: Column(
                      children: [
                        const Icon(Icons.person_add_disabled_outlined, size: 40, color: AppColors.textSecondaryLight),
                        const SizedBox(height: 8),
                        const Text(
                          'No trusted contacts added yet.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add up to 5 family members or trusted contacts to receive emergency scam notifications.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showAddContactDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Contact'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: contacts.map((contact) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: contact.isPrimary
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.dividerLight,
                        child: Text(
                          contact.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: contact.isPrimary ? AppColors.primary : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                               contact.name, 
                               style: const TextStyle(fontWeight: FontWeight.bold),
                               overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.isPrimary) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: const Text('PRIMARY', style: TextStyle(fontSize: 10, color: Colors.white)),
                              backgroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text('${contact.relationship} • ${contact.phoneNumber}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) async {
                          if (val == 'primary' && contact.id != null) {
                            await repository.markPrimary(contact.id!);
                          } else if (val == 'edit') {
                            showDialog(
                              context: context,
                              builder: (context) => AddEditContactDialog(
                                contact: contact,
                                onSave: (updated) => repository.editContact(updated),
                              ),
                            );
                          } else if (val == 'delete' && contact.id != null) {
                            await repository.deleteContact(contact.id!);
                          }
                        },
                        itemBuilder: (context) => [
                          if (!contact.isPrimary)
                            const PopupMenuItem(value: 'primary', child: Text('Mark as Primary')),
                          const PopupMenuItem(value: 'edit', child: Text('Edit Contact')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete Contact', style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),

          const SizedBox(height: AppSpacing.s24),

          // 3. Notification History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alert Delivery History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(appDatabaseProvider).clearFamilyAlertHistory();
                },
                child: const Text('Clear All', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),

          historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.dividerLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.s16),
                    child: Text(
                      'No alert emails have been dispatched yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  ),
                );
              }

              return Column(
                children: history.take(5).map((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.deliveryStatus == 'sent'
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.danger.withOpacity(0.1),
                        child: Icon(
                          item.deliveryStatus == 'sent' ? Icons.mark_email_read : Icons.error_outline,
                          color: item.deliveryStatus == 'sent' ? AppColors.success : AppColors.danger,
                          size: 20,
                        ),
                      ),
                      title: Text('Alert sent to ${item.recipientName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${item.category} • ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(item.deliveryStatus.toUpperCase(), style: const TextStyle(fontSize: 10)),
                            backgroundColor: item.deliveryStatus == 'sent' ? AppColors.success.withOpacity(0.1) : AppColors.danger.withOpacity(0.1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                            onPressed: () => ref.read(appDatabaseProvider).deleteFamilyAlertHistory(item.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
