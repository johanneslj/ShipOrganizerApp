import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/views/SendBill/send_bill_confirmed_view.dart';
import 'package:ship_organizer_app/views/SendBill/send_bill_new_view.dart';
import 'package:ship_organizer_app/views/SendBill/send_bill_pending_view.dart';
import 'package:ship_organizer_app/views/login/login_view.dart';

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
  bool admin = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
              tabs: admin
                  ? ([
                      Tab(child: Text(AppLocalizations.of(context)!.newBill)),
                      Tab(child: Text(AppLocalizations.of(context)!.pending)),
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
                    const pendingBill(),
                    GridView.count(
                      crossAxisCount: 2,
                      children: getlist(),
                    ),
                  ]
                : [const confimedBill()]),
      ),
    );
  }

  List<Widget> getlist() {
    List<String> hei = departments;
    return List.generate(hei.length, (index) {
      return Center(
          child: Column(
        children: [Text('Item $index')],
      ));
    });
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
