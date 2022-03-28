import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/entities/user.dart';
import 'package:ship_organizer_app/views/add_new_item/add_new_item_view.dart';
import 'package:ship_organizer_app/views/create_user/create_user_view.dart';
import 'package:ship_organizer_app/views/inventory/item.dart';

/// This is the view for administering users
///
/// Here an admin is able to browse through all users,
/// and delete any given user
class AdministerUsersView extends StatefulWidget {
  final bool isAdministeringUsers;

  const AdministerUsersView({Key? key, required this.isAdministeringUsers}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdministerUsersViewState();
}

class _AdministerUsersViewState extends State<AdministerUsersView> {
  final ApiService _apiService = ApiService.getInstance();
  bool _isLoading = false;
  List<TableRow> tableRows = [];

  @override
  Widget build(BuildContext context) {
    _apiService.setContext(context);
    if (tableRows.isEmpty) {
      createUserRow();
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isAdministeringUsers
              ? AppLocalizations.of(context)!.administerUsers
              : AppLocalizations.of(context)!.administerProducts,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: _isLoading
          ? circularProgress()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Table(
                        border: const TableBorder(
                            horizontalInside: BorderSide(width: 1, style: BorderStyle.solid)),
                        columnWidths: widget.isAdministeringUsers
                            ? const <int, TableColumnWidth>{
                                0: FlexColumnWidth(0.4),
                                1: FlexColumnWidth(),
                                2: FixedColumnWidth(65),
                              }
                            : const <int, TableColumnWidth>{
                                0: FlexColumnWidth(1.05),
                                1: FlexColumnWidth(),
                                2: FixedColumnWidth(65),
                              },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: tableRows),
                  )
                ],
              ),
            ),
    );
  }

  /// creates an additional row in the table for each user
  Future<void> createUserRow() async {
    setState(() {
      _isLoading = true;
    });
    List<TableRow> rows = [];
    rows.add(
      widget.isAdministeringUsers
          ? TableRow(
              children: [
                Text(AppLocalizations.of(context)!.name),
                Text(AppLocalizations.of(context)!.email),
                const Text("")
              ],
            )
          : TableRow(
              children: [
                Text(AppLocalizations.of(context)!.productName),
                Text(AppLocalizations.of(context)!.productNumber),
                const Text("")
              ],
            ),
    );
    if (widget.isAdministeringUsers) {
      List<User> users = await _apiService.getAllUsers();
      for (User user in users) {
        rows.add(TableRow(
          children: [
            Text(
              user.getName(),
              style: Theme.of(context).textTheme.caption,
            ),
            Text(
              user.getEmail(),
              style: Theme.of(context).textTheme.caption,
            ),
            TextButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CreateUser(isCreateUser: false, userToEdit: user)),
                      )
                    },
                child: Text(AppLocalizations.of(context)!.edit))
          ],
        ));
      }
    } else {
      List<Item> items = await _apiService.getAllItems();
      for (Item item in items) {
        rows.add(TableRow(
          children: [
            Text(
              item.productName,
              style: Theme.of(context).textTheme.caption,
            ),
            Text(
              item.productNumber!,
              style: Theme.of(context).textTheme.caption,
            ),
            TextButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewItem(isCreateNew: false, itemToEdit: item)),
                      )
                    },
                child: Text(AppLocalizations.of(context)!.edit))
          ],
        ));
      }
    }

    setState(() {
      _isLoading = false;
      tableRows = rows;
    });
  }

  /// Show a small loading circle on screen
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
