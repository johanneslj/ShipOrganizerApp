import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';
import 'package:ship_organizer_app/entities/Order.dart';

/// Class for the confirmed bills tab in the send_bill_view
/// This class is responsible for the view where the admin can
/// check the bills that are confirmed.
/// And for the normal user, can here set the bills as confirmed.
class ConfimedBill extends StatefulWidget {
  final bool admin;

  const ConfimedBill({Key? key, required this.admin}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _confimedBill();
}

class _confimedBill extends State<ConfimedBill> {
  late List<Order> confirmedOrders = <Order>[];
  late bool _isLoading = false;


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
    return Scaffold(
        body: _isLoading ? circularProgress() :
        GridView.builder(
      itemCount: confirmedOrders.length,
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
                          radius: 75.0,
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
                        confirmedOrders[index].department.toString(),
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      widget.admin ? const Text("") :
                      ElevatedButton(onPressed: () => sendToServer(index),
                      child: Text(AppLocalizations.of(context)!.confirm),)
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

  /// Function to send notice to the server that the bill has been confirmed
  Future<void> sendToServer(int index) async{
    ApiService apiService = ApiService(context);
    String imageName = confirmedOrders[index].imagename;
    String departmentName = confirmedOrders[index].department;
    await apiService.updateOrder(imageName, departmentName);
    getConfirmedOrder();
  }

  Future<void> getConfirmedOrder() async {
    ApiService apiService = ApiService(context);
    List<Order> userOrders = await apiService.getUserConfirmedOrders();
    List<Order> adminOrders = await apiService.getAdminConfirmedOrders();

    setState(() {
      if(widget.admin){
        confirmedOrders = adminOrders;
      }
      else {
        confirmedOrders = userOrders;
      }

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
