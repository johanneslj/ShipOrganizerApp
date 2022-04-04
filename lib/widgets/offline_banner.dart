import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfflineBanner {
  static MaterialBanner getBanner(BuildContext context) {
    return MaterialBanner(
        content: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            color: Theme
                .of(context)
                .errorColor,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                AppLocalizations.of(context)!.offline,
                style: TextStyle(color: Theme
                    .of(context)
                    .colorScheme
                    .onError),
                textAlign: TextAlign.center,
              )
            ])),
        actions: [TextButton(
          onPressed: () {
          ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
        },
        child: Text("Dismiss"))]);
  }
}