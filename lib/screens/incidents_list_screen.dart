import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentsListScreen extends StatefulWidget {
  const IncidentsListScreen({super.key});

  @override
   State<IncidentsListScreen> createState() => _IncidentsListScreenState();
}

class _IncidentsListScreenState extends State<IncidentsListScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 167, 157, 180), 
        title: const Text('Opened Incidents List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('firstaid_incident_reports')
            .where('status', isEqualTo: 'open')       //only fetch open incidents
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var incidents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              var incident = incidents[index];
              String openTime = 'Opened On: ${incident['opened_on']?.toDate().toString()}'; 
              
              return ListTile(
                title: Text(incident['Description'] ?? 'No details'), //Description
                subtitle: Text(openTime), 
                trailing: IconButton(
                  icon: const Text('Close', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),), 
                  onPressed: () => _updateIncidentStatus(incident.id, 'closed'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateIncidentStatus(String docId, String newStatus) async {
    try {
      await firestore.collection('firstaid_incident_reports').doc(docId).update({'status': newStatus, 'closed_on':FieldValue.serverTimestamp(),});
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident closed')));
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error closing incident: $e')));
    }
  }
}