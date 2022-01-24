import 'package:flutter/material.dart';
import '../../../main.dart';

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

  String email = "";
  String password = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 10),
              child: Column(
                children: [
                  Image.asset(
                    "assets/FishingBoatSilhouette.jpg",
                    width: 200,
                  ),
                  const Text(
                    "Fishing. inc.",
                    style: TextStyle(
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
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary, fontSize: 20)),
                        TextFormField(
                          validator: (val) =>
                              val!.isEmpty || !val.contains("@") ? "Enter a valid email" : null,
                          // Username text field
                          controller: emailController,
                          decoration: const InputDecoration(hintText: 'Email'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Password",
                            style: TextStyle(
                                fontSize: 20, color: Theme.of(context).colorScheme.onPrimary)),
                        TextFormField(
                          // Password text field
                          controller: passwordController,
                          decoration: const InputDecoration(hintText: 'Password'),
                          obscureText: true,
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(children: [
                          ButtonTheme(
                              minWidth: 250.0,
                              height: 100.0,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  (const MyApp()) //TODO push to inventory/default/home view
                                              ));
                                    }
                                  },
                                  child: const Text('Sign In'))),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            (const MyApp()) //TODO ForgotPasswordView())),
                                        ));
                              },
                              child: const Text('Forgot Password?',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  ))),
                        ]))
                  ])),
            ),
          ],
        ))));
  }
}
