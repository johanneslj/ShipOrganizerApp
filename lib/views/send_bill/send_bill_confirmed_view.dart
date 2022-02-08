import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GridView.count(
      crossAxisCount: 1,
      children: List.generate(1, (index) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
                child: GestureDetector(
                  onTap: () async {
                    await showDialog(context: context, builder: (_) => imageDialog());
                  },
                ),
                radius: 100.0,
                backgroundImage: const AssetImage('assets/FishingBoatSilhouette.jpg')),
            Text(AppLocalizations.of(context)!.changeImageSize,
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                )),
            widget.admin
                ? const Text("")
                : TextButton(
                    onPressed: () {
                      sendToServer(index);
                    },
                    child: Text(AppLocalizations.of(context)!.confirm,
                        style: const TextStyle(
                          fontSize: 20.0,
                        )))
          ],
        ));
      }),
    ));
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
  void sendToServer(int index) {
    //TODO Add server access
    // Need image-name and department name
  }
}
