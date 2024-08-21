import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_aid_project/screens/home_screen.dart';
import 'package:first_aid_project/screens/incidents_list_screen.dart';
import 'package:first_aid_project/screens/security_map_screen.dart';
import 'package:first_aid_project/screens/settings_fa_screen.dart';
import 'package:first_aid_project/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:first_aid_project/services/availability_status.dart'; 


class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  State<SecurityDashboardScreen> createState() => _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> {
  final FirebaseAuth _authenticate = FirebaseAuth.instance;  
  String _userName = '';  
  
  @override 
  void initState() { 
    super.initState();
    _getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 167, 157, 180),
        title: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold),), 
        actions: [
          //update user availability status
          Consumer<UserAvailabilityStatus>(builder: (context, availabilityStatus, child) {  
              Color iconColor = availabilityStatus.status == "Online" ? Colors.greenAccent : Colors.yellowAccent;
              return Icon(Icons.circle, color: iconColor, size: 25,);
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder:(context) => const SettingsFAScreen()),);
            }, 
            icon: const Icon(Icons.settings),
            color: Colors.black,
            iconSize: 25,
          ),
          IconButton(
            onPressed: _signUserOut, 
            icon: const Icon(Icons.logout),
            color: Colors.redAccent,
            iconSize: 25,
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 213, 245, 241), 
      body: Stack(
        children: [
          Image.asset('assets/images/screenbg4.jpeg',
          fit:BoxFit.fill,
          width:double.maxFinite,
          height:double.maxFinite,
          ),
          Center(
            child: Column(    
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Navigate to First Aider List
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder:(context) => const FirstAiderListScreen()),
                    );                            
                  }, 
                  child: const Text("First Aiders")
                ),
                const SizedBox(height: 5,),
                //Navigate to view active incidents List
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder:(context) => const IncidentsListScreen()), 
                    );                            
                  }, 
                  child: const Text("View Incidents")
                ),
                const SizedBox(height: 5,),
                //go to map for sending alert
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder:(context) => const SecurityMapScreen()),
                    );                            
                  }, 
                  child: const Text("Go to Map")
                ),
              ],
            ),
          )
        ],
      )
    );
  }

//logout the user function
  void _signUserOut(){
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false
    );    
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

}
