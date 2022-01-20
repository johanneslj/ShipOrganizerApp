import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> departments = <String>["Dock", "Facotry", "Bridge", "Quarters"];

  String email = "";
  String fullName = "";
  List<String> selectedDepartments = <String>[];

  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
        child: Column(children: [
          Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary, fontSize: 20)),
                    TextFormField(
                      validator: (val) =>
                          val!.isEmpty || !val.contains("@") ? AppLocalizations.of(context)!.enterValidEmail : null,
                      // Email Address text field
                      controller: emailController,
                      decoration: const InputDecoration(hintText: 'Email'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((AppLocalizations.of(context)!.fullName),
                        style: TextStyle(
                            fontSize: 20, color: Theme.of(context).colorScheme.primary)),
                    TextFormField(
                      // Full Name text field
                      controller: fullNameController,
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.fullName),
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
                              child: const Text('Create User'))),
                    ]))
              ])),
        ]),
      ),
    );
  }
}
