import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_google_map/consts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'pages/google_map.dart';
import 'dart:async';
import 'package:location/location.dart' as location;
import 'package:http/http.dart' as http;

class BPage extends StatefulWidget {
  @override
  _BPageState createState() => _BPageState();
}

// 24.12624, 120.6751733
class _BPageState extends State<BPage> {
  // location.Location _locationController = new location.Location();
  // late LatLng _currentP;
  late GoogleMapController mapController;
  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  String navigation = "car";

  late double latitude;
  late double longitude;

  bool isMapVisible = false; // visible for map

//for audio
  final player = AudioPlayer();
//end audio

//for timer
  Timer? _timer;
  int _remainingHours;
  int _remainingSeconds;
  int _remainingMinutes;
  Timer? _callTimer;
  late AudioPlayer _audioPlayer;

  _BPageState({
    int startSeconds = 0,
  })  : _remainingSeconds = startSeconds,
        _remainingMinutes = 00,
        _remainingHours = 0;
  //end timer

  @override
  void initState() {
    // getLocationUpdates();
    super.initState();
    //_startCountdown();
    //setSource();
    // _audioPlayer.setSourceAsset(audioUrl);
  }

//for audio

  void play() async {
    await player.play(AssetSource('audio/beep-warning.mp3'));
  }
//end audio

