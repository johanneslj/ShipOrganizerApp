import 'package:flutter/material.dart';
import 'package:ship_organizer_app/services/api_service.dart';
import 'package:ship_organizer_app/views/select_department/department_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// My account class. Here the user has access to different actions for user management.
/// There is different menu options based on if the user has admin rights or not
class MyAccount extends StatefulWidget {

  const MyAccount({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _MyAccount();
  }

class _MyAccount extends State<MyAccount> {
  ApiService apiService = ApiService();
  late bool admin = false;
  @override
  void initState() {
    getUserRights();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.myAccount,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
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
      destination: "/selectDepartment",
    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.changePassword,
      destination: "/changePassword",
    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.preferredInventory,
      destination: "/recommendedInventory",
    ));
    if (admin) {
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.registerNewUser,
        destination: "/createUser",
      ));
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.sendBill,
        destination: "/sendBill",
      ));
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.administerUsers,
        destination: "/administerUsers",
      ));
    }
    return departmentCardList;
  }

  Future<void> getUserRights() async{
    String result = await apiService.getUserRights();
    if(result.contains("USER")){
      setState(() {
      admin = true;
    });}
  }

}
