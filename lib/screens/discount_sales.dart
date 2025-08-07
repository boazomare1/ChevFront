import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chevenergies/models/discount_sale.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:chevenergies/screens/payment.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class DiscountSalesScreen extends StatefulWidget {
  const DiscountSalesScreen({super.key});

  @override
  State<DiscountSalesScreen> createState() => _DiscountSalesScreenState();
}

class _DiscountSalesScreenState extends State<DiscountSalesScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  Set<String> expandedSaleIds = {};
  String searchQuery = '';
  String? statusFilter; // 'Pending', 'Approved', 'Rejected', null
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Use Future.microtask to avoid setState during build
    Future.microtask(() => _loadDiscountSales());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasInitialized) {
      _refreshOnFocus();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasInitialized) {
      _refreshOnFocus();
    }
  }

  void _refreshOnFocus() {
    if (!mounted) return;
    _loadDiscountSales();
  }

  void _loadDiscountSales() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.fetchDiscountSales(status: statusFilter).then((_) {
      if (mounted) {
        setState(() {
          _hasInitialized = true;
        });
      }
    });
  }

  void _clearFilters() {
    setState(() {
      searchQuery = '';
      statusFilter = null;
    });
    _loadDiscountSales();
  }

  void _goToPaymentScreen(DiscountSale sale) {
    // Only allow payment for approved sales with a sales invoice
    if (sale.status.toLowerCase() != 'approved' || sale.salesInvoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment is only available for approved sales with an invoice',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Calculate final amount (totalAmount - totalDiscount)
    final finalAmount = sale.totalAmount - sale.totalDiscount;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentScreen(
              invoiceId: sale.salesInvoice!,
              totalAmount: finalAmount,
            ),
      ),
    ).then((_) {
      // Refresh the list when returning from payment screen
      _loadDiscountSales();
    });
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      case 'pending':
        color = AppTheme.warningColor;
        icon = Icons.pending;
        break;
      default:
        color = AppTheme.textSecondary;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSaleCard(DiscountSale sale) {
    final isExpanded = expandedSaleIds.contains(sale.discountSalesId);

    // Filter based on search query
    final matchesSearch =
        sale.customer.customerName.toLowerCase().contains(searchQuery) ||
        sale.shop.toLowerCase().contains(searchQuery) ||
        sale.routeId.toLowerCase().contains(searchQuery);

    if (searchQuery.isNotEmpty && !matchesSearch) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              if (isExpanded) {
                expandedSaleIds.remove(sale.discountSalesId);
              } else {
                expandedSaleIds.add(sale.discountSalesId);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Discount icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.local_offer,
                        color: AppTheme.warningColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Customer info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale.customer.customerName,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            sale.shop,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    _buildStatusBadge(sale.status),

                    // Sales invoice indicator
                    if (sale.salesInvoice != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppTheme.successColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt,
                              color: AppTheme.successColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'INVOICE',
                              style: TextStyle(
                                color: AppTheme.successColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Amount and discount row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Original: Ksh ${sale.totalAmount.toStringAsFixed(0)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Discount: Ksh ${sale.totalDiscount.toStringAsFixed(0)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Amount to Pay: Ksh ${(sale.totalAmount - sale.totalDiscount).toStringAsFixed(0)}',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          sale.day.toUpperCase(),
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          sale.routeId,
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Expandable items section
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  Text(
                    'Items',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...sale.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${item.qty}',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.itemName, style: AppTheme.bodySmall),
                                if (item.discountAmount > 0)
                                  Text(
                                    'Discount: Ksh ${item.discountAmount.toStringAsFixed(0)}',
                                    style: AppTheme.caption.copyWith(
                                      color: AppTheme.warningColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Ksh ${item.rate}',
                                style: AppTheme.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Ksh ${item.discountedAmount.toStringAsFixed(0)}',
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sales invoice information
                  if (sale.salesInvoice != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.successColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt,
                            color: AppTheme.successColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sales Invoice',
                                  style: AppTheme.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.successColor,
                                  ),
                                ),
                                Text(
                                  sale.salesInvoice!,
                                  style: AppTheme.bodySmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (sale.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.textLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notes:',
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sale.notes,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Action buttons
                  if (sale.status.toLowerCase() == 'approved' &&
                      sale.salesInvoice != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _goToPaymentScreen(sale),
                            icon: const Icon(Icons.payment, size: 18),
                            label: const Text('Make Payment'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Creation date
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(sale.creation))}',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder:
            (context, index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: AppTheme.cardDecoration,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 16,
                                width: double.infinity,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 12,
                                width: 100,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                width: 80,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 12,
                                width: 60,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 12,
                              width: 50,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 10,
                              width: 40,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final discountSales = appState.discountSales;
          final isLoading = appState.isLoadingDiscountSales;

          return Column(
            children: [
              // Header section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.8),
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
                            color: Colors.white.withValues(alpha: 0.2),
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
                                'DISCOUNT SALES',
                                style: AppTheme.headingLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'Pending approval requests',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
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
                          'Total',
                          discountSales.length.toString(),
                          Icons.local_offer,
                        ),
                        AppTheme.statItem(
                          'Pending',
                          discountSales
                              .where((sale) => sale.status == 'Pending')
                              .length
                              .toString(),
                          Icons.pending,
                        ),
                        AppTheme.statItem(
                          'Approved',
                          discountSales
                              .where((sale) => sale.status == 'Approved')
                              .length
                              .toString(),
                          Icons.check_circle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search and filter section
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      decoration: AppTheme.inputDecoration(
                        label: 'Search',
                        hintText: 'Search by customer name...',
                        prefixIcon: Icons.search,
                      ),
                      onChanged:
                          (val) =>
                              setState(() => searchQuery = val.toLowerCase()),
                    ),
                    const SizedBox(height: 12),

                    // Status filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.textLight),
                      ),
                      child: DropdownButton<String>(
                        value: statusFilter,
                        hint: Text(
                          'Filter by status',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items:
                            ['Pending', 'Approved', 'Rejected']
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                status.toLowerCase() ==
                                                        'approved'
                                                    ? AppTheme.successColor
                                                    : status.toLowerCase() ==
                                                        'rejected'
                                                    ? AppTheme.errorColor
                                                    : AppTheme.warningColor,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            status,
                                            style: AppTheme.bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() => statusFilter = val);
                          _loadDiscountSales();
                        },
                      ),
                    ),

                    // Clear filters button
                    if (searchQuery.isNotEmpty || statusFilter != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear Filters'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Discount sales list
              Expanded(
                child:
                    isLoading
                        ? _buildShimmerLoader()
                        : discountSales.isEmpty
                        ? AppTheme.emptyState(
                          icon: Icons.local_offer,
                          title: 'No Discount Sales',
                          subtitle: 'No discount sales found',
                        )
                        : RefreshIndicator(
                          onRefresh: () async {
                            _loadDiscountSales();
                          },
                          color: AppTheme.primaryColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: discountSales.length,
                            itemBuilder:
                                (context, index) => _buildDiscountSaleCard(
                                  discountSales[index],
                                ),
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
