import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';

class StockItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final String unit;
  final String location;
  final DateTime lastUpdated;
  final String status;

  StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.unit,
    required this.location,
    required this.lastUpdated,
    required this.status,
  });
}

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  _StockManagementScreenState createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<StockItem> _allItems = [];
  List<StockItem> _filteredItems = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;

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
    _loadStockItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStockItems() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Demo data
    _allItems = [
      StockItem(
        id: 'GAS001',
        name: '13kg Gas Cylinder',
        category: 'Gas Cylinders',
        quantity: 150,
        price: 2500.0,
        unit: 'pieces',
        location: 'Main Warehouse',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'In Stock',
      ),
      StockItem(
        id: 'GAS002',
        name: '6kg Gas Cylinder',
        category: 'Gas Cylinders',
        quantity: 89,
        price: 1200.0,
        unit: 'pieces',
        location: 'Main Warehouse',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
        status: 'Low Stock',
      ),
      StockItem(
        id: 'ACC001',
        name: 'Gas Regulator',
        category: 'Accessories',
        quantity: 45,
        price: 800.0,
        unit: 'pieces',
        location: 'Main Warehouse',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        status: 'In Stock',
      ),
      StockItem(
        id: 'ACC002',
        name: 'Gas Hose',
        category: 'Accessories',
        quantity: 12,
        price: 350.0,
        unit: 'meters',
        location: 'Main Warehouse',
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Low Stock',
      ),
      StockItem(
        id: 'EQP001',
        name: 'Gas Detector',
        category: 'Equipment',
        quantity: 8,
        price: 15000.0,
        unit: 'pieces',
        location: 'Main Warehouse',
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        status: 'In Stock',
      ),
      StockItem(
        id: 'SPR001',
        name: 'Valve Assembly',
        category: 'Spare Parts',
        quantity: 25,
        price: 1200.0,
        unit: 'pieces',
        location: 'Main Warehouse',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
        status: 'In Stock',
      ),
      StockItem(
        id: 'GAS003',
        name: '50kg Gas Cylinder',
        category: 'Gas Cylinders',
        quantity: 0,
        price: 8500.0,
        unit: 'pieces',
        location: 'Main Warehouse',
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Out of Stock',
      ),
      StockItem(
        id: 'ACC003',
        name: 'Pressure Gauge',
        category: 'Accessories',
        quantity: 67,
        price: 450.0,
        unit: 'pieces',
        location: 'Main Warehouse',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        status: 'In Stock',
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
                  item.id.toLowerCase().contains(query) ||
                  item.category.toLowerCase().contains(query);
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Stock':
        return AppTheme.successColor;
      case 'Low Stock':
        return AppTheme.warningColor;
      case 'Out of Stock':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
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
          'STOCK MANAGEMENT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add Item feature coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
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
              : Column(
                children: [
                  // Header stats
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AppTheme.statItem(
                              'Total Items',
                              _allItems.length.toString(),
                              Icons.inventory_2,
                            ),
                            AppTheme.statItem(
                              'Categories',
                              (_categories.length - 1).toString(),
                              Icons.category,
                            ),
                            AppTheme.statItem(
                              'Low Stock',
                              _allItems
                                  .where((item) => item.status == 'Low Stock')
                                  .length
                                  .toString(),
                              Icons.warning,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Search and filter section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: AppTheme.inputDecoration(
                            label: 'Search items',
                            hintText: 'Search by name, ID, or category...',
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
                      ],
                    ),
                  ),

                  // Items list
                  Expanded(
                    child:
                        _filteredItems.isEmpty
                            ? AppTheme.emptyState(
                              icon: Icons.inventory_2_outlined,
                              title: 'No Items Found',
                              subtitle:
                                  _searchController.text.isEmpty
                                      ? 'No items available'
                                      : 'No items match your search',
                            )
                            : RefreshIndicator(
                              onRefresh: _loadStockItems,
                              color: AppTheme.primaryColor,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredItems[index];
                                  return _buildItemCard(item, index);
                                },
                              ),
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add Item feature coming soon!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('ADD ITEM'),
      ),
    );
  }

  Widget _buildItemCard(StockItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration.copyWith(
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to item details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Item details for ${item.name}'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID: ${item.id}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: _getStatusColor(item.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Category', item.category),
                    _buildInfoItem('Quantity', '${item.quantity} ${item.unit}'),
                    _buildInfoItem(
                      'Price',
                      'KES ${item.price.toStringAsFixed(0)}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Location', item.location),
                    _buildInfoItem('Updated', _formatDate(item.lastUpdated)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}
