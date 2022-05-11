import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../entities/item.dart';

/// Dialog window used for confirming addition or removal of components in inventory view.
class AddRemoveItemDialog extends Dialog {
  AddRemoveItemDialog({Key? key, required this.item, required this.isAdd, this.onSubmit})
      : super(key: key);

  /// Item to add or remove amount.
  final Item item;

  /// True when adding item, false when removing item.
  final bool isAdd;

  /// Called when submitting
  final Function()? onSubmit;

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.howMany +
                item.productName +
                (isAdd
                    ? AppLocalizations.of(context)!.toAdd
                    : AppLocalizations.of(context)!.toRemove),
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                keyboardType: TextInputType.number,
                showCursor: true,
                controller: _controller,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 24.0))),
              TextButton(
                  onPressed: () => Navigator.pop(context, int.parse(_controller.text)),
                  child: Text(
                    AppLocalizations.of(context)!.confirm,
                    style: const TextStyle(color: Color(0xff7FE01A), fontSize: 24.0),
                  ))
            ],
          )
        ],
      ),
    ));
  }
}
