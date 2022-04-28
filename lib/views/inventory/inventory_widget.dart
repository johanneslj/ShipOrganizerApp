import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/config/device_screen_type.dart';
import 'package:ship_organizer_app/config/ui_utils.dart';
import 'package:ship_organizer_app/views/inventory/add_remove_item_dialog.dart';
import 'package:ship_organizer_app/views/map/map_view.dart';
import 'package:location/location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'item.dart';

/// Widget that displays the input items as a ListView.
///
/// Usable for both actual inventory and recommended inventory.
class Inventory extends StatelessWidget {
  Inventory({
    Key? key,
    this.onAdd,
    this.onRemove,
    this.items = const [],
    this.onConfirm,
    this.isRecommended = false,
  }) : super(key: key);

  /// Items in the inventory
  final List<Item> items;

  /// Function to be called on add button pressed.
  /// Default function shows dialog to confirm addition amount.
  final Function()? onAdd;

  /// Function to be called on remove button pressed.
  /// Default function shows dialog to confirm removal amount.
  final Function()? onRemove;

  /// Function called when completed recommended amount editing.
  final Function()? onConfirm;

  /// If inventory is for seeing/editing the recommended stock.
  final bool isRecommended;

  /// Controllers used for TextFields in recommended tiles.
  late List<TextEditingController> _controllers = [];

  final Location _location = Location();

  final ApiService apiService = ApiService.getInstance();

  @override
  Widget build(BuildContext context) {
    apiService.setContext(context);
    _controllers = List.generate(items.length, (i) => TextEditingController());
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        _controllers[index] = (TextEditingController(text: items[index].stock.toString()));
        if (index == items.length - 1) {
          return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 55),
              child: getListTile(context, index));
        }
        return getListTile(context, index);
      },
/*     separatorBuilder: (BuildContext context, int index) =>
          Divider(color: Theme.of(context).colorScheme.primary),*/
    );
  }

  /// Returns the correct ListTile depending on whether it is for the recommended inventory or not.
  ListTile getListTile(BuildContext context, int index) {
    bool tablet =
        (getDeviceType(MediaQuery.of(context)) == DeviceScreenType.Tablet);
    if (isRecommended) {
      if (_controllers[index].text.isNotEmpty) {
        _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length));
      }

      return ListTile(
          contentPadding: tablet
              ? const EdgeInsets.fromLTRB(8, 20, 8, 20)
              : const EdgeInsets.fromLTRB(8, 8, 8, 8),
          title: Text(
            items[index].productName,
            style: Theme.of(context).textTheme.headline5,
            overflow: TextOverflow.clip,
          ),
          trailing: SizedBox(
              width: 160.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                        constraints:
                            const BoxConstraints.expand(width: 96, height: 48),
                        child: TextField(
                          controller: _controllers[index],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10)
                          ],
                          onChanged: (text) => {
                            if (_controllers[index].text.isNotEmpty)
                              {
                                items[index].stock =
                                    int.parse(_controllers[index].text),
                                FocusManager.instance.primaryFocus?.unfocus()

                              },
                          },
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              constraints:
                              const BoxConstraints(maxWidth: 200),
                              contentPadding: const EdgeInsets.only(
                                  left: 0, bottom: 0, top: 0, right: 0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      width: 4.0))),
                          style: Theme.of(context).textTheme.headline5,
                        ),),
                  ),
                  // IconButton(onPressed: () => onConfirm, icon: const Icon(Icons.check, size: 32.0)),
                ],
              )));
    } else {
      return ListTile(
          contentPadding: tablet
              ? const EdgeInsets.fromLTRB(8, 20, 8, 20)
              : const EdgeInsets.fromLTRB(8, 8, 8, 8),
          title: InkWell(
              child: Text(
                items[index].productName,
                style: Theme.of(context).textTheme.headline5,
                overflow: TextOverflow.clip,
              ),
              onDoubleTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => (MapView(
                                  itemToShow: items[index].productName,
                                ))))
                  }),
          trailing: SizedBox(
              width: 160.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () => _onRemove(context, items[index]),
                      icon: const Icon(Icons.remove, size: 36.0)),
                  Text(
                    items[index].stock.toString(),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  IconButton(
                      onPressed: () => _onAdd(context, items[index]),
                      icon: const Icon(Icons.add, size: 36.0)),
                ],
              )));
    }
  }

  /// Creates a dialog to get amount to add, then handles adding the requested amount.
  void _onAdd(BuildContext context, Item item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddRemoveItemDialog(item: item, isAdd: true);
        }).then((amount) async => {
          if (amount is int)
            {
              item.stock = item.stock + amount,
              await updateStock(item.productNumber, amount, context),
            }
        });
  }

  /// Creates a dialog to get amount to remove, then handles removing the requested amount.
  void _onRemove(BuildContext context, Item item) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddRemoveItemDialog(item: item, isAdd: false);
        }).then((amount) async => {
          if (amount is int)
            {
              if (item.stock - amount >= 0)
                {
                  item.stock = item.stock - amount,
                  await updateStock(item.productNumber, -amount, context)
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.wrongQuantity)))
                }
            }
        });
  }

  /// Update the stock on the specified product.
  /// Uses product number, username, location of the device and the decrease or increase amount
  /// Makes call to apiService to update the api
  Future<void> updateStock(
      String? itemNumber, int amount, BuildContext context) async {
    var currentLocation = await _location.getLocation();
    var latitude = currentLocation.latitude!;
    var longitude = currentLocation.longitude!;
    var username = await apiService.storage.read(key: "username");
    await apiService.updateStock(
        itemNumber!, username!, amount, latitude, longitude);
    onConfirm!();
  }
}
