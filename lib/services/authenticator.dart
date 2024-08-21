import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationServices{  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; //for storing data in cloud
  final FirebaseAuth _authenticate = FirebaseAuth.instance; //for authentication

  //save data when user registers
  Future<User?> registerUser({ 
      required String userRole,
      required String fullName,
      required DateTime dateOfBirth,
      required String gender,
      required String email,
      required String password,
      required String contactNumber,
  }) async {
    try{
      //Create a new user with Firebase Auth
      UserCredential userCredential = await _authenticate.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //get the newly registered account credential
      User? user = userCredential.user;

      if(user != null){
        await _firestore.collection('users').doc(user.uid).set({
          'userRole':userRole,
          'fullName':fullName,
          'dateOfBirth':dateOfBirth,
          'gender':gender,
          'email':email,
          'contactNumber':contactNumber,
          'uid':user.uid,
        });
      }
      return user;
    } on FirebaseAuthException catch(e){
      throw Exception('Error during Registering: $e');
    }
  }

  //authenticate during log in
  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential userCredential = await _authenticate.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Error during Log-In: $e');
    }
  }
  //getting user role
  Future<String?> getUserRole(User user) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc['userRole'];
    } catch (e) {
      throw Exception('Error fetching user role: $e');
    }
  }
  //getting user name
  Future<String?> getUserName(User user) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc['fullName'];
    } catch (e) {
      throw Exception('Error fetching user name: $e');
    }
  }   
}
