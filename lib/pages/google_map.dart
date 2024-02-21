// import 'dart:html';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:flutter_google_map/consts.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_directions_api/google_directions_api.dart' as directions;
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
// import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as location;
import 'package:google_maps_utils/google_maps_utils.dart';
// import 'package:location_permissions/location_permissions.dart';

class Google_Map extends StatefulWidget {
  final Function(int) onTimeReceived;
  final String source;
  final double destinationLat;
  final double destinationLng;
  final String navigation;
  // LatLng currentP;

  Google_Map({
    required this.onTimeReceived,
    required this.source,
    required this.destinationLat,
    required this.destinationLng,
    required this.navigation,
    // required this.currentP,
  });

  //const Map2({super.key});

  @override
  State<Google_Map> createState() => _MyAppState();
}

class _MyAppState extends State<Google_Map> {
  location.Location _locationController = new location.Location();
  LatLng _currentP = LatLng(24.123988, 120.675187);
  // late GooglePlace googlePlace;
  late GoogleMapController mapController;
  TextEditingController StartController = TextEditingController();
  TextEditingController DesController = TextEditingController();

  final directinosService = directions.DirectionsService(); // 添加一个存储返回值的变量
  // LatLng originLatLng = LatLng(40.7128, -74.0060); // New York
  // LatLng destinationLatLng = LatLng(37.7749, -76.0060);
  //this is for tarval time
  var request = directions.DirectionsRequest(
    origin: '24.123988, 120.675187', // Chicago, IL coordinates
    destination: '37.4119983, -122.074',
    travelMode: directions.TravelMode.driving,
  );

  final player = AudioPlayer();
  AudioStream _audioStream = AudioStream.music;
  double _volume = 0;

  //this is for draw the path on map
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  // List<LatLng> polylineCoordinates = [];
  double _originLatitude = 24.123988, _originLongitude = 120.675187;
  // double _destLatitude = 37.4119983, _destLongitude = -122.074;
  // these are for check if position on path
  Point from = Point(37.4319983, -122.094);
  Point to = Point(37.4119983, -122.074);
  Point now = Point(37.4219983, -122.084);

  List<Point> polylineee = [];
  int pointnum = 0;

  PolylinePoints polylinePoints = PolylinePoints();
  PolylineResult result = PolylineResult();

  bool isOldPath = true;
  bool isShowDialog = false;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
    _originLatitude = _currentP.latitude;
    _originLongitude = _currentP.longitude;
    from = Point(_currentP.latitude, _currentP.longitude);
    now = Point(_currentP.latitude, _currentP.longitude);
    to = Point(widget.destinationLat, widget.destinationLng);
    polylineee.add(from);
    // if (widget.source != null) {
    //   autoCompleteSearch(widget.source);
    // }
    //use tarval travel time api have to init with api first
    directions.DirectionsService.init(GOOGLE_MAPS_API_KEY);

    //add start marker on map
    // _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
    //     BitmapDescriptor.defaultMarker);

