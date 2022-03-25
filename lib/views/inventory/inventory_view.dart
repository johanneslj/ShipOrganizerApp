import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/entities/department.dart';
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

  ApiService apiService = ApiService.getInstance();
  List<Item> items = [];
  List<Item> displayedItems = [];
  late bool _isLoading = true;
  late int selectedRadioButton = 0;

  Department selectedDepartment = Department(departmentName: "");

  @override
  void initState() {
    dataLoadFunction();
    super.initState();
  }
  dataLoadFunction() async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });
    selectedDepartment.departmentName = await apiService.getActiveDepartment();
    await getItems();
    displayedItems = items;
    // fetch you data over here
    setState(() {
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }

  @override
  Widget build(BuildContext context) {
    apiService.setContext(context);
    final colorScheme = Theme.of(context).colorScheme;
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
              controller: _controller,
              recommended: false,
              onScan: scanBarcodeNormal,
            )),
        drawer: const SideMenu(),
        body: _isLoading ? circularProgress() : GestureDetector(
          // Used to remove keyboard on tap outside.
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: RefreshIndicator(onRefresh: () => getItems(),
          child: Inventory(items: displayedItems,onConfirm:getItems),color: colorScheme.onPrimary,
              backgroundColor: colorScheme.primary),
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
    List<Item> result = [];
    String query = _controller.text;
    for (Item item in items) {
      if (item.name.toUpperCase().contains(query.toUpperCase())) {
        result.add(item);
      } else if (item.productNumber != null) {
        if (item.productNumber!.toUpperCase().contains(query.toUpperCase())) {
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
    });}


  ///Method to scan the barcode
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes =
      await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _controller.text = barcodeScanRes;
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
    for(int i=0; i<departments.length; i++) {
      popMenuItems.add(
        PopupMenuItem(
          child: Row(
            children: [
              Radio(
                  groupValue: selectedRadioButton,
                value: i, onChanged: (int? value) {  },
                fillColor:MaterialStateColor.resolveWith((states) =>  Theme.of(context).colorScheme.secondary)

              ),
             Text(departments[i]),
            ],
          ),
          onTap: () async {
            changeSelectedRadioButton(i);
            setState(() {
              _isLoading = true;
            });
            selectedDepartment.departmentName = departments[i];
            await apiService.storage.write(key:"items",value:"");
            await getItems();
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
    }
    /*for (String department in departments) {
      popMenuItems.add(
        PopupMenuItem(
          child: Row(
            children: <Widget>[
              Radio(
                groupValue: selectedRadioButton,
                value: ,
                onChanged: (int? value) {
                  if(department ==  selectedDepartment.departmentName){
                    changeSelectedRadioButton(value!);
                  }
                  },
              ),
              Text(department),
            ],
          ),
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            selectedDepartment.departmentName = department;
            await apiService.storage.write(key:"items",value:"");
            await getItems();
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
    }*/
    return popMenuItems;
  }

  void changeSelectedRadioButton(int value){
    setState(() {
      selectedRadioButton = value;
    });
  }

  Future<void> getItems() async {
    List<Item> displayed = [];
      displayed = await apiService.getItems(selectedDepartment.departmentName);
    setState((){
      items = displayed;
      displayedItems = items;
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
