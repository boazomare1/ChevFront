import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
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
  final currencyFormatter = NumberFormat.currency(locale: 'en_KE', symbol: 'KSh ');
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
      _itemsFuture =
          Provider.of<AppState>(context, listen: false).listItems(widget.routeId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Item> _filterAndSortItems(List<Item> items) {
    var filteredItems = items.where((item) {
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

    var excel = Excel.createExcel();
    var sheet = excel['Stock'];

    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Name'),
      TextCellValue('Code'),
      TextCellValue('Quantity'),
      TextCellValue('Price'),
    ]);

    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      sheet.appendRow([
        TextCellValue((i + 1).toString()),
        TextCellValue(item.itemName ?? ''),
        TextCellValue(item.itemCode ?? ''),
        TextCellValue(item.quantity?.toStringAsFixed(2) ?? '0.00'),
        TextCellValue(currencyFormatter.format(item.sellingPrice)),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final fileName = 'Warehouse_Stock_${DateTime.now().toIso8601String()}.xlsx';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles([XFile(filePath)], text: 'Warehouse Stock Export');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excel file exported and ready to share')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const padding = 16.0 * 2;
    final availableWidth = screenWidth - padding;
    const columnWidths = {
      0: 0.10, // No: 10%
      1: 0.30, // Name: 30%
      2: 0.25, // Code: 25%
      3: 0.15, // Qty: 15%
      4: 0.20, // Price: 20%
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Stock'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshItems,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to Excel',
            onPressed: () async {
              final snapshot = await _itemsFuture;
              await _exportToExcel(_filterAndSortItems(snapshot ?? []));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or code...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Item>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _refreshItems,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final items = _filterAndSortItems(snapshot.data ?? []);

                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items available.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: availableWidth),
                    child: DataTable(
                      columnSpacing: 4.0,
                      dataRowHeight: 44.0,
                      headingRowHeight: 52.0,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * columnWidths[0]!,
                            child: const Text(
                              'No',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * columnWidths[1]!,
                            child: const Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * columnWidths[2]!,
                            child: const Text(
                              'Code',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * columnWidths[3]!,
                            child: const Text(
                              'Qty',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: availableWidth * columnWidths[4]!,
                            child: const Text(
                              'Price',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                      ],
                      rows: List.generate(items.length, (index) {
                        final item = items[index];
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: availableWidth * columnWidths[0]!,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: availableWidth * columnWidths[1]!,
                                child: Text(
                                  item.itemName ?? '',
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: availableWidth * columnWidths[2]!,
                                child: Text(
                                  item.itemCode ?? '',
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: availableWidth * columnWidths[3]!,
                                child: Text(
                                  item.quantity!.toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: availableWidth * columnWidths[4]!,
                                child: Text(
                                  currencyFormatter.format(item.sellingPrice),
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new item feature coming soon!')),
          );
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}