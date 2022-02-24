import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ship_organizer_app/views/inventory/inventory_view.dart';

///This class represents the possibility to add a new item to the inventory list
///

class NewItem extends StatefulWidget {
  const NewItem({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _newItem();
}

class _newItem extends State<NewItem> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = "Search query";
  final _formKey = GlobalKey<FormState>();

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
      _searchQueryController.text = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.addProduct,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Center(
          child: SingleChildScrollView(
              child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
              child: Form(
                key: _formKey,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(AppLocalizations.of(context)!.productName),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enterValidText;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.productName,
                        hintStyle: TextStyle(color: Theme.of(context).disabledColor)),
                  ),
                  Text(AppLocalizations.of(context)!.productNumber),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enterValidText;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.productNumber,
                        hintStyle: TextStyle(color: Theme.of(context).disabledColor)),
                  ),
                  Text(AppLocalizations.of(context)!.productStock),
                  TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterValidNumber;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.productStock,
                        hintStyle: TextStyle(color: Theme.of(context).disabledColor),
                      ),
                      keyboardType: TextInputType.number),
                  Text(AppLocalizations.of(context)!.barcode),
                  TextFormField(
                    onChanged: (query) => updateSearchQuery(query),
                    controller: _searchQueryController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.barcode,
                      hintStyle: TextStyle(color: Theme.of(context).disabledColor),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt_sharp, color: Colors.black),
                          onPressed: () => {scanBarcodeNormal()},
                        ), // icon is 48px widget.
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: ButtonTheme(
                          minWidth: 250.0,
                          height: 100.0,
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Processing Data')),
                                  );
                                  sendToServer(context);
                                }
                              },
                              child: Text(AppLocalizations.of(context)!.submit))))
                ]),
              ))
        ],
      ))),
    );
  }

  /// Update the searchbar with ean-code
  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void sendToServer(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => (const InventoryView())));
  }
}
