// screens/add_category_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category; // null for new category, Category object for editing

  const AddCategoryScreen({super.key, this.category});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Selected icon (store IconData)
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;

  bool get isEditing => widget.category != null;

  // Available colors for categories
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Popular Material Icons for categories
  final List<IconData> _availableIcons = [
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.medical_services,
    Icons.school,
    Icons.fitness_center,
    Icons.home,
    Icons.directions_car,
    Icons.flight,
    Icons.movie,
    Icons.shopping_bag,
    Icons.coffee,
    Icons.pets,
    Icons.work,
    Icons.phone,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.local_grocery_store,
    Icons.local_pharmacy,
    Icons.local_hospital,
    Icons.local_taxi,
    Icons.train,
    Icons.directions_bus,
    Icons.hotel,
    Icons.restaurant_menu,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.fastfood,
    Icons.cake,
    Icons.local_pizza,
    Icons.icecream,
    Icons.sports_soccer,
    Icons.sports_basketball,
    Icons.sports_tennis,
    Icons.sports_golf,
    Icons.sports_baseball,
    Icons.pool,
    Icons.beach_access,
    Icons.park,
    Icons.forest,
    Icons.music_note,
    Icons.headphones,
    Icons.tv,
    Icons.videogame_asset,
    Icons.book,
    Icons.library_books,
    Icons.brush,
    Icons.palette,
    Icons.camera,
    Icons.photo_camera,
    Icons.volunteer_activism,
    Icons.favorite,
    Icons.star,
    Icons.celebration,
    Icons.card_giftcard,
    Icons.redeem,
    Icons.savings,
    Icons.account_balance,
    Icons.credit_card,
    Icons.payment,
    Icons.currency_exchange,
    Icons.attach_money,
    Icons.euro,
    Icons.category,
  ];

  Future<void> _pickIcon() async {
    final IconData? pickedIcon = await showDialog<IconData>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose an Icon',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  width: double.maxFinite,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(icon),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            size: 28,
                            color: _selectedColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (pickedIcon != null) {
      setState(() {
        _selectedIcon = pickedIcon;
      });
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final newCategory = Category(
      id: isEditing ? widget.category!.id : null,
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
    );

    try {
      if (isEditing) {
        await CategoryService.updateCategory(newCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      } else {
        await CategoryService.addCategory(newCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      // fallback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving category: $e')),
      );
    }
  }

  Future<void> _deleteCategory() async {
    if (!isEditing || widget.category!.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await CategoryService.deleteCategory(widget.category!.id!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted successfully')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // For duplicate-name check we read the notifier value directly
    final existingCategories = categoriesNotifier.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCategory,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preview card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _selectedColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            _selectedIcon,
                            color: _selectedColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preview',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _nameController.text.isEmpty ? 'Category Name' : _nameController.text,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Category name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Groceries, Transportation',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    final lower = value.trim().toLowerCase();
                    final existing = existingCategories.firstWhere(
                      (c) => c.name.toLowerCase() == lower && (!isEditing || c.id != widget.category!.id),
                      orElse: () => Category(id: null, name: '', icon: Icons.category, color: Colors.blue),
                    );
                    if (existing.id != null) {
                      return 'A category with this name already exists';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}), // refresh preview
                ),

                const SizedBox(height: 24),

                // Icon selection
                const Text(
                  'Select Icon',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickIcon,
                  icon: Icon(_selectedIcon, color: _selectedColor),
                  label: const Text('Pick Icon'),
                ),

                const SizedBox(height: 24),

                // Color selection
                const Text(
                  'Select Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableColors.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey.shade400,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(isEditing ? 'Update Category' : 'Add Category', style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
