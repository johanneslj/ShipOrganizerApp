import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'item.dart';

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
  List<String> _receivers = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getEmail();
  }

  getEmail() async {
    _email = (await _apiService.storage.read(key: "username"))!;
    _receivers.add(_email);
    setState(() {});
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
            Text(AppLocalizations.of(context)!.recipients),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
              child: Column(children: getListOfReceivers()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        AppLocalizations.of(context)!.enterAdditionalRecipient),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: TextFormField(
                          controller: emailController,
                          validator: (val) => val!.isEmpty || !val.contains("@")
                              ? AppLocalizations.of(context)!.enterValidEmail
                              : null),
                      width: 250,
                    ),
                    ElevatedButton(
                        onPressed: () => {
                              if (_formKey.currentState!.validate())
                                {
                                  setState(() {
                                    _receivers.add(emailController.value.text);
                                    emailController.text = "";
                                  }),
                                },
                            },
                        child: Text(AppLocalizations.of(context)!.add))
                  ],
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () => {
                  if(_receivers.isNotEmpty) {
                    sendMissingInventory()
                  } else {
                ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterEmails))),
                  }
                },
                child: Text(AppLocalizations.of(context)!.sendMissingInventory))
          ],
        ),
      )),
    );
  }

  List<Widget> getListOfReceivers() {
    List<Widget> emailAddresses = [];
    for (String email in _receivers) {
      emailAddresses.add(Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove,
                color: Theme.of(context).colorScheme.primary),
            onPressed: () => {
              setState(() {
                _receivers.remove(email);
              })
            },
          ),
          Text(email)
        ],
      ));
    }
    setState(() {});
    return emailAddresses;
  }

  void sendMissingInventory() {
    _apiService.sendMissingInventory(widget.items, _receivers);
  }
}
