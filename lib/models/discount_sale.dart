class DiscountSale {
  final String discountSalesId;
  final Customer customer;
  final String routeId;
  final String stopId;
  final String shop;
  final String day;
  final double totalAmount;
  final double totalDiscount;
  final String status;
  final String? approvedBy;
  final String? approvedOn;
  final String? salesInvoice;
  final String notes;
  final String creation;
  final List<DiscountSaleItem> items;

  DiscountSale({
    required this.discountSalesId,
    required this.customer,
    required this.routeId,
    required this.stopId,
    required this.shop,
    required this.day,
    required this.totalAmount,
    required this.totalDiscount,
    required this.status,
    this.approvedBy,
    this.approvedOn,
    this.salesInvoice,
    required this.notes,
    required this.creation,
    required this.items,
  });

  factory DiscountSale.fromJson(Map<String, dynamic> json) {
    return DiscountSale(
      discountSalesId: json['discount_sales_id'] ?? '',
      customer: Customer.fromJson(json['customer'] ?? {}),
      routeId: json['route_id'] ?? '',
      stopId: json['stop_id'] ?? '',
      shop: json['shop'] ?? '',
      day: json['day'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      totalDiscount: (json['total_discount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unknown',
      approvedBy: json['approved_by'],
      approvedOn: json['approved_on'],
      salesInvoice: json['sales_invoice'],
      notes: json['notes'] ?? '',
      creation: json['creation'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => DiscountSaleItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class DiscountSaleItem {
  final String itemCode;
  final String itemName;
  final double qty;
  final double rate;
  final double amount;
  final double discountAmount;
  final double discountedAmount;

  DiscountSaleItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.discountAmount,
    required this.discountedAmount,
  });

  factory DiscountSaleItem.fromJson(Map<String, dynamic> json) {
    return DiscountSaleItem(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      qty: (json['qty'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      discountedAmount: (json['discounted_amount'] ?? 0).toDouble(),
    );
  }
}

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
      return Customer(customerId: json, customerName: json);
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
