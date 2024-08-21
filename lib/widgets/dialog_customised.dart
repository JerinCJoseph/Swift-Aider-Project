import 'package:flutter/material.dart';

class DialogCustomised{
  //reuse for custom error msg Dialog
  static void showCustomErrorDialog(BuildContext context, String strTitle, String strMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strTitle),
          content: Text(strMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  //reuse for custom msg Dialog
  static Future<void> showCustomDialog(BuildContext context, String strTitle, String strMessage) {  
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strTitle),
          content: Text(strMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}