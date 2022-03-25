/// Represents an item in the inventory.
class Item {
  Item({required this.name, this.productNumber, this.ean13, required this.amount});

  final String name;
  final String? productNumber;
  final String? ean13;
  int amount;

  Map toJson() => {
    'name': name,
    'productNumber': productNumber,
    'ean13': ean13,
    'amount': amount,
  };
}
