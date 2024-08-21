import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

final Logger log = Logger();
class FirstAiderListScreen extends StatelessWidget {
  const FirstAiderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 167, 157, 180), //Color.fromARGB(255, 213, 245, 241)
        title: const Text('Registered First Aiders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users')
            .where('userRole', isEqualTo: 'First Aider')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['fullName']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteFirstAider(user.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteFirstAider(String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).delete().then((_) {
      log.i("User $userId deleted successfully");
      log.d("User $userId deleted successfully");
    }).catchError((error) {
      log.i("Failed to delete user: $error");
      log.d("User $userId deleted successfully");
    });
  }
}