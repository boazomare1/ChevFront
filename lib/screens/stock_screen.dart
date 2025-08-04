import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class StockScreen extends StatefulWidget {
  final String routeId;

  const StockScreen({super.key, required this.routeId});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  late Future<List<Item>> _itemsFuture;
  final currencyFormatter = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'KSh ',
  );
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _refreshItems();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _refreshItems() {
    setState(() {
      _itemsFuture = Provider.of<AppState>(
        context,
        listen: false,
      ).listItems(widget.routeId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Item> _filterAndSortItems(List<Item> items) {
    var filteredItems =
        items.where((item) {
          final name = item.itemName?.toLowerCase() ?? '';
          final code = item.itemCode?.toLowerCase() ?? '';
          return name.contains(_searchQuery) || code.contains(_searchQuery);
        }).toList();

    if (_sortColumnIndex != null) {
      filteredItems.sort((a, b) {
        int cmp;
        switch (_sortColumnIndex) {
          case 1: // Name
            cmp = (a.itemName ?? '').compareTo(b.itemName ?? '');
            break;
          case 2: // Code
            cmp = (a.itemCode ?? '').compareTo(b.itemCode ?? '');
            break;
          case 3: // Quantity
            cmp = (a.quantity ?? 0).compareTo(b.quantity ?? 0);
            break;
          case 4: // Price
            cmp = (a.sellingPrice ?? 0).compareTo(b.sellingPrice ?? 0);
            break;
          default:
            cmp = 0;
        }
        return _sortAscending ? cmp : -cmp;
      });
    }
    return filteredItems;
  }

  Future<void> _exportToExcel(List<Item> items) async {
    var status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    var excelDoc = excel.Excel.createExcel();
    var sheet = excelDoc['Stock'];

    sheet.appendRow([
      excel.TextCellValue('No'),
      excel.TextCellValue('Name'),
      excel.TextCellValue('Code'),
      excel.TextCellValue('Quantity'),
      excel.TextCellValue('Price'),
    ]);

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      sheet.appendRow([
        excel.TextCellValue((i + 1).toString()),
        excel.TextCellValue(item.itemName ?? ''),
        excel.TextCellValue(item.itemCode ?? ''),
        excel.TextCellValue((item.quantity ?? 0).toString()),
        excel.TextCellValue(currencyFormatter.format(item.sellingPrice ?? 0)),
      ]);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/stock_${widget.routeId}.xlsx');
    await file.writeAsBytes(excelDoc.encode()!);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Stock Report for Route ${widget.routeId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTheme.appBarStyle(
        title: 'STOCK INVENTORY',
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              final items = await _itemsFuture;
              await _exportToExcel(items);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return AppTheme.emptyState(
              icon: Icons.error_outline,
              title: 'Error Loading Stock',
              subtitle: 'Failed to load stock data: ${snapshot.error}',
            );
          }

          final items = snapshot.data ?? [];
          final filteredItems = _filterAndSortItems(items);

          if (items.isEmpty) {
            return AppTheme.emptyState(
              icon: Icons.inventory_2,
              title: 'No Stock Available',
              subtitle: 'No items found for this route',
            );
          }

          return Column(
            children: [
              // Header section with stats
              AppTheme.headerSection(
                title: 'ROUTE ${widget.routeId}',
                subtitle: '${items.length} items in stock',
                stats: [
                  AppTheme.statItem(
                    'Total Items',
                    items.length.toString(),
                    Icons.inventory,
                  ),
                  AppTheme.statItem(
                    'Available',
                    items
                        .where((item) => (item.quantity ?? 0) > 0)
                        .length
                        .toString(),
                    Icons.check_circle,
                  ),
                  AppTheme.statItem(
                    'Out of Stock',
                    items
                        .where((item) => (item.quantity ?? 0) <= 0)
                        .length
                        .toString(),
                    Icons.warning,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: AppTheme.cardDecoration,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search items...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stock list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildStockCard(item, index + 1);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStockCard(Item item, int index) {
    final quantity = item.quantity ?? 0;
    final isOutOfStock = quantity <= 0;
    final isLowStock = quantity <= 10 && quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Item number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isOutOfStock
                        ? AppTheme.errorColor.withOpacity(0.1)
                        : isLowStock
                        ? AppTheme.warningColor.withOpacity(0.1)
                        : AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  index.toString(),
                  style: TextStyle(
                    color:
                        isOutOfStock
                            ? AppTheme.errorColor
                            : isLowStock
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName ?? 'Unknown Item',
                    style: AppTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Code: ${item.itemCode ?? 'N/A'}',
                    style: AppTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Qty: ${quantity}',
                        style: AppTheme.bodyMedium.copyWith(
                          color:
                              isOutOfStock
                                  ? AppTheme.errorColor
                                  : isLowStock
                                  ? AppTheme.warningColor
                                  : AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        currencyFormatter.format(item.sellingPrice ?? 0),
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isOutOfStock
                        ? AppTheme.errorColor.withOpacity(0.1)
                        : isLowStock
                        ? AppTheme.warningColor.withOpacity(0.1)
                        : AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isOutOfStock
                          ? AppTheme.errorColor
                          : isLowStock
                          ? AppTheme.warningColor
                          : AppTheme.successColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOutOfStock
                        ? Icons.cancel
                        : isLowStock
                        ? Icons.warning
                        : Icons.check_circle,
                    color:
                        isOutOfStock
                            ? AppTheme.errorColor
                            : isLowStock
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOutOfStock
                        ? 'OUT'
                        : isLowStock
                        ? 'LOW'
                        : 'OK',
                    style: TextStyle(
                      color:
                          isOutOfStock
                              ? AppTheme.errorColor
                              : isLowStock
                              ? AppTheme.warningColor
                              : AppTheme.successColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
