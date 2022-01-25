

import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/inventory/top_bar_widget.dart';
import 'package:ship_organizer_app/views/select_department/department_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';

/// My account class. Here the user has access to different actions for user management.
/// There is different menu options based on if the user has admin rights or not
class MyAccount extends StatelessWidget {
  final bool admin = true;

  MyAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(
              MediaQuery.of(context).size.width, MediaQuery.of(context).viewPadding.top + 24.0),
          child: TopBar(
            onMenuPressed: _onMenuPressed,
          )),
      body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
            child: Column(
                children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text("Full Name",
                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1),
              ),
               Expanded(
                 child: Column(
                   children: getMenuItems(admin, context)
                 ),
              ),
            ]),
          )),
    );

    // TODO: implement build
    throw UnimplementedError();
  }
  Function() _onMenuPressed = () {
    // TODO Render side menu
  };
  /// Gets the right menu items base on admin rights
  List<Widget> getMenuItems(bool admin,BuildContext context) {
    List<Widget> departmentCardList = <Widget>[];
  
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.changeDepartment,
      nav: const MyApp(),
    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.changePassword,
      nav: const MyApp(),
    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.preferredInventory,
      nav: const MyApp(),
    ));
    if(admin){
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.registerNewUser,
        nav: const MyApp(),
      ));
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.sendBill,
        nav: const MyApp(),
      ));
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.administerUser,
        nav: const MyApp(),
      ));
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.changeDepartment,
        nav: const MyApp(),
      ));
    }
    return departmentCardList;
  }

}