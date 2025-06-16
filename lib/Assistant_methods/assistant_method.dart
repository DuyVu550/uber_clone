
import 'package:firebase_database/firebase_database.dart';
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
}