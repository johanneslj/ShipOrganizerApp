import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/config/theme_config.dart';

import 'package:ship_organizer_app/entities/department.dart';
import 'package:ship_organizer_app/services/api_service.dart';
import 'package:ship_organizer_app/views/inventory/side_menu.dart';
import 'package:ship_organizer_app/views/inventory/top_bar_widget.dart';
import 'inventory_widget.dart';
import 'item.dart';

/// View where the user can see the inventory for their department.
///
///
class RecommendedInventoryView extends StatefulWidget {
  const RecommendedInventoryView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendedInventoryViewState();
}

/// State of the inventory view.
class _RecommendedInventoryViewState extends State<RecommendedInventoryView> {
  final TextEditingController _controller = TextEditingController();
  ApiService apiService = ApiService();

  List<Item> items = [];
  List<Item> displayedItems = [];

  // TODO Implement with API
  Department selectedDepartment = Department(departmentName: "Bridge");

  @override
  void initState() {
    super.initState();
    getItems();
    // TODO Get items from API, or from local cache if offline.
    /*items = [
      Item(name: "Name", ean13: "1432456789059", amount: 200),
      Item(name: "Product", ean13: "1432456789059", amount: 60),
      Item(name: "Test123", ean13: "1432456789059", amount: 72),
      Item(name: "Weird-stuff../123###13!", ean13: "1432456789059", amount: 40),
      Item(name: "__234rfgg245", ean13: "1432456789059", amount: 300),
      Item(name: "Product Name", ean13: "1432456789059", amount: 10),
      Item(name: "Something", ean13: "1432456789059", amount: 100),
      Item(name: "Yes", ean13: "1432456789059", amount: 900),
      Item(name: "asdfsdfgsdfg", ean13: "1432456789059", amount: 5),
      Item(name: "Something", ean13: "1432456789059", amount: 90),
      Item(name: "Yes", ean13: "1432456789059", amount: 800),
      Item(name: "asdfsdfgsdfg", ean13: "1432456789059", amount: 10),
      Item(name: "Something", ean13: "1432456789059", amount: 150),
      Item(name: "Yes", ean13: "1432456789059", amount: 1000),
      Item(name: "asdfsdfgsdfg", ean13: "1432456789059", amount: 10),
    ];*/

    displayedItems = items;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize:
              // Creates top padding for the top bar so that it starts below status/notification bar.
              Size(
                  MediaQuery.of(context).size.width, MediaQuery.of(context).viewPadding.top + 32.0),
          child: TopBar(
            onSearch: onSearch,
            onClear: onClear,
            filter: showSelectDepartmentMenu,
            controller: _controller,
          )),
      drawer: const SideMenu(),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: RefreshIndicator(onRefresh: () => getItems(),
          child: Inventory(items: displayedItems,isRecommended: true),
        color: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Theme.of(context).colorScheme.primaryVariant,
        onPressed: onOrderStockUp,
        child: Icon(Icons.send_sharp, color: Theme.of(context).colorScheme.surface)
      ),
    );
  }


  void onOrderStockUp() {

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
    for (Item item in items) {
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

  /// Displays the select department pop up menu, where the user can select which department's inventory
  /// they want to view.
  void showSelectDepartmentMenu() {
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(16.0, 64.0, 0.0, 0.0),
        items: getPopupMenuItems());
  }

  /// Gets the departments as a [List] of [PopupMenuItem] to be used in the select department pop up menu.
  List<PopupMenuItem> getPopupMenuItems() {
    // TODO Get departments from API
    return [
      PopupMenuItem(
        child: Text("Bridge"),
        value: 1,
      ),
      PopupMenuItem(
        child: Text("Factory"),
        value: 2,
      ),
      PopupMenuItem(
        child: Text("Deck"),
        value: 3,
      ),
      PopupMenuItem(
        child: Text("Storage"),
        value: 4,
      ),
      PopupMenuItem(
        child: Text("Office"),
        value: 5,
      ),
      PopupMenuItem(
        child: Text("Kitchen"),
        value: 6,
      ),
    ];
  }
  Future<void> getItems() async {
    List<Item> displayed = [];
    displayed = await apiService.getRecommendedItems();
    setState((){
      displayedItems = displayed;
    });
  }
}
