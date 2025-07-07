
import 'package:flutter/material.dart';
import '../Models/predicted_places.dart';

class PlacePredictionTileDesign extends StatefulWidget {

  final PredictedPlaces? predictedPlace;
  PlacePredictionTileDesign({
    this.predictedPlace,
  });

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProgressDialog();
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
        onPressed: (){

        },
      style: ElevatedButton.styleFrom(
          backgroundColor: darkTheme ? Colors.black : Colors.white,
        ),
        child: Padding(
            padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add_location,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ),
              SizedBox(width: 10.0,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.predictedPlace!.main_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        widget.predictedPlace!.secondary_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                          fontSize: 16.0,
                        ),
                      )
                    ],
                )
              )
            ],
          )
        ),
    );
  }
}
