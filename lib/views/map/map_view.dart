import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ship_organizer_app/api handling/api_controller.dart';
import 'package:ship_organizer_app/entities/report.dart';

/// A map view
/// It implements a Google map
/// In the map are markers which show how much equipment has been used there
/// pressing a marker brings up a drawer from the bottom with more details
/// about what items have been used there
class MapView extends StatefulWidget {
  const MapView({
    Key? key,
    this.itemToShow,
  }) : super(key: key);
  final String? itemToShow;

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Location _location = Location();

  ApiService apiService = ApiService.getInstance();

  Map<LatLng, List<Report>> markerLocations = <LatLng, List<Report>>{};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int min = 1;
  int max = 2;

  @override
  Widget build(BuildContext context) {
    apiService.setContext(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.itemToShow == null
              ? AppLocalizations.of(context)!.map
              : AppLocalizations.of(context)!.mapOf + widget.itemToShow!,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Stack(children: [
        GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          markers: Set<Marker>.of(markers.values),
          initialCameraPosition: const CameraPosition(
            target: LatLng(63.353506, 4.944406),
            zoom: 7,
          ),
        ),
        markerLocations.isEmpty || (max == min)
            ? const Positioned(child: Text(""))
            : Positioned(
                top: 1,
                right: 1,
                child: Column(
                  children: [
                    Container(
                      width: 75,
                      color: Theme.of(context).colorScheme.onPrimary,
                      child: Text(
                        AppLocalizations.of(context)!.amount,
                      ),
                    ),
                    Container(
                        height: 150.0,
                        width: 75.0,
                        color: Theme.of(context).colorScheme.onPrimary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                child: Column(
                              children: [
                                Text(max.toString(),
                                    style: Theme.of(context).textTheme.caption,
                                    overflow: TextOverflow.ellipsis),
                                Text(((max + min) / 2).toString(),
                                    style: Theme.of(context).textTheme.caption,
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                  min.toString(),
                                  style: Theme.of(context).textTheme.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            )),
                            RotatedBox(
                              quarterTurns: 3,
                              child: Image.asset(
                                "assets/hue.jpeg",
                              ),
                            ),
                          ],
                        )),
                  ],
                )),
      ]),
    );
  }

  /// Happens when the map is first created.
  /// Adds markers to the map and moves the camera to center around
  /// the users location
  Future<void> _onMapCreated(GoogleMapController _controller) async {
    _controller = _controller;
    var currentLocation = await _location.getLocation();
    addMarkers();
    _controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(currentLocation.latitude!, currentLocation.longitude!), 7));
  }

  /// Adds markers to the map
  /// First the map of locations is sorted according to how many items are present at each location
  /// a marker is created for each of the location and its hue is set depending on how many items
  /// are present at the location
  Future<void> addMarkers() async {
    if (widget.itemToShow != null) {
      markerLocations =
          await apiService.getAllMarkersWithName(widget.itemToShow!);
    } else {
      markerLocations = await apiService.getAllMarkers();
    }

    List<List<Report>> sortedList = markerLocations.values.toList()
      ..sort((a, b) =>
          getAmountOfItemsAtMarker(a).compareTo(getAmountOfItemsAtMarker(b)));
    max = getAmountOfItemsAtMarker(sortedList.last);
    min = getAmountOfItemsAtMarker(sortedList.first);

    markerLocations.forEach((latLng, item) {
      String markerIdVal =
          latLng.toString().replaceAll("LatLng(", "").replaceAll(")", "");
      final MarkerId markerId = MarkerId(markerIdVal);

      final Marker marker = Marker(
        markerId: markerId,
        position: latLng,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(calculateHue(item, max, min)),
        infoWindow: InfoWindow(
            title: markerIdVal.toString(),
            snippet: getAmountOfItemsAtMarker(item).toString() +
                AppLocalizations.of(context)!.itemsUsedHere,
            onTap: () => {
                  apiService.getAllMarkers(),
                  if (item.isNotEmpty) {showMenu(item)}
                }),
      );

      setState(() {
        // adding a new marker to map
        markers[markerId] = marker;
      });
    });
  }

  /// Adds together the quantities of each item on a marker
  int getAmountOfItemsAtMarker(List<Report> reports) {
    int amount = 0;

    for (Report report in reports) {
      amount += report.quantity!;
    }
    return amount;
  }

  /// Method for calculating the hue of markers
  /// Using a max and min value of amount of equipment per marker this
  /// method is able to calculate a hue value from 0 up to but not including 360
  double calculateHue(List<Report> marker, int max, int min) {
    double hue = 0;

    if (max != min) {
      hue = ((getAmountOfItemsAtMarker(marker) - min) / (max - min)) * 265;
    }
    // hue has to be 0 <= hue < 360
    // This function normalizes the value to be between 0 and 265 so that each marker can get a
    // hue relative to the amount of equipment that is present there, it stops at 265 because closer
    // to 360 the colors start to get similar to the ones around 0

    return hue;
  }

  /// Shows a description of the marker which has been pressed
  /// This makes a widget pop up from the bottom of the screen
  /// In it the details of what equipment has been left there is shown
  showMenu(List<Report> item) {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.primary,
        context: context,
        builder: (BuildContext context) {
          return Scrollbar(
            isAlwaysShown: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                    height: (56 * 6).toDouble(),
                    child: Stack(
                      alignment: const Alignment(0, 0),
                      children: <Widget>[
                        Positioned(
                          child: ListView(
                            children: createListView(item),
                          ),
                        )
                      ],
                    )),
              ],
            ),
          );
        });
  }

  /// Takes in a List of Strings to creates a List of ListTiles
  /// Each tile is styled the same.
  List<Widget> createListView(List<Report> item) {
    final equipments = <Widget>[];

    for (Report descriptiveItem in item) {
      equipments.add(ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Text(
                descriptiveItem.name! +
                    " x" +
                    descriptiveItem.quantity.toString(),
                style: Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.fade,
              ),
              width: 175,
            ),
            Text(
              descriptiveItem.getLatLng(),
              style: Theme.of(context).textTheme.subtitle2,
            )
          ],
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(descriptiveItem.userName!,
                    style: Theme.of(context).textTheme.subtitle2),
                Text(
                    descriptiveItem.registrationDate.toString().split(":")[0] +
                        ":" +
                        descriptiveItem.registrationDate
                            .toString()
                            .split(":")[1],
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15))
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            Divider(
              color: Theme.of(context).disabledColor,
            ),
          ],
        ),
        tileColor: Theme.of(context).colorScheme.primary,
      ));
    }

    return equipments;
  }
}
