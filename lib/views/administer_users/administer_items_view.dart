import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api_handling/api_controller.dart';
import 'package:ship_organizer_app/config/device_screen_type.dart';
import 'package:ship_organizer_app/config/ui_utils.dart';
import 'package:ship_organizer_app/entities/user.dart';
import 'package:ship_organizer_app/views/add_new_item/add_new_item_view.dart';
import 'package:ship_organizer_app/views/create_user/create_user_view.dart';
import 'package:ship_organizer_app/entities/item.dart';

/// This is the view for administering users
///
/// Here an admin is able to browse through all users,
/// and delete any given user
class AdministerUsersView extends StatefulWidget {
  final bool isAdministeringUsers;

  const AdministerUsersView({Key? key, required this.isAdministeringUsers})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdministerUsersViewState();
}

class _AdministerUsersViewState extends State<AdministerUsersView> {
  final ApiService _apiService = ApiService.getInstance();
  bool _isLoading = false;
  List<TableRow> tableRows = [];

  @override
  Widget build(BuildContext context) {
    setState(() {});
    bool mobile =
        (getDeviceType(MediaQuery.of(context)) == DeviceScreenType.Mobile);
    _apiService.setContext(context);
    if (tableRows.isEmpty) {
      createUserRow(mobile);
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pushNamed("/home"),
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Column(
                  children: [
                    Table(
                        border: const TableBorder(
                            horizontalInside: BorderSide(
                                width: 0.2, style: BorderStyle.solid)),
                        columnWidths: widget.isAdministeringUsers
                            ? const <int, TableColumnWidth>{
                                0: FlexColumnWidth(0.4),
                                1: FlexColumnWidth(),
                                2: FixedColumnWidth(75),
                              }
                            : const <int, TableColumnWidth>{
                                0: FlexColumnWidth(1.05),
                                1: FlexColumnWidth(),
                                2: FixedColumnWidth(75),
                              },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: tableRows),
                  ],
                ),
              ),
            ),
    );
  }

  /// creates an additional row in the table for each user
  Future<void> createUserRow(bool mobile) async {
    setState(() {
      _isLoading = true;
    });
    List<TableRow> rows = [];
    rows.add(
      widget.isAdministeringUsers
          ? TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(AppLocalizations.of(context)!.name),
                ),
                Text(AppLocalizations.of(context)!.email),
                const Text("")
              ],
            )
          : TableRow(
              children: [
                !mobile
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(10, 15, 0, 15),
                        child: Text(AppLocalizations.of(context)!.productName))
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(AppLocalizations.of(context)!.productName)),
                !mobile
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child:
                            Text(AppLocalizations.of(context)!.productNumber))
                    : Text(AppLocalizations.of(context)!.productNumber),
                const Text("")
              ],
            ),
    );
    if (widget.isAdministeringUsers) {
      List<User> users = await _apiService.getAllUsers();
      for (User user in users) {
        int i = users.indexOf(user);
        rows.add(TableRow(
          decoration: i % 2 == 0
              ? BoxDecoration(color: Colors.grey[100])
              : const BoxDecoration(color: Colors.white),
          children: [
            !mobile
                ? Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                        user.getName(),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      user.getName(),
                      style: Theme.of(context).textTheme.caption,
                    )),
            !mobile
                ? Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Text(
                      user.getName(),
                      style: Theme.of(context).textTheme.bodyText2,
                    ))
                : Text(
                    user.getEmail(),
                    style: Theme.of(context).textTheme.caption,
                  ),
            TextButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateUser(
                                isCreateUser: false, userToEdit: user)),
                      )
                    },
                child: Text(AppLocalizations.of(context)!.edit))
          ],
        ));
      }
    } else {
      List<Item> items =
          await _apiService.getItems(await _apiService.getActiveDepartment());
      for (Item item in items) {
        int i = items.indexOf(item);
        rows.add(TableRow(
          decoration: i % 2 == 0
              ? BoxDecoration(color: Colors.grey[100])
              : const BoxDecoration(color: Colors.white),
          children: [
            !mobile
                ? Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                          item.productName,
                          style: Theme.of(context).textTheme.bodyText2,
                        )))
                : Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      item.productName,
                      style: Theme.of(context).textTheme.caption,
                    )),
            !mobile
                ? Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Text(
                      item.productNumber!,
                      style: Theme.of(context).textTheme.bodyText2,
                    ))
                : Text(
                    item.productNumber!,
                    style: Theme.of(context).textTheme.caption,
                  ),
            TextButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NewItem(isCreateNew: false, itemToEdit: item)),
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
