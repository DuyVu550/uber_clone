
import 'package:firebase_database/firebase_database.dart';
import 'package:uber_clone/Assistant_methods/request_assistant.dart';
import 'package:uber_clone/Models/directions.dart';
import 'package:uber_clone/global/Map.dart';
import 'package:uber_clone/global/global.dart';

import '../Models/user_model.dart';

class AssistantMethod{
  static void readCurrentOnlineUserInfo() async{
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentUser!.uid);
    userRef.once().then((snap) {
      if(snap.snapshot.value != null){
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }
  static Future<String> searchAddressForGeographicCoordinates(dynamic position, context) async {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if(requestResponse != "Error occured"){
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude.toString();
      userPickUpAddress.locationLongtitude = position.longitude.toString();
      userPickUpAddress.locationName = humanReadableAddress;
    }
    return humanReadableAddress;
  }

}