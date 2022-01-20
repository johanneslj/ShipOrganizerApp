import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/select_department/department_card.dart';
import '../../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectDepartmentView extends StatelessWidget {
  SelectDepartmentView({
    Key? key,
  }) : super(key: key);

  final List<String> departments = <String>["heia", "Kult", "Sjallabis"];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
        child: Column(children: [
          Text(AppLocalizations.of(context)!.accessToMultipleDepartments, textAlign: TextAlign.center,),
          Column(
            children: getDepartments(departments),
          )
        ]),
      )),
    );
  }

  List<Widget> getDepartments(List<String> departments) {
    List<Widget> departmentCardList = <Widget>[];

    for (String department in departments) {
      Widget departmentCard = DepartmentCard(
        departmentName: department,
      );
      departmentCardList.add(departmentCard);
    }

    return departmentCardList;
  }
}