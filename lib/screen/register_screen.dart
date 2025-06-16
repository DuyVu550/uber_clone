import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:uber_clone/global/global.dart';
import 'package:uber_clone/screen/main_page.dart';

import 'forgot_password_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmPasswordTextEditingController = TextEditingController();
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth
          .createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
          )
          .then((auth) async {
            currentUser = auth.user;
            if (currentUser != null) {
              Map userMap = {
                "id": currentUser!.uid,
                "name": nameTextEditingController.text.trim(),
                "email": emailTextEditingController.text.trim(),
                "address": addressTextEditingController.text.trim(),
                "phone": phoneTextEditingController.text.trim(),
              };
              DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users",);
              userRef.child(currentUser!.uid).set(userMap);
            }
            await Fluttertoast.showToast(msg: "Registration Successful");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => MainScreen()));
          }).catchError((error) {
            Fluttertoast.showToast(
              msg: "Registration Failed: ${error.toString()}",
            );
          });
    } else {
      Fluttertoast.showToast(msg: "Please fill in all fields correctly");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
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
                  "Register",
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
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Name",
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
                                  Icons.person,
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
                                  return "Name cannot be empty";
                                }
                                if (text.length < 2) {
                                  return "Please enter a valid name";
                                }
                                if (text.length > 49) {
                                  return "Name cannot be more than 50 characters";
                                }
                              },
                              onChanged: (text) {
                                setState(() {
                                  nameTextEditingController.text = text;
                                });
                              },
                            ),
                            SizedBox(height: 20),
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
                            IntlPhoneField(
                              showCountryFlag: false,
                              dropdownIcon: Icon(
                                Icons.arrow_drop_down,
                                color:
                                    darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.grey,
                              ),
                              decoration: InputDecoration(
                                hintText: "PhoneNumber",
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
                              ),
                              initialCountryCode: 'VN',
                              onChanged:
                                  (text) => {
                                    setState(() {
                                      phoneTextEditingController.text =
                                          text.completeNumber;
                                    }),
                                  },
                            ),
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Address",
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
                                  Icons.location_on_outlined,
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
                                  return "Address cannot be empty";
                                }
                                if (text.length < 2) {
                                  return "Please enter a valid Address";
                                }
                                if (text.length > 99) {
                                  return "Address cannot be more than 100 characters";
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
                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Password",
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
                                  Icons.password_outlined,
                                  color:
                                      darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color:
                                        darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Password cannot be empty";
                                }
                                if (text.length < 6) {
                                  return "Please enter a valid Password";
                                }
                                if (text.length > 49) {
                                  return "Password cannot be more than 100 characters";
                                }
                                return null;
                              },
                              onChanged: (text) {
                                setState(() {
                                  passwordTextEditingController.text = text;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "ConfirmPassword",
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
                                  Icons.password,
                                  color:
                                      darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color:
                                        darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Confirm Password cannot be empty";
                                }
                                if (text !=
                                    passwordTextEditingController.text) {
                                  return "Confirm Password does not match";
                                }
                                if (text.length < 6) {
                                  return "Please enter a valid confirm password";
                                }
                                if (text.length > 49) {
                                  return "Confirm password cannot be more than 100 characters";
                                }
                                return null;
                              },
                              onChanged: (text) {
                                setState(() {
                                  confirmPasswordTextEditingController.text =
                                      text;
                                });
                              },
                            ),
                            SizedBox(height: 20),
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
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color:
                                      darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.blue,
                                  fontSize: 16,
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
                                "Login",
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
