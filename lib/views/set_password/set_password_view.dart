import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
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
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  ApiService apiService = ApiService.getInstance();
  final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final RegExp passwordRegex =
      RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$");

  int page = 1;
  bool _isButtonDisabled = true;
  bool isLoading = false;

  setLoading(bool state) => setState(() => isLoading = state);

  TextEditingController emailController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    apiService.setContext(context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          title: Text(
            AppLocalizations.of(context)!.changePassword,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
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
        child: FutureBuilder<bool>(
            future: _autoFillEmailIfExists(),
            builder: (context, hasUsername) {
              return Column(children: [
                Text(AppLocalizations.of(context)!.email,
                    style: Theme.of(context).textTheme.headline5),
                TextFormField(
                  validator: (value) => _emailValidator(value, context),
                  controller: emailController,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.email),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: _submitEmailButton(context),
                )
              ]);
            }));
  }

  /// Returns widget where user can enter the verification code received by e-mail.
  ///
  /// Verifies of the code is correct and then updates state to display page to set new password.
  Widget enterCodePage() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        Text(AppLocalizations.of(context)!.verificationCode,
            style: Theme.of(context).textTheme.headline5),
        TextFormField(
          controller: verificationCodeController,
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.verificationCode),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(children: [
              _getVerifyCodeButton(),
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
            style: Theme.of(context).textTheme.headline5),
        TextFormField(
          validator: (value) => _getPasswordValidator(value),
          controller: passwordController,
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.newPassword),
          obscureText: true,
        ),
        Text(AppLocalizations.of(context)!.confirmPassword,
            style: Theme.of(context).textTheme.headline5),
        TextFormField(
          validator: (value) => _getConfirmPasswordValidator(value),
          controller: confirmPasswordController,
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.confirmPassword,
              errorMaxLines: 3),
          obscureText: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: _getConfirmPasswordButton(),
        )
      ]),
    );
  }

  Future<bool> _autoFillEmailIfExists() async {
    bool hasKey = false;
    if (await _storage.containsKey(key: "username")) {
      hasKey = true;
      _storage
          .read(key: "username")
          .then((value) => value != null ? emailController.text = value : null);
    }
    return hasKey;
  }

  String? _emailValidator(String? value, BuildContext context) {
    return value!.isNotEmpty && emailRegex.hasMatch(value)
        ? null
        : AppLocalizations.of(context)!.enterValidEmail;
  }

  ButtonTheme _submitEmailButton(BuildContext context) {
    return ButtonTheme(
        disabledColor: Colors.grey,
        minWidth: 250.0,
        height: 100.0,
        child: ElevatedButton(
            onPressed: _onSubmitEmailPressed(context),
            child: Text(AppLocalizations.of(context)!.sendCode)));
  }

  Set Function()? _onSubmitEmailPressed(BuildContext context) {
    return isLoading
        ? null
        : () => {
              if (emailController.text.isEmpty ||
                  !emailRegex.hasMatch(emailController.text))
                {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.enterValidEmail)))
                }
              else
                {
                  setLoading(true),
                  apiService
                      .sendVerificationCode(emailController.value.text)
                      .then((isSent) => {
                            if (isSent)
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            AppLocalizations.of(context)!
                                                .sentCode))),
                                setState(() {
                                  page = 2;
                                })
                              }
                          })
                },
              setLoading(false),
            };
  }

  ButtonTheme _getVerifyCodeButton() {
    return ButtonTheme(
        disabledColor: Colors.grey,
        minWidth: 250.0,
        height: 100.0,
        child: ElevatedButton(
            onPressed: _onVerifyCodePressed(),
            child: Text(AppLocalizations.of(context)!.verifyCode)));
  }

  Set Function()? _onVerifyCodePressed() {
    return isLoading
        ? null
        : () => {
              setLoading(true),
              apiService
                  .verifyVerificationCode(emailController.value.text,
                      verificationCodeController.value.text)
                  .then((isValid) => {
                        if (isValid)
                          {
                            setState(() {
                              page = 3;
                            })
                          }
                        else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .somethingWentWrong))),
                          }
                      }),
              setLoading(false),
            };
  }

  String? _getPasswordValidator(String? value) {
    if (!passwordRegex.hasMatch(value!)) {
      _isButtonDisabled = true;
      return AppLocalizations.of(context)!.enterValidPassword;
    } else {
      return null;
    }
  }

  String? _getConfirmPasswordValidator(String? value) {
    if (value.toString() != passwordController.text) {
      _isButtonDisabled = true;
      return AppLocalizations.of(context)!.passwordsMustMatch;
    } else if (passwordRegex.hasMatch(passwordController.text)) {
      _isButtonDisabled = false;
      return null;
    } else {
      return null;
    }
  }

  ButtonTheme _getConfirmPasswordButton() {
    return ButtonTheme(
        disabledColor: Colors.grey,
        minWidth: 250.0,
        height: 100.0,
        child: ElevatedButton(
            onPressed: _onConfirmPasswordPressed(),
            child: Text(AppLocalizations.of(context)!.confirm)));
  }

  Set Function()? _onConfirmPasswordPressed() {
    return isLoading
        ? null
        : () => {
              if (_isButtonDisabled)
                {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .enterValidPasswordShort)))
                }
              else
                {
                  setLoading(true),
                  apiService
                      .setNewPassword(
                          emailController.value.text,
                          verificationCodeController.value.text,
                          passwordController.value.text)
                      .then((success) => Navigator.pushNamedAndRemoveUntil(
                          context, "/", (r) => false))
                },
              setLoading(false),
            };
  }

  /// Just in case :)
  Widget errorPage() {
    return Text(AppLocalizations.of(context)!.errorHappened);
  }
}
