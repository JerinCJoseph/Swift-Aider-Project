import 'package:flutter/foundation.dart';

class UserAvailabilityStatus with ChangeNotifier {
  String _userStatus = "Online";

  String get status => _userStatus;

  void toggleStatus(bool isAvailable) {
    _userStatus = isAvailable ? "Online" : "Offline";  //store Online if true else Offline
    notifyListeners();
  }
}