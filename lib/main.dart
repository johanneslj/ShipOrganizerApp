import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/api_handling/api_controller.dart';
import 'package:ship_organizer_app/offline_queue/offline_enqueue_service.dart';
import 'package:ship_organizer_app/views/add_new_item/add_new_item_view.dart';
import 'package:ship_organizer_app/views/login/login_view.dart';
import 'package:ship_organizer_app/views/map/map_view.dart';
import 'package:ship_organizer_app/views/inventory/recommended_inventory_view.dart';
import 'package:ship_organizer_app/views/my_account/myaccount_view.dart';
import 'package:ship_organizer_app/views/administer_users/administer_items_view.dart';
import 'package:ship_organizer_app/views/create_user/create_user_view.dart';
import 'package:ship_organizer_app/views/inventory/inventory_view.dart';
import 'package:ship_organizer_app/views/select_department/select_department_view.dart';
import 'package:ship_organizer_app/views/send_bill/send_bill_view.dart';
import 'package:ship_organizer_app/views/set_password/set_password_view.dart';
import 'package:ship_organizer_app/widgets/bottom_navigation_bar_widget.dart';
import 'package:ship_organizer_app/widgets/bottom_navigation_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity/connectivity.dart';

import 'config/device_screen_type.dart';
import 'config/theme_config.dart';
import 'config/ui_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService apiService = ApiService(null);
  bool isLoggedIn = await apiService.isTokenValid();

  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? selectedLanguage = await storage.read(key: "selectedLanguage");

  Locale selectedLocale = const Locale("No Locale");
  if (selectedLanguage != null && selectedLanguage.isNotEmpty) {
    selectedLocale = Locale(selectedLanguage);
  }
  return runApp(ProviderScope(
      child: MainApp(
    isLoggedIn: isLoggedIn,
    selectedLanguage: selectedLocale,
  )));
}

class MainApp extends StatefulWidget {
  MainApp({
    Key? key,
    required this.isLoggedIn,
    this.selectedLanguage,
  }) : super(key: key);
  final bool isLoggedIn;
  Locale? selectedLanguage;

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MainAppState state = context.findAncestorStateOfType<_MainAppState>()!;
    state.changeLanguage(newLocale);
  }

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale? selectedLanguage;

  changeLanguage(Locale locale) {
    setState(() {
      selectedLanguage = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedLanguage == null) {
      changeLanguage(widget.selectedLanguage!);
    }

    // Try to execute queue when connectivity status changes.
    Connectivity().onConnectivityChanged.listen((event) {
      OfflineEnqueueService().startService();
    });

    ApiService apiService = ApiService(context);
    apiService.setContext(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale("en"), Locale("nb")],
      locale: selectedLanguage,
      localeListResolutionCallback: (locales, supportedLocales) {
        // Checks if a language preference has been set whilst using the app
        if (selectedLanguage != null &&
            selectedLanguage?.languageCode != "" &&
            selectedLanguage?.languageCode != null &&
            selectedLanguage?.languageCode != "No Locale") {
          return selectedLanguage;
        }
        // If no language preference has been set the app turns
        for (Locale locale in locales!) {
          // if device language is supported by the app,
          // return it to set it as current app language
          if (locale.languageCode.contains("en") ||
              locale.languageCode.contains("nb")) {
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
      initialRoute: widget.isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LoginView(),
        '/selectDepartment': (context) => SelectDepartmentView(
              isInitial: false,
            ),
        '/selectInitialDepartment': (context) => SelectDepartmentView(
              isInitial: true,
            ),
        '/changePassword': (context) => const SetPasswordView(),
        '/createUser': (context) => const CreateUser(isCreateUser: true),
        '/inventoryList': (context) => const InventoryView(),
        '/administerUsers': (context) =>
            const AdministerUsersView(isAdministeringUsers: true),
        '/administerProducts': (context) =>
            const AdministerUsersView(isAdministeringUsers: false),
        '/sendBill': (context) => const SendBill(),
        '/inventory': (context) => const InventoryView(),
        '/recommendedInventory': (context) => const RecommendedInventoryView(),
        '/map': (context) => const MapView(),
        '/newProduct': (context) => const NewItem(isCreateNew: true),
        '/home': (context) => const MyHomePage(title: 'Home'),
      },
    );
  }

  /// Method to update the app language
  void setLanguage() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? language = await storage.read(key: "selectedLanguage");
    selectedLanguage = Locale(language!);
    setState(() {});
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
    if (getDeviceType(MediaQuery.of(context)) == DeviceScreenType.Mobile) {
      _portraitModeOnly();
    }
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

  /// Sets the orientation to not allow portrait
  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
