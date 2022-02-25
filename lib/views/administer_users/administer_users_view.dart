import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/entities/user.dart';
import 'package:ship_organizer_app/views/create_user/create_user_view.dart';

/// This is the view for administering users
///
/// Here an admin is able to browse through all users,
/// and delete any given user
class AdministerUsersView extends StatefulWidget {
  const AdministerUsersView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdministerUsersViewState();
}

class _AdministerUsersViewState extends State<AdministerUsersView> {
  final ApiService _apiService = ApiService();
  List<TableRow> userRows = [];

  @override
  Widget build(BuildContext context) {
    if (userRows.isEmpty) {
      createUserRow();
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.administerUsers,
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
                  children: userRows),
            )
          ],
        ),
      ),
    );
  }

  /// creates an additional row in the table for each user
  Future<void> createUserRow() async {
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
    List<User> users = await _apiService.getAllUsers();
    for (User user in users) {
      userRows.add(TableRow(
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
                          builder: (context) => CreateUser(isCreateUser: false, userToEdit: user)),
                    )
                  },
              child: Text(AppLocalizations.of(context)!.edit))
        ],
      ));
    }

    setState(() {
      this.userRows = userRows;
    });
  }

  /// Shows a confirmation dialog for deleting a user
  AlertDialog showConfirmationDialog(String personToDelete) {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.cancel),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context)!.delete),
      onPressed: () {
        //TODO make this delete user from server
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.deleteUser),
      content: Text(AppLocalizations.of(context)!.deleteConfirmationDialog + personToDelete),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    return alert;
  }
}
