import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chevenergies/models/invoice.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  appState.fetchInvoices(
    startDate: selectedDate,
    endDate: selectedDate,
  );
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

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'unpaid':
        color = Colors.red;
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
            final updated = await Provider.of<AppState>(context, listen: false)
                .getInvoiceById(invoice.invoiceId);
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
                  Text(invoice.customer, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                ...invoice.items.map((item) => Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text('${item.qty} x ${item.itemName} @ Ksh ${item.rate}'),
                    )),
                SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _previewInvoicePDF(invoice),
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Preview PDF'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _previewInvoicePDF(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Invoice ID: ${invoice.invoiceId}', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Text('Customer: ${invoice.customer}'),
            pw.Text('Shop: ${invoice.shop}'),
            pw.Text('Status: ${invoice.status}'),
            pw.Text('Date: ${invoice.postingDate}'),
            pw.SizedBox(height: 10),
            pw.Text('Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...invoice.items.map((item) => pw.Text(
                '${item.qty} x ${item.itemName} @ Ksh ${item.rate}')),
            pw.SizedBox(height: 10),
            pw.Text('Total: Ksh ${invoice.total}', style: pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
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
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          if (appState.isLoadingInvoices) {
            return _buildShimmerLoader();
          }

          final filtered = appState.invoices.where((inv) {
            final matchesDate = inv.postingDate == DateFormat('yyyy-MM-dd').format(selectedDate);
            final matchesSearch = inv.customer.toLowerCase().contains(searchQuery);
            final matchesStatus = statusFilter == null || inv.status == statusFilter;
            return matchesDate && matchesSearch && matchesStatus;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by customer...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: statusFilter,
                      hint: Text('Filter by status'),
                      isExpanded: true,
                      items: ['Paid', 'Unpaid']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => statusFilter = val),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No sales for selected criteria.'))
                    : ListView(children: filtered.map(_buildInvoiceCard).toList()),
              ),
            ],
          );
        },
      ),
    );
  }
}
