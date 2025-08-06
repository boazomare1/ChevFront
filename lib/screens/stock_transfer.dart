import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';

class TransferItem {
  final String id;
  final String name;
  final String category;
  final int availableQuantity;
  final String unit;
  final String currentLocation;

  TransferItem({
    required this.id,
    required this.name,
    required this.category,
    required this.availableQuantity,
    required this.unit,
    required this.currentLocation,
  });
}

class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({super.key});

  @override
  _StockTransferScreenState createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  List<TransferItem> _allItems = [];
  List<TransferItem> _filteredItems = [];
  TransferItem? _selectedItem;
  String _selectedFromLocation = 'Main Warehouse';
  String _selectedToLocation = 'Branch A';
  String _selectedCategory = 'All';
  bool _isLoading = false;

  final List<String> _locations = [
    'Main Warehouse',
    'Branch A',
    'Branch B',
    'Branch C',
    'Distribution Center',
    'Mobile Unit 1',
    'Mobile Unit 2',
  ];

  final List<String> _categories = [
    'All',
    'Gas Cylinders',
    'Accessories',
    'Equipment',
    'Spare Parts',
  ];

  @override
  void initState() {
    super.initState();
    _loadTransferItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTransferItems() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Demo data
    _allItems = [
      TransferItem(
        id: 'GAS001',
        name: '13kg Gas Cylinder',
        category: 'Gas Cylinders',
        availableQuantity: 150,
        unit: 'pieces',
        currentLocation: 'Main Warehouse',
      ),
      TransferItem(
        id: 'GAS002',
        name: '6kg Gas Cylinder',
        category: 'Gas Cylinders',
        availableQuantity: 89,
        unit: 'pieces',
        currentLocation: 'Main Warehouse',
      ),
      TransferItem(
        id: 'ACC001',
        name: 'Gas Regulator',
        category: 'Accessories',
        availableQuantity: 45,
        unit: 'pieces',
        currentLocation: 'Main Warehouse',
      ),
      TransferItem(
        id: 'ACC002',
        name: 'Gas Hose',
        category: 'Accessories',
        availableQuantity: 12,
        unit: 'meters',
        currentLocation: 'Main Warehouse',
      ),
      TransferItem(
        id: 'EQP001',
        name: 'Gas Detector',
        category: 'Equipment',
        availableQuantity: 8,
        unit: 'pieces',
        currentLocation: 'Main Warehouse',
      ),
      TransferItem(
        id: 'SPR001',
        name: 'Valve Assembly',
        category: 'Spare Parts',
        availableQuantity: 25,
        unit: 'pieces',
        currentLocation: 'Main Warehouse',
      ),
    ];

    _filteredItems = List.from(_allItems);

    setState(() {
      _isLoading = false;
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty && _selectedCategory == 'All') {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems =
            _allItems.where((item) {
              final matchesSearch =
                  item.name.toLowerCase().contains(query) ||
                  item.id.toLowerCase().contains(query);
              final matchesCategory =
                  _selectedCategory == 'All' ||
                  item.category == _selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();
      }
    });
  }

  void _onCategoryChanged(String? category) {
    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
      _filterItems();
    }
  }

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an item to transfer'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedFromLocation == _selectedToLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Source and destination locations must be different'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
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
          content: Text(
            'Transfer initiated successfully! ${_quantityController.text} ${_selectedItem!.unit} of ${_selectedItem!.name} will be transferred from $_selectedFromLocation to $_selectedToLocation',
          ),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 4),
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
      setState(() {
        _selectedItem = null;
        _selectedFromLocation = 'Main Warehouse';
        _selectedToLocation = 'Branch A';
      });
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
          'STOCK TRANSFER',
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
                              Icons.transfer_within_a_station,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Transfer Stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Move inventory between locations',
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
                            _buildItemSelectionSection(),
                            const SizedBox(height: 20),
                            _buildTransferDetailsSection(),
                            const SizedBox(height: 20),
                            _buildNotesSection(),
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

  Widget _buildItemSelectionSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('SELECT ITEM', Icons.inventory_2),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: AppTheme.inputDecoration(
              label: 'Search items',
              hintText: 'Search by name or ID...',
              prefixIcon: Icons.search,
            ),
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
            onChanged: _onCategoryChanged,
          ),
          const SizedBox(height: 16),
          Text(
            'Available Items',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.textLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                _filteredItems.isEmpty
                    ? Center(
                      child: Text(
                        'No items available',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = _selectedItem?.id == item.id;
                        return _buildItemOption(item, isSelected);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemOption(TransferItem item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          item.name,
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'ID: ${item.id} • ${item.availableQuantity} ${item.unit} available',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24,
                )
                : null,
        onTap: () {
          setState(() {
            _selectedItem = item;
            _selectedFromLocation = item.currentLocation;
          });
        },
      ),
    );
  }

  Widget _buildTransferDetailsSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'TRANSFER DETAILS',
            Icons.transfer_within_a_station,
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedFromLocation,
                decoration: AppTheme.inputDecoration(
                  label: 'From Location',
                  prefixIcon: Icons.location_on_outlined,
                ),
                items:
                    _locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFromLocation = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedToLocation,
                decoration: AppTheme.inputDecoration(
                  label: 'To Location',
                  prefixIcon: Icons.location_on,
                ),
                items:
                    _locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedToLocation = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            decoration: AppTheme.inputDecoration(
              label: 'Transfer Quantity',
              hintText:
                  _selectedItem != null
                      ? 'Max: ${_selectedItem!.availableQuantity} ${_selectedItem!.unit}'
                      : 'Enter quantity',
              prefixIcon: Icons.numbers,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter quantity';
              }
              final quantity = int.tryParse(value);
              if (quantity == null || quantity <= 0) {
                return 'Please enter a valid quantity';
              }
              if (_selectedItem != null &&
                  quantity > _selectedItem!.availableQuantity) {
                return 'Quantity exceeds available stock';
              }
              return null;
            },
          ),
          if (_selectedItem != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Available: ${_selectedItem!.availableQuantity} ${_selectedItem!.unit} at ${_selectedItem!.currentLocation}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.infoColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('NOTES', Icons.note),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: AppTheme.inputDecoration(
              label: 'Transfer Notes',
              hintText: 'Add any notes about this transfer (optional)',
              prefixIcon: Icons.edit_note,
            ),
            maxLines: 3,
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
        onPressed: _submitTransfer,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          'INITIATE TRANSFER',
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
