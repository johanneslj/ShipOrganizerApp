import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/entities/Order.dart';

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

  dataLoadFunction() async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });
    await getConfirmedOrder();
    // fetch you data over here
    setState(() {
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }

  @override
  Widget build(BuildContext context) {
    apiService.setContext(context);
    return Scaffold(
        body: _isLoading ? circularProgress() :
        GridView.builder(
            itemCount: confirmedOrders.length,
            itemBuilder: (BuildContext context, int index) {
              NetworkImage image = NetworkImage(apiService.imagesBaseUrl + confirmedOrders[index].imagename);
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
                    ],
                  ));
            }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        )),
    );
  }

  ///Creates widget for the popup image
  Widget imageDialog(NetworkImage image) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: image, fit: BoxFit.cover)),
      ),
    );
  }

  Future<void> getConfirmedOrder() async {
    List<Order> orders;
    if(widget.admin){
      orders = await apiService.getAdminConfirmedOrders();
    }
    else{
      orders = await apiService.getUserConfirmedOrders();
    }

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
