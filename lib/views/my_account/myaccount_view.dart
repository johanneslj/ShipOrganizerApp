import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/views/select_department/department_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';

/// My account class. Here the user has access to different actions for user management.
/// There is different menu options based on if the user has admin rights or not
class MyAccount extends StatefulWidget {
  const MyAccount({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAccount();
}

class _MyAccount extends State<MyAccount> {
  ApiService apiService = ApiService.getInstance();

  late bool admin = false;
  late String fullName = "";
  bool _isLoading = false;

  @override
  void initState() {
    dataLoadFunction();
    super.initState();
  }

  dataLoadFunction() async {
    setState(() {
      _isLoading = true;
    });
    await getUserRights();
    await getUserFullName();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
              icon: Icon(Icons.language_sharp, color: Theme.of(context).colorScheme.onPrimary),
              iconSize: 35,
              itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => {
                        if (storage.read(key: "selectedLanguage") != null)
                          {
                            storage.delete(key: "selectedLanguage"),
                            storage.write(key: "selectedLanguage", value: "nb"),
                          },
                        MainApp.setLocale(context, Locale("nb")),
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/NorwegianLanguageFlag.png",
                            width: 30,
                          ),
                          Text(AppLocalizations.of(context)!.norwegian),
                        ],
                      ),
                      value: 1,
                    ),
                    PopupMenuItem(
                      onTap: () => {
                        if (storage.read(key: "selectedLanguage") != null)
                          {
                            storage.delete(key: "selectedLanguage"),
                            storage.write(key: "selectedLanguage", value: "en"),
                          },
                        MainApp.setLocale(context, Locale("en")),
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/EnglishLanguageFlag.png",
                            width: 30,
                          ),
                          Text(AppLocalizations.of(context)!.english),
                        ],
                      ),
                      value: 2,
                    )
                  ])
        ],
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.myAccount,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: _isLoading
          ? circularProgress()
          : Center(
              child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(fullName,
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1),
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
      arguments: "false",
    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.changePassword,
      destination: "/changePassword",
      arguments: "false",
    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.preferredInventory,
      destination: "/recommendedInventory",
      arguments: "false",
    ));
    departmentCardList.add(DepartmentCard(
      departmentName: AppLocalizations.of(context)!.billing,
      destination: "/sendBill",
      arguments: admin.toString(),
    ));
    if (admin) {
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.registerNewUser,
        destination: "/createUser",
        arguments: "false",
      ));
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.administerUsers,
        destination: "/administerUsers",
        arguments: "false",
      ));

      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.administerProducts,
        destination: "/administerProducts",
        arguments: "false",
      ));
    }
    return departmentCardList;
  }

  /// Gets Users rights from api service
  Future<void> getUserRights() async {
    String? result = await apiService.storage.read(key: "userRights");
    if (result!.contains("ADMIN")) {
      setState(() {
        admin = true;
      });
    }
  }

  /// Gets Users full name from api service
  Future<void> getUserFullName() async {
    String? result = await apiService.storage.read(key: "name");
    setState(() {
      fullName = result!;
    });
  }

  /// Creates a container with a CircularProgressIndicator
  Container circularProgress() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10.0),
      child: const CircularProgressIndicator(
        strokeWidth: 2.0,
      ),
    );
  }
}
