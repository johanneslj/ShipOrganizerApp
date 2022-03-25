import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ship_organizer_app/api handling//api_controller.dart';
import 'package:ship_organizer_app/views/inventory/inventory_view.dart';
import 'package:ship_organizer_app/views/set_password/set_password_view.dart';
import 'package:ship_organizer_app/widgets/loading_overlay_widget.dart';
import '../../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A Class which supplies the login view for the app
/// It is constructed by several different widgets
/// It has an Email and Password controller which are used to detect text input
/// in the email and password text fields
///
/// This is the first view a new user will when first opening the app
/// From here they are able to log in and start using the app
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

/// State of the login view.
class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ApiService apiService = ApiService.getInstance();

  String email = "";
  String password = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    apiService.setContext(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: LoadingOverlay(
        inAsyncCall: isLoading,
        progressIndicator: SizedBox(
          height: 200.0,
          width: 200.0,
          child: Center(
            child: Column(
              children: const [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                    strokeWidth: 10.0,
                  ),
                ),
                SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
                  child: Column(
                    children: [
                      //TODO use real logo
                      Image.asset(
                        "assets/FishingBoatSilhouette.jpg",
                        width: 200,
                      ),
                      Text(
                        AppLocalizations.of(context)!.companyName,
                        style: const TextStyle(
                            color: Color(0xffE8F1F2), fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.email,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary, fontSize: 20)),
                            TextFormField(
                              validator: (val) => val!.isEmpty || !val.contains("@")
                                  ? AppLocalizations.of(context)!.enterValidEmail
                                  : null,
                              // Username text field
                              controller: emailController,
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.email,
                                  hintStyle: TextStyle(color: Theme.of(context).disabledColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.password,
                                style: TextStyle(
                                    fontSize: 20, color: Theme.of(context).colorScheme.onPrimary)),
                            TextFormField(
                              // Password text field
                              controller: passwordController,
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.password,
                                  hintStyle: TextStyle(color: Theme.of(context).disabledColor)),
                              obscureText: true,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            children: [
                              ButtonTheme(
                                  disabledColor: Colors.grey,
                                  minWidth: 250.0,
                                  height: 100.0,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        if (_formKey.currentState!.validate()) {
                                          bool logInSuccessful = await login();
                                          if (logInSuccessful) {
                                            Navigator.pushNamed(context, "/home");
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text(
                                                    AppLocalizations.of(context)!.loginFailed)));
                                          }
                                        }
                                      },
                                      child: Text(AppLocalizations.of(context)!.signIn))),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              (const SetPasswordView())
                                          ));
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.forgotPassword,
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isLoading = false;

  setLoading(bool state) => setState(() => isLoading = state);

  Future<bool> login() async {
    setLoading(true);
    bool success =
        await apiService.attemptToLogIn(emailController.value.text, passwordController.value.text);
    setLoading(false);
    return success;
  }
}
