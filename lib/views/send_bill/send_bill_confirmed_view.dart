import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api_handling/api_controller.dart';
import 'package:ship_organizer_app/entities/order.dart';

/// Class for the confirmed bills tab in the send_bill_view
/// This class is responsible for the view where the admin can
/// check the bills that are confirmed.
/// And for the normal user, can here set the bills as confirmed.
class ConfirmedBill extends StatefulWidget {
  final bool admin;

  const ConfirmedBill({Key? key, required this.admin}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfirmedBill();
}

class _ConfirmedBill extends State<ConfirmedBill> {
  late List<Order> confirmedOrders = <Order>[];
  late bool _isLoading = false;

  ApiService apiService = ApiService.getInstance();

  @override
  void initState() {
    dataLoadFunction();
    super.initState();
  }

  /// Function to load data when entering the view
  dataLoadFunction() async {
    setState(() {
      _isLoading = true;
    });
    await getConfirmedOrder();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    apiService.setContext(context);
    return Scaffold(
      body: _isLoading
          ? circularProgress()
          : GridView.builder(
              itemCount: confirmedOrders.length,
              itemBuilder: (BuildContext context, int index) {
                NetworkImage image = NetworkImage(apiService.imagesBaseUrl +
                    confirmedOrders[index].imagename);
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
                          radius: 60.0,
                          backgroundImage: image),
                      Text(
                        AppLocalizations.of(context)!.changeImageSize,
                        style: const TextStyle(
                          fontSize: 10.0,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        confirmedOrders[index].department.toString(),
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        getStatus(confirmedOrders[index].status, context),
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
            ),
    );
  }

  /// Gets the status of the bills
  String getStatus(int status, BuildContext context) {
    String result = "";
    if (status == 1) {
      result = AppLocalizations.of(context)!.confirmed;
    } else {
      result = AppLocalizations.of(context)!.reject;
    }
    return result;
  }

  ///Creates widget for the popup image
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

  /// Requests the api service to get the confirmed orders
  Future<void> getConfirmedOrder() async {
    List<Order> orders;
    orders = await apiService.getAdminConfirmedOrders();
    setState(() {
      confirmedOrders = orders;
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
