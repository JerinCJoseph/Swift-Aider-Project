import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_aid_project/screens/home_screen.dart';
import 'package:first_aid_project/screens/settings_fa_screen.dart';
import 'package:first_aid_project/services/location_services.dart';
import 'package:first_aid_project/services/notification_services.dart';
import 'package:first_aid_project/widgets/dialog_customised.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart'; 
import 'package:first_aid_project/services/availability_status.dart'; 

class SecurityMapScreen extends StatefulWidget {
  const SecurityMapScreen({super.key});

  @override
  State<SecurityMapScreen> createState() => _SecurityMapScreenState();
}

class _SecurityMapScreenState extends State<SecurityMapScreen> {
  static const LatLng _initialPos = LatLng(56.458306554271324, -2.9802166978184794); 
  GoogleMapController? gMapController; 
  final Set<Polygon> _polygons = {}; 

  final Set<Marker> _markers = {}; 
  final LocationServices _locationServices = LocationServices(); 
  final double closestFARadius = 0.25; 
  LatLng? _pinnedLocation; 

  final FirebaseAuth _authenticate = FirebaseAuth.instance;  
  String _userName = '';  
  String _responderUserID = '';
  String _respondedFAName = ''; 

  final FirebaseFirestore _firestoredb = FirebaseFirestore.instance; //for adding incidents to database
  String _incidentDescription = ''; 

  final TextEditingController _noteController = TextEditingController();
  String _selectedEmergencyOption = 'First Aid';
  final List<String> _options = ['First Aid', 'Basic Life Support', 'Anaphylaxis', 'Bleeding'] ;

