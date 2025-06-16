import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/global/global.dart';

import 'login_screen.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  void _submit() {
    firebaseAuth.sendPasswordResetEmail(email: emailTextEditingController.text.trim())
        .then((value) {
      Fluttertoast.showToast(msg: "We have sent you an email to reset your password. Please check your inbox.");
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg:"Error occured ${error.toString()}");
    });
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(
                  darkTheme ? "../image/city_night.jpg" : "../image/city.jpg",
                ),
                SizedBox(height: 20),
                Text(
                  "Forgot Password",
                  style: TextStyle(
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /////Email
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor:
                                darkTheme
                                    ? Colors.black45
                                    : Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color:
                                  darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.grey,
                                ),
                              ),
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Email cannot be empty";
                                }
                                if (EmailValidator.validate(text)) {
                                  return null;
                                }
                                if (text.length < 2) {
                                  return "Please enter a valid email";
                                }
                                if (text.length > 99) {
                                  return "Email cannot be more than 100 characters";
                                }
                              },
                              onChanged: (text) {
                                setState(() {
                                  emailTextEditingController.text = text;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            // Password
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                _submit();
                              },
                              child: Text(
                                "Send reset password code",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 1),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Log in",
                                style: TextStyle(
                                  color:
                                  darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
