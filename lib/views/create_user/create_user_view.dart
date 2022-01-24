import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/widgets/multi_select_widget.dart';
import '../../main.dart';

/// A class which enables an admin to create a new user
/// An admin enters the new users full name, email and what departments
/// they should have access too
/// When the "create user" button is pressed the backend handles the call
/// and sends a simple email to the new user who can then create a password in the app
/// and start using the app
class CreateUser extends StatefulWidget {
  const CreateUser({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> departments = <String>["Dock", "Factory", "Bridge", "Quarters"];

  String email = "";
  String fullName = "";
  List<String> selectedDepartments = <String>[];

  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //selectedDepartment = AppLocalizations.of(context)!.selectDepartment;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 150),
        child: SingleChildScrollView(
          child: Column(children: [
            Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.email,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary, fontSize: 20)),
                      TextFormField(
                        validator: (val) => val!.isEmpty || !val.contains("@")
                            ? AppLocalizations.of(context)!.enterValidEmail
                            : null,
                        // Email Address text field
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
                      Text((AppLocalizations.of(context)!.fullName),
                          style: TextStyle(
                              fontSize: 20, color: Theme.of(context).colorScheme.primary)),
                      TextFormField(
                        // Full Name text field
                        controller: fullNameController,
                        decoration:
                            InputDecoration(hintText: AppLocalizations.of(context)!.fullName),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: ElevatedButton(
                            onPressed: _showMultiSelect,
                            child: Text(AppLocalizations.of(context)!.selectDepartment)),
                      ),
                      Row(
                        children: [
                          Text(selectedDepartments
                              .toString()
                              .replaceAll("[", "")
                              .replaceAll("]", ""))
                        ],
                      )
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
                                child: Text(AppLocalizations.of(context)!.createUser))),
                      ]))
                ])),
          ]),
        ),
      ),
    );
  }

  void _showMultiSelect() async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          items: departments,
          selectedItems: selectedDepartments,
        );
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        selectedDepartments = results;
      });
    }
  }
}
