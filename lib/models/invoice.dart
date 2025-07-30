class Customer {
  final String customerId;
  final String customerName;
  final String? customerType;
  final String? customerGroup;
  final String? territory;

  Customer({
    required this.customerId,
    required this.customerName,
    this.customerType,
    this.customerGroup,
    this.territory,
  });

  factory Customer.fromJson(dynamic json) {
    if (json is String) {
      return Customer(
        customerId: json,
        customerName: json,
      );
    }
    return Customer(
      customerId: json['customer_id'] ?? json['customer_name'] ?? '',
      customerName: json['customer_name'] ?? json['customer_id'] ?? '',
      customerType: json['customer_type'],
      customerGroup: json['customer_group'],
      territory: json['territory'],
    );
  }
}

class Invoice {
  final String invoiceId;
  final Customer customer;
  final String routeId;
  final String shop;
  final double total;
  final double paidAmount;
  final double outstandingBalance;
  final String status;
  final String paymentStatus;
  final String postingDate;
  final List<InvoiceItem> items;

  Invoice({
    required this.invoiceId,
    required this.customer,
    required this.routeId,
    required this.shop,
    required this.total,
    required this.paidAmount,
    required this.outstandingBalance,
    required this.status,
    required this.paymentStatus,
    required this.postingDate,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final double total = (json['total_amount'] ?? 0).toDouble();
    final double outstandingBalance = (json['outstanding_balance'] ?? 0).toDouble();
    final double paidAmount = total - outstandingBalance;
    return Invoice(
      invoiceId: json['invoice_id'],
      customer: Customer.fromJson(json['customer']),
      routeId: json['route_id'],
      shop: json['shop'],
      total: total,
      paidAmount: paidAmount,
      outstandingBalance: outstandingBalance,
      status:  json['status'] ?? 'Unknown',
      paymentStatus: json['payment_status']?? 'Unknown',
      postingDate: json['posting_date'],
      items: (json['items'] as List<dynamic>?)?.map((item) => InvoiceItem.fromJson(item)).toList() ?? [],
    );
  }
}

class InvoiceItem {
  final String itemCode;
  final String itemName;
  final double qty;
  final double rate;
  final double amount;
  final String uom;

  InvoiceItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.uom,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemCode: json['item_code'],
      itemName: json['item_name'],
      qty: (json['qty'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      uom: json['uom'] ?? 'pcs',
    );
  }
}