import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';

/// Creates a widget that is used as a top bar for the inventory views in the ship organizer app.
///
/// For use as app bar in scaffold, it needs to be wrapped in a [PreferredSize] widget.
/// Allows custom functions as well as icons for buttons.
class TopBar extends StatefulWidget {
  const TopBar(
      {Key? key,
      this.onMenuPressed,
      this.onSearch,
      this.filter,
      this.onScan,
      this.onClear,
      this.searchFieldController,
      this.menuIcon,
      this.searchIcon,
      this.clearIcon,
      this.filterIcon,
      required this.isMobile,
      required this.isRecommendedView,
      this.scanIcon})
      : super(key: key);

  final void Function()? onMenuPressed;
  final void Function()? onSearch;
  final void Function()? filter;
  final void Function()? onScan;
  final void Function()? onClear;
  final TextEditingController? searchFieldController;
  final Icon? menuIcon;
  final Icon? searchIcon;
  final Icon? clearIcon;
  final Icon? filterIcon;
  final Icon? scanIcon;
  final bool isRecommendedView;
  final bool isMobile;

  @override
  State<StatefulWidget> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late bool isRecommendedView = widget.isRecommendedView;
  bool hasMultipleDepartments = false;
  late bool isMobile = widget.isMobile;

  /// If no function is specified, menu button tries to open [Drawer] in [Scaffold]
  void Function()? get _onMenuPressed =>
      widget.onMenuPressed ??
      () {
        Scaffold.of(context).hasDrawer
            ? Scaffold.of(context).openDrawer()
            : null;
      };

  void Function()? get _onSearch => widget.onSearch;

  void Function()? get _filter => widget.filter;

  void Function()? get _onScan => widget.onScan;

  void Function()? get _onClear => widget.onClear;

  @override
  void initState() {
    super.initState();
    getDepartments();
  }

  Future<void> getDepartments() async {
    ApiService _apiService = ApiService.getInstance();
    List<String> departments = await _apiService.getDepartments();
    if (departments.length > 1) {
      setState(() {
        hasMultipleDepartments = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).viewPadding.top, 0, 0),
        color: Theme.of(context).colorScheme.primary,
        child: isMobile ? buildMobileRow(context) : buildTabletRow(context));
  }

  Row buildTabletRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              "Ship Organizer",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        Expanded(flex: 4, child: buildSearchFieldContainer(context)),
        hasMultipleDepartments
            ? getCameraAndFilterRow(context)
            : getCameraRow(context),
      ],
    );
  }

  Row buildMobileRow(BuildContext context) {
    return Row(
      children: [
        isRecommendedView
            ? IconButton(
                onPressed: () => {
                      FocusScope.of(context).requestFocus(FocusNode()),
                      Navigator.of(context).pop()
                    },
                icon: widget.menuIcon ??
                    Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 32.0,
                    ))
            : IconButton(
                onPressed: _onMenuPressed,
                icon: widget.menuIcon ??
                    Icon(
                      Icons.menu,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 32.0,
                    )),
        Flexible(child: buildSearchFieldContainer(context)),
        hasMultipleDepartments
            ? getCameraAndFilterRow(context)
            : getCameraRow(context)
      ],
    );
  }

  Container buildSearchFieldContainer(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: TextField(
          controller: widget.searchFieldController,
          onEditingComplete: _onSearch,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            hintText: AppLocalizations.of(context)!.search + "...",
            suffixIcon: IconButton(
                onPressed: _onClear ?? widget.searchFieldController?.clear,
                icon: widget.clearIcon ??
                    Icon(Icons.clear,
                        color: Theme.of(context).colorScheme.primary)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
        ));
  }

  Row getCameraRow(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _onScan,
          icon: widget.scanIcon ??
              Icon(
                Icons.camera_alt_sharp,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 32.0,
              ),
        ),
      ],
    );
  }

  Row getCameraAndFilterRow(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _onScan,
          icon: widget.scanIcon ??
              Icon(
                Icons.camera_alt_sharp,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 32.0,
              ),
        ),
        IconButton(
          onPressed: _filter,
          icon: widget.filterIcon ??
              Icon(Icons.filter_alt_sharp,
                  color: Theme.of(context).colorScheme.onPrimary, size: 32.0),
        ),
      ],
    );
  }
}