import 'package:flutter/material.dart';
import '../../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///
/// This view is used for letting the user set a new password.
/// Gives the user opportunity to receive a verification code, enter it,
/// and then enter a new password.
///
class SetPasswordView extends StatefulWidget {
  const SetPasswordView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetPasswordViewState();
}

class _SetPasswordViewState extends State<SetPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int page = 1;

  String email = "";
  String verificationCode = "";
  String newPassword = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: page == 1
                        ? enterEmailPage()
                        : page == 2
                            ? enterCodePage()
                            : errorPage()))));
  }

  ///
  /// Returns widget where user can enter e-mail address.
  /// Sends verification code to e-mail address if user exists, and then updates states page number
  /// so that the verification code entry page is displayed.
  ///
  Widget enterEmailPage() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        Text(AppLocalizations.of(context)!.email,
            style: Theme.of(context).textTheme.headline6),
        TextFormField(
          validator: (value) => value!.isEmpty || !value.contains("@")
              ? AppLocalizations.of(context)!.enterValidEmail
              : null,
          // Username text field
          controller: emailController,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.email),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: ButtonTheme(
              minWidth: 250.0,
              height: 100.0,
              child: ElevatedButton(
                  onPressed: () => {
                        setState(() {
                          page = 2;
                          // TODO Send verification code to email
                        })
                      },
                  child: Text(AppLocalizations.of(context)!.sendCode))),
        )
      ]),
    );
  }

  ///
  /// Returns widget where user can enter the verification code received by e-mail.
  /// Verifies of the code is correct and then updates state to display page to set new password.
  ///
  Widget enterCodePage() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        Text(AppLocalizations.of(context)!.verificationCode,
            style: Theme.of(context).textTheme.headline6),
        TextFormField(
          // Username text field
          controller: verificationCodeController,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.verificationCode),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(children: [
              ButtonTheme(
                  minWidth: 250.0,
                  height: 100.0,
                  child: ElevatedButton(
                      onPressed: () => {
                            // TODO Verify code
                            if (verificationCodeController.toString() == "12345")
                              {
                                setState(() {
                                  page = 3;
                                })
                              }
                          },
                      child: Text(AppLocalizations.of(context)!.sendCode))),
            ]))
      ]),
    );
  }

  ///
  /// Widget that lets user enter new password and updates it.
  ///
  Widget enterNewPasswordPage() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        Text(AppLocalizations.of(context)!.enterEmail,
            style: Theme.of(context).textTheme.headline6),
        TextFormField(
          validator: (value) => value!.isEmpty || !value.contains("@")
              ? AppLocalizations.of(context)!.enterValidEmail
              : null,
          // Username text field
          controller: emailController,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.enterEmail),
        ),
        Text(AppLocalizations.of(context)!.enterEmail,
            style: Theme.of(context).textTheme.headline6),
        TextFormField(
          validator: (value) => value!.isEmpty || !value.contains("@")
              ? AppLocalizations.of(context)!.enterValidEmail
              : null,
          // Username text field
          controller: emailController,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.enterEmail),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: ButtonTheme(
              minWidth: 250.0,
              height: 100.0,
              child: ElevatedButton(
                  onPressed: () => {
                        // TODO Change password with API
                      },
                  child: Text(AppLocalizations.of(context)!.confirm))),
        )
      ]),
    );
  }

  Widget errorPage() {
    return Text(AppLocalizations.of(context)!.errorHappened);
  }
}
