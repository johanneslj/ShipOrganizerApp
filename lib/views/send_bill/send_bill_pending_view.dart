import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/entities/Order.dart';

/// Class for the pending bills tab in the send_bill_view
/// This class is responsible for the view where the admin can
/// check the bills that are not confirmed.
class PendingBill extends StatefulWidget {
  const PendingBill({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _pendingBill();
}

class _pendingBill extends State<PendingBill> {
  late List<Order> pendingOrders = <Order>[];
  late bool _isLoading = false;

  ApiService apiService = ApiService.getInstance();

  @override
  void initState() {
    dataLoadFunction();
    super.initState();
  }

  dataLoadFunction() async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });
    await getPendingOrder();
    // fetch you data over here
    setState(() {
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }
  @override
  Widget build(BuildContext context) {
    apiService.setContext(context);
    return SafeArea(
        child: Scaffold(
            body: pendingOrders.isEmpty ? const Text("No pending orders")  :  _isLoading
                ? circularProgress()
                : RefreshIndicator(
                    onRefresh: ()  => getPendingOrder(),
                    child: GridView.builder(
                      itemCount: pendingOrders.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                                child: GestureDetector(
                                  onTap: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (_) => imageDialog());
                                  },
                                ),
                                radius: 50.0,
                                //Photo by Tamas Tuzes-Katai on Unsplash
                                backgroundImage: const AssetImage(
                                    'assets/FishingBoatSilhouette.jpg')),
                            Text(
                              AppLocalizations.of(context)!.changeImageSize,
                              style: const TextStyle(
                                fontSize: 10.0,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                             pendingOrders[index].department.toString(),
                              style: const TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ));
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                      ),
                    ),
                  )));
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

  Future<void> getPendingOrder() async {
    List<Order> order = [];
    order = await apiService.getPendingOrder();
    setState(() {
      pendingOrders = order;
    });
  }

  /// Creates a container with a CircularProgressIndicator
  Container circularProgress() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10.0),
      child: const CircularProgressIndicator(
        strokeWidth: 2.0,
      ),
    );
  }
}
