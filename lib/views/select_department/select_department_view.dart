import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/select_department/department_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectDepartmentView extends StatelessWidget {
  SelectDepartmentView({
    Key? key,
  }) : super(key: key);

  final List<String> departments = <String>["Bridge", "Factory", "Deck"];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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

  List<Widget> getDepartments(List<String> departments) {
    List<Widget> departmentCardList = <Widget>[];

    for (String department in departments) {
      Widget departmentCard = DepartmentCard(
        departmentName: department,
        destination: "/inventoryList",
      );
      departmentCardList.add(departmentCard);
    }

    return departmentCardList;
  }
}
