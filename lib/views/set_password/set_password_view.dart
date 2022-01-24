import 'package:flutter/material.dart';
import 'package:ship_organizer_app/views/login/login_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This view is used for letting the user set a new password.
///
/// Gives the user opportunity to receive a verification code, enter it,
/// and then enter a new password.
class SetPasswordView extends StatefulWidget {
  const SetPasswordView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetPasswordViewState();
}

class _SetPasswordViewState extends State<SetPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final RegExp passwordRegex = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$");

  int page = 1;

  bool _isButtonDisabled = true;

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
                            : page == 3
                                ? enterNewPasswordPage()
                                : errorPage()))));
  }

  /// Returns widget where user can enter e-mail address.
  ///
  /// Sends verification code to e-mail address if user exists, and then updates states page number
  /// so that the verification code entry page is displayed.
  Widget enterEmailPage() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        // Enter email to get verification code
        Text(AppLocalizations.of(context)!.email, style: Theme.of(context).textTheme.headline6),
        TextFormField(
          validator: (value) => value!.isNotEmpty && emailRegex.hasMatch(value)
              ? null
              : AppLocalizations.of(context)!.enterValidEmail,
          // Username text field
          controller: emailController,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.email),
        ),

        // Send code button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: ButtonTheme(
              minWidth: 250.0,
              height: 100.0,
              child: ElevatedButton(
                  onPressed: () => {
                        // Prompts user to enter valid email before trying to send code.
                        if (emailController.text.isEmpty || !emailRegex.hasMatch(emailController.text))
                          {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!.enterValidEmail)))
                          }
                        else
                          {
                            setState(() {
                              page = 2;
                              // TODO Send verification code to email
                            })
                          }
                      },
                  child: Text(AppLocalizations.of(context)!.sendCode))),
        )
      ]),
    );
  }

  /// Returns widget where user can enter the verification code received by e-mail.
  ///
  /// Verifies of the code is correct and then updates state to display page to set new password.
  Widget enterCodePage() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        // Enter verification code
        Text(AppLocalizations.of(context)!.verificationCode,
            style: Theme.of(context).textTheme.headline6),
        TextFormField(
          // Username text field
          controller: verificationCodeController,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.verificationCode),
        ),

        // Submit code button
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(children: [
              ButtonTheme(
                  minWidth: 250.0,
                  height: 100.0,
                  child: ElevatedButton(
                      onPressed: () => {
                            // TODO Verify code with API
                            if (verificationCodeController.text == "12345")
                              {
                                setState(() {
                                  page = 3;
                                })
                              }
                          },
                      child: Text(AppLocalizations.of(context)!.verifyCode))),
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
        // Enter new password
        Text(AppLocalizations.of(context)!.newPassword,
            style: Theme.of(context).textTheme.headline6),
        TextFormField(
          validator: (value) {
            if (!passwordRegex.hasMatch(value!)) {
              _isButtonDisabled = true;
              return AppLocalizations.of(context)!.enterValidPassword;
            } else {
              return null;
            }
          },
          controller: passwordController,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.newPassword),
          obscureText: true,
        ),

        // Confirm new password
        Text(AppLocalizations.of(context)!.confirmPassword,
            style: Theme.of(context).textTheme.headline6),
        TextFormField(
          validator: ((value) {
            // Displays error message if passwords do not match.
            // If all password entry is correct, button is enabled.
            if (value.toString() != passwordController.text) {
              _isButtonDisabled = true;
              return AppLocalizations.of(context)!.passwordsMustMatch;
            } else if (passwordRegex.hasMatch(passwordController.text)) {
              _isButtonDisabled = false;
              return null;
            } else {
              return null;
            }
          }),
          // Username text field
          controller: confirmPasswordController,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.confirmPassword),
          obscureText: true,
        ),

        // Submit password button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: ButtonTheme(
              minWidth: 250.0,
              height: 100.0,
              child: ElevatedButton(
                  onPressed: () => {
                        // Gives feedback to user with a snack bar if trying to confirm invalid password.
                        if (_isButtonDisabled)
                          {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(AppLocalizations.of(context)!.enterValidPasswordShort)))
                          }
                        else
                          {
                            // TODO Change password with API
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => (const LoginView())))
                          }
                      },
                  child: Text(AppLocalizations.of(context)!.confirm))),
        )
      ]),
    );
  }

  /// Just in case :)
  Widget errorPage() {
    return Text(AppLocalizations.of(context)!.errorHappened);
  }
}
