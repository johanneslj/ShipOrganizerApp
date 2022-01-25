/// Represents an item in the inventory.
class Item {
  Item({required this.name, required this.ean13, required this.amount});

  final String name;
  final String ean13;
  int amount;
}