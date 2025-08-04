import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../services/app_state.dart';
import '../screens/payment.dart';

class GenericInvoiceListScreen extends StatefulWidget {
  final String title;
  final bool Function(Invoice invoice)? filterFn;

  const GenericInvoiceListScreen({
    super.key,
    required this.title,
    this.filterFn,
  });

  @override
  State<GenericInvoiceListScreen> createState() =>
      _GenericInvoiceListScreenState();
}

class _GenericInvoiceListScreenState extends State<GenericInvoiceListScreen> {
  late DateTimeRange dateRange;
  String searchQuery = '';
  String? statusFilter;
  Set<String> expanded = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final lastMonday = now.subtract(Duration(days: now.weekday - 1));
    dateRange = DateTimeRange(start: lastMonday, end: now);
    _fetchInvoices();
  }

  void _fetchInvoices() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.fetchInvoices(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 90)),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
    );

    if (picked != null) {
      setState(() => dateRange = picked);
      _fetchInvoices();
    }
  }

  void _clearFilters() {
    setState(() {
      searchQuery = '';
      statusFilter = null;
    });
  }

  Widget _buildStatusBadge(String status) {
    final color = {
      'paid': Colors.green,
      'unpaid': Colors.red,
      'partly paid': Colors.blue,
      'overdue': Colors.deepOrange,
    }[status.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final isExpanded = expanded.contains(invoice.invoiceId);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              expanded.add(invoice.invoiceId);
            });
          } else {
            setState(() => expanded.remove(invoice.invoiceId));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(invoice.customer.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  _buildStatusBadge(invoice.status),
                ],
              ),
              const SizedBox(height: 4),
              Text('Shop: ${invoice.shop}'),
              Text('Total: Ksh ${invoice.total.toStringAsFixed(0)}'),
              Text('Outstanding: Ksh ${invoice.outstandingBalance.toStringAsFixed(0)}'),
              Text('Date: ${invoice.postingDate}'),
              if (isExpanded) ...[
                const Divider(),
                const Text('Items:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...invoice.items.map(
                  (item) => Text(
                    '${item.qty} x ${item.itemName} @ Ksh ${item.rate}',
                  ),
                ),
                const SizedBox(height: 10),
                if (['Unpaid', 'Partly Paid', 'Overdue']
                    .contains(invoice.status))
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(invoiceId: invoice.invoiceId, totalAmount: invoice.outstandingBalance,),
                      ),
                    ),
                    icon: const Icon(Icons.payment),
                    label: const Text('Make Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: _selectDateRange, icon: const Icon(Icons.date_range)),
          IconButton(onPressed: _clearFilters, icon: const Icon(Icons.clear)),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          if (appState.isLoadingInvoices) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = appState.invoices.where((invoice) {
            final invoiceDate = DateTime.parse(invoice.postingDate);
            final inRange = invoiceDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
                            invoiceDate.isBefore(dateRange.end.add(const Duration(days: 1)));

            final matchesSearch = invoice.customer.customerName
                .toLowerCase()
                .contains(searchQuery.toLowerCase());

            final matchesStatus =
                statusFilter == null || invoice.status == statusFilter;

            final matchesCustom = widget.filterFn?.call(invoice) ?? true;

            return inRange && matchesSearch && matchesStatus && matchesCustom;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search customer...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) =>
                          setState(() => searchQuery = val.toLowerCase()),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: statusFilter,
                      hint: const Text('Filter by status'),
                      items: ['Paid', 'Unpaid', 'Partly Paid', 'Overdue']
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => statusFilter = val),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No invoices found.'))
                    : ListView(children: filtered.map(_buildInvoiceCard).toList()),
              ),
            ],
          );
        },
      ),
    );
  }
}
