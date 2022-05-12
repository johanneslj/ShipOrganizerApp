import 'package:flutter/material.dart';
import 'package:ship_organizer_app/api_handling/api_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../entities/item.dart';

class SendReportToEmail extends StatefulWidget {
  final List<Item> items;

  const SendReportToEmail({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendReportToEmailState();
}

class _SendReportToEmailState extends State<SendReportToEmail> {
  TextEditingController emailController = TextEditingController();
  String _email = "";
  final ApiService _apiService = ApiService.getInstance();
  final List<String> _receivers = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getEmail();
    super.initState();
  }

  getEmail() async {
    _email = (await _apiService.storage.read(key: "username"))!;
    setState(() {
      _receivers.add(_email);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context)!.sendRecommended,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.recipients,
                style: Theme.of(context).textTheme.headline5,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: getListOfReceivers(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!
                          .enterAdditionalRecipient),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: TextFormField(
                          controller: emailController,
                          validator: (val) => val!.isNotEmpty &&
                                  !val.contains("@")
                              ? AppLocalizations.of(context)!.enterValidEmail
                              : null,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.email,
                            suffixIcon: IconButton(
                                onPressed: () => {
                                      if (_formKey.currentState!.validate())
                                        {
                                          setState(() {
                                            _receivers.add(
                                                emailController.value.text);
                                            emailController.text = "";
                                          }),
                                        },
                                    },
                                icon: Icon(Icons.add,
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                          ),
                        ),
                        width: 250,
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_receivers.isNotEmpty) {
                            bool success = await sendMissingInventory();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .emailWillBeSent)));
                              Navigator.pushNamed(context, "/home");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .somethingWentWrong)));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .pleaseEnterEmails)));
                          }
                        },
                  child:
                      Text(AppLocalizations.of(context)!.sendMissingInventory))
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the list of receivers entered by the user
  List<Widget> getListOfReceivers() {
    List<Widget> emailAddresses = [];
    for (String email in _receivers) {
      emailAddresses.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(email),
            ),
            IconButton(
              icon: Icon(Icons.delete,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () => {
                setState(
                  () {
                    _receivers.remove(email);
                  },
                )
              },
            ),
          ],
        ),
      );
    }
    setState(() {});
    return emailAddresses;
  }

  bool isLoading = false;

  /// Function for toggling if the view is waiting for a response or not
  setLoading(bool state) => setState(() => isLoading = state);

  /// Requests the api service to send the missing inventory
  /// to the specified receivers
  Future<bool> sendMissingInventory() async {
    setLoading(true);
    bool success = false;
    success = await _apiService.sendMissingInventory(widget.items, _receivers);
    setLoading(false);
    return success;
  }
}
