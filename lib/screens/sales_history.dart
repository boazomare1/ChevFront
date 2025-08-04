import 'dart:io';

import 'package:chevenergies/screens/payment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chevenergies/models/invoice.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});
  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  DateTime selectedDate = DateTime.now();
  Set<String> expandedInvoiceIds = {};
  String searchQuery = '';
  String? statusFilter; // 'Paid', 'Unpaid', 'Partly Paid', null

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid setState during build
    Future.microtask(() => _loadInvoices());
  }

  void _loadInvoices() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.fetchInvoices(startDate: selectedDate, endDate: selectedDate);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadInvoices();
    }
  }

  void _clearFilters() {
    setState(() {
      searchQuery = '';
      statusFilter = null;
    });
    _loadInvoices();
  }

  PdfColor getStatusPdfColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PdfColors.green;
      case 'unpaid':
        return PdfColors.red;
      case 'partly paid':
        return PdfColors.blue;
      case 'overdue':
        return PdfColors.deepOrange;
      default:
        return PdfColors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = AppTheme.successColor;
        break;
      case 'unpaid':
        color = AppTheme.errorColor;
        break;
      case 'partly paid':
        color = AppTheme.infoColor;
        break;
      case 'overdue':
        color = AppTheme.warningColor;
        break;
      default:
        color = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.toLowerCase() == 'paid'
                ? Icons.check_circle
                : status.toLowerCase() == 'unpaid'
                ? Icons.error
                : status.toLowerCase() == 'partly paid'
                ? Icons.pending
                : Icons.warning,
            color: color,
            size: 14,
          ),
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

  Widget _buildInvoiceCard(Invoice invoice) {
    final isExpanded = expandedInvoiceIds.contains(invoice.invoiceId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (!isExpanded) {
              final updated = await Provider.of<AppState>(
                context,
                listen: false,
              ).getInvoiceById(invoice.invoiceId);
              setState(() {
                invoice.items.clear();
                invoice.items.addAll(updated.items);
                expandedInvoiceIds.add(invoice.invoiceId);
              });
            } else {
              setState(() => expandedInvoiceIds.remove(invoice.invoiceId));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Invoice icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt,
                        color: AppTheme.primaryColor,
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
                            invoice.customer.customerName,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            invoice.shop,
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
                    _buildStatusBadge(invoice.status),
                  ],
                ),

                const SizedBox(height: 12),

                // Amount and date row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total: Ksh ${invoice.total.toStringAsFixed(0)}',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          if (invoice.outstandingBalance > 0)
                            Text(
                              'Outstanding: Ksh ${invoice.outstandingBalance.toStringAsFixed(0)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(invoice.postingDate, style: AppTheme.caption),
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

                  ...invoice.items.map(
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
                              color: AppTheme.primaryColor.withOpacity(0.1),
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
                            child: Text(
                              item.itemName,
                              style: AppTheme.bodySmall,
                            ),
                          ),
                          Text(
                            'Ksh ${item.rate}',
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _previewInvoicePDF(invoice),
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text('Preview PDF'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: BorderSide(color: AppTheme.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (invoice.status == 'Unpaid' ||
                          invoice.status == 'Partly Paid' ||
                          invoice.status == 'Overdue')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _goToPaymentScreen(invoice),
                            icon: const Icon(Icons.payment, size: 18),
                            label: Text(
                              invoice.status == 'Unpaid' ? 'Pay' : 'Complete',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
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

  void _goToPaymentScreen(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentScreen(
              invoiceId: invoice.invoiceId,
              totalAmount:
                  invoice.outstandingBalance > 0
                      ? invoice.outstandingBalance
                      : invoice.total,
            ),
      ),
    );
  }

  Future<void> _previewInvoicePDF(Invoice invoice) async {
    final pdf = pw.Document();

    final logoBytes = await rootBundle.load('assets/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(logoImage, width: 80),
                    pw.SizedBox(width: 20),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CHEV ENERGIES',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('INVOICE', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Date: ${invoice.postingDate}'),
                      ],
                    ),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Invoice ID: ${invoice.invoiceId}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text('Customer: ${invoice.customer.customerName}'),
                pw.Text('Customer Type: ${invoice.customer.customerType}'),
                if (invoice.customer.territory != null)
                  pw.Text('Territory: ${invoice.customer.territory}'),
                pw.Text('Shop: ${invoice.shop}'),
                pw.Text(
                  'Status: ${invoice.status}',
                  style: pw.TextStyle(color: getStatusPdfColor(invoice.status)),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Items:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                // Table for items
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FixedColumnWidth(50), // No
                    1: pw.FlexColumnWidth(), // Name
                    2: pw.FixedColumnWidth(80), // Quantity
                    3: pw.FixedColumnWidth(100), // Price
                  },
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'No',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Name',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Quantity',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Price',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    // Data rows
                    ...invoice.items.asMap().entries.map((entry) {
                      final index = entry.key + 1; // Start numbering from 1
                      final item = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('$index'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.itemName),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.qty.toStringAsFixed(0)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Ksh ${item.rate.toStringAsFixed(0)}',
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Total: Ksh ${invoice.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text('Paid: Ksh ${invoice.paidAmount.toStringAsFixed(2)}'),
                pw.Text(
                  'Outstanding: Ksh ${invoice.outstandingBalance.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color:
                        invoice.outstandingBalance > 0
                            ? PdfColors.red
                            : PdfColors.black,
                  ),
                ),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/Invoice_${invoice.invoiceId}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF saved to: ${file.path}')));
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: AppTheme.cardDecoration,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          if (appState.isLoadingInvoices) {
            return _buildShimmerLoader();
          }

          final filtered =
              appState.invoices.where((inv) {
                final matchesDate =
                    inv.postingDate ==
                    DateFormat('yyyy-MM-dd').format(selectedDate);
                final matchesSearch = inv.customer.customerName
                    .toLowerCase()
                    .contains(searchQuery);
                final matchesStatus =
                    statusFilter == null || inv.status == statusFilter;
                return matchesDate && matchesSearch && matchesStatus;
              }).toList();

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
                      AppTheme.primaryColor.withOpacity(0.8),
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
                                'SALES HISTORY',
                                style: AppTheme.headingLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'EEEE, MMMM d, yyyy',
                                ).format(selectedDate),
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Date picker button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                            ),
                            onPressed: _selectDate,
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
                          filtered.length.toString(),
                          Icons.receipt,
                        ),
                        AppTheme.statItem(
                          'Paid',
                          filtered
                              .where((inv) => inv.status == 'Paid')
                              .length
                              .toString(),
                          Icons.check_circle,
                        ),
                        AppTheme.statItem(
                          'Pending',
                          filtered
                              .where((inv) => inv.status != 'Paid')
                              .length
                              .toString(),
                          Icons.pending,
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
                            ['Paid', 'Unpaid', 'Partly Paid', 'Overdue']
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
                                                status.toLowerCase() == 'paid'
                                                    ? AppTheme.successColor
                                                    : status.toLowerCase() ==
                                                        'unpaid'
                                                    ? AppTheme.errorColor
                                                    : status.toLowerCase() ==
                                                        'partly paid'
                                                    ? AppTheme.infoColor
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
                        onChanged: (val) => setState(() => statusFilter = val),
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

              // Invoice list
              Expanded(
                child:
                    filtered.isEmpty
                        ? AppTheme.emptyState(
                          icon: Icons.receipt_long,
                          title: 'No Sales Found',
                          subtitle: 'No sales match your search criteria',
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder:
                              (context, index) =>
                                  _buildInvoiceCard(filtered[index]),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
