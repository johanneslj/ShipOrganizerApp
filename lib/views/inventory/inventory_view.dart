import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/inventory/top_bar_widget.dart';

/// View where the user can see the inventory for their department.
///
///
class InventoryView extends StatefulWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InventoryViewState();
}

/// State of the inventory view.
class _InventoryViewState extends State<InventoryView> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size(
                MediaQuery.of(context).size.width, MediaQuery.of(context).viewPadding.top + 24.0),
            child: TopBar(
              onMenuPressed: _onMenuPressed,
              onSearch: _onSearch,
              controller: searchController,
            )),
        body: SingleChildScrollView());
  }

  Function() _onMenuPressed = () {
    // TODO Render side menu
  };

  Function() _onSearch = () {
    // TODO Handle search functionality
  };
}
