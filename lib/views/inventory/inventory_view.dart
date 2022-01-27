import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/inventory/add_remove_item_dialog.dart';
import 'package:ship_organizer_app/views/inventory/side_menu.dart';
import 'package:ship_organizer_app/views/inventory/top_bar_widget.dart';
import 'inventory_widget.dart';
import 'item.dart';

/// View where the user can see the inventory for their department.
///
/// Uses the [Inventory] widget to display the items. When adding or removing items a confirmation
/// [AddRemoveItemDialog] pops up and prompts user for amount to add or remove of item.
///
/// TODO User and API calls for inventory usage should be handled here.
///
/// TODO Implement caching to local storage to be able to close and open app offline, in case of no internet.
class InventoryView extends StatefulWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InventoryViewState();
}

/// State of the inventory view.
class _InventoryViewState extends State<InventoryView> {
  final TextEditingController _controller = TextEditingController();

  List<Item> items = [];
  List<Item> displayedItems = [];

  @override
  void initState() {
    super.initState();
    // TODO Get items from API, or from local cache if offline.
    items = [
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

    displayedItems = items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize:
                // Creates top padding for the top bar so that it starts below status/notification bar.
                Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).viewPadding.top + 24.0),
            child: TopBar(
              onSearch: onSearch,
              onClear: onClear,
              controller: _controller,
            )),
        drawer: const SideMenu(),
        body: GestureDetector(
          // Used to remove keyboard on tap outside.
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Inventory(items: displayedItems),
        ));
  }

  /// Clears search bar and sets state for displayed items to all items.
  void onClear() {
    _controller.clear();
    setState(() {
      displayedItems = items;
    });
  }

  /// Sets state for displayed items to the result of the search.
  void onSearch() {
    // TODO Handle search functionality
    List<Item> result = [];
    String query = _controller.text;
    for (Item item in items ) {
      if (item.name.contains(query)) {
        result.add(item);
      } else if (item.productNumber != null) {
        if (item.productNumber!.contains(query)) {
          result.add(item);
        }
      } else if (item.ean13 != null) {
        if (item.ean13!.contains(query)) {
          result.add(item);
        }
      }
    }

    setState(() {
      displayedItems = result;
    });
  }

}
