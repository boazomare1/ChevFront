// models/invoice.dart

class Invoice {
  final String invoiceId;
  final String customer;
  final String routeId;
  final String shop;
  final double total;
  final String status;
  final String postingDate;
  final List<InvoiceItem> items;

  Invoice({
    required this.invoiceId,
    required this.customer,
    required this.routeId,
    required this.shop,
    required this.total,
    required this.status,
    required this.postingDate,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceId: json['invoice_id'],
      customer: json['customer'],
      routeId: json['route_id'],
      shop: json['shop'],
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'],
      postingDate: json['posting_date'],
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
    );
  }
}

class InvoiceItem {
  final String itemCode;
  final String itemName;
  final double qty;
  final double rate;

  InvoiceItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemCode: json['item_code'],
      itemName: json['item_name'],
      qty: (json['qty'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
    );
  }
}
