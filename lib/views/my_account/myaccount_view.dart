import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/config/device_screen_type.dart';
import 'package:ship_organizer_app/config/ui_utils.dart';
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
  bool hasMultipleDepartments = false;

  @override
  void initState() {
    dataLoadFunction();
    super.initState();
  }

  dataLoadFunction() async {
    setState(() {
      _isLoading = true;
    });
    List<String> departments = await apiService.getDepartments();
    if (departments.length > 1) {
      hasMultipleDepartments = true;
    }
    await getUserRights();
    await getUserFullName();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    bool mobile =
        (getDeviceType(MediaQuery.of(context)) == DeviceScreenType.Mobile);
    int tabletCrossAxisCount = getCrossAxisCount(context);
    return Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton(
                icon: Icon(Icons.language_sharp,
                    color: Theme.of(context).colorScheme.onPrimary),
                iconSize: 35,
                itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => {
                          if (storage.read(key: "selectedLanguage") != null)
                            {
                              storage.delete(key: "selectedLanguage"),
                              storage.write(
                                  key: "selectedLanguage", value: "nb"),
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
                              storage.write(
                                  key: "selectedLanguage", value: "en"),
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
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 60, bottom: 10),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Text(fullName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                  mobile
                      ? Expanded(
                          child: Column(children: getMenuItems(admin, context)),
                        )
                      : Expanded(
                          child: GridView.count(
                            crossAxisCount: tabletCrossAxisCount,
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                            padding: const EdgeInsets.all(2.0),
                            children: getGridTiles(admin, context),
                          ),
                        )
                ]),
              )));
  }

  /// Gets the right menu items base on admin rights
  /// Reuses DepartmentCard for display
  List<Widget> getMenuItems(bool admin, BuildContext context) {
    List<Widget> departmentCardList = <Widget>[];
    if (hasMultipleDepartments) {
      departmentCardList.add(DepartmentCard(
        departmentName: AppLocalizations.of(context)!.changeDepartment,
        destination: "/selectDepartment",
        arguments: "false",
      ));
    }
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

  /// Gets the right menu items base on admin rights
  /// Creates Gridview tiles for display
  List<Widget> getGridTiles(bool admin, BuildContext context) {
    List<Widget> departmentCardList = <Widget>[];
    departmentCardList.add(gridTileWidget(
        "/selectDepartment", AppLocalizations.of(context)!.changeDepartment));
    departmentCardList.add(gridTileWidget(
        "/changePassword", AppLocalizations.of(context)!.changePassword));
    departmentCardList.add(gridTileWidget("/recommendedInventory",
        AppLocalizations.of(context)!.preferredInventory));
    departmentCardList
        .add(gridTileWidget("/sendBill", AppLocalizations.of(context)!.billing));
    if (admin) {
      departmentCardList.add(gridTileWidget(
          "/createUser", AppLocalizations.of(context)!.registerNewUser));
      departmentCardList.add(gridTileWidget(
          "/administerUsers", AppLocalizations.of(context)!.administerUsers));
      departmentCardList.add(gridTileWidget("/administerProducts",
          AppLocalizations.of(context)!.administerProducts));
    }
    return departmentCardList;
  }

  /// Custom Gridview tile
  Widget gridTileWidget(route, routeName) {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.onPrimary,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5.0,
                  )
                ]),
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(child: Text(routeName)
                ))));
  }

  /// Checks if device is in landscape or portrait mode
  /// to see if grid should have crossAxisCount 4 or 3
  int getCrossAxisCount(context) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return 4;
    } else {
      return 3;
    }
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
