
import 'package:flutter/cupertino.dart';

import '../Models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotallTrips = 0;

  void updatePickUpLocationAddress(Directions pickUpLocation) {
    userPickUpLocation = pickUpLocation;
    notifyListeners();
  }
  void updateDropOffLocationAddress(Directions dropOffLocation) {
    userDropOffLocation = dropOffLocation;
    notifyListeners();
  }

}
