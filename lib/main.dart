import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_aid_project/screens/splash_screen.dart';
import 'package:first_aid_project/services/availability_status.dart';
import 'package:first_aid_project/services/handle_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:first_aid_project/firebase_options.dart';
import 'package:provider/provider.dart';

//for background message handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
    if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; 
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>(); 

void main() async {
  //firebse initialization 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Request Permission 
  final settings = await _firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }

  //background msg handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); 

  runApp(
    //for listening to availability status
    ChangeNotifierProvider(
      create: (context) => UserAvailabilityStatus(),
      child: const MyApp(),
    ),
  );    
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    HandleNotificationsReceived.setupFirebaseMessaging(context);
  }
  //This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,  
      debugShowCheckedModeBanner: false,
      title: 'Swift Aider',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),  //navigate to Splash Screen
    );
  }
}