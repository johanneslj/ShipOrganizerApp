import 'package:flutter/material.dart';
import '../../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SetPasswordView extends StatefulWidget {
  const SetPasswordView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetPasswordViewState();
}

class _SetPasswordViewState extends State<SetPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email = "";
  String verificationCode = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController verificationCodeController = TextEditingController();

  int page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                child: page == 1
                    ? enterEmailPage()
                    : page == 2
                        ? enterCodePage()
                        : errorPage())));
  }

  Widget enterEmailPage() {
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
          decoration: const InputDecoration(hintText: AppLocalizations.of(context).enterEmail),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(children: [
              ButtonTheme(
                  minWidth: 250.0,
                  height: 100.0,
                  child: ElevatedButton(
                      onPressed: () => {
                        setState(() => page = 2)
                      },
                      child: Text(AppLocalizations.of(context)!.sendCode))),
            ]))
      ]),
    );
  }

  Widget enterCodePage() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        Text(AppLocalizations.of(context)!.verificationCode,
            style: Theme.of(context).textTheme.headline6),
        TextFormField(
          validator: (value) => value?.length == 5
              ? null
              : AppLocalizations.of(context)!.invalidCode, // TODO Check for correct code
          // Username text field
          controller: verificationCodeController,
          decoration: const InputDecoration(hintText: 'Email'),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(children: [
              ButtonTheme(
                  minWidth: 250.0,
                  height: 100.0,
                  child: ElevatedButton(
                      onPressed: () => {}, child: Text(AppLocalizations.of(context)!.sendCode))),
            ]))
      ]),
    );
  }

  Widget errorPage() {
    return Text(AppLocalizations.of(context)!.errorHappened);
  }
}
