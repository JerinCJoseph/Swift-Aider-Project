import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationServices{

  static Future<String> getAccessToken() async{
    //paste the downloaded service account .json data here 
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "flutterfirstaider",
      "private_key_id": "aa3191a2e062f4381d123e8fcd253f8f89910815",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDkeyFuDNO5WiSL\n+3QCnXvfn8j9QqfA2dkXESRdd9Q94GhYMWgBpaRc7g3yZ1+LmU9zsZyQAzL5RnKR\nyOQEoEiW6d+McQjbxwrg14P57aKQKmgXbgg+NM9NSHQcNh+j4X2U21CGdZPclJpK\n3pRDPZh97MMOaDMpmEAI1LrhiNBnogqDR//fjeIgk8Ub/bp4DvReMn2e53qsdui7\nCYL4B15xGEThfYIniTVWKJDZ5bUo67c06xdDss+OjDIJwNKgieJRrc/TPg9RG9Ru\nOp2/n7J/9u+wgWMr48uRDANp3j75Hn5p9gsJCJxbXYRtY8Xb0FOf3xM4QvZMmnCV\nhTbAcMoxAgMBAAECggEANT3jJaGsEchpdUw4daaMl+kEXU3zyOsK3UbzlitHBE8/\niXOj5KRch4I6ska3+1ATtWZJUT7JmVB7ALFTPye5mp8vpmqtsYcxqADYonwnclhL\nbtBHb/V+7Ceq1Osg1t/EE5TCsD6EYPWo+bLh0kRvfUKXloseBv6RR22JCebHh6pI\nWm+LhSW5eCGP2ORgPgJjxj0VAJZxr2DrvbK5siVCuVRg1FB0qJjwL37jicRANpLw\nKV6DjXdjpKlP2M5oj0JCQncWuokattUTOsX+k5rvkO0N9ljoDkQ3N2HG5jfedRiQ\nfdtSAG7ZlC9jUUzkhbdV2gk3ZxdgGyce2uR8pu3qZQKBgQD9Rih/Bt50QRlFR+4Q\ncn/3bNmXhXKd7cEyaZIYPPrrZer6uc6ZJOK8xncnd0YB8qStygbSKDTJjjA3h6EH\nFEOSA5EPbkn3AUYQnuUvKbU4alBkC9YgMD6QRBG9Iyt0mqi1dHrKKDzKcZzC8FUl\n++Tl8XiMfQEl36n0eLHIfO8nDQKBgQDm8KkS2DQTrZD0Jb5RzeUWGhI1ofqxfba6\ngLanICnkPQQGYh08dsUeB55I1213R2geZ2GOyQLSdWYu0LAgaGAnTJOsWRJDnrzZ\nkQwQHKtKSHcrxfIZdDmxeDwPb6iO1frRlscpql+bO09A7yv4mFkqh+puVhAN3IOg\nO38VNjdmtQKBgQDzU5sGZyADSqOvpup1zLtah64I34F9bvUkrL5aIQPkchct6KMv\nCHv5ZycEuJd+uZIzERw6fbwxRDTYtKok9ffw6RJNY+UVtJiO0UlYZVagq6suYxzF\n8fO5gFwWfRp7vTaGljB91eiJiltUAbecdYO00qfBOTuIGnja0bXj6vuMZQKBgQCd\nxYpsgmJJk0k1UtfMAVLhn5wTIf8n5Q/CKI8gbDvSXtDyH3ODzExscJ31e5+gXptG\nMjCXIMKZz3SoxQ+ehFA0aP92Pj/ZDIhORuar1zo6fHlV4Vy9gQatNMwra4gHVS6O\no2ibEXdRkNpbLUqoAkTgZoyFJqy/G4idHih68Fg3BQKBgB7vr4fNrnLEaBHNxbRq\naitPotGJ1TUDjkewzzF7fQIRogK5Bv8OazdeV2U0CFThyAVOSRizMkk7f72mkbUV\nMkw128qCHX1juLzrLdXv6LtDRgqP1iVrxQ2Lni3C0w8HoXBF+jfgR+TGEw/I+Fn1\n5Syw2AKKn+8dNiDraiUDW4Fc\n-----END PRIVATE KEY-----\n",
      "client_email": "flutter-first-aider-alert-msg@flutterfirstaider.iam.gserviceaccount.com",
      "client_id": "109397669971431827595",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-first-aider-alert-msg%40flutterfirstaider.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    //define scopes for services
    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging", //cloud msging
      "https://www.googleapis.com/auth/firebase.database",  //to access database
      "https://www.googleapis.com/auth/userinfo.email"  //access email
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson), 
      scopes,
    );

    //using above client obtain the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson), 
      scopes, 
      client
    );

    client.close();

    //to send push notification via new FCM v1 api
    return credentials.accessToken.data;
  }

  static sendAlertToFirstAiders(String deviceToken, String userID, String userName, LatLng incidentLocation, String customMsg) async{
    final String serverToken = await getAccessToken();
    String endpointFCM = "https://fcm.googleapis.com/v1/projects/flutterfirstaider/messages:send"; //api url for sending notification

    //notification payload
    final Map<String,dynamic> messages = {
      'message' : {
        'token': deviceToken,  //token of the first aider phone we want send notification to
        'notification' :{
          'title': "Medical Emergency", 
          'body': "Alert First Aid Required!!"  
        },
        'data':{  
          'userID': userID, 
          'firstAiderName': userName, 
          'latitude': incidentLocation.latitude.toString(), 
          'longitude': incidentLocation.longitude.toString(), 
          'msg': customMsg, 
          'click_action': 'FLUTTER_NOTIFICATION_CLICK' 
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: <String, String> {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverToken'
      },
      body: jsonEncode(messages),
    );

    if(response.statusCode == 200){
      if(kDebugMode){
        print("notification sent.");
      }
    }else{
      if(kDebugMode){
        print("failed, notification could not be sent. Error : ${response.statusCode}");
      }  
    }
  }
}