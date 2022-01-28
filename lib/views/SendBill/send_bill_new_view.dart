import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Class for the new bill tab in the send_bill_view
/// This class is responsible for the creation of a new bill for
/// confirmation. The class uses dropdownmenu and imageuploader
class newBill extends StatefulWidget {
  const newBill({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _newBill();
}

class _newBill extends State<newBill> {
  final List<String> departments = <String>["Bridge", "Factory", "Deck"];
  String selectedValue = "Bridge";
  bool admin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const Text("Select a department"),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField(
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1),
                  ),
                ),
                validator: (value) =>
                    value == null ? "Select a Department" : null,
                dropdownColor: Theme.of(context).colorScheme.background,
                value: selectedValue,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
                items: dropdownItems),
          ],
        ),
        ElevatedButton(
            child: Text(
              "Upload image",
              style: Theme.of(context).textTheme.headline6,
            ),
            onPressed: () => {})
      ],
    ));
  }

  ///Creates the menu items based on the department list
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = <DropdownMenuItem<String>>[];
    for (String department in departments) {
      DropdownMenuItem<String> departmentCard = DropdownMenuItem(
        child: Text(department),
        value: department,
      );
      menuItems.add(departmentCard);
    }
    return menuItems;
  }
}
