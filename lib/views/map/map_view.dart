import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

/// A map view
/// It implements a Google map
/// In the map are markers which show how much equipment has been used there
/// pressing a marker brings up a drawer from the bottom with more details
/// about what items have been used there
class MapView extends StatefulWidget {
  const MapView({Key? key, this.itemToShow,}) : super(key: key);
  final String? itemToShow;

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Location _location = Location();

  //TODO Get marker locations from backend
  Map<LatLng, List<List<String>>> exampleLocations = {
    const LatLng(63.41745, 4.40407): <List<String>>[],
    const LatLng(62.47210, 4.23550): <List<String>>[
      ["Booey", "2", "Hans", "17.12.2022"],
      ["Chain", "1", "Johannes", "11.12.2022"],
      ["Weapond", "5", "Kurt", "25.12.2022"],
      ["Fishing net", "3", "Kjellern", "16.12.2022"],
      ["Lamp", "2", "Simon", "30.12.2022"],
      ["Booey", "2", "Hans", "17.12.2022"],
      ["Chain", "1", "Johannes", "11.12.2022"],
      ["Weapond", "5", "Kurt", "25.12.2022"],
      ["Fishing net", "3", "Kjellern", "16.12.2022"],
      ["Lamp", "2", "Simon", "30.12.2022"],
      ["Booey", "2", "Hans", "17.12.2022"],
      ["Chain", "1", "Johannes", "11.12.2022"],
      ["Weapond", "5", "Kurt", "25.12.2022"],
      ["Fishing net", "3", "Kjellern", "16.12.2022"],
      ["Lamp", "2", "Simon", "30.12.2022"],
    ],
    const LatLng(60.78890, 4.68110): <List<String>>[
      ["Booey", "Number", "Username", "DateTime"],
      ["Booey", "Number", "Username", "DateTime"],
      ["Booey", "Number", "Username", "DateTime"],
      ["Booey", "Number", "Username", "DateTime"],
      ["Booey", "Number", "Username", "DateTime"],
    ]
  };

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.map,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        markers: Set<Marker>.of(markers.values),
        initialCameraPosition: const CameraPosition(
          target: LatLng(63.353506, 4.944406),
          zoom: 7,
        ),
      ),
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
  void addMarkers() {
    List<List<List<String>>> sortedList = exampleLocations.values.toList()
      ..sort((a, b) => a.length.compareTo(b.length));
    int max = sortedList.last.length;
    int min = sortedList.first.length;

    exampleLocations.forEach((latLng, item) {
      String markerIdVal = latLng.toString().replaceAll("LatLng(", "").replaceAll(")", "");
      final MarkerId markerId = MarkerId(markerIdVal);

      final Marker marker = Marker(
        markerId: markerId,
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(calculateHue(item, max, min)),
        infoWindow: InfoWindow(
            title: markerIdVal.toString(),
            snippet: item.length.toString() + " Items used here",
            onTap: () => {
                  if (item.isNotEmpty) {showMenu(item)}
                }),
      );

      setState(() {
        // adding a new marker to map
        markers[markerId] = marker;
      });
    });
  }

  /// Method for calculating the hue of markers
  /// Using a max and min value of amount of equipment per marker this
  /// method is able to calculate a hue value from 0 up to but not including 360
  double calculateHue(List<List<String>> marker, int max, int min) {
    double hue = 0;

    hue = ((marker.length - min) / (max - min)) * 270; // hue has to be 0 <= hue < 360
    // This function normalizes the value to be between 0 and 240 so that each marker can get a
    // hue relative to the amount of equipment that is present there, it stops at 240 because close
    // to 360 the colors start to get similar to the ones around 0

    return hue;
  }

  /// Shows a description of the marker which has been pressed
  /// This makes a widget pop up from the bottom of the screen
  /// In it the details of what equipment has been left there is shown
  showMenu(List<List<String>> item) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
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
  List<Widget> createListView(List<List<String>> item) {
    final equipments = <Widget>[];

    for (List<String> descriptiveItem in item) {
      equipments.add(ListTile(
        title: Text(descriptiveItem[0] + " x" + descriptiveItem[1],
            style: Theme.of(context).textTheme.headline6),
        subtitle: Column(
          children: [
            Row(
              children: [
                Text(descriptiveItem[2], style: Theme.of(context).textTheme.subtitle2),
                Text(descriptiveItem[3], style: Theme.of(context).textTheme.subtitle2)
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
