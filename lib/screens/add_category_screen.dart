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
  
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;
  
  bool get isEditing => widget.category != null;

  // Available icons for categories
  final List<IconData> _availableIcons = [
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.home,
    Icons.car_rental,
    Icons.medical_services,
    Icons.school,
    Icons.fitness_center,
    Icons.movie,
    Icons.shopping_bag,
    Icons.phone,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.wifi,
    Icons.flight,
    Icons.hotel,
    Icons.coffee,
    Icons.fastfood,
    Icons.local_grocery_store,
    Icons.local_pharmacy,
    Icons.local_hospital,
    Icons.directions_bus,
    Icons.train,
    Icons.local_taxi,
    Icons.pets,
    Icons.child_care,
    Icons.sports_esports,
    Icons.music_note,
    Icons.book,
    Icons.brush,
    Icons.build,
    Icons.cleaning_services,
    Icons.computer,
    Icons.phone_android,
    Icons.headphones,
    Icons.camera_alt,
    Icons.account_balance,
    Icons.savings,
    Icons.credit_card,
    Icons.attach_money,
    Icons.money_off,
    Icons.trending_up,
    Icons.business,
    Icons.work,
    Icons.category,
  ];

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

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final category = Category(
      id: isEditing ? widget.category!.id : DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
    );

    if (isEditing) {
      // Update existing category in the global list
      final index = categories.indexWhere((c) => c.id == widget.category!.id);
      if (index != -1) {
        categories[index] = category;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated successfully')),
      );
    } else {
      // Add new category to the global list
      categories.add(category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category added successfully')),
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Category'),
                    content: Text('Are you sure you want to delete this category? This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  categories.removeWhere((c) => c.id == widget.category!.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Category deleted successfully')),
                  );
                  Navigator.pop(context, true);
                }
              },
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
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _selectedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            _selectedIcon,
                            color: _selectedColor,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
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
                                _nameController.text.isEmpty 
                                    ? 'Category Name' 
                                    : _nameController.text,
                                style: TextStyle(
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

                SizedBox(height: 24),

                // Category name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Groceries, Transportation',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    // Check for duplicate names (excluding current category when editing)
                    final existingCategory = categories.firstWhere(
                      (c) => c.name.toLowerCase() == value.trim().toLowerCase() && 
                             (!isEditing || c.id != widget.category!.id),
                      orElse: () => Category(id: -1, name: '', icon: Icons.category, color: Colors.blue),
                    );
                    if (existingCategory.id != -1) {
                      return 'A category with this name already exists';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {}); // Refresh preview
                  },
                ),

                SizedBox(height: 24),

                // Icon selection
                Text(
                  'Select Icon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIcon = icon;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? _selectedColor.withOpacity(0.2)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected 
                                  ? _selectedColor 
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? _selectedColor : Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 24),

                // Color selection
                Text(
                  'Select Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableColors.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
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
                        child: isSelected 
                            ? Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(
                    isEditing ? 'Update Category' : 'Add Category',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}