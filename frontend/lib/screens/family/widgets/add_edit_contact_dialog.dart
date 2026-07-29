import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../models/trusted_contact.dart';

class AddEditContactDialog extends StatefulWidget {
  final TrustedContact? contact;
  final Function(TrustedContact) onSave;

  const AddEditContactDialog({
    super.key,
    this.contact,
    required this.onSave,
  });

  @override
  State<AddEditContactDialog> createState() => _AddEditContactDialogState();
}

class _AddEditContactDialogState extends State<AddEditContactDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _relationship;
  late NotificationMethod _notificationMethod;
  late bool _isPrimary;

  final List<String> _relationships = [
    'Son',
    'Daughter',
    'Spouse',
    'Sibling',
    'Parent',
    'Friend',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _relationship = widget.contact?.relationship ?? 'Son';
    _notificationMethod = widget.contact?.preferredNotificationMethod ?? NotificationMethod.email;
    _isPrimary = widget.contact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updated = TrustedContact(
        id: widget.contact?.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        relationship: _relationship,
        preferredNotificationMethod: _notificationMethod,
        isPrimary: _isPrimary,
        isEmergency: true,
      );
      widget.onSave(updated);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(isEditing ? Icons.edit_outlined : Icons.person_add_outlined, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(isEditing ? 'Edit Trusted Contact' : 'Add Trusted Contact'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: AppSpacing.s12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter phone number';
                  if (val.replaceAll(RegExp(r'\D'), '').length < 10) return 'Enter valid 10-digit phone number';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter email address';
                  if (!val.contains('@') || !val.contains('.')) return 'Enter valid email address';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship *',
                  prefixIcon: Icon(Icons.family_restroom),
                  border: OutlineInputBorder(),
                ),
                items: _relationships
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _relationship = val);
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              DropdownButtonFormField<NotificationMethod>(
                value: _notificationMethod,
                decoration: const InputDecoration(
                  labelText: 'Preferred Method',
                  prefixIcon: Icon(Icons.notifications_active_outlined),
                  border: OutlineInputBorder(),
                ),
                items: NotificationMethod.values
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.displayName),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _notificationMethod = val);
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark as Primary Contact'),
                subtitle: const Text('Primary contact receives highest priority alert emails'),
                value: _isPrimary,
                onChanged: (val) => setState(() => _isPrimary = val ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _submit,
          child: Text(isEditing ? 'Save Changes' : 'Add Contact'),
        ),
      ],
    );
  }
}