    // and end marker on map
    // _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
    //     BitmapDescriptor.defaultMarkerWithHue(90));
    //_startCountdown();
    //setSource();
    // _audioPlayer.setSourceAsset(audioUrl);
    //get the path point
    // listenVolume();
    getvolume();
    _getPolyline();
    Future.delayed(Duration.zero, () {
      this._checkOnpath(context);
    });
  }

  final LatLng _center = const LatLng(37.4219983, -122.084);
  @override
  void dispose() {
    StartController.dispose();
    DesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          polylines: Set<Polyline>.of(
              polylines.values), //have to set path point on map
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(24.123988, 120.675187), // 初始地图中心坐标
            zoom: 12.0, // 初始缩放级别
          ),
          // markers: Set<Marker>.of(markers.values), //have to set maker on map
          markers: {
            Marker(
              markerId: MarkerId("currentLocation"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              position: _currentP,
            ),
            Marker(
              markerId: MarkerId("source"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueYellow),
              position: LatLng(_originLatitude, _originLongitude),
            ),
            Marker(
              markerId: MarkerId("destination"),
              icon: BitmapDescriptor.defaultMarker,
              position: LatLng(widget.destinationLat, widget.destinationLng),
            ),
          },
        ),
      ),
    );
  }

  //maker configuration
  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  //path configuration
  _addPolyLine(List<LatLng> polylineCoordinates, String ID) {
    // print(polylineCoordinates);
    PolylineId id = PolylineId(ID);
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 6);
    polylines[id] = polyline;
    setState(() {});
  }

  _addOldPolyLine(List<LatLng> polylineCoordinates, String oldID) {
    // print(polylineCoordinates);
    PolylineId id = PolylineId(oldID);
    Polyline polyline = Polyline(
        polylineId: id,
        color: Color.fromARGB(255, 175, 175, 175),
        points: polylineCoordinates,
        width: 6);
    polylines[id] = polyline;
    setState(() {});
  }

  _getthepath(LatLng start, LatLng end, bool isOldPath, String ID) async {
    List<LatLng> polylineCoordinates = [];
    // print(isOldPath);
    // print(polylineCoordinates);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAPS_API_KEY,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
      travelMode: TravelMode.bicycling,
      //it have to set in the same localtion with the start localtion and end localtion
      // wayPoints: [
      //   PolylineWayPoint(location: "24.12575667987216, 120.67524843702927")
      // ]
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        if (pointnum != 1) {
          polylineee.add(Point(point.latitude, point.longitude));
        }
        print(result);
      });
    }
    if (isOldPath) {
      _addOldPolyLine(polylineCoordinates, ID);
    } else {
      _addPolyLine(polylineCoordinates, ID);
    }
  }

  _getPolyline() async {
    //get the path point with api

    // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    //     GOOGLE_MAPS_API_KEY,
    //     PointLatLng(_originLatitude, _originLongitude),
    //     PointLatLng(_destLatitude, _destLongitude),
    //     travelMode: TravelMode.bicycling,
    //     //it have to set in the same localtion with the start localtion and end localtion
    //     wayPoints: [
    //       PolylineWayPoint(location: "24.12575667987216, 120.67524843702927")
    //     ]);
    // if (result.points.isNotEmpty) {
    //   result.points.forEach((PointLatLng point) {
    //     polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    //     polylineee.add(Point(point.latitude, point.longitude));
    //     print(result);
    //   });
    // }

    //set direction travel mode
    if (widget.navigation == "Driving") {
      request = directions.DirectionsRequest(
        origin: '24.123988, 120.675187', // Chicago, IL coordinates
        destination: '${widget.destinationLat}, ${widget.destinationLng}',
        travelMode: directions.TravelMode.driving,
      );
    } else if (widget.navigation == "Bicycling") {
      request = directions.DirectionsRequest(
        origin: '24.123988, 120.675187', // Chicago, IL coordinates
        destination: '${widget.destinationLat}, ${widget.destinationLng}',
        travelMode: directions.TravelMode.bicycling,
      );
    } else if (widget.navigation == "Walking") {
      request = directions.DirectionsRequest(
        origin: '24.123988, 120.675187', // Chicago, IL coordinates
        destination: '${widget.destinationLat}, ${widget.destinationLng}',
        travelMode: directions.TravelMode.walking,
      );
    }

    //get the travel time
    directinosService.route(request, (directions.DirectionsResult? response,
        directions.DirectionsStatus? status) {
      if (status == directions.DirectionsStatus.ok) {
        if (response != null &&
            response.routes != null &&
            response.routes!.isNotEmpty) {
          final firstRoute = response.routes!.first;

          // Check if the route contains at least one leg
          if (firstRoute.legs != null && firstRoute.legs!.isNotEmpty) {
            // Access the first leg's duration
            final duration = firstRoute.legs!.first.duration;

            // Now, you can use 'duration' as needed
            print("Travel time: ${duration?.text}");

            print("tra: ${duration?.value}");
            if (duration != null) {
              // Access the duration value in seconds
              final durationInSeconds = duration.value;

              // Check if durationInSeconds is not null before using it
              if (durationInSeconds != null) {
                // Explicitly cast durationInSeconds to int
                final durationInInt = durationInSeconds.toInt();

                // Now, you can use 'durationInInt' as needed
                print("Travel time in seconds: $durationInInt");
                widget.onTimeReceived(durationInInt);
              } else {
                print("Error: Duration value is null");
                // Handle the case when durationInSeconds is null
              }
            } else {
              print("Error: No duration found in the route");
              // Handle the case when no duration is found
            }
            // You may also want to extract other information such as distance, steps, etc.
            // For example: final distance = firstRoute.legs.first.distance;
          } else {
            print("Error: No legs found in the route");
            // Handle the case when no legs are found
          }
        } else {
          print("Error: No routes found");
          // Handle the case when no routes are found
        }
      } else {
        // If the status is not OK, handle the error
        // You can log the error or take appropriate action
        print("Error flutter: $status");
        // You may also want to inspect the response for more details about the error
      }

      // Now, you can use 'duration' as needed
    });
    isOldPath = false;
    pointnum = 1;
    _getthepath(
        LatLng(_originLatitude, _originLongitude),
        LatLng(widget.destinationLat, widget.destinationLng),
        isOldPath,
        "complete");
    pointnum = 0;
    isOldPath = true;
    _getthepath(LatLng(_originLatitude, _originLongitude), _currentP, isOldPath,
        "oldpoly");
    polylineee.add(now);
    isOldPath = false;
    _getthepath(_currentP, LatLng(widget.destinationLat, widget.destinationLng),
        isOldPath, "poly");
    polylineee.add(to);
    pointnum = 1;
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Set<Marker> _createMarkers() {
    final lat = double.tryParse(StartController.text) ?? 24.123777;
    final lng = double.tryParse(DesController.text) ?? 120.675006;

    return {
      Marker(
        markerId: MarkerId('Marker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: 'Marker Title'),
      ),
    };
  }

  void getvolume() async {
    // get system volume
    final volume =
        await FlutterVolumeController.getVolume(stream: _audioStream);
    _volume = volume as double;
    print("_volume");
    print(_volume);
  }

  void play() async {
    getvolume();

    // set system volume to max volume
    FlutterVolumeController.setVolume(1, stream: _audioStream);

    // Max volume
    player.setVolume(1);

    // play by loop
    player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource('audio/beep-warning.mp3'));
  }

  void stopplay() async {
    // set system volume to origin volume
    FlutterVolumeController.setVolume(_volume, stream: _audioStream);
    await player.stop();
  }

  void _checkOnpath(BuildContext context) async {
    // print(polylineee);
    bool isOnPath = PolyUtils.isLocationOnPathTolerance(
        Point(_currentP.latitude, _currentP.longitude), polylineee, false, 300);
    print("isonpath:" + isOnPath.toString());
    if (!isOnPath && !isShowDialog) {
      __showNotOnPathDialog(context);
    }
  }

  void __showNotOnPathDialog(BuildContext context) {
    isShowDialog = true;
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('⚠️Warning'),
        content: const Text(
          'You have deviated from the planning path.\nAre you in danger?',
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => {play()},
            child: const Text('YES'),
          ),
          TextButton(
            onPressed: () => {
              stopplay(),
              Navigator.pop(context, 'No'),
              isShowDialog = false,
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    location.PermissionStatus _permissionGranted;
    _serviceEnabled = await _locationController.serviceEnabled() as bool;
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService() as bool;
    } else {
      return;
    }
    _permissionGranted =
        await _locationController.hasPermission() as location.PermissionStatus;
    if (_permissionGranted == location.PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission()
          as location.PermissionStatus;
      if (_permissionGranted != location.PermissionStatus.granted) {
        return;
      }
    }
    int i = 0;
    _locationController.onLocationChanged
        .listen((location.LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          i++;
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);

          // update the polyline

          String ID, oldID;
          if (i % 2 == 0) {
            oldID = "earlyoldpoly";
            ID = "earlypoly";
          } else {
            oldID = "oldpoly";
            ID = "poly";
          }
          // print("i=" + i.toString());
          // if (i == 15 || i == 16) {
          //   _currentP = LatLng(24.123988, 120.675187);
          // }
          isOldPath = true;
          _getthepath(
            LatLng(_originLatitude, _originLongitude),
            _currentP,
            isOldPath,
            oldID,
          );
          // isOldPath = false;
          // _getthepath(
          //   _currentP,
          //   LatLng(widget.destinationLat, widget.destinationLng),
          //   isOldPath,
          //   ID,
          // );

          // check if deviation
          _checkOnpath(context);

          print("CurrentLocation: " + _currentP.toString());
        });
      }
    });
  }
}
