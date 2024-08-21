import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_aid_project/main.dart';
import 'package:first_aid_project/screens/firstaider_map_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart'; 
final _messageStreamController = BehaviorSubject<RemoteMessage>(); 
String userId ='';
String userName =''; 
class HandleNotificationsReceived {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void setupFirebaseMessaging(BuildContext context) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.getToken().then((token) {
      if(kDebugMode){
        print("FCM Token: $token");
      }      
      //Save the token to Firestore
      if (token != null) {
        saveTokenToFirestore(token);
      }
    });

    //Set up foreground message handler 
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification; //only this line was added from prev code 25072024
      if (kDebugMode) {
        print('Handling a foreground message: ${message.messageId}');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
        print('Message notification: ${message.notification?.body}');
      }
      _messageStreamController.sink.add(message);
      if (notification != null) {
        showNotification(context, notification, message.data);
      }
    });

    //when notification is opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if(kDebugMode){
        print('This from On Message Opened app');
      }
      navigateToMap(context, message.data); 
    });

    const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ); 
    const InitializationSettings initSettings = InitializationSettings(android: initSettingsAndroid, iOS: initSettingsIOS,); //added on 28072024 //android: initSettingsAndroid
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  static void saveTokenToFirestore(String token) async {
    //store user ID
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      //Save the token to Firestore
      await FirebaseFirestore.instance.collection('firstaider_locations').doc(userId).update({
        'token': token,
      });
    }
  }

//show notification on screen with the alert message rcvd from the security
  static void showNotification(BuildContext context, RemoteNotification notification, Map<String, dynamic> data) async {
    String receivedMsg = data['msg'] ?? 'First Aid required!'; //to show message in dialog 
    userId = data['userID'];    
    userName = data['firstAiderName'];  
    globalNavigatorKey.currentState?.context != null ? showDialog(  
      context: globalNavigatorKey.currentState!.context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.title ?? 'Alert'),
          content: Text(receivedMsg), 
          actions: [
            TextButton(
              child: const Text('Respond'),
              onPressed: () {
                Navigator.of(context).pop();
                navigateToMap(context, data);
              },
            ),
            TextButton(
              child: const Text('Ignore'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ) : null;  
  }

  //send emergency location's lat and long values to First Aider Map screen
  static void navigateToMap(BuildContext context, Map<String, dynamic> data) {
    onRespondButtonClicked(userId);
    double rcvdLatitude = double.parse(data['latitude']);  
    double rcvdLongitude = double.parse(data['longitude']); 
    globalNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => FirstaiderMapScreen(incidentLatitude: rcvdLatitude, incidentLongitude: rcvdLongitude,), 
      ),
    );
  }

  static void onRespondButtonClicked(String responderId) {
    FirebaseFirestore.instance.collection('firstAiderActions').doc(responderId).set({
      'responderName': userName, 
      'haveResponded': true, 
      'actionCompleted': false,  
      'respondedTime': FieldValue.serverTimestamp(), 
    });
  }

}
