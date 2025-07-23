class Item {
  final String itemCode;
  final String? itemName;
  final String? description;
  final double? quantity;
  final String? warehouse;
  final double? sellingPrice;
  final double? amount;

  Item({
    required this.itemCode,
     this.itemName,
     this.description,
     this.quantity,
     this.warehouse,
     this.sellingPrice,
     this.amount,
  });
}