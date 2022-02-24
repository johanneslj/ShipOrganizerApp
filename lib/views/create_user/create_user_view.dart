import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
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

  //TODO Get departments from backend
  List<String> departments = <String>[
    "Bridge",
    "Deck"
  ];

  String email = "";
  String fullName = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();

  List<String> _selectedDepartments = <String>[];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedDepartments.add(itemValue);
      } else {
        _selectedDepartments.remove(itemValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ApiService apiService = ApiService();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.createUser,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
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
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.fullName,
                            hintStyle: TextStyle(color: Theme.of(context).disabledColor)),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          // Checkbox list where an admin can select what departments a new user
                          // will have access to
                          child: Column(
                            children: [
                              Text(AppLocalizations.of(context)!.selectDepartment),
                              ListBody(
                                children: departments
                                    .map((item) => Theme(
                                        data: ThemeData(
                                            unselectedWidgetColor:
                                                Theme.of(context).colorScheme.primary),
                                        child: CheckboxListTile(
                                          selected: _selectedDepartments.contains(item),
                                          value: _selectedDepartments.contains(item),
                                          activeColor: Theme.of(context).colorScheme.primary,
                                          checkColor: Theme.of(context).colorScheme.onPrimary,
                                          title: Text(
                                            item,
                                            style: Theme.of(context).textTheme.bodyText2,
                                          ),
                                          controlAffinity: ListTileControlAffinity.leading,
                                          onChanged: (isChecked) => _itemChange(item, isChecked!),
                                        )))
                                    .toList(),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          )),
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
                                    await apiService.registerUser(emailController.value.text,
                                        fullNameController.value.text, _selectedDepartments);

                                    Navigator.pushNamed(context, "/home");
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
}
