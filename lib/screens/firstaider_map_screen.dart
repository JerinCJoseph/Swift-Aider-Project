import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_aid_project/constants/app_constants.dart';
import 'package:first_aid_project/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_aid_project/screens/settings_fa_screen.dart';
import 'package:first_aid_project/services/availability_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; //added for creating navigation path

class FirstaiderMapScreen extends StatefulWidget {
  final double? incidentLatitude;  
  final double? incidentLongitude;  
  const FirstaiderMapScreen({  
    super.key,
    this.incidentLatitude,
    this.incidentLongitude,
  });

  @override
  State<FirstaiderMapScreen> createState() => _FirstaiderMapScreenState();
}

class _FirstaiderMapScreenState extends State<FirstaiderMapScreen> {

  late GoogleMapController googleMapController;
  static const CameraPosition initialCameraPosition = CameraPosition(target: LatLng(56.45854, -2.98238), zoom: 14);
  Set<Marker> markers = {};
  final FirebaseFirestore _firestoredb = FirebaseFirestore.instance;
  final FirebaseAuth _authenticate = FirebaseAuth.instance; 
  String _userName = '';  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; 
  LatLng? alertedLocation; 
  LatLng? cLocation; 
  StreamSubscription<Position>? positionStreamSubscription; 
  String _userCurrentAvailStatus = ''; 
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Polyline> polylines = {};
  String duration = "";
  bool isAlertLocReceived = false;
  bool isGoingToAlertLocation = false;

  @override  
  void initState() {
    super.initState();
    _getUserName();
    //checking for alertloc latitude and longitude from notification
    if (widget.incidentLatitude != null && widget.incidentLongitude != null) {
      alertedLocation = LatLng(widget.incidentLatitude!, widget.incidentLongitude!);
      _addAlertMarker(); 
      isAlertLocReceived = true;
    }
    _listenToLocationChanges(); 
  }

//checks for change in availability status
@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final availabilityStatus = Provider.of<UserAvailabilityStatus>(context);
    _userCurrentAvailStatus = availabilityStatus.status;
  }

  @override 
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 167, 157, 180), 
        title: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold),),  
        actions: [
          Consumer<UserAvailabilityStatus>(builder: (context, availabilityStatus, child) {  
              Color iconColor = availabilityStatus.status == "Online" ? Colors.greenAccent : Colors.yellowAccent;
              return Icon(Icons.circle, color: iconColor, size: 25,);
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder:(context) => const SettingsFAScreen(),));
            }, 
            icon: const Icon(Icons.settings),
            color: Colors.black,
            iconSize: 25,
            tooltip: "Settings",
          ),
          IconButton(
            onPressed: _signUserOut, 
            icon: const Icon(Icons.logout),
            color: Colors.redAccent,
            iconSize: 25,
            tooltip: "Logout",
          ),          
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              googleMapController =controller;
              if (alertedLocation != null) { 
                _setCameraToAlertLocation();
              }
            },
            markers: markers,
            polylines: polylines,
            trafficEnabled:true,
          ),
          Positioned(
            bottom: 35,
            left: 25,
            child: FloatingActionButton(
            onPressed: () async{
              Position position = await _determinePosition();
              setState(() {
                cLocation = LatLng(position.latitude, position.longitude);
                _updateCurrentLocationMarker();
              });
              googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: cLocation!, zoom: 14.0),
                )
              );
              await updateLocationToDb(position); 
            },
            tooltip: 'Get Current Location',
            child: const Icon(Icons.my_location, size: 30,),
            ),
          ),
          Positioned(
            bottom: 35,
            left: 85,
            child: Visibility(
              visible: isAlertLocReceived,
              child: FloatingActionButton(
              onPressed: () {
                _createDirectionPolylines();
                setState(() {
                isGoingToAlertLocation=true;                  
                });
              },
              tooltip: 'Go to Alert Location',
              child: const Icon(Icons.directions, size: 30,),
            ),), 
          ),
          Positioned(
            top: 25,
            left: 10,
            child:  Visibility(
              visible: isGoingToAlertLocation,
              child: Text(              
                'Estimated Duration: $duration',
                style: const TextStyle(fontSize: 22,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 181, 15, 3)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if(isGoingToAlertLocation)
            Positioned(
            top: 35,
            right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  String fauserid =_authenticate.currentUser!.uid;
                  _onReachedDesitination(fauserid);
                },
                tooltip: 'Send Notification of your Arrival',
                backgroundColor: Colors.green,
                child: const Icon(Icons.check_circle, size: 42.5,),
              )
            ),  
        ],
      )
    );
  }

  //user logout function
  void _signUserOut(){
    String uid =_authenticate.currentUser!.uid;
    _deleteFirstAiderLocOnLogout(uid);
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false
    ); 
  }


  void _listenToLocationChanges() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15,
    );
    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        cLocation = LatLng(position.latitude, position.longitude);
        _updateCurrentLocationMarker();
        if (alertedLocation != null) {
          _boundMarkers();
        } else {
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: cLocation!, zoom: 14),
            ),
          );
        }
      });
      updateLocationToDb(position);
    });
  }

  void _updateCurrentLocationMarker() {
    if (cLocation != null) {
      markers.removeWhere((marker) => marker.markerId == const MarkerId('currentLocation'));
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: cLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), 
          infoWindow: InfoWindow(title: _userName, snippet: 'You are here.'),
        ),
      );
    }
  }