  @override
  void initState(){
    super.initState();
    _setOutline();  
    listenForResponderActions(); 
    _getUserName(); 
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [  
              DropdownButtonFormField<String>(
                value: _selectedEmergencyOption,
                items: _options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedEmergencyOption = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Choose an Emergency Type',
                ),
              ),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Write a brief note'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Send'),
              onPressed: () {
                //send notification
                _onSendAlertClicked();
                if(kDebugMode){
                  print('Type of Emergency: $_selectedEmergencyOption');
                  print('Alert Message sent: ${_noteController.text}');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 167, 157, 180), 
        title: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold),), 
        actions: [
          //update availability status
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
            initialCameraPosition: const CameraPosition(
              target: _initialPos,
              zoom: 15,
            ),
            onMapCreated: _onMapCreated, 
            markers: _markers, 
            onTap: _onMapTapped, 
            polygons: _polygons,  
            zoomGesturesEnabled: true,
            myLocationEnabled: false, 
            myLocationButtonEnabled: false,
            trafficEnabled:true,
          ),
          //position send alert button on map          
          Positioned( 
            bottom: 35, 
            left: 30,  
            child: FloatingActionButton(
              onPressed: (){
                if(_pinnedLocation==null){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("No Medical Emergency Location Pinned."),
                    ),
                  );
                  return;
                }else{
                  _showAlertDialog(); //show alert msg box
                }
              },
              tooltip: "Send Alert to First Aiders",
              child: const Icon(Icons.send_to_mobile),
            )
          )
        ],
      ),
    );
  }

  void _signUserOut(){
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false
    ); 
  }

  void _setOutline(){
    final Polygon polygon = Polygon(
      polygonId: const PolygonId('boundary_outline'),
      points: _createCampusBoundary(),
      strokeWidth: 4,
      strokeColor: const Color.fromARGB(255, 7, 74, 129),
      fillColor: const Color.fromARGB(255, 117, 131, 196).withOpacity(0.15),       
    );

    setState(() {
      _polygons.add(polygon);
    });
  }

  List<LatLng> _createCampusBoundary() {
    return [
      const LatLng(56.45967300700373, -2.983309605950046), //heithfield
      const LatLng(56.45853156191588, -2.986014729447811), //ise carpark
      const LatLng(56.456864471798006, -2.9870440006016152), //miller wynd cp 
      const LatLng(56.45639168119807, -2.985581771993043),
      //const LatLng(56.455132459714825, -2.981755728986961), //seabres res 
      const LatLng(56.45653247222341, -2.981128748957081), //resrch innovation 
      const LatLng(56.45724279918035, -2.9779254835951994), //tower build
      const LatLng(56.45756791383245, -2.9768570784306774), //bonar 
      const LatLng(56.45860110600557, -2.978301674446819), //added 09082024
      //const LatLng(56.457983059345544, -2.977659292717462), //scrgym 
      //const LatLng(56.45855922663817, -2.9788301074282044), //dental
      //const LatLng(56.4586794277798, -2.9803164097093657), //science engg 
      const LatLng(56.459243277803324, -2.9802156884526685), //fulton carpark  
      //const LatLng(56.45937651587362, -2.9825670193748093), //dalhousie 
      const LatLng(56.45984025555479, -2.9823959549153303), //dalhousie hunter st 
      //const LatLng(56.45906937317946, -2.9859621069777713),

    ];
  }

  void _onMapCreated(GoogleMapController controller){ 
    gMapController = controller;
  }

  void _onMapTapped(LatLng pinnedLocation) async { 
  List<DocumentSnapshot> firstaiders = await _locationServices.fetchNearbyFirstAiders(pinnedLocation, closestFARadius);
    setState(() {
      _markers.clear();
    });
    setState(() {
      _markers.clear();  //clearing any existing markers 
      _pinnedLocation = pinnedLocation; 
      //ading the tapped location to marker
      _markers.add(
        Marker(
          markerId: const MarkerId('medicalEmergencyLocation'),
          position: pinnedLocation,
          infoWindow: const InfoWindow(title: 'Incident Point'),
        ),
      );
    });

    //add fetched first aiders markers
    for(var fa in firstaiders){
      GeoPoint faLocation = fa['location'];
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(fa.id),
            position: LatLng(faLocation.latitude, faLocation.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), 
            infoWindow: const InfoWindow(title: 'First Aider'),
          )
        );
      });
    }
  }

  //sending alerts to closest first aiders 
  void _onSendAlertClicked() async {
    List<DocumentSnapshot> firstaiders = await _locationServices.fetchNearbyFirstAiders(_pinnedLocation!, closestFARadius);
    for(var fa in firstaiders){
      String faToken = fa['token'] as String;
      String userID = fa.id;
      String userName = fa['username'];  
      String message = '$_selectedEmergencyOption,  Details: ${_noteController.text}'; 
      _incidentDescription = message;

      NotificationServices.sendAlertToFirstAiders(faToken, userID, userName, _pinnedLocation!, message); 
      //for adding incidents to database
    Map<String, dynamic> newIncidentData = {
        'raised_by': _userName,
        'Description': _incidentDescription,
        'opened_on': FieldValue.serverTimestamp(), 
        'closed_on': '', 
        'status': 'open',
    };
    addIncidentsIfAlertSent(newIncidentData);

    }
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

//added on 02082024 for response action
  void listenForResponderActions() {
    FirebaseFirestore.instance.collection('firstAiderActions').snapshots().listen((snapshot) async { 
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
          var data = change.doc.data();
          _respondedFAName = data?['responderName'];
          _responderUserID = change.doc.id; 
          if (data != null && data['haveResponded'] == true) { 
            if(kDebugMode){
              print('First Aider ${change.doc.id} has responded');
            }
            await DialogCustomised.showCustomDialog(context, 'First Aider Response', '$_respondedFAName is on the way to the emergency location.');
            _updateRespondedFirstAiderActions(_responderUserID);
          } else if(data != null && data['actionCompleted'] == true){  
            await DialogCustomised.showCustomDialog(context, 'First Aider Response', '$_respondedFAName has reached the location.');
            _deleteRespondedFirstAiderFromActions(_responderUserID);
          }
        }
      }
    });
  }
  
  void _deleteRespondedFirstAiderFromActions(String userid) {
    FirebaseFirestore.instance.collection('firstAiderActions').doc(userid).delete().then((_) {  
      if(kDebugMode){
        print('Responder $userid response deleted successfully');
      }
    }).catchError((error) {
      if(kDebugMode){
        print('Failed to delete user: $error');
      }
    });
  }

  void _updateRespondedFirstAiderActions(String userid) {
    FirebaseFirestore.instance.collection('firstAiderActions').doc(userid).update({
      'haveResponded': false,    
    }).then((_) {  
      if(kDebugMode){
        print('Responder $userid response changed to false');
      }
    }).catchError((error) {
      if(kDebugMode){
        print('Failed to change response of first aider: $error');
      }
    });
  }

//added on 05082024 for incident report entry
void addIncidentsIfAlertSent(Map<String, dynamic> data) async {
  CollectionReference collectionRef = _firestoredb.collection('firstaid_incident_reports');

  QuerySnapshot querySnapshot = await collectionRef.get(); //Chheck if any doc exists in collection

  if (querySnapshot.docs.isNotEmpty) {
    await collectionRef.add(data).then((DocumentReference docRef) {
      if(kDebugMode){
      print('Document added with ID: ${docRef.id}');}
    }).catchError((error) {
      if(kDebugMode){
      print('Error adding document: $error');}
    });
  } else {
    if(kDebugMode){
    print('No existing documents. This is the first Incident entry.');}
    await collectionRef.add(data).then((DocumentReference docRef) {
      if(kDebugMode){
      print('Document added with ID: ${docRef.id}');}
    }).catchError((error) {
      if(kDebugMode){
      print('Error adding document: $error');}
    });
  }
}

}