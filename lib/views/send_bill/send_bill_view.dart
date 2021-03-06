import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/views/send_bill/send_bill_confirmed_view.dart';
import 'package:ship_organizer_app/views/send_bill/send_bill_new_view.dart';
import 'package:ship_organizer_app/views/send_bill/send_bill_pending_view.dart';

/// This class represents the possibility to send and receive bills between the
/// departments
class SendBill extends StatefulWidget {
  const SendBill({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendBill();
}

class _SendBill extends State<SendBill> {
  final List<String> departments = <String>["Bridge", "Factory", "Deck"];
  String selectedValue = "Bridge";
  late bool admin = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String args = ModalRoute.of(context)!.settings.arguments as String;
    if (args.startsWith("true")) {
      admin = true;
    }
    return DefaultTabController(
      length: admin ? 3 : 1,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
              indicatorColor: admin
                  ? Colors.amberAccent
                  : Theme.of(context).colorScheme.onBackground,
              indicatorWeight: admin ? 5 : 0.1,
              tabs: admin
                  ? ([
                      Tab(child: Text(AppLocalizations.of(context)!.newBill)),
                      Tab(child: Text(AppLocalizations.of(context)!.pending)),
                      Tab(child: Text(AppLocalizations.of(context)!.confirmed))
                    ])
                  : [
                      Tab(child: Text(AppLocalizations.of(context)!.pending)),
                    ]),
          title: Text(
            AppLocalizations.of(context)!.billing,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: TabBarView(
            children: admin
                ? [
                    const NewBill(),
                    PendingBill(admin: admin),
                    ConfirmedBill(admin: admin)
                  ]
                : [PendingBill(admin: admin)]),
      ),
    );
  }
}
