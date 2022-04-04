/// Represents an item in the inventory.
class Item {
  Item({required this.productName, this.productNumber, this.barcode, this.desiredStock,required this.stock});

  String productName;
  String? productNumber;
  String? barcode;
  int stock;
  int? desiredStock;

  Map toJson() => {
    'productName': productName,
    'productNumber': productNumber,
    'barcode': barcode,
    'desired_Stock': desiredStock,
    'stock': stock,
  };
}
