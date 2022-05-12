/// Represents an item in the inventory.
class Item {
  Item({required this.id, required this.productName, this.productNumber, this.barcode, this.desiredStock,required this.stock});
  int id;
  String productName;
  String? productNumber;
  String? barcode;
  int stock;
  int? desiredStock;

  Map toJson() => {
    'id': id,
    'productName': productName,
    'productNumber': productNumber,
    'barcode': barcode,
    'desiredStock': desiredStock,
    'stock': stock,
  };
}
