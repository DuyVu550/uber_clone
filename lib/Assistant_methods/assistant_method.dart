import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/Assistant_methods/request_assistant.dart';
import 'package:uber_clone/InfoHandler/app_info.dart';
import 'package:uber_clone/Models/directions.dart';
import 'package:uber_clone/global/Map.dart';
import 'package:uber_clone/global/global.dart';

import '../Models/user_model.dart';

class AssistantMethod {
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(Position position,
      context) async {
    String apiUrl = "https://nominatim.openstreetmap.org/reverse?lat=${position
        .latitude}lon=${position.longitude}&format=json";
    String humanReadableAddress = "";
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if (requestResponse != "Error occured") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude.toString();
      userPickUpAddress.locationLongtitude = position.longitude.toString();
      userPickUpAddress.locationName = humanReadableAddress;
      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }
}
