import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/inventory/add_remove_item_dialog.dart';

import 'item.dart';

/// Widget that displays the input items as a ListView.
///
class Inventory extends StatelessWidget {
  Inventory({
    Key? key,
    this.onAdd,
    this.onRemove,
    this.items = const [],
    this.onConfirm,
    this.isRecommended = false,
  }) : super(key: key);

  final List<Item> items;
  final Function()? onAdd;
  final Function()? onRemove;
  final Function()? onConfirm;
  final bool isRecommended;

  final List<TextEditingController> _controllers = [];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        _controllers.add(TextEditingController(text: items[index].amount.toString()));
        return getListTile(context, index);
      },
      separatorBuilder: (BuildContext context, int index) =>
          Divider(color: Theme.of(context).colorScheme.primary),
    );
  }

  /// Creates a dialog to get amount to add, then handles adding the requested amount.
  void _onAdd(BuildContext context, Item item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddRemoveItemDialog(item: item, isAdd: true);
        }).then((amount) => {
          // TODO Implement with API. Add to call queue.
          if (amount is int) {item.amount += amount}
        });
  }

  /// Creates a dialog to get amount to remove, then handles removing the requested amount.
  void _onRemove(BuildContext context, Item item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddRemoveItemDialog(item: item, isAdd: false);
        }).then((amount) => {
          // TODO Implement with API. Add to call queue.
          if (amount is int) {item.amount -= amount}
        });
  }

  ListTile getListTile(BuildContext context, int index) {
    if (isRecommended) {
      return ListTile(
          contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          title: Text(
            items[index].name,
            style: Theme.of(context).textTheme.headline5,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: SizedBox(
              width: 160.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(width: 96),
                      child: TextField(
                        controller: _controllers[index],
                        onEditingComplete: () => {
                          // TODO Implement with API.
                          items[index].amount = int.parse(_controllers[index].text)
                        },
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                            constraints: const BoxConstraints(maxWidth: 200),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary,
                                    width: 4.0))),
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  )

                  // IconButton(onPressed: () => onConfirm, icon: const Icon(Icons.check, size: 32.0)),
                ],
              )));
    } else {
      return ListTile(
          contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                  IconButton(
                      onPressed: () => _onRemove(context, items[index]),
                      icon: const Icon(Icons.remove, size: 36.0)),
                  Text(
                    items[index].amount.toString(),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  IconButton(
                      onPressed: () => _onAdd(context, items[index]),
                      icon: const Icon(Icons.add, size: 36.0)),
                ],
              )));
    }
  }
}