//fits the camera to view bboth first aider location and alert location in screen
  void _boundMarkers() {
    LatLngBounds setbounds;
    if (cLocation != null && alertedLocation != null) {
      setbounds = LatLngBounds(
        southwest: LatLng(
          cLocation!.latitude < alertedLocation!.latitude ? cLocation!.latitude : alertedLocation!.latitude,
          cLocation!.longitude < alertedLocation!.longitude ? cLocation!.longitude : alertedLocation!.longitude,
        ),
        northeast: LatLng(
          cLocation!.latitude > alertedLocation!.latitude ? cLocation!.latitude : alertedLocation!.latitude,
          cLocation!.longitude > alertedLocation!.longitude ? cLocation!.longitude : alertedLocation!.longitude,
        ),
      );
      googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(setbounds, 50),
      );
    }
  }
  //adds alert location marker on map
  void _addAlertMarker() async{
    if (alertedLocation != null) {
    String geoCoordConvAddressofAlertLoc = await getAddressFromLatLng(alertedLocation!);
      markers.add(
        Marker(
          markerId: const MarkerId('alertLocation'),
          position: alertedLocation!,
          infoWindow: InfoWindow(title: 'Emergency Location', snippet: geoCoordConvAddressofAlertLoc), 
        ),
      );
      setState(() {});
    }
  }

  void _setCameraToAlertLocation() {
    if (alertedLocation != null) {
      googleMapController.animateCamera(
        CameraUpdate.newLatLng(alertedLocation!),
      );
    }
  }

  //access location permission for current location
  Future<Position> _determinePosition() async {
    bool isServiceEnabled;
    LocationPermission permission;

    isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isServiceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation); 

    return position;
  }

  Future<void> _getUserName() async {
    User? cUser= _authenticate.currentUser;
    if (cUser != null) {
      setState(() {
        cUser; 
      });
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(cUser.uid)
          .get();
      setState(() {
        _userName = userData['fullName'];
      });
    }
  }

  //Update user location to database and update availability status
  Future<void> updateLocationToDb(Position position) async {
    User? cUser = _authenticate.currentUser; 
    String? faToken = await _firebaseMessaging.getToken(); 
    if(kDebugMode){
      print('First Aider Token: $faToken' );
    } 

    if (cUser != null && _userCurrentAvailStatus == "Online") {
      _firestoredb.collection('firstaider_locations').doc(cUser.uid).set({
        'username': _userName,
        'location': GeoPoint(position.latitude, position.longitude),
        'token': faToken, 
        'timestamp': FieldValue.serverTimestamp(),
        'availability': "online",
      });
    } else if (cUser != null && _userCurrentAvailStatus == "Offline") {
      _firestoredb.collection('firstaider_locations').doc(cUser.uid).set({
        'username': _userName,
        'location': GeoPoint(position.latitude, position.longitude),
        'token': faToken, 
        'timestamp': FieldValue.serverTimestamp(),
        'availability': "offline",
      });
    }
  }

  //for removing first aider location details when logs out
  void _deleteFirstAiderLocOnLogout(String userid) {
    FirebaseFirestore.instance.collection('firstaider_locations').doc(userid).delete().then((_) {
      if(kDebugMode){
        print('FirstAider- $userid  deleted from firstaider_locations successfully');
      }
    }).catchError((error) {
      if(kDebugMode){
        print('Failed to delete user from firstaider_locations: $error');
      }
    });
  }

  //converts the geocode to address
  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}"; 
      } else {
        return "No address found";
      }
    } catch (e) {
      if(kDebugMode){
        print(e);
      }
      return "Failed to get address";
    }
  }

  //set the direction from current location of responder to alert location
  Future<void> _createDirectionPolylines() async {   
    if (cLocation == null || alertedLocation == null) return;
    String googleAPIKey = Platform.isAndroid ? gmapAndroidAPIKey : gmapIosAPIKey;
    String origin = "${cLocation!.latitude},${cLocation!.longitude}";
    String destination = "${alertedLocation!.latitude},${alertedLocation!.longitude}";
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=walking&key=$googleAPIKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final route = jsonResponse['routes'][0];
        final legs = route['legs'][0];
        final durationText = legs['duration']['text'];
        final points = PolylinePoints().decodePolyline(route['overview_polyline']['points']);

        setState(() {
          duration = durationText;
          polylineCoordinates.clear();
          for (var pt in points) {
            polylineCoordinates.add(LatLng(pt.latitude, pt.longitude));
          }

          polylines.add(Polyline(
            polylineId: const PolylineId('polyline'),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          ));
        });
      } else {
        throw Exception("Failed to load directions to Alert Location.");
      }
    } catch (e) {
      if(kDebugMode){
        print("Error getting directions: $e");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get directions: $e")),
      );
    }
  }

  void _onReachedDesitination(String userid) {
    FirebaseFirestore.instance.collection('firstAiderActions').doc(userid).update({
      'actionCompleted': true,    
    }).then((_) {  
      if(kDebugMode){
        print('Responder $userid response changed to false successfully');
      }
    }).catchError((error) {
      if(kDebugMode){
        print('Failed to change response of first aider: $error');
      }
    });
    setState(() {
      isGoingToAlertLocation = false;      
    });
  }

}