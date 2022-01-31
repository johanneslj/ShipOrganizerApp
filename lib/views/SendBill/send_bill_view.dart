import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/views/SendBill/send_bill_confirmed_view.dart';
import 'package:ship_organizer_app/views/SendBill/send_bill_new_view.dart';
import 'package:ship_organizer_app/views/SendBill/send_bill_pending_view.dart';

/// This class represents the possibility to send and receive bills between the
/// departments
class Sendbill extends StatefulWidget {
  const Sendbill({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendBill();
}

class _SendBill extends State<Sendbill> {
  final List<String> departments = <String>["Bridge", "Factory", "Deck"];
  String selectedValue = "Bridge";
  bool admin = true;
  String pendingCount = "";
@override
initState(){
  pendingCount = (" (" + departments.length.toString() + ")");
}
  _updatePendingCount(String text){
    setState(() {
      pendingCount = (" (" + text + ")");
    });
  }


  @override
  Widget build(BuildContext context) {
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
              indicatorColor: admin ?  Colors.amberAccent : Theme.of(context).colorScheme.onBackground,
              indicatorWeight: admin ? 5 : 0.1,

              tabs: admin
                  ? ([
                      Tab(child: Text(AppLocalizations.of(context)!.newBill)),
                      Tab(child: Text(AppLocalizations.of(context)!.pending + (pendingCount))),
                      Tab(child: Text(AppLocalizations.of(context)!.confirmed))
                    ])
                  : [
                      Tab(child: Text(AppLocalizations.of(context)!.confirm)),
                    ]),
          title: Text(
            AppLocalizations.of(context)!.billing,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: TabBarView(
            children: admin
                ? [
                    const newBill(),
                    pendingBill( parentAction: _updatePendingCount,),
                     confimedBill(admin: admin)
                  ]
                : [confimedBill(admin : admin)]),
      ),
    );
  }

  Widget imageDialog() {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/FishingBoatSilhouette.jpg'),
                fit: BoxFit.cover)),
      ),
    );
  }
}
