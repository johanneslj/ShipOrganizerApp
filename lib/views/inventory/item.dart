/// Represents an item in the inventory.
class Item {
  Item({required this.productName, this.productNumber, this.barcode, this.desiredStock,required this.stock});

  final String productName;
  final String? productNumber;
  final String? barcode;
  int stock;
  int? desiredStock;

  Map toJson() => {
    'productName': productName,
    'productNumber': productNumber,
    'barcode': barcode,
    'desiredStock': desiredStock,
    'stock': stock,
  };
}
