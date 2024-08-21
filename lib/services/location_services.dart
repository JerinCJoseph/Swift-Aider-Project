import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationServices{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //Fetch all responders closest to the point of emergency and who are online
  Future<List<DocumentSnapshot>> fetchNearbyFirstAiders(LatLng pinnedLocation, double radius) async { 
    //Fetch all responders from Firestore
    QuerySnapshot snapshot = await _firestore.collection('firstaider_locations').get();

    List<DocumentSnapshot> nearbyFirstAiders = [];

    for (var doc in snapshot.docs) {
      GeoPoint geoPoint = doc['location'];
      double distanceInMeters = Geolocator.distanceBetween(
        pinnedLocation.latitude,
        pinnedLocation.longitude,
        geoPoint.latitude,
        geoPoint.longitude,
      );
      String status = doc['availability']; 
      double distance = distanceInMeters / 1000;
      if (distance <= radius && status=='online') { 
        nearbyFirstAiders.add(doc);
      }
    }
    return nearbyFirstAiders;
  }
}