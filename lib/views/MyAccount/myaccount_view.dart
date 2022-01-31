import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/select_department/department_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


/// My account class. Here the user has access to different actions for user management.
/// There is different menu options based on if the user has admin rights or not
class MyAccount extends StatelessWidget {
  final bool admin = true;

  const MyAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.myAccount,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Center(
          child: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text("Full Name", // TODO: Get from user
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1),
          ),
          Expanded(
            child: Column(children: getMenuItems(admin, context)),
          ),
        ]),
      )),
    );
  }

  /// Gets the right menu items base on admin rights
  List<Widget> getMenuItems(bool admin, BuildContext context) {
    List<Widget> departmentCardList = <Widget>[];
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.changeDepartment,
      destination: "/selectDepartmemnt",
    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.changePassword,
      destination: "/changePassword",
    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.preferredInventory,
      destination: "/selectDepartmemnt",

    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.billing,
      destination: "/sendBill",
    ));
    if (admin) {
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.registerNewUser,
        destination: "/createUser",
      ));

      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.administerUser,
        destination: "/selectDepartmemnt",
      ));
    }
    return departmentCardList;
  }
}