  //for timer function
  void _startCountdown() {
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel(); // Cancel the current timer if it's running
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (Timer timer) {
      if (_remainingHours <= 0 &&
          _remainingMinutes <= 0 &&
          _remainingSeconds <= 0) {
        setState(() {
          _showTimeUpDialog(context);
          _startCallTimer();
          timer.cancel();
        });
      } else {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          if (_remainingMinutes > 0) {
            setState(() {
              _remainingMinutes--;
              _remainingSeconds = 59;
            });
          } else {
            setState(() {
              _remainingHours--;
              _remainingMinutes = 59;
              _remainingSeconds = 59;
            });
          }
        }
      }
    });
  }

  void _addTime() {
    setState(() {
      // Add desired amount of time when OK is pressed (e.g., 5 seconds)
      _remainingMinutes += 5;
    });
  }

  void _startCallTimer() {
    const fiveMinute = Duration(seconds: 5); //改五分鐘
    _callTimer = Timer.periodic(fiveMinute, (Timer callTimer) {
      play();
      //xplay();
      //print("123");
      //_showDialogExample(context);
    });
  }
  //end timer function

  @override
  void dispose() {
    sourceController.dispose();
    destinationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showTimeUpDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('time up'),
        content: const Text('Do you want to add time?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => {
              _addTime(),
              _restartTimer(),
              Navigator.pop(context, 'YES'),
            },
            child: const Text('YES'),
          ),
          TextButton(
            onPressed: () => {
              Navigator.pop(context, 'Cancel'),
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Cancel'),
              content: Container(
                width: 300.0, // Set the desired width
                height: 200.0, // Set the desired height
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                ),
              ),
              contentPadding: EdgeInsets.zero, // Remove default padding
              actions: <Widget>[
                TextButton(
                  onPressed: () => {
                    Navigator.pop(context),
                    Navigator.pop(context, 'YES'),
                  },
                  child: const Text('YES'),
                ),
                TextButton(
                  onPressed: () => {
                    Navigator.pop(context, 'Cancel'),
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  void _showAddPathDialog(BuildContext context) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Center(
                  child: Text(
                'Add path',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              )),
              content: Container(
                width: 500.0,
                height: 1000.0,
                child: Column(
                  children: [
                    Container(
                      width: 300.0,
                      height: 100.0,
                      padding: EdgeInsets.all(16.0),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'add new path'),
                      ),
                    ),
                    // Container(
                    //   width:
                    //       double.infinity, // Take the full width of the parent
                    //   height: 450.0, // Adjust the height as needed
                    //   child: Google_Map(
                    //     onTimeReceived: (_doNotThing),
                    //     source: sourceController.text,
                    //     destination: destinationController.text,
                    //   ),
                    // ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => {
                    //Navigator.pop(context),
                    Navigator.pop(context, 'YES'),
                  },
                  child: const Text('YES'),
                ),
                TextButton(
                  onPressed: () => {
                    Navigator.pop(context, 'Cancel'),
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  void _showCommonPathDialog(BuildContext context) {
    final List<String> items = [
      "NCHU",
      "101",
      "NYC",
      "MY Home",
    ];
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment(0.5, 3),
                      child: Text(
                        'Common Path',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add), // Replace with your desired icon
                    onPressed: () {
                      _showAddPathDialog(context);
                      // Add your button's functionality here
                      // This function will be called when the button is pressed
                    },
                  ),
                ],
              ),
              //color: Colors.white10,
              content: Container(
                width: 500.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    // Use ListView.builder with a Scrollbar
                    Container(
                      width: double
                          .infinity, // Take the full width of the parent container
                      height:
                          500.0, // Set a specific height or adjust as needed
                      child: Scrollbar(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Material(
                              elevation: 0.0,
                              color: Color.fromARGB(255, 238, 235, 245),
                              child: InkWell(
                                onTap: () {
                                  // Handle the tap on the list item
                                  Navigator.pop(context, 'Cancel');
                                  print('Item tapped: ${items[index]}');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(items[index]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => {
                    Navigator.pop(context, 'Cancel'),
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () => {_showCancelDialog(context)},
              child: Icon(
                Icons.cancel,
                size: 26.0,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () => {_showCommonPathDialog(context)},
              child: Icon(
                Icons.add_circle,
                size: 26.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: TextField(
                //     controller: sourceController,
                //     decoration: InputDecoration(
                //       labelText: "Source Location",
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                placesAutoCompleteTextField(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TransportButton(
                      icon: Icons.directions_car,
                      isSelected: navigation == 'Driving',
                      onPressed: () {
                        setState(() {
                          navigation = 'Driving';
                        });
                      },
                    ),
                    SizedBox(
                      width: 35,
                    ),
                    TransportButton(
                      icon: Icons.directions_bike,
                      isSelected: navigation == 'Bicycling',
                      onPressed: () {
                        setState(() {
                          navigation = 'Bicycling';
                        });
                      },
                    ),
                    SizedBox(
                      width: 35,
                    ),
                    TransportButton(
                      icon: Icons.directions_walk,
                      isSelected: navigation == 'Walking',
                      onPressed: () {
                        setState(() {
                          navigation = 'Walking';
                        });
                      },
                    ),
                    SizedBox(
                      width: 35,
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isMapVisible = true;
                    });
                  },
                  child: Text("Start"),
                ),
                SizedBox(height: 16.0),
                Row(children: [
                  Text(
                    'Time:' +
                        '$_remainingHours' +
                        ":" +
                        '$_remainingMinutes' +
                        ':' +
                        '$_remainingSeconds',
                    style: TextStyle(fontSize: 24),
                  ),
                ])
              ],
            ),
          ),
          if (isMapVisible)
            Stack(
              children: [
                Container(
                  height: 450, // 设置地图高度
                  child: Google_Map(
                    onTimeReceived: (_onTimeReceived),
                    source: sourceController.text,
                    destinationLat: latitude,
                    destinationLng: longitude,
                    navigation: navigation,
                    // currentP: _currentP,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // void getLocationUpdates() async {
  //   bool _serviceEnabled;
  //   location.PermissionStatus _permissionGranted;
  //   _serviceEnabled = await _locationController.serviceEnabled();
  //   if (_serviceEnabled) {
  //     _serviceEnabled = await _locationController.requestService();
  //   } else {
  //     return;
  //   }
  //   _permissionGranted = await _locationController.hasPermission();
  //   if (_permissionGranted == location.PermissionStatus.denied) {
  //     _permissionGranted = await _locationController.requestPermission();
  //     if (_permissionGranted != location.PermissionStatus.granted) {
  //       return;
  //     }
  //   }
  //   _locationController.onLocationChanged
  //       .listen((location.LocationData currentLocation) {
  //     if (currentLocation.latitude != null &&
  //         currentLocation.longitude != null) {
  //       setState(() {
  //         _currentP =
  //             LatLng(currentLocation.latitude!, currentLocation.longitude!);
  //         // mapController.moveCamera(CameraUpdate.newLatLng(_currentP));
  //         print("CurrentLocation: " + _currentP.toString());
  //       });
  //     }
  //   });
  // }

  // autocomplete
  placesAutoCompleteTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: destinationController,
        googleAPIKey: GOOGLE_MAPS_API_KEY,
        inputDecoration: InputDecoration(
          hintText: "Search your location",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: ["tw"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("placeDetails" + prediction.lat.toString());
        },

        itemClick: (Prediction prediction) {
          destinationController.text = prediction.description ?? "";
          getLatLngFromPlaceId(prediction.placeId ?? "");
          destinationController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),
        containerHorizontalPadding: 10,

        // OPTIONAL// If you want to customize list view item builder
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(
                  width: 7,
                ),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },

        isCrossBtnShown: true,

        // default 600 ms ,
      ),
    );
  }

  Future<Map<String, dynamic>> fetchPlaceDetails(String placeId) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$GOOGLE_MAPS_API_KEY'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load place details');
    }
  }

  void getLatLngFromPlaceId(String placeId) async {
    try {
      final details = await fetchPlaceDetails(placeId);
      final location = details['result']['geometry']['location'];
      setState(() {
        latitude = location['lat'];
        longitude = location['lng'];
      });
      print('Latitude: $latitude, Longitude: $longitude');
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onTimeReceived(int Seconds) {
    // Handle the received time here
    if (Seconds > 3600) {
      _remainingHours = (Seconds / 3600).toInt();
      Seconds = (Seconds % 60).toInt();
    }
    if (Seconds > 60) {
      _remainingMinutes = (Seconds / 60).toInt();
      Seconds = (Seconds % 60).toInt();
    }
    _remainingSeconds = Seconds;

    Future.microtask(() {
      setState(() {
        // Handle the received data here
        print("Received Data:  $Seconds");
        // Perform any additional logic or trigger a re-render here
      });
    });
    _startCountdown();
    // You can do more with the received time if needed
  }

  void _doNotThing(int NotThing) {}
}

class TransportButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const TransportButton({
    Key? key,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.red; // 按下时的颜色
            }
            return isSelected ? Colors.grey : Colors.white; // 当前选定的按钮有颜色，其他按钮变灰
          },
        ),
      ),
      child: Icon(icon), // 将按钮文本改为图标
    );
  }
}
