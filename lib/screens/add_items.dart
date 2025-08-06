import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';

class AddItemsScreen extends StatefulWidget {
  const AddItemsScreen({super.key});

  @override
  _AddItemsScreenState createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = 'Gas Cylinders';
  String _selectedUnit = 'pieces';
  String _selectedSupplier = 'Chevron Kenya';
  bool _isLoading = false;

  final List<String> _categories = [
    'Gas Cylinders',
    'Accessories',
    'Equipment',
    'Spare Parts',
    'Tools',
    'Safety Equipment',
  ];

  final List<String> _units = [
    'pieces',
    'kg',
    'liters',
    'meters',
    'boxes',
    'pairs',
  ];

  final List<String> _suppliers = [
    'Chevron Kenya',
    'Total Energies',
    'Shell Kenya',
    'Kenol Kobil',
    'Vivo Energy',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _generateItemId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _generateItemId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000).toString().padLeft(3, '0');
    final category = _selectedCategory.substring(0, 3).toUpperCase();
    _idController.text = '$category$random';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item added successfully!'),
          backgroundColor: AppTheme.successColor,
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );

      // Reset form
      _formKey.currentState!.reset();
      _generateItemId();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'ADD NEW ITEM',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.add_box,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Add New Inventory Item',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fill in the details below to add a new item',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Form section
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildBasicInfoSection(),
                            const SizedBox(height: 20),
                            _buildPricingSection(),
                            const SizedBox(height: 20),
                            _buildLocationSection(),
                            const SizedBox(height: 20),
                            _buildAdditionalInfoSection(),
                            const SizedBox(height: 30),
                            _buildSubmitButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('BASIC INFORMATION', Icons.info),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: AppTheme.inputDecoration(
              label: 'Item Name',
              hintText: 'Enter item name (e.g., 13kg Gas Cylinder)',
              prefixIcon: Icons.inventory_2,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter item name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _idController,
            decoration: AppTheme.inputDecoration(
              label: 'Item ID',
              hintText: 'Auto-generated ID',
              prefixIcon: Icons.qr_code,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: AppTheme.inputDecoration(
              label: 'Category',
              prefixIcon: Icons.category,
            ),
            items:
                _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
                _generateItemId();
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: AppTheme.inputDecoration(
              label: 'Description',
              hintText: 'Enter item description (optional)',
              prefixIcon: Icons.description,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PRICING & QUANTITY', Icons.attach_money),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: AppTheme.inputDecoration(
                    label: 'Unit Price',
                    hintText: '0.00',
                    prefixIcon: Icons.attach_money,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  decoration: AppTheme.inputDecoration(
                    label: 'Initial Quantity',
                    hintText: '0',
                    prefixIcon: Icons.numbers,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: AppTheme.inputDecoration(
                    label: 'Unit',
                    prefixIcon: Icons.straighten,
                  ),
                  items:
                      _units.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSupplier,
                  decoration: AppTheme.inputDecoration(
                    label: 'Supplier',
                    prefixIcon: Icons.business,
                  ),
                  items:
                      _suppliers.map((supplier) {
                        return DropdownMenuItem(
                          value: supplier,
                          child: Text(supplier),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSupplier = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('LOCATION', Icons.location_on),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: AppTheme.inputDecoration(
              label: 'Storage Location',
              hintText: 'Enter storage location (e.g., Main Warehouse)',
              prefixIcon: Icons.warehouse,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter storage location';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ADDITIONAL INFORMATION', Icons.more_horiz),
          const SizedBox(height: 16),
          _buildInfoRow('Minimum Stock Level', '10'),
          _buildInfoRow('Reorder Point', '5'),
          _buildInfoRow('Lead Time', '3-5 days'),
          _buildInfoRow('Shelf Life', 'N/A'),
          _buildInfoRow('Hazardous', 'No'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.headingSmall.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          'ADD ITEM',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
