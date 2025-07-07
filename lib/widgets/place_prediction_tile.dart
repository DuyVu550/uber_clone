
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/Models/directions.dart';
import 'package:uber_clone/global/Map.dart';
import 'package:uber_clone/widgets/progress_dialog.dart';
import '../Assistant_methods/request_assistant.dart';
import '../InfoHandler/app_info.dart';
import '../Models/predicted_places.dart';
import '../global/global.dart';

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
          return ProgressDialog(
            message: "Please wait...",
          );
        }
    );
    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);
    Navigator.pop(context);
    if(responseApi == "Error Occurred") {
      return;
    }
    if(responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongtitude = responseApi["result"]["geometry"]["location"]["lng"];
      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);
      setState(() {
        userDropOffAddress = directions.locationName!;
      });
      Navigator.pop(context, "containedDropoff");
    }
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
        onPressed: (){
          getPlaceDirectionDetails(widget.predictedPlace!.place_id, context);
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
