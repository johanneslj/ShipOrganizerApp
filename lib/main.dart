import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ship_organizer_app/views/MyAccount/myaccount_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ship_organizer_app/views/administer_users/administer_users_view.dart';
import 'package:ship_organizer_app/views/create_user/create_user_view.dart';
import 'package:ship_organizer_app/views/inventory/inventory_view.dart';
import 'package:ship_organizer_app/views/login/login_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/views/map/map_view.dart';
import 'package:ship_organizer_app/views/select_department/select_department_view.dart';
import 'package:ship_organizer_app/views/set_password/set_password_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'config/theme_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale("en", "US"), Locale("nb", "NO")],
      localeListResolutionCallback: (locales, supportedLocales) {
        for (Locale locale in locales!) {
          // if device language is supported by the app,
          // return it to set it as current app language
          if (supportedLocales.contains(locale)) {
            return locale;
          }
        }
        // If no device language is supported by the app,
        // Return Norwegian bokmål as the default language in the app
        return const Locale("nb", "NO");
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      title: 'Ship Organizer',
      theme: theme,
      routes: {
        '/': (BuildContext context) => const MyHomePage(title: 'Home'),
        '/selectDepartmemnt': (context) => SelectDepartmentView(),
        '/changePassword': (context) => const SetPasswordView(),
        '/createUser': (context) => const CreateUser(),
        '/inventoryList': (context) => const InventoryView(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.title),
            Text(AppLocalizations.of(context)!.helloWorld),
            const Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Text("Views that are under \n under progress or done:")),
            TextButton(
              child: const Text("Login view"),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (const LoginView()) //ForgotPasswordPage())),
                        ))
              },
            ),
            TextButton(
              child: const Text("Select department"),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (SelectDepartmentView()) //ForgotPasswordPage())),
                        ))
              },
            ),
            TextButton(
              child: const Text("Set new password"),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (const SetPasswordView()) //ForgotPasswordPage())),
                        ))
              },
            ),
            TextButton(
              child: const Text("Add User"),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (const CreateUser()) //ForgotPasswordPage())),
                        ))
              },
            ),
            TextButton(
              child: const Text("Inventory"),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (const InventoryView()) //ForgotPasswordPage())),
                        ))
              },
            ),
            TextButton(
              child: const Text("Map"),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => (MapView()) //ForgotPasswordPage())),
                        ))
              },
            ),
            TextButton(
              child: Text("MyAccount"),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => (MyAccount()) //ForgotPasswordPage())),
                        ))
              },
            ),
            TextButton(
              child: Text("AdministerUsers"),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => (AdministerUsersView()) //ForgotPasswordPage())),
                        ))
              },
            ),
          ],
        ),
      ),
    );
  }
}
