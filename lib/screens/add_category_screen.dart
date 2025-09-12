// screens/add_category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import '../models/category.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';




class AddCategoryScreen extends StatefulWidget {
  final Category? category; // null for new category, Category object for editing

  const AddCategoryScreen({super.key, this.category});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  Icon? _icon;

  
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;
  
  bool get isEditing => widget.category != null;

  Future<void> _pickIcon() async {
    final IconPickerIcon? pickedIcon = await showIconPicker(
        context,
        configuration: SinglePickerConfiguration(
          iconPackModes: [IconPack.material],
        ),
    );

    if (pickedIcon != null) {
      setState(() {
      _selectedIcon = pickedIcon.data;
      });
    }
  }


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
                            color: _selectedColor.withValues(alpha: .1),
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
                ElevatedButton.icon(
                  onPressed: _pickIcon,
                  icon: Icon(_selectedIcon, color: _selectedColor),
                  label: Text('Pick Icon'),
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