import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/global/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");

  Future<void> showUserNameAlertDialog(BuildContext context, String name) {
    nameTextEditingController.text =
        name; // Set the initial value of the text field
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update'),
          content: SingleChildScrollView(
            child: Column(
              children: [TextFormField(controller: nameTextEditingController)],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                userRef.child(FirebaseAuth.instance.currentUser!.uid).update({
                  "name": nameTextEditingController.text.trim(),
                }).then((value) {
                  nameTextEditingController.clear(); // Clear the text field after update
                  Fluttertoast.showToast(msg: "Name updated successfully");
                }).catchError((error) {
                  Fluttertoast.showToast(msg: "Failed to update name: $error");
                });
                Navigator.pop(context); // Dismiss the dialog
              },
              child: Text('Ok', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
  Future<void> showUserPhoneAlertDialog(BuildContext context, String phone) {
    phoneTextEditingController.text =
        phone; // Set the initial value of the text field
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update'),
          content: SingleChildScrollView(
            child: Column(
              children: [TextFormField(controller: phoneTextEditingController)],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                userRef.child(FirebaseAuth.instance.currentUser!.uid).update({
                  "phone": phoneTextEditingController.text.trim(),
                }).then((value) {
                  phoneTextEditingController.clear(); // Clear the text field after update
                  Fluttertoast.showToast(msg: "Phone updated successfully");
                }).catchError((error) {
                  Fluttertoast.showToast(msg: "Failed to update phone: $error");
                });
                Navigator.pop(context); // Dismiss the dialog
              },
              child: Text('Ok', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
  Future<void> showUserAddressAlertDialog(BuildContext context, String address) {
    nameTextEditingController.text =
        address; // Set the initial value of the text field
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update'),
          content: SingleChildScrollView(
            child: Column(
              children: [TextFormField(controller: addressTextEditingController)],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                userRef.child(FirebaseAuth.instance.currentUser!.uid).update({
                  "name": addressTextEditingController.text.trim(),
                }).then((value) {
                  addressTextEditingController.clear(); // Clear the text field after update
                  Fluttertoast.showToast(msg: "Address updated successfully");
                }).catchError((error) {
                  Fluttertoast.showToast(msg: "Failed to update Address: $error");
                });
                Navigator.pop(context); // Dismiss the dialog
              },
              child: Text('Ok', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard if open
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title: Text(
            "Profile screen",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${userModelCurrentInfo!.name!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showUserNameAlertDialog(
                          context,
                          userModelCurrentInfo!.name!,
                        );
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),

                Divider(thickness: 1),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${userModelCurrentInfo!.phone!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showUserPhoneAlertDialog(
                          context,
                          userModelCurrentInfo!.phone!,
                        );
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),
                Divider(thickness: 1),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${userModelCurrentInfo!.address!}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showUserAddressAlertDialog(
                          context,
                          userModelCurrentInfo!.address!,
                        );
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),

                Divider(thickness: 1),
                Text(
                  "${userModelCurrentInfo!.email!}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
