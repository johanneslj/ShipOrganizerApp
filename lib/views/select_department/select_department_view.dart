import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/select_department/department_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


/// The view which is presented when selecting department
/// The view is made up of several cards, one for each department the user can access
/// In this view the user can choose which department's inventory and
/// bills they want to view
class SelectDepartmentView extends StatelessWidget {
  SelectDepartmentView({
    Key? key,
  }) : super(key: key);

  //TODO get departments from backend
  final List<String> departments = <String>["Bridge", "Factory", "Deck"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.of(context)!.changeDepartment, style: Theme.of(context).textTheme.headline6,),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(AppLocalizations.of(context)!.accessToMultipleDepartments,
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1),
          ),
          Expanded(
            child: Column(
              children: getDepartments(departments),
            ),
          ),
        ]),
      )),
    );
  }

  /// Uses a list of Strings to create a card for each
  /// Pressing the created card pushes the user to the inventory view
  List<Widget> getDepartments(List<String> departments) {
    List<Widget> departmentCardList = <Widget>[];

    for (String department in departments) {
      Widget departmentCard = DepartmentCard(
        departmentName: department,
        destination: "/",
      );
      departmentCardList.add(departmentCard);
    }

    return departmentCardList;
  }
}
