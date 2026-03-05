import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

import '../services/db_service.dart';
import '../models/category.dart';
import '../theme/app_tokens.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final db = DBService();
  final _amountController = TextEditingController();
  final _noteController   = TextEditingController();
  final _formKey          = GlobalKey<FormState>();
  final _amountFocus      = FocusNode();

  String    _type         = 'expense';
  int?      _categoryId;
  DateTime  _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool      _isScanning   = false;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!['amount'].toString();
      _noteController.text   = widget.transaction!['note'] ?? '';
      _type                  = widget.transaction!['type'];
      _categoryId            = widget.transaction!['categoryId'];
      final dt               = DateTime.parse(widget.transaction!['date']);
      _selectedDate          = dt;
      _selectedTime          = TimeOfDay(hour: dt.hour, minute: dt.minute);
    }
    if (_categoryId == null && categoriesNotifier.value.isNotEmpty) {
      _categoryId = categoriesNotifier.value.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
    final heroColor = _type == 'expense' ? AppColors.error : AppColors.success;
    return AnimatedContainer(
      duration: AppDurations.normal,
      decoration: BoxDecoration(
        color: heroColor,
        borderRadius: const BorderRadius.vertical(
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
              const SizedBox(height: AppSpacing.lg),
              _buildTypePills(),
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
            isEditing ? 'Edit Transaction' : 'Add Transaction',
            textAlign: TextAlign.center,
            style: AppTypography.sectionTitle.copyWith(color: Colors.white),
          ),
        ),
        _isScanning
            ? const SizedBox(
                width: 48, height: 48,
                child: Center(
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2,
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.document_scanner_outlined,
                    color: Colors.white, size: 24),
                onPressed: _showScanOptions,
              ),
        if (isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.white70, size: 24),
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

  Widget _buildTypePills() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TypePill(
          label: 'Expense',
          icon: Icons.arrow_upward_rounded,
          isSelected: _type == 'expense',
          selectedColor: AppColors.error,
          onTap: () => setState(() => _type = 'expense'),
        ),
        const SizedBox(width: AppSpacing.md),
        _TypePill(
          label: 'Income',
          icon: Icons.arrow_downward_rounded,
          isSelected: _type == 'income',
          selectedColor: AppColors.success,
          onTap: () => setState(() => _type = 'income'),
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
      child: ValueListenableBuilder<List<Category>>(
        valueListenable: categoriesNotifier,
        builder: (context, categories, _) {
          if (_categoryId == null && categories.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _categoryId = categories.first.id);
            });
          }

          final selectedCategory = _categoryId != null && categories.isNotEmpty
              ? categories.firstWhere(
                  (c) => c.id == _categoryId,
                  orElse: () => categories.first,
                )
              : null;

          return Column(
            children: [
              _CardRow(
                icon: selectedCategory != null
                    ? Icon(selectedCategory.icon,
                        color: selectedCategory.color, size: 22)
                    : const Icon(Icons.category_outlined,
                        color: Colors.grey, size: 22),
                label: 'Category',
                value: selectedCategory?.name ?? 'Select Category',
                onTap: () => _showCategoryPicker(categories),
              ),

              const Divider(height: 1, indent: 56, endIndent: 16),

              _CardRow(
                icon: const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary, size: 22),
                label: 'Date & Time',
                value: DateFormat('MMM d, yyyy  hh:mm a').format(
                  DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day,
                    _selectedTime.hour, _selectedTime.minute,
                  ),
                ),
                onTap: _pickDateTime,
              ),

              const Divider(height: 1, indent: 56, endIndent: 16),

              // Note — borderless inline TextField
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: Icon(Icons.notes_outlined,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                        style: AppTypography.body,
                        decoration: const InputDecoration(
                          hintText: 'Add a note…',
                          border: InputBorder.none,
                          labelText: 'Note',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: AppTypography.caption,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a note';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
          onPressed: _saveTransaction,
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
          child: Text(isEditing ? 'Update Transaction' : 'Save Transaction'),
        ),
      ),
    ),
    );
  }

  // ── Category picker ────────────────────────────────────────────────────────

  Future<void> _showCategoryPicker(List<Category> categories) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
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
            Text('Select Category', style: AppTypography.sectionTitle.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: categories.map((cat) {
                  final isSelected = cat.id == _categoryId;
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: cat.color.withValues(alpha: 0.15),
                      child: Icon(cat.icon, color: cat.color, size: 18),
                    ),
                    title: Text(cat.name, style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () => Navigator.pop(context, cat.id),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _categoryId = selected);
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
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
      await db.delete('transactions', widget.transaction!['id']);
      if (mounted) Navigator.pop(context, true);
    }
  }

  // ── Date / time picker ─────────────────────────────────────────────────────

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime = pickedTime;
      });
    }
  }

  // ── Save transaction ───────────────────────────────────────────────────────

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final data = {
      'amount': amount,
      'type': _type,
      'categoryId': _categoryId,
      'date': DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute,
      ).toIso8601String(),
      'note': _noteController.text.trim(),
    };

    try {
      if (isEditing) {
        await db.update('transactions', widget.transaction!['id'], data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction updated successfully')),
          );
        }
      } else {
        await db.insert('transactions', data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction added successfully')),
          );
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')),
        );
      }
    }
  }

  // ── OCR: scan options sheet ────────────────────────────────────────────────

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      ),
      builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Scan Receipt',
                      style: AppTypography.sectionTitle.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primary),
                ),
                title: Text('Camera', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                subtitle: Text('Take a photo of your receipt', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                onTap: () {
                  Navigator.pop(context);
                  _scanReceipt(ImageSource.camera);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primary),
                ),
                title: Text('Gallery', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                subtitle: Text('Choose from your photo library', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                onTap: () {
                  Navigator.pop(context);
                  _scanReceipt(ImageSource.gallery);
                },
              ),
            ],
          ),
      ),
    );
  }

  // ── OCR: pick image + run recognition ─────────────────────────────────────

  Future<void> _scanReceipt(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Camera permission is required to scan receipts'),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isScanning = true);
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
      );
      if (pickedFile == null) return;

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final recognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final result = await recognizer.processImage(inputImage);
        _parseOcrResult(result.text);
      } finally {
        recognizer.close();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to scan receipt: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  // ── OCR: parse raw text → auto-fill ───────────────────────────────────────

  void _parseOcrResult(String rawText) {
    // Largest dollar amount → total
    final amountRegex = RegExp(
      r'\$?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+\.\d{1,2})',
    );
    double? largest;
    for (final m in amountRegex.allMatches(rawText)) {
      final value =
          double.tryParse(m.group(1)!.replaceAll(',', ''));
      if (value != null && (largest == null || value > largest)) {
        largest = value;
      }
    }

    // First non-numeric/symbolic line → merchant name
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    String? merchant;
    for (final line in lines) {
      if (RegExp(r'^[\d\s\$\.\,\-\/\:]+$').hasMatch(line)) continue;
      merchant = line.length > 50 ? line.substring(0, 50) : line;
      break;
    }

    setState(() {
      if (largest != null) {
        _amountController.text = largest.toStringAsFixed(2);
      }
      if (merchant != null) _noteController.text = merchant;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt scanned — please verify the details'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final String       label;
  final IconData     icon;
  final bool         isSelected;
  final Color        selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.hero),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white54,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16,
                color: isSelected ? selectedColor : Colors.white70),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final Widget       icon;
  final String       label;
  final String       value;
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
                  Text(label, style: AppTypography.caption.copyWith(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(value, style: AppTypography.body.copyWith(fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
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
