import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/login/login_view.dart';
import 'package:ship_organizer_app/views/select_department/select_department_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

/*----------------------
Theme configurations:
 ----------------------*/
ThemeData theme = ThemeData(
  primaryColor: const Color(0xff13293d),
  colorScheme: colorScheme,
  scaffoldBackgroundColor: const Color(0xffe8f1f2),
  appBarTheme: appBarTheme,
  buttonTheme: buttonThemeData,
  textTheme: textTheme,
);

ColorScheme colorScheme = const ColorScheme(
    primary: Color(0xff13293d),
    primaryVariant: Color(0xff006494),
    secondary: Color(0xff1b98e0),
    secondaryVariant: Color(0xffe8f1f2),
    surface: Color(0xffe8f1f2),
    background: Color(0xffe8f1f2),
    error: Color(0xffe01a1a),
    onPrimary: Color(0xffe8f1f2),
    onSecondary: Color(0xffe8f1f2),
    onSurface: Color(0xff13293d),
    onBackground: Color(0xff13293d),
    onError: Color(0xfff2e8e8),
    brightness: Brightness.dark);

TextTheme textTheme = const TextTheme(
  headline1: TextStyle(color: Color(0xff13293d)),
  headline2: TextStyle(color: Color(0xff13293d)),
  headline3: TextStyle(color: Color(0xff13293d)),
  headline4: TextStyle(color: Color(0xff13293d)),
  headline5: TextStyle(color: Color(0xff13293d)),
  headline6: TextStyle(color: Color(0xffe8f1f2)),
  subtitle1: TextStyle(color: Color(0xff13293d)),
  subtitle2: TextStyle(color: Color(0xff13293d)),
  bodyText1: TextStyle(color: Color(0xff13293d)),
  bodyText2: TextStyle(color: Color(0xff13293d)),
  caption: TextStyle(color: Color(0xff13293d)),
  button: TextStyle(color: Color(0xffe8f1f2)),
  overline: TextStyle(color: Color(0xff13293d)),
);

AppBarTheme appBarTheme = const AppBarTheme(
  color: Color(0xff13293d),
  titleTextStyle: TextStyle(color: Color(0xffe8f1f2), fontWeight: FontWeight.bold),
);
ButtonThemeData buttonThemeData = const ButtonThemeData(buttonColor: Color(0xff1b98e0));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale("en", "US"),
        Locale("nb", "NO")],
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => (SelectDepartmentView()) //ForgotPasswordPage())),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.title),
            Text(AppLocalizations.of(context)!.helloWorld),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
