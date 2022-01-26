import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Creates a widget that is used as a top bar for the inventory views in the ship organizer app.
///
/// For use as app bar in scaffold, it needs to be wrapped in a [PreferredSize] widget.
/// Allows custom functions as well as icons for buttons.
class TopBar extends StatefulWidget {
  const TopBar({Key? key,
    this.onMenuPressed,
    this.onSearch,
    this.filter,
    this.onScan,
    this.onClear,
    this.controller,
    this.menuIcon,
    this.searchIcon,
    this.clearIcon,
    this.filterIcon,
    this.scanIcon})
      : super(key: key);

  /// Function called when the menu button is pressed.
  final void Function()? onMenuPressed;

  /// Function called when search button is pressed.
  final void Function()? onSearch;

  /// Function called when filter button is pressed.
  final void Function()? filter;

  /// Function called when the scan button in the top bar is pressed.
  final void Function()? onScan;

  final void Function()? onClear;

  /// Controller for search [TextField].
  final TextEditingController? controller;

  /// Icon for menu button. If null [Icons.menu] is used.
  final Icon? menuIcon;

  /// Icon for menu button. If null [Icons.search] is used.
  final Icon? searchIcon;

  /// Icon for menu button. If null [Icons.clear] is used.
  final Icon? clearIcon;

  /// Icon for menu button. If null [Icons.filter_alt_sharp] is used.
  final Icon? filterIcon;

  final Icon? scanIcon;

  @override
  State<StatefulWidget> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  /// If no function is specified, menu button tries to open [Drawer] in [Scaffold]
  void Function()? get _onMenuPressed =>
      widget.onMenuPressed ??
              () {
            Scaffold
                .of(context)
                .hasDrawer ? Scaffold.of(context).openDrawer() : null;
          };

  void Function()? get _onSearch => widget.onSearch;

  void Function()? get _filter => widget.filter;

  void Function()? get _onScan => widget.onScan;

  void Function()? get _onClear => widget.onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, MediaQuery
            .of(context)
            .viewPadding
            .top, 0, 0),
        color: Theme
            .of(context)
            .colorScheme
            .primary,
        child: Row(
          children: [
            IconButton(
                onPressed: _onMenuPressed,
                icon: widget.menuIcon ??
                    Icon(
                      Icons.menu,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onPrimary,
                    )),
            Flexible(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                    child: TextField(
                      controller: widget.controller,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        hintText: AppLocalizations.of(context)!.search + "...",
                        suffixIcon: IconButton(
                            onPressed: _onClear ?? widget.controller?.clear,
                            icon: widget.clearIcon ??
                                Icon(Icons.clear, color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      ),
                    ))),
            IconButton(
                onPressed: _onSearch,
                icon: widget.searchIcon ??
                    Icon(Icons.search, color: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary)),
            IconButton(
                onPressed: _onScan,
                icon: widget.scanIcon ??
                    Icon(Icons.camera_alt_sharp, color: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary)),
            IconButton(
                onPressed: _filter,
                icon: widget.filterIcon ??
                    Icon(
                      Icons.filter_alt_sharp,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onPrimary,
                    ))
          ],
        ));
  }
}
