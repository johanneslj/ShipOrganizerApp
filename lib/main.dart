import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ship_organizer_app/views/add_new_item/add_new_item_view.dart';
import 'package:ship_organizer_app/views/map/map_view.dart';
import 'package:ship_organizer_app/views/inventory/recommended_inventory_view.dart';
import 'package:ship_organizer_app/views/my_account/myaccount_view.dart';
import 'package:ship_organizer_app/views/administer_users/administer_users_view.dart';
import 'package:ship_organizer_app/views/create_user/create_user_view.dart';
import 'package:ship_organizer_app/views/inventory/inventory_view.dart';
import 'package:ship_organizer_app/views/select_department/select_department_view.dart';
import 'package:ship_organizer_app/views/send_bill/send_bill_view.dart';
import 'package:ship_organizer_app/views/set_password/set_password_view.dart';
import 'package:ship_organizer_app/widgets/bottom_navigation_bar_widget.dart';
import 'package:ship_organizer_app/widgets/bottom_navigation_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'config/theme_config.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale("en"), Locale("nb", "NO")],
      localeListResolutionCallback: (locales, supportedLocales) {
        for (Locale locale in locales!) {
          // if device language is supported by the app,
          // return it to set it as current app language
          if (locale.languageCode.contains("en") || locale.languageCode.contains("nb")) {
            return locale;
          }
        }
        // If no device language is supported by the app,
        // Return Norwegian bokmål as the default language in the app
        return const Locale('nb', 'NO');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Ship Organizer',
      theme: theme,
      routes: {
        '/': (BuildContext context) => const MyHomePage(
              title: 'Home',
            ),
        '/selectDepartment': (context) => SelectDepartmentView(),
        '/changePassword': (context) => const SetPasswordView(),
        '/createUser': (context) => const CreateUser(),
        '/inventoryList': (context) => const InventoryView(),
        '/administerUsers': (context) => const AdministerUsersView(),
        '/sendBill': (context) => const SendBill(),
        '/inventory': (context) => const InventoryView(),
        '/recommendedInventory': (context) => const RecommendedInventoryView(),
        '/map': (context) => const MapView(),
        '/newProduct': (context) => const NewItem(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _getViewContainer(int index) {
    List<Widget> mainViewsList = [const InventoryView(), const MyAccount()];

    return mainViewsList[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, watch, child) {
          final _indexState = watch(bottomNavigationBarIndexProvider);
          return Container(
            child: _getViewContainer(_indexState),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }
}
