import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bottom_navigation_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Bottom navigation bar widget is used for quickly navigating
/// Between the two main views of the app, the inventory view and profile view
/// By pressing the item (icon and text) the user is pushed to the corresponding view
class BottomNavigationBarWidget extends ConsumerWidget {
  const BottomNavigationBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _indexState = watch(bottomNavigationBarIndexProvider);
    final _indexNotifier = watch(bottomNavigationBarIndexProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    List<BottomNavigationBarItem> getNavigationBarItem() {
      List<BottomNavigationBarItem> barItemsList = [];
      barItemsList.add(BottomNavigationBarItem(
          label: AppLocalizations.of(context)!.inventory,
          icon: const Icon(Icons.inventory_rounded)));
      barItemsList.add(BottomNavigationBarItem(
          label: AppLocalizations.of(context)!.profile, icon: const Icon(Icons.person)));
      return barItemsList;
    }

    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indexState,
        backgroundColor: colorScheme.primary,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.onPrimary.withOpacity(.60),
        selectedLabelStyle: textTheme.caption,
        unselectedLabelStyle: textTheme.caption,
        onTap: (value) => {_indexNotifier.updateIndex(value)},
        items: getNavigationBarItem());
  }
}
