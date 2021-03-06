import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ship_organizer_app/api_handling/api_controller.dart';
import 'package:ship_organizer_app/entities/item.dart';

///This class represents the possibility to add a new item to the inventory list
/// or the option of editing an existing one

class NewItem extends StatefulWidget {
  final bool isCreateNew;
  final Item? itemToEdit;

  const NewItem({Key? key, required this.isCreateNew, this.itemToEdit})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final TextEditingController barcodeController = TextEditingController();
  String searchQuery = "Search query";
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService.getInstance();
  String department = "";

  TextEditingController productNameController = TextEditingController();
  TextEditingController productNumberController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController desiredStockController = TextEditingController();

  /// Method to scan a barcode
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("e8f1f2",
          AppLocalizations.of(context)!.cancel, true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      barcodeController.text = barcodeScanRes != "-1" ? barcodeScanRes : "";
    });
  }

  @override
  void initState() {
    super.initState();
    getDepartment();
    if (!widget.isCreateNew) {
      productNameController.text = widget.itemToEdit!.productName;
      productNumberController.text = widget.itemToEdit!.productNumber!;
      stockController.text = widget.itemToEdit!.stock.toString();
      desiredStockController.text = widget.itemToEdit!.desiredStock.toString();
      barcodeController.text = widget.itemToEdit!.barcode.toString().trim();
    }
  }

  /// Gets the users active department from api service
  getDepartment() async {
    String activeDepartment = await _apiService.getActiveDepartment();
    setState(() {
      department = activeDepartment;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => {
            FocusScope.of(context).requestFocus(FocusNode()),
            Navigator.of(context).pop()
          },
        ),
        title: getTitle(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 20, bottom: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.productName),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: productNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .enterValidText;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(context)!.productName,
                                hintStyle: TextStyle(
                                    color: Theme.of(context).disabledColor)),
                          ),
                          Text(AppLocalizations.of(context)!.productNameNoComma,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 16,
                              )),
                        ],
                      ),
                    ),
                    Text(AppLocalizations.of(context)!.productNumber),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: TextFormField(
                        //readOnly: !widget.isCreateNew,
                        controller: productNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.enterValidText;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.productNumber,
                            hintStyle: TextStyle(
                                color: Theme.of(context).disabledColor)),
                      ),
                    ),
                    Text(AppLocalizations.of(context)!.desiredStock),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: TextFormField(
                        controller: desiredStockController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.enterValidText;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.desiredStock,
                            hintStyle: TextStyle(
                                color: Theme.of(context).disabledColor)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Text(AppLocalizations.of(context)!.productStock),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: TextFormField(
                          readOnly: !widget.isCreateNew,
                          controller: stockController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .enterValidNumber;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.productStock,
                            hintStyle: TextStyle(
                                color: Theme.of(context).disabledColor),
                          ),
                          keyboardType: TextInputType.number),
                    ),
                    Text(AppLocalizations.of(context)!.barcode),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (query) => updateSearchQuery(query),
                      controller: barcodeController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.barcode,
                        hintStyle:
                            TextStyle(color: Theme.of(context).disabledColor),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt_sharp,
                                color: Colors.black),
                            onPressed: () => {scanBarcodeNormal()},
                          ), // icon is 48px widget.
                        ),
                      ),
                    ),
                    widget.isCreateNew
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: ButtonTheme(
                                  minWidth: 250.0,
                                  height: 100.0,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        if (widget.isCreateNew) {
                                          addNewItem(
                                              productNameController.value.text,
                                              productNumberController
                                                  .value.text,
                                              desiredStockController.value.text,
                                              stockController.value.text,
                                              barcodeController.value.text);
                                        } else {
                                          editItem(
                                              productNameController.value.text,
                                              productNumberController
                                                  .value.text,
                                              desiredStockController.value.text,
                                              barcodeController.value.text);
                                        }
                                      }
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.submit),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: ButtonTheme(
                                  minWidth: 250.0,
                                  height: 100.0,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        if (widget.isCreateNew) {
                                          addNewItem(
                                              productNameController.value.text,
                                              productNumberController
                                                  .value.text,
                                              desiredStockController.value.text,
                                              stockController.value.text,
                                              barcodeController.value.text);
                                        } else {
                                          editItem(
                                              productNameController.value.text,
                                              productNumberController
                                                  .value.text,
                                              desiredStockController.value.text,
                                              barcodeController.value.text);
                                        }
                                      }
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.update),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 30, left: 20),
                                child: ButtonTheme(
                                  minWidth: 250.0,
                                  height: 100.0,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                    ),
                                    onPressed: () async {
                                      bool success = await deleteProduct();
                                      if (success) {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            "/administerProducts",
                                            (route) => false);
                                      }
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .deleteProduct),
                                  ),
                                ),
                              )
                            ],
                          )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the title of the view depending on the mode its in
  Widget getTitle(BuildContext context) {
    return widget.isCreateNew
        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppLocalizations.of(context)!.addProduct,
                style: Theme.of(context).textTheme.headline6),
            Text(department, style: Theme.of(context).textTheme.headline6)
          ])
        : Text(AppLocalizations.of(context)!.editProduct,
            style: Theme.of(context).textTheme.headline6);
  }

  /// Update the barcode field with ean-code
  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  /// Edits an already existing item
  /// Stock cant be edited so it is not required to be passed here
  /// Product number cant be edited but is necessary to identify the product
  /// in the database
  Future<void> editItem(String productName, String productNumber,
      String desiredStock, String barcode) async {
    bool success = await _apiService.editProduct(widget.itemToEdit!.id,
        productName, productNumber, desiredStock, barcode);
    if (success) {
      Navigator.pushNamed(context, "/administerProducts");
    }
  }

  /// Handles what happens when the user presses create ne item
  /// Uses API service to create a new item in the backend
  Future<void> addNewItem(String productName, String productNumber,
      String desiredStock, String stock, String barcode) async {
    bool success = await _apiService.createNewProduct(
        productName, productNumber, desiredStock, stock, barcode);
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
    }
  }

  /// Attempts to delete the selected product from the backend
  Future<bool> deleteProduct() async {
    bool success =
        await _apiService.deleteProduct(productNumberController.value.text);
    return success;
  }
}
