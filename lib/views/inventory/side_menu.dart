import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/views/login/login_view.dart';
import 'package:ship_organizer_app/views/map/map_view.dart';

/// Creates a side menu for use as a [Drawer] in a [Scaffold] for the ship organizer app.
///
class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).viewPadding.top),
                Center(
                  heightFactor: 2,
                  child: Text("Ship Organizer", style: Theme.of(context).textTheme.headline6,)),
                const Divider(),
                // TODO Add routes
                _createRouteTextButton(
                    context, AppLocalizations.of(context)!.scanNewInventory, Icon(Icons.archive_sharp), '/inventory'),
                const Divider(),
                _createRouteTextButton(context, AppLocalizations.of(context)!.map, Icon(Icons.pin_drop_sharp), '/map'),
                const Divider(),
                _createRouteTextButton(context, AppLocalizations.of(context)!.addProduct, Icon(Icons.shopping_cart_sharp), '/'),
                const Divider(),
                _createRouteTextButton(
                    context, AppLocalizations.of(context)!.recommendedInventory, Icon(Icons.inventory_sharp), '/recommendedInventory'),
              ],
            )),
            Expanded(
                child: Align(
              alignment: Alignment.bottomLeft,
              child: TextButton(
                  onPressed: () {},
                  child: Text(
                    AppLocalizations.of(context)!.logOut,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        decoration: TextDecoration.underline),
                  )),
            ))
          ],
        ));
  }

  Widget _createRouteTextButton(BuildContext context, String text, Icon icon, String route) {
    return TextButton.icon(
        onPressed: () => {
              if (route != null)
                {
                  Navigator.pushNamed(context, route)
                }
            },
        icon: icon,
        label: Text(text, style: Theme.of(context).textTheme.headline6));
  }
}
