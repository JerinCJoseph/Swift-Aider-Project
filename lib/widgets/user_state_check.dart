import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_aid_project/screens/firstaider_map_screen.dart';
import 'package:first_aid_project/screens/home_screen.dart';
import 'package:flutter/material.dart';

class UserStateCheck extends StatelessWidget {
  const UserStateCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return const FirstaiderMapScreen(); 
          }else{
            return const HomeScreen(); 
          }
        },        
      ),
    );
  }
}