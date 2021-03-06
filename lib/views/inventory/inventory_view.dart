import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ship_organizer_app/api_handling/api_controller.dart';
import 'package:ship_organizer_app/config/ui_utils.dart';
import 'package:ship_organizer_app/entities/department.dart';
import 'package:ship_organizer_app/widgets/add_remove_item_dialog.dart';
import 'package:ship_organizer_app/widgets/side_menu.dart';
import 'package:ship_organizer_app/widgets/top_bar_widget.dart';
import '../../widgets/inventory_widget.dart';
import 'package:ship_organizer_app/config/device_screen_type.dart';
import '../../entities/item.dart';

/// View where the user can see the inventory for their department.
///
/// Uses the [Inventory] widget to display the items. When adding or removing items a confirmation
/// [AddRemoveItemDialog] pops up and prompts user for amount to add or remove of item.
///
///
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
  bool isOffline = false;

  Department selectedDepartment = Department(departmentName: "");

  @override
  void initState() {
    super.initState();
    dataLoadFunction();
    _initialConnectionCheck();
    _setUpConnectivitySubscription();
  }

  /// Function for loading the inventory
  dataLoadFunction() async {
    setState(() {
      _isLoading = true;
    });
    selectedDepartment.departmentName = await apiService.getActiveDepartment();
    await getItems();
    displayedItems = items;

    setState(() {
      _isLoading = false;
    });
    apiService.getUserRights();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    apiService.setContext(context);
    return createView(context, colorScheme);
  }

  /// Checks if the user is online when entering the view
  void _initialConnectionCheck() {
    Connectivity().checkConnectivity().then(
      (result) {
        if (result == ConnectivityResult.none) {
          setState(
            () {
              isOffline = true;
            },
          );
        } else {
          setState(
            () {
              isOffline = false;
            },
          );
        }
      },
    );
  }

  /// Sets up a subscription to be notified if the
  /// User goes offline
  void _setUpConnectivitySubscription() {
    if (mounted) {
      Connectivity().onConnectivityChanged.listen(
        (result) {
          if (result == ConnectivityResult.none) {
            setState(() {
              isOffline = true;
            });
          } else {
            setState(
              () {
                isOffline = false;
              },
            );
          }
        },
      );
    }
  }

  Widget createView(BuildContext context, colorScheme) {
    if (getDeviceType(MediaQuery.of(context)) == DeviceScreenType.Mobile) {
      return Scaffold(
        appBar: isOffline
            ? PreferredSize(
                preferredSize:
                    // Creates top padding for the top bar so that it starts below status/notification bar.
                    Size(MediaQuery.of(context).size.width,
                        MediaQuery.of(context).viewPadding.top + 70.0),
                child: Column(
                  children: [
                    TopBar(
                      onSearch: onSearch,
                      onClear: onClear,
                      filter: showSelectDepartmentMenu,
                      searchFieldController: _controller,
                      isRecommendedView: false,
                      isMobile: true,
                      onScan: scanBarcodeNormal,
                    ),
                    Container(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning),
                          Text(AppLocalizations.of(context)!.offline)
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : PreferredSize(
                preferredSize:
                    // Creates top padding for the top bar so that it starts below status/notification bar.
                    Size(MediaQuery.of(context).size.width,
                        MediaQuery.of(context).viewPadding.top + 50.0),
                child: Column(
                  children: [
                    TopBar(
                      onSearch: onSearch,
                      onClear: onClear,
                      filter: showSelectDepartmentMenu,
                      searchFieldController: _controller,
                      isRecommendedView: false,
                      isMobile: true,
                      onScan: scanBarcodeNormal,
                    ),
                  ],
                ),
              ),
        drawer: const SideMenu(),
        body: _isLoading
            ? circularProgress()
            : GestureDetector(
                // Used to remove keyboard on tap outside.
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: RefreshIndicator(
                    onRefresh: () => getItems(),
                    child: displayedItems.isEmpty
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.emptyInventory),
                          )
                        : Inventory(items: displayedItems, onConfirm: getItems),
                    color: colorScheme.onPrimary,
                    backgroundColor: colorScheme.primary),
              ),
      );
    } else {
      return Scaffold(
        appBar: isOffline
            ? PreferredSize(
                preferredSize:
                    // Creates top padding for the top bar so that it starts below status/notification bar.
                    Size(MediaQuery.of(context).size.width,
                        MediaQuery.of(context).viewPadding.top + 70.0),
                child: Column(
                  children: [
                    TopBar(
                      onSearch: onSearch,
                      onClear: onClear,
                      filter: showSelectDepartmentMenu,
                      searchFieldController: _controller,
                      isRecommendedView: false,
                      isMobile: false,
                      onScan: scanBarcodeNormal,
                    ),
                    Container(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning),
                          Text(AppLocalizations.of(context)!.offline)
                        ],
                      ),
                    )
                  ],
                ),
              )
            : PreferredSize(
                preferredSize:
                    // Creates top padding for the top bar so that it starts below status/notification bar.
                    Size(MediaQuery.of(context).size.width,
                        MediaQuery.of(context).viewPadding.top + 60.0),
                child: TopBar(
                  onSearch: onSearch,
                  onClear: onClear,
                  filter: showSelectDepartmentMenu,
                  searchFieldController: _controller,
                  isRecommendedView: false,
                  isMobile: false,
                  onScan: scanBarcodeNormal,
                ),
              ),
        body: _isLoading
            ? circularProgress()
            : Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: SideMenu(),
                  ),
                  Expanded(
                    flex: 5,
                    child: GestureDetector(
                      // Used to remove keyboard on tap outside.
                      onTap: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      child: RefreshIndicator(
                          onRefresh: () => getItems(),
                          child: displayedItems.isEmpty
                              ? Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .emptyInventory),
                                )
                              : Inventory(
                                  items: displayedItems, onConfirm: getItems),
                          color: colorScheme.onPrimary,
                          backgroundColor: colorScheme.primary),
                    ),
                  ),
                ],
              ),
      );
    }
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
      } else if (item.productNumber!
              .toUpperCase()
              .contains(query.toUpperCase()) &&
          item.productNumber != null) {
        result.add(item);
      } else if (item.barcode!.contains(query) && item.barcode != null) {
        result.add(item);
      }
    }
    setState(() {
      displayedItems = result;
    });
  }

  ///Method to scan the barcode
  ///
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("e8f1f2",
          AppLocalizations.of(context)!.cancel, true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = "Failed to get platform version.";
    }
    if (!mounted) return;
    setState(() {
      _controller.text = barcodeScanRes != "-1" ? barcodeScanRes : "";
      if (barcodeScanRes.isNotEmpty) {
        onSearch();
      }
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
    String activeDepartment = await apiService.getActiveDepartment();
    departments.remove(activeDepartment);
    departments.insert(0, activeDepartment);

    List<PopupMenuItem> popMenuItems = [];
    for (int i = 0; i < departments.length; i++) {
      popMenuItems.add(
        PopupMenuItem(
          child: Row(
            children: [
              Radio(
                  groupValue: selectedRadioButton,
                  value: i,
                  onChanged: (int? value) {},
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => Theme.of(context).colorScheme.secondary)),
              Text(departments[i]),
            ],
          ),
          onTap: () async {
            changeSelectedRadioButton(i);
            setState(() {
              _isLoading = true;
            });
            selectedDepartment.departmentName = departments[i];
            await apiService.storage.write(key: "items", value: "");
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

  /// Changes the selected department in the dropdown
  void changeSelectedRadioButton(int value) {
    setState(() {
      selectedRadioButton = value;
    });
  }

  /// Requests the api service to fetch the inventory
  Future<void> getItems() async {
    List<Item> displayed = [];
    displayed = await apiService.getItems(selectedDepartment.departmentName);
    setState(() {
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
