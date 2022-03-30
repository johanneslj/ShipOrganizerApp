import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';

import 'package:ship_organizer_app/entities/department.dart';
import 'package:ship_organizer_app/views/inventory/sendReportToEmailView.dart';
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
  ApiService apiService = ApiService.getInstance();
  List<Item> items = [];
  List<Item> displayedItems = [];
  late bool _isLoading = true;
  Department selectedDepartment = Department(departmentName: "");

  @override
  void initState() {
    super.initState();
    dataLoadFunction();
  }

  dataLoadFunction() async {
    setState(() {
      _isLoading = true;
    });
    selectedDepartment.departmentName = await apiService.getActiveDepartment();
    await getItems();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    apiService.setContext(context);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize:
              // Creates top padding for the top bar so that it starts below status/notification bar.
              Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).viewPadding.top + 32.0),
          child: TopBar(
            onSearch: onSearch,
            onClear: onClear,
            filter: showSelectDepartmentMenu,
            searchFieldController: _controller,
            isRecommendedView: true,
            isMobile: true,
            onScan: scanBarcodeNormal,
          )),
      drawer: const SideMenu(),
      body: _isLoading
          ? circularProgress()
          : GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: RefreshIndicator(
                  onRefresh: () => getItems(),
                  child: Inventory(items: displayedItems, isRecommended: true),
                  color: colorScheme.onPrimary,
                  backgroundColor: colorScheme.primary),
            ),
      floatingActionButton: FloatingActionButton(
          foregroundColor: Theme.of(context).colorScheme.primaryVariant,
          onPressed: onOrderStockUp,
          child: Icon(Icons.send_sharp,
              color: Theme.of(context).colorScheme.surface)),
    );
  }

  void onOrderStockUp() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SendReportToEmail(items: displayedItems,)));
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
    List<Item> result = [];
    String query = _controller.text;
    for (Item item in items) {
      if (item.productName.toUpperCase().contains(query.toUpperCase())) {
        result.add(item);
      } else if (item.productNumber != null) {
        if (item.productNumber!.toUpperCase().contains(query.toUpperCase())) {
          result.add(item);
        }
      } else if (item.barcode != null) {
        if (item.barcode!.contains(query)) {
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
  void showSelectDepartmentMenu() async {
    showMenu(
        context: context,
        position: const RelativeRect.fromLTRB(16.0, 64.0, 0.0, 0.0),
        items: await getPopupMenuItems());
  }

  /// Gets the departments as a [List] of [PopupMenuItem] to be used in the select department pop up menu.
  Future<List<PopupMenuItem>> getPopupMenuItems() async {
    List<String> departments = await apiService.getDepartments();
    List<PopupMenuItem> popMenuItems = [];
    for (String department in departments) {
      popMenuItems.add(
        PopupMenuItem(
          child: Text(department),
          value: 1,
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            selectedDepartment.departmentName = department;
            await getItems();
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
    }
    return popMenuItems;
  }

  Future<void> getItems() async {
    List<Item> displayed = [];
    displayed =
        await apiService.getRecommendedItems(selectedDepartment.departmentName);
    setState(() {
      items = displayed;
      displayedItems = items;
    });
  }

  ///Method to scan the barcode
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _controller.text = barcodeScanRes != "-1" ? barcodeScanRes : "";
    });
  }

  /// Creates a container with a CircularProgressIndicator
  Container circularProgress() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10.0),
      child: const CircularProgressIndicator(
        strokeWidth: 2.0,
      ),
    );
  }
}
