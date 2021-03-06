import 'package:flutter/material.dart';
import 'package:ship_organizer_app/api_handling/api_controller.dart';
import 'package:ship_organizer_app/widgets/department_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The view which is presented when selecting department
/// The view is made up of several cards, one for each department the user can access
/// In this view the user can choose which department's inventory and
/// bills they want to view
class SelectDepartmentView extends StatefulWidget {
  bool? isInitial = false;

  SelectDepartmentView({Key? key, this.isInitial}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectDepartmentView();
}

class _SelectDepartmentView extends State<SelectDepartmentView> {
  late ApiService apiService = ApiService.getInstance();
  late List<Widget> departments = [];

  @override
  initState() {
    getDepartments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    apiService.setContext(context);
    return Scaffold(
      appBar: (widget.isInitial!)
          ? AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text(
                AppLocalizations.of(context)!.selectDepartment,
                style: Theme.of(context).textTheme.headline6,
              ),
            )
          : AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                AppLocalizations.of(context)!.changeDepartment,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
      body: SingleChildScrollView(
          child: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
                AppLocalizations.of(context)!.accessToMultipleDepartments,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1),
          ),
          SingleChildScrollView(
            child: Column(
              children: departments,
            ),
          ),
        ]),
      )),
    );
  }

  /// Uses a list of Strings to create a card for each
  /// Pressing the created card pushes the user to the inventory view
  Future<void> getDepartments() async {
    List<Widget> departmentCardList = <Widget>[];
    List<String> departmentList = await apiService.getDepartments();
    for (String department in departmentList) {
      Widget departmentCard = DepartmentCard(
        departmentName: department,
        destination: "/home",
        arguments: "department",
      );
      departmentCardList.add(departmentCard);
    }
    await apiService.storage.write(key: "items", value: "");
    setState(() {
      departments = departmentCardList;
    });
  }
}
