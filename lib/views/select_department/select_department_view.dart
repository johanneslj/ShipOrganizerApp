import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/select_department/department_card.dart';
import '../../../main.dart';

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
      child: Column(children: [

        Column(
          children: getDepartments(departments),
        )
      ]),
    ));
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
