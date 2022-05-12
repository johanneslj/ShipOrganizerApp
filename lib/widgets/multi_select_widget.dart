import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A widget which can be used to select multiple items from a list
/// When submit is pressed the selected items are returned and can be used
/// for whatever purpose necessary
class MultiSelect extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;

  const MultiSelect({Key? key, required this.items, required this.selectedItems}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  //holds the selected items
  List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  /// called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

  /// called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    _selectedItems = widget.selectedItems;
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      title: Text(
        AppLocalizations.of(context)!.selectDepartment,
        style: Theme.of(context).textTheme.headline2,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => Theme(
                  data: ThemeData(unselectedWidgetColor: Theme.of(context).colorScheme.primary),
                  child: CheckboxListTile(
                    selected: _selectedItems.contains(item),
                    value: _selectedItems.contains(item),
                    activeColor: Theme.of(context).colorScheme.primary,
                    checkColor: Theme.of(context).colorScheme.onPrimary,
                    title: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  )))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: _cancel,
        ),
        ElevatedButton(
          child: const Text('Submit'),
          onPressed: _submit,
        ),
      ],
    );
  }
}
