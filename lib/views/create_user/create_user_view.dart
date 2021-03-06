import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api_handling/api_controller.dart';
import 'package:ship_organizer_app/entities/user.dart';
import 'package:ship_organizer_app/widgets/loading_overlay_widget.dart';

/// A class which enables an admin to create a new user
/// An admin enters the new users full name, email and what departments
/// they should have access too
/// When the "create user" button is pressed the backend handles the call
/// and sends a simple email to the new user who can then create a password in the app
/// and start using the app
class CreateUser extends StatefulWidget {
  final bool isCreateUser;
  final User? userToEdit;

  const CreateUser({Key? key, required this.isCreateUser, this.userToEdit})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ApiService apiService = ApiService.getInstance();

  List<String> departments = [];

  String email = "";
  String fullName = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();

  List<String> _selectedDepartments = <String>[];

  @override
  void initState() {
    super.initState();
    getDepartments();
  }

  /// Gets the active department of the user
  void getDepartments() async {
    List<String> _departments = await apiService.getDepartments();
    setState(() {
      departments = _departments;
    });
  }

/// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      FocusScope.of(context).requestFocus(FocusNode());
      if (isSelected) {
        _selectedDepartments.add(itemValue);
      } else {
        _selectedDepartments.remove(itemValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    apiService.getDepartments().then((value) => departments = value);
    apiService.setContext(context);
    if (widget.isCreateUser) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () => {
              FocusScope.of(context).requestFocus(FocusNode()),
              Navigator.of(context).pop()
            },
          ),
          title: Text(
            AppLocalizations.of(context)!.createUser,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: [
                  Form(
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 20)),
                            TextFormField(
                              validator: (val) =>
                                  val!.isEmpty || !val.contains("@")
                                      ? AppLocalizations.of(context)!
                                          .enterValidEmail
                                      : null,
                              controller: emailController,
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.email,
                                  hintStyle: TextStyle(
                                      color: Theme.of(context).disabledColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((AppLocalizations.of(context)!.fullName),
                                style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            TextFormField(
                              // Full Name text field
                              controller: fullNameController,
                              decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.fullName,
                                  hintStyle: TextStyle(
                                      color: Theme.of(context).disabledColor)),
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                // Checkbox list where an admin can select what departments a new user
                                // will have access to
                                child: Column(
                                  children: [
                                    Text(AppLocalizations.of(context)!
                                        .selectDepartment),
                                    ListBody(
                                      children: departments
                                          .map((item) => Theme(
                                              data: ThemeData(
                                                  unselectedWidgetColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                              child: CheckboxListTile(
                                                selected: _selectedDepartments
                                                    .contains(item),
                                                value: _selectedDepartments
                                                    .contains(item),
                                                activeColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                checkColor: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                title: Text(
                                                  item,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2,
                                                ),
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                                onChanged: (isChecked) =>
                                                    _itemChange(
                                                        item, isChecked!),
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
                          child: Column(
                            children: [
                              ButtonTheme(
                                  minWidth: 250.0,
                                  height: 100.0,
                                  child: ElevatedButton(
                                      onPressed: isLoading ||
                                              fullNameController.text.isEmpty
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                if (_selectedDepartments
                                                    .isNotEmpty) {
                                                  bool success =
                                                      await registerUser(
                                                          emailController
                                                              .value.text,
                                                          fullNameController
                                                              .value.text,
                                                          _selectedDepartments);
                                                  if (success) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                    Navigator.pushNamed(
                                                        context, "/home");
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .registerFailed)));
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .selectAtLeastOneDepartment)));
                                                }
                                              }
                                            },
                                      child: Text(AppLocalizations.of(context)!
                                          .createUser))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      _selectedDepartments = widget.userToEdit!.departments;
      emailController.text = widget.userToEdit!.email!;
      fullNameController.text = widget.userToEdit!.name!;
      return _createEditUserView(context);
    }
  }

  /// Creates the view if the mode is edit user
  Scaffold _createEditUserView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.editUser,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              children: [
                Form(
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
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 20)),
                          TextFormField(
                            validator: (val) => val!.isEmpty ||
                                    !val.contains("@")
                                ? AppLocalizations.of(context)!.enterValidEmail
                                : null,
                            controller: emailController,
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.email,
                                hintStyle: TextStyle(
                                    color: Theme.of(context).disabledColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((AppLocalizations.of(context)!.fullName),
                              style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                          TextFormField(
                            // Full Name text field
                            controller: fullNameController,
                            decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(context)!.fullName,
                                hintStyle: TextStyle(
                                    color: Theme.of(context).disabledColor)),
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              // Checkbox list where an admin can select what departments a new user
                              // will have access to
                              child: Column(
                                children: [
                                  Text(AppLocalizations.of(context)!
                                      .selectDepartment),
                                  ListBody(
                                    children: departments
                                        .map((item) => Theme(
                                            data: ThemeData(
                                                unselectedWidgetColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                            child: CheckboxListTile(
                                              selected: _selectedDepartments
                                                  .contains(item),
                                              value: _selectedDepartments
                                                  .contains(item),
                                              activeColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              checkColor: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              title: Text(
                                                item,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              onChanged: (isChecked) =>
                                                  _itemChange(item, isChecked!),
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
                        child: Column(
                          children: [
                            ButtonTheme(
                                disabledColor: Colors.grey,
                                minWidth: 250.0,
                                height: 100.0,
                                child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            if (_formKey.currentState!
                                                .validate()) {
                                              apiService.editUser(
                                                  widget.userToEdit?.email,
                                                  emailController.value.text,
                                                  fullNameController.value.text,
                                                  _selectedDepartments);
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                              Navigator.pushNamed(
                                                  context, "/home");
                                            }
                                          },
                                    child: Text(AppLocalizations.of(context)!
                                        .confirmEdit))),
                            const SizedBox(height: 20),
                            ButtonTheme(
                                minWidth: 250.0,
                                height: 100.0,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            bool success = await deleteUser(
                                                widget.userToEdit?.email!);
                                            if (success) {
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                              Navigator.pushNamed(
                                                  context, "/home");
                                            }
                                          },
                                    child: Text(AppLocalizations.of(context)!
                                        .deleteUser))),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                      )
                    ],
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

  /// Toggle if the view is waiting on a response or not
  setLoading(bool state) => setState(() => isLoading = state);

  /// Sends a request to the API to try to register a new user
  /// The details of the new user are used to do this
  Future<bool> registerUser(
      String email, String fullName, List<String> departments) async {
    setLoading(true);
    bool success = await apiService.registerUser(email, fullName, departments);
    setLoading(false);
    return success;
  }

  /// If in edit user mode it is possible to try to delete
  /// the user being viewed
  /// This method makes the API try to delete the user
  Future<bool> deleteUser(String? email) async {
    setLoading(true);
    bool success = await apiService.deleteUser(email!);
    setLoading(false);
    return success;
  }
}
