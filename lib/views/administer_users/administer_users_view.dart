import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdministerUsersView extends StatefulWidget {
  AdministerUsersView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdministerUsersViewState();
}

class _AdministerUsersViewState extends State<AdministerUsersView> {
  //TODO get users from backend
  List<String> users = ["Hans Hansen, hans@hansen.no", "Jon Jonsen, jon@jonsen.no"];

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
                    horizontalInside:
                        BorderSide(width: 1, style: BorderStyle.solid)),
                columnWidths: const <int, TableColumnWidth>{
                  0: FlexColumnWidth(),
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

  List<TableRow> createUserRow() {
    List<TableRow> userRows = [];
    userRows.add(
      TableRow(
        children: [Text(AppLocalizations.of(context)!.name), Text(AppLocalizations.of(context)!.email), Text("")],
      ),
    );

    for (String user in users) {
      List<String> details = user.split(",");
      userRows.add(TableRow(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: Text(details[0]),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: Text(details[1]),
          ),
          TextButton(onPressed: () => {

          }, child: Text(AppLocalizations.of(context)!.delete))
        ],
      ));
    }

    return userRows;
  }


  void showConfirmationDialog() {



  }
}
