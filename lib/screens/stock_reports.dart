import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';

class StockReport {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  StockReport({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}

class StockReportsScreen extends StatefulWidget {
  const StockReportsScreen({super.key});

  @override
  _StockReportsScreenState createState() => _StockReportsScreenState();
}

class _StockReportsScreenState extends State<StockReportsScreen> {
  String _selectedPeriod = 'This Month';
  bool _isLoading = false;

  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
    });
  }

  List<StockReport> _getReports() {
    return [
      StockReport(
        title: 'Total Stock Value',
        value: 'KES 2,450,000',
        change: '+12.5%',
        isPositive: true,
        icon: Icons.attach_money,
        color: AppTheme.successColor,
      ),
      StockReport(
        title: 'Items in Stock',
        value: '1,247',
        change: '+8.2%',
        isPositive: true,
        icon: Icons.inventory_2,
        color: AppTheme.primaryColor,
      ),
      StockReport(
        title: 'Low Stock Items',
        value: '23',
        change: '-5.1%',
        isPositive: true,
        icon: Icons.warning,
        color: AppTheme.warningColor,
      ),
      StockReport(
        title: 'Out of Stock',
        value: '7',
        change: '+2.3%',
        isPositive: false,
        icon: Icons.error,
        color: AppTheme.errorColor,
      ),
      StockReport(
        title: 'Stock Turnover',
        value: '4.2x',
        change: '+15.7%',
        isPositive: true,
        icon: Icons.trending_up,
        color: AppTheme.infoColor,
      ),
      StockReport(
        title: 'Average Stock Age',
        value: '45 days',
        change: '-8.9%',
        isPositive: true,
        icon: Icons.schedule,
        color: AppTheme.secondaryColor,
      ),
    ];
  }

  List<Map<String, dynamic>> _getTopItems() {
    return [
      {
        'name': '13kg Gas Cylinder',
        'quantity': 150,
        'value': 'KES 375,000',
        'trend': '+5.2%',
        'isPositive': true,
      },
      {
        'name': '6kg Gas Cylinder',
        'quantity': 89,
        'value': 'KES 106,800',
        'trend': '-2.1%',
        'isPositive': false,
      },
      {
        'name': 'Gas Regulator',
        'quantity': 45,
        'value': 'KES 36,000',
        'trend': '+12.3%',
        'isPositive': true,
      },
      {
        'name': 'Gas Detector',
        'quantity': 8,
        'value': 'KES 120,000',
        'trend': '+8.7%',
        'isPositive': true,
      },
      {
        'name': 'Pressure Gauge',
        'quantity': 67,
        'value': 'KES 30,150',
        'trend': '+3.4%',
        'isPositive': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getCategoryBreakdown() {
    return [
      {
        'category': 'Gas Cylinders',
        'items': 3,
        'value': 'KES 1,250,000',
        'percentage': 51.0,
        'color': AppTheme.primaryColor,
      },
      {
        'category': 'Accessories',
        'items': 3,
        'value': 'KES 450,000',
        'percentage': 18.4,
        'color': AppTheme.successColor,
      },
      {
        'category': 'Equipment',
        'items': 1,
        'value': 'KES 120,000',
        'percentage': 4.9,
        'color': AppTheme.infoColor,
      },
      {
        'category': 'Spare Parts',
        'items': 1,
        'value': 'KES 30,000',
        'percentage': 1.2,
        'color': AppTheme.warningColor,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'STOCK REPORTS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download report feature coming soon!'),
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
              : RefreshIndicator(
                onRefresh: _loadReports,
                color: AppTheme.primaryColor,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header with period selector
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Stock Analytics',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedPeriod,
                                    dropdownColor: AppTheme.primaryColor,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    underline: Container(),
                                    items:
                                        _periods.map((period) {
                                          return DropdownMenuItem(
                                            value: period,
                                            child: Text(period),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPeriod = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AppTheme.statItem(
                                  'Total Value',
                                  'KES 2.45M',
                                  Icons.attach_money,
                                ),
                                AppTheme.statItem(
                                  'Items',
                                  '1,247',
                                  Icons.inventory_2,
                                ),
                                AppTheme.statItem(
                                  'Categories',
                                  '4',
                                  Icons.category,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Key Metrics Grid
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildKeyMetricsGrid(),
                            const SizedBox(height: 20),
                            _buildTopItemsSection(),
                            const SizedBox(height: 20),
                            _buildCategoryBreakdownSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildKeyMetricsGrid() {
    final reports = _getReports();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildMetricCard(report);
      },
    );
  }

  Widget _buildMetricCard(StockReport report) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: report.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(report.icon, color: report.color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      report.isPositive
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      report.isPositive
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color:
                          report.isPositive
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      report.change,
                      style: TextStyle(
                        color:
                            report.isPositive
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.title,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            report.value,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTopItemsSection() {
    final topItems = _getTopItems();
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
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
                child: const Icon(
                  Icons.trending_up,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('TOP ITEMS BY VALUE', style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 16),
          ...topItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildTopItemRow(index + 1, item);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopItemRow(int rank, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color:
                  rank <= 3
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item['quantity']} units • ${item['value']}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:
                  item['isPositive']
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['trend'],
              style: TextStyle(
                color:
                    item['isPositive']
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownSection() {
    final categories = _getCategoryBreakdown();
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: AppTheme.infoColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('CATEGORY BREAKDOWN', style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 16),
          ...categories.map((category) => _buildCategoryRow(category)).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: category['color'],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['category'],
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${category['items']} items • ${category['value']}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${category['percentage'].toStringAsFixed(1)}%',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: category['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: category['percentage'] / 100,
            backgroundColor: AppTheme.textLight.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(category['color']),
          ),
        ],
      ),
    );
  }
}
