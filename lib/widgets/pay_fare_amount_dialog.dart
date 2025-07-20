import 'package:flutter/material.dart';
import 'package:uber_clone/screen/rate_driver_screen.dart';
import 'package:uber_clone/splashScreen/SplashScreen.dart';
class PayFareAmountDialog extends StatefulWidget {

  double? fareAmount;
  PayFareAmountDialog({this.fareAmount});

  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("Fare Amount".toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              "₹ ${0}",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.white,
              ),
            ),
            SizedBox(height: 10),

            Padding(
                padding: EdgeInsets.all(10),
              child: Text(
                "This is the total fare amount for this ride.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkTheme ? Colors.amber.shade400 : Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
                padding: EdgeInsets.all(20),
              child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white,
              ),
                onPressed: (){
                   Navigator.push(context, MaterialPageRoute(builder: (c) => RateDriverScreen()));
                },
                child: Row(
                  children: [
                    Text(
                      "Pay Cash",
                      style: TextStyle(
                        fontSize: 20,
                        color: darkTheme ? Colors.black : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "",
                      style: TextStyle(
                        fontSize: 20,
                        color: darkTheme ? Colors.black : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
             ),
            )
          ],
        ),
      ),
    );
  }
}

