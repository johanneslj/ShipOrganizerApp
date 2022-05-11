import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/entities/order.dart';

/// Class for the pending bills tab in the send_bill_view
/// This class is responsible for the view where the admin can
/// check the bills that are not confirmed.
class PendingBill extends StatefulWidget {
  final bool admin;

  const PendingBill({Key? key, required this.admin}) : super(key: key);

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
            body: _isLoading
                ? circularProgress()
                : pendingOrders.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!.noPendingOrders)
                            ],
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        onRefresh: () => getPendingOrder(),
                        child: GridView.builder(
                          itemCount: pendingOrders.length,
                          itemBuilder: (BuildContext context, int index) {
                            NetworkImage image = NetworkImage(
                                apiService.imagesBaseUrl +
                                    pendingOrders[index].imagename);
                            return Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (_) => imageDialog(image));
                                      },
                                    ),
                                    radius: 50.0,
                                    backgroundImage: image),
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
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => sendToServer(index, 1),
                                      child: const Icon(Icons.check,
                                          color: Colors.green),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => sendToServer(index, 2),
                                      child: const Icon(Icons.clear,
                                          color: Colors.red),
                                    )
                                  ],
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

  /// Function to send notice to the server that the bill has been confirmed
  Future<void> sendToServer(int index, int status) async {
    String imageName = pendingOrders[index].imagename;
    String departmentName = pendingOrders[index].department;
    await apiService.updateOrder(imageName, departmentName, status);
    getPendingOrder();
  }

  Widget imageDialog(NetworkImage image) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        decoration: BoxDecoration(
            image: DecorationImage(image: image, fit: BoxFit.cover)),
      ),
    );
  }

  Future<void> getPendingOrder() async {
    List<Order> order = [];
    if (widget.admin) {
      order = await apiService.getPendingOrders();
    } else {
      order = await apiService.getUserPendingOrders();
    }

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
