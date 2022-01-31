import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
/// Class for the pending bills tab in the send_bill_view
/// This class is responsible for the view where the admin can
/// check the bills that are not confirmed.
class pendingBill extends StatefulWidget {
  final ValueChanged<String> parentAction;

  const pendingBill({Key? key, required this.parentAction}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _pendingBill();
}

class _pendingBill extends State<pendingBill> {

  final List<String> departments = <String>["Bridge", "Factory", "Deck"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () {
            return Future.delayed(
              const Duration(seconds: 1),
                (){
                setState(() {
                  //TODO get from backend server
                    departments.clear();
                    departments.addAll(["Bridge", "Factory", "Deck","Hei"]);
                    widget.parentAction(departments.length.toString());
                });
                }
            );
          },
          child:GridView.count(
            crossAxisCount: 2,
            children: List.generate(departments.length, (index) {
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                          child: GestureDetector(
                            onTap: () async {
                              await showDialog(
                                  context: context, builder: (_) => imageDialog());
                            },
                          ),
                          radius: 50.0,
                          //Photo by Tamas Tuzes-Katai on Unsplash
                          backgroundImage:
                          const AssetImage('assets/FishingBoatSilhouette.jpg')),
                      Text(
                        AppLocalizations.of(context)!.changeImageSize,
                        style: const TextStyle(
                          fontSize: 10.0,

                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        "Department name here",
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ));
            }),
          ),

        )

        ));
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
