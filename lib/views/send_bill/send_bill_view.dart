import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
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
  late bool _isLoading = false;
  String pendingCount = "";
  ApiService apiService = ApiService();

  @override
  initState() {
    dataLoadFunction();
    pendingCount = (" (" + departments.length.toString() + ")");
  }

  _updatePendingCount(String text) {
    setState(() {
      pendingCount = (" (" + text + ")");
    });
  }

  dataLoadFunction() async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });
    await getUserRights();
    // fetch you data over here
    setState(() {
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: admin ? 3 : 1,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
              indicatorColor:
                  admin ? Colors.amberAccent : Theme.of(context).colorScheme.onBackground,
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
                    const NewBill(),
                    PendingBill(
                      parentAction: _updatePendingCount,
                    ),
                    ConfimedBill(admin: admin)
                  ]
                : [ConfimedBill(admin: admin)]),
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
                image: AssetImage('assets/FishingBoatSilhouette.jpg'), fit: BoxFit.cover)),
      ),
    );
  }

  Future<void> getUserRights() async{
    String result = await apiService.getUserRights();
    if(result.contains("ADMIN")){
      setState(() {
        admin = true;
      });}
  }
}
