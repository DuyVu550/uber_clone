import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:uber_clone/global/global.dart';

import '../splashScreen/SplashScreen.dart';
class RateDriverScreen extends StatefulWidget {
  String? assignedDriverId;
  RateDriverScreen({this.assignedDriverId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text("Rate Your Driver",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ),
            ),
            SizedBox(height: 14),
            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 22),
                  Text(
                    "Please rate your driver",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: darkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 2, color: darkTheme ? Colors.amber.shade400 : Colors.blue,),
                  SizedBox(height: 20),
                  SmoothStarRating(
                    rating: countRatingStars,
                    allowHalfRating: false,
                    starCount: 5,
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    borderColor: darkTheme ? Colors.amber.shade400 : Colors.grey,
                    size: 46,
                    onRatingChanged: (rating) {
                      countRatingStars = rating;
                      if(countRatingStars == 1){
                        setState(() {
                          titleStarsRating = "Very bad";
                        });
                      }
                      if(countRatingStars == 2){
                        setState(() {
                          titleStarsRating = "Bad";
                        });
                      }
                      if(countRatingStars == 3){
                        setState(() {
                          titleStarsRating = "Good";
                        });
                      }
                      if(countRatingStars == 4){
                        setState(() {
                          titleStarsRating = "Very good";
                        });
                      }
                      if(countRatingStars == 5){
                        setState(() {
                          titleStarsRating = "Excellent";
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10,),
                  Text(
                    titleStarsRating,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
                  },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                      ),
                      child: Text("Submit",
                        style: TextStyle(
                          fontSize: 20,
                          color: darkTheme ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  )],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
