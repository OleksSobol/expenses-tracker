// lib/screens/add_bill_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../services/bill_service.dart';
import '../theme/app_tokens.dart';

class AddBillScreen extends StatefulWidget {
  final Bill? bill;

  const AddBillScreen({super.key, this.bill});

  @override
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final BillService _billService = BillService();

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late TextEditingController _linkController;
  late DateTime _nextDueDate;
  late String _frequency;

  final _amountFocus = FocusNode();

  bool get isEditing => widget.bill != null;

  static const _frequencies = ['daily', 'weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bill?.name ?? '');
    _amountController = TextEditingController(
      text: widget.bill?.amount.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.bill?.notes ?? '');
    _linkController = TextEditingController(text: widget.bill?.link ?? '');
    _nextDueDate = widget.bill?.nextDueDate ?? DateTime.now().add(const Duration(days: 30));
    _frequency = widget.bill?.frequency ?? 'monthly';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _linkController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeroSection(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
                ),
                child: _buildDetailCard(),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ── Hero section ───────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return AnimatedContainer(
      duration: AppDurations.normal,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.hero),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, AppSpacing.lg,
          ),
          child: Column(
            children: [
              _buildHeroTopRow(),
              const SizedBox(height: AppSpacing.lg),
              _buildHeroAmountField(),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroTopRow() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            isEditing ? 'Edit Bill' : 'Add Bill',
            textAlign: TextAlign.center,
            style: AppTypography.sectionTitle.copyWith(color: Colors.white),
          ),
        ),
        if (isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 24),
            onPressed: _confirmDelete,
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildHeroAmountField() {
    return Column(
      children: [
        Text(
          'USD',
          style: AppTypography.caption.copyWith(
            color: Colors.white70,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        IntrinsicWidth(
          child: TextFormField(
            controller: _amountController,
            focusNode: _amountFocus,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: -1,
              ),
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
              border: InputBorder.none,
              errorStyle: const TextStyle(color: Colors.white, fontSize: 12),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter an amount';
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) return 'Please enter a valid amount';
              return null;
            },
          ),
        ),
      ],
    );
  }

  // ── Detail card ────────────────────────────────────────────────────────────

  Widget _buildDetailCard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: [
          _CardRow(
            icon: const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 22),
            label: 'Bill Name',
            value: _nameController.text.isEmpty ? 'Enter bill name' : _nameController.text,
            onTap: _editBillName,
          ),

          const Divider(height: 1, indent: 56, endIndent: 16),

          _CardRow(
            icon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 22),
            label: 'Next Due Date',
            value: DateFormat('MMM d, yyyy').format(_nextDueDate),
            onTap: _selectDate,
          ),

          const Divider(height: 1, indent: 56, endIndent: 16),

          _CardRow(
            icon: const Icon(Icons.repeat_outlined, color: AppColors.primary, size: 22),
            label: 'Frequency',
            value: _frequency[0].toUpperCase() + _frequency.substring(1),
            onTap: _showFrequencyPicker,
          ),

          const Divider(height: 1, indent: 56, endIndent: 16),

          // Notes field
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Icon(Icons.notes_outlined, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                    style: AppTypography.body.copyWith(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Website, account number, or other info…',
                      border: InputBorder.none,
                      labelText: 'Notes (Optional)',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: AppTypography.caption.copyWith(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 56, endIndent: 16),

          // Link field
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Icon(Icons.link_outlined, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _linkController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    style: AppTypography.body.copyWith(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'https://example.com',
                      border: InputBorder.none,
                      labelText: 'Link (Optional)',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: AppTypography.caption.copyWith(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final regExp = RegExp(r'^https?:\/\/[^\s]+$');
                        if (!regExp.hasMatch(value.trim())) {
                          return 'Enter a valid URL starting with http:// or https://';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Save button ────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveBill,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              textStyle: AppTypography.sectionTitle,
            ),
            child: Text(isEditing ? 'Update Bill' : 'Add Bill'),
          ),
        ),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _editBillName() async {
    final controller = TextEditingController(text: _nameController.text);
    final result = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Bill Name',
                style: AppTypography.sectionTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g., Electric Bill',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => Navigator.pop(context, controller.text),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
    if (result != null) setState(() => _nameController.text = result);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _nextDueDate = picked);
  }

  Future<void> _showFrequencyPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Frequency',
                style: AppTypography.sectionTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.md),
            ..._frequencies.map((freq) {
              final isSelected = freq == _frequency;
              return ListTile(
                title: Text(
                  freq[0].toUpperCase() + freq.substring(1),
                  style: AppTypography.body.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, freq),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              );
            }),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _frequency = selected);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text('Are you sure you want to delete this bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _billService.deleteBill(widget.bill!.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a bill name')),
      );
      return;
    }

    final bill = Bill(
      id: isEditing ? widget.bill!.id : null,
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      nextDueDate: _nextDueDate,
      frequency: _frequency,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      link: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
    );

    try {
      if (isEditing) {
        await _billService.updateBill(widget.bill!.id!, bill);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bill updated successfully')),
          );
        }
      } else {
        await _billService.addBill(bill);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bill added successfully')),
          );
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving bill: $e')),
        );
      }
    }
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTypography.caption.copyWith(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
                  const SizedBox(height: 2),
                  Text(value,
                      style: AppTypography.body.copyWith(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
