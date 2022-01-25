import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'item.dart';

/// Represents the inventory for the selected department.
///
/// TODO Needs to be implemented in a way that changes to inventory can be made when offline to be pushed later.
class Inventory extends StatefulWidget {
  Inventory({Key? key, this.items}) : super(key: key);

  List<Item>? items;

  @override
  State<StatefulWidget> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {

  // TODO Get items from API
  List<Item> items = [
    Item(name: "Name", ean13: "1432456789059", amount: 234),
    Item(name: "Product", ean13: "1432456789059", amount: 54),
    Item(name: "Test123", ean13: "1432456789059", amount: 72),
    Item(name: "Weird-stuff../123###13!", ean13: "1432456789059", amount: 22),
    Item(name: "__234rfgg245", ean13: "1432456789059", amount: 234),
    Item(name: "Product Name", ean13: "1432456789059", amount: 4),
    Item(name: "Something", ean13: "1432456789059", amount: 88),
    Item(name: "Yes", ean13: "1432456789059", amount: 765),
    Item(name: "asdfsdfgsdfg", ean13: "1432456789059", amount: 2),
    Item(name: "Something", ean13: "1432456789059", amount: 88),
    Item(name: "Yes", ean13: "1432456789059", amount: 765),
    Item(name: "asdfsdfgsdfg", ean13: "1432456789059", amount: 2),
    Item(name: "Something", ean13: "1432456789059", amount: 88),
    Item(name: "Yes", ean13: "1432456789059", amount: 765),
    Item(name: "asdfsdfgsdfg", ean13: "1432456789059", amount: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            title: Text(
          items[index].name,
          style: Theme.of(context).textTheme.headline5,
          overflow: TextOverflow.ellipsis,
        ),
          trailing: SizedBox(
              width: 160.0,
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.remove, size: 36.0)),
            Text(items[index].amount.toString(), style: Theme.of(context).textTheme.headline5,),
            IconButton(onPressed: () {}, icon: Icon(Icons.add, size: 36.0)),
          ],)),
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          Divider(color: Theme.of(context).colorScheme.primary),
    );
  }
}
