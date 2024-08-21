import 'package:flutter/material.dart';
import 'package:first_aid_project/services/availability_status.dart'; 
import 'package:provider/provider.dart'; 

class SettingsFAScreen extends StatefulWidget {
  const SettingsFAScreen({super.key});

  @override
  State<SettingsFAScreen> createState() => _SettingsFAScreenState();
}

class _SettingsFAScreenState extends State<SettingsFAScreen> {
  late bool isAvailable;  
  String availabilityStatus = "Online";
  String strAvailStatus = "Online";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 167, 157, 180), 
        title: const Text('Settings'),
      ),
      body: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 20,
            ) 
          ),
          Text(strAvailStatus),
          Consumer<UserAvailabilityStatus>(
            builder: (context, availabilityStatus, child) {
              isAvailable = availabilityStatus.status == "Online";
              return Switch(
                value: isAvailable, 
                onChanged: (value){
                  setState(() {
                    isAvailable = value;
                    if(value){
                      strAvailStatus = "Online"; 
                    }else{
                      strAvailStatus = "Offline";
                    }
                  });
                  availabilityStatus.toggleStatus(value);
                },
                activeColor: Colors.green,
              );
            },
          ),
        ],
      ),
    );
  }
}