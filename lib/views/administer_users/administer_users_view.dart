import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This is the view for administering users
///
/// Here an admin is able to browse through all users,
/// and delete any given user
class AdministerUsersView extends StatefulWidget {
  AdministerUsersView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdministerUsersViewState();
}

class _AdministerUsersViewState extends State<AdministerUsersView> {
  //TODO get users from backend
  List<String> users = ["Hans Hansen, hanshansen@hansen.no", "Jon Jonsen, jon@jonsen.no"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.administerUser,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Table(
                border: const TableBorder(
                    horizontalInside: BorderSide(width: 1, style: BorderStyle.solid)),
                columnWidths: const <int, TableColumnWidth>{
                  0: FlexColumnWidth(0.4),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(64),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: createUserRow(),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// creates an additional row in the table for each user
  List<TableRow> createUserRow() {
    List<TableRow> userRows = [];
    userRows.add(
      TableRow(
        children: [
          Text(AppLocalizations.of(context)!.name),
          Text(AppLocalizations.of(context)!.email),
          const Text("")
        ],
      ),
    );

    for (String user in users) {
      List<String> details = user.split(",");
      userRows.add(TableRow(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: Text(
              details[0],
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: Text(
              details[1],
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          TextButton(
              onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return showConfirmationDialog();
                      },
                    )
                  },
              child: Text(AppLocalizations.of(context)!.delete))
        ],
      ));
    }

    return userRows;
  }

  /// Shows a confirmation dialog for deleting a user
  AlertDialog showConfirmationDialog() {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {},
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Would you like to continue learning how to use Flutter alerts?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    return alert;
  }
}
