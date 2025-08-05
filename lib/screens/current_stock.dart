import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockItem {
  final String id;
  final String name;
  int quantity;

  StockItem({required this.id, required this.name, this.quantity = 0});
}

class CurrentStockScreen extends StatefulWidget {
  final String salespersonName;
  final String salespersonCode;

  const CurrentStockScreen({
    super.key,
    required this.salespersonName,
    required this.salespersonCode,
  });

  @override
  _CurrentStockScreenState createState() => _CurrentStockScreenState();
}

class _CurrentStockScreenState extends State<CurrentStockScreen> {
  List<StockItem> _stockItems = [];
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock data - in real app this would come from API
    _stockItems = [
      StockItem(id: '4103', name: 'POWER REFIL 13KG'),
      StockItem(id: '4104', name: 'lantern'),
      StockItem(id: '4105', name: 'GLASS TOP 2 BURNER'),
      StockItem(id: '4106', name: 'mantle'),
      StockItem(id: '4107', name: '#A1 burners'),
      StockItem(id: '4108', name: 'black grill'),
      StockItem(id: '4109', name: 'high pressure regulator'),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  void _updateQuantity(int index, String value) {
    final quantity = int.tryParse(value) ?? 0;
    setState(() {
      _stockItems[index].quantity = quantity;
      _hasChanges = true;
    });
  }

  Future<void> _submitStock() async {
    // Validate that all quantities are entered
    final emptyItems = _stockItems.where((item) => item.quantity == 0).toList();

    if (emptyItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter quantities for all items (${emptyItems.length} remaining)',
          ),
          backgroundColor: AppTheme.warningColor,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _hasChanges = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Stock updated successfully for ${widget.salespersonName}',
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back after success
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
                  // Header section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.successColor,
                          AppTheme.successColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                    child: Column(
                      children: [
                        // Back button and title row
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CURRENT STOCK',
                                    style: AppTheme.headingLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    height: 2,
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(top: 4),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${widget.salespersonName} (${widget.salespersonCode})',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AppTheme.statItem(
                              'Items',
                              _stockItems.length.toString(),
                              Icons.inventory,
                            ),
                            AppTheme.statItem(
                              'Total Qty',
                              _stockItems
                                  .fold(0, (sum, item) => sum + item.quantity)
                                  .toString(),
                              Icons.shopping_cart,
                            ),
                            AppTheme.statItem(
                              'Updated',
                              _hasChanges ? 'Yes' : 'No',
                              Icons.update,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stock items list
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: AppTheme.cardDecoration,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _stockItems.length,
                        itemBuilder: (context, index) {
                          final item = _stockItems[index];
                          return _buildStockItemRow(item, index);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitStock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'SUBMIT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
    );
  }

  Widget _buildStockItemRow(StockItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          // Item ID
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.id,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 16),

          // Item name
          Expanded(
            child: Text(
              item.name,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 16),

          // Quantity input field
          Container(
            width: 80,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!, width: 1),
            ),
            child: TextField(
              controller: TextEditingController(
                text: item.quantity > 0 ? item.quantity.toString() : '',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Qty',
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => _updateQuantity(index, value),
            ),
          ),
        ],
      ),
    );
  }
}
