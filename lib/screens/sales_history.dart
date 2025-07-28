import 'dart:io';

import 'package:chevenergies/screens/payment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chevenergies/models/invoice.dart';
import 'package:chevenergies/services/app_state.dart';
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
  String? statusFilter; // 'Paid', 'Unpaid', null

  @override
  void initState() {
    super.initState();
    _loadInvoices();
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
      setState(() => selectedDate = picked);
      _loadInvoices(); // currently fetches all
    }
  }

  // Determine PDF color
  PdfColor getStatusPdfColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PdfColors.green;
      case 'unpaid':
        return PdfColors.red;
      case 'partly paid':
        return PdfColors.blue;
      default:
        return PdfColors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'unpaid':
        color = Colors.red;
        break;
      case 'partly paid':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final isExpanded = expandedInvoiceIds.contains(invoice.invoiceId);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.customer,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusBadge(invoice.status),
                ],
              ),
              SizedBox(height: 4),
              Text('Shop: ${invoice.shop}'),
              Text('Total: Ksh ${invoice.total.toStringAsFixed(0)}'),
              Text('Date: ${invoice.postingDate}'),
              if (isExpanded) ...[
                Divider(),
                Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...invoice.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      '${item.qty} x ${item.itemName} @ Ksh ${item.rate}',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _previewInvoicePDF(invoice),
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('Preview PDF'),
                    ),
                    if (invoice.status == 'Unpaid' ||
                        invoice.status == 'Partly Paid')
                      ElevatedButton.icon(
                        onPressed: () => _goToPaymentScreen(invoice),
                        icon: Icon(Icons.payment),
                        label: Text(
                          invoice.status == 'Unpaid'
                              ? 'Pay'
                              : 'Complete Payment',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _goToPaymentScreen(Invoice invoice) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentScreen(
        invoiceId: invoice.invoiceId,
        totalAmount: invoice.total, // or remaining balance if available
      ),
    ),
  );
}


  Future<void> _previewInvoicePDF(Invoice invoice) async {
    final pdf = pw.Document();

    // Load logo image
    final logoBytes = await rootBundle.load('assets/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    PdfColor getStatusPdfColor(String status) {
      switch (status.toLowerCase()) {
        case 'paid':
          return PdfColors.green;
        case 'unpaid':
          return PdfColors.red;
        case 'partly paid':
          return PdfColors.blue;
        default:
          return PdfColors.grey;
      }
    }

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
                pw.Text('Customer: ${invoice.customer}'),
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
                ...invoice.items.map(
                  (item) => pw.Text(
                    '${item.qty} x ${item.itemName} @ Ksh ${item.rate.toStringAsFixed(0)}',
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Total: Ksh ${invoice.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );

    // Show preview
    await Printing.layoutPdf(onLayout: (format) => pdf.save());

    // Save file to downloads directory
    final output =
        await getApplicationDocumentsDirectory(); // or getDownloadsDirectory() on desktop
    final file = File('${output.path}/Invoice_${invoice.invoiceId}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF saved to: ${file.path}')));
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Container(
              height: 100,
              padding: EdgeInsets.all(16),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Invoices'),
        actions: [
          IconButton(icon: Icon(Icons.calendar_today), onPressed: _selectDate),
        ],
      ),
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
                final matchesSearch = inv.customer.toLowerCase().contains(
                  searchQuery,
                );
                final matchesStatus =
                    statusFilter == null || inv.status == statusFilter;
                return matchesDate && matchesSearch && matchesStatus;
              }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by customer...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged:
                          (val) =>
                              setState(() => searchQuery = val.toLowerCase()),
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: statusFilter,
                      hint: Text('Filter by status'),
                      isExpanded: true,
                      items:
                          ['Paid', 'Unpaid', 'Partly Paid']
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              status.toLowerCase() == 'paid'
                                                  ? Colors.green
                                                  : status.toLowerCase() ==
                                                      'unpaid'
                                                  ? Colors.red
                                                  : Colors.blue,
                                        ),
                                      ),
                                      Text(status),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => statusFilter = val),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    filtered.isEmpty
                        ? Center(child: Text('No sales for selected criteria.'))
                        : ListView(
                          children: filtered.map(_buildInvoiceCard).toList(),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
