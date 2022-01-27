import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// This class represents the possibility to send and receive bills between the
/// departments
class Sendbill extends StatefulWidget {
  Sendbill({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _SendBill();
}

class _SendBill extends State<Sendbill> {
  final List<String> departments = <String>["Bridge", "Factory", "Deck"];
  String selectedValue = "Bridge";
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            tabs: [
              Tab(child: Text(AppLocalizations.of(context)!.newBill)),
              Tab(child: Text(AppLocalizations.of(context)!.confirmed)),
            ],
          ),
          title: Text(
            AppLocalizations.of(context)!.billing,
            style: Theme
                .of(context)
                .textTheme
                .headline6,
          ),
        ),
        body: TabBarView(
          children: [
        Column(
        children: [
          const Text("Select a department"),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Colors.blueAccent,
                  ),
                  validator: (value) => value == null ? "Select a Department" : null,
                  dropdownColor: Colors.blueAccent,
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
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6,
              ),
              onPressed: () => {})
          ],
        ),
        GridView.count(
          crossAxisCount: 2,
          children: List.generate(20, (index) {
            return Center(
                child: Text('Item $index'));
          }),
        ),
        ],
      ),
    ),);
    throw
    UnimplementedError
    (
    );
  }

  ///Creates the menu items based on the department list
  List<DropdownMenuItem<String>> get dropdownItems{
    List<DropdownMenuItem<String>> menuItems = <DropdownMenuItem<String>>[];
    for (String department in departments) {
      DropdownMenuItem<String> departmentCard = DropdownMenuItem(
        child: Text(department), value: department,
      );
      menuItems.add(departmentCard);
    }
    return menuItems;
  }


}
