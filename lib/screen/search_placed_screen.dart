import 'package:flutter/material.dart';
import 'package:uber_clone/widgets/place_prediction_tile.dart';

import '../Assistant_methods/request_assistant.dart';
import '../Models/predicted_places.dart';
import '../global/Map.dart';

class SearchPlacedScreen extends StatefulWidget {
  const SearchPlacedScreen({super.key});

  @override
  State<SearchPlacedScreen> createState() => _SearchPlacedScreenState();
}

class _SearchPlacedScreenState extends State<SearchPlacedScreen> {
  List<PredictedPlaces> placesPredictedList = [];

  findPlaceAutoCompleteSearch(String inputText) async {
    if(inputText.length > 1){
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:BD";
      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);
      if (responseAutoCompleteSearch == "Error Occurred") {
        return;
      }
      if(responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];
        var placesPredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();
        setState(() {
          placesPredictedList = placesPredictionsList;
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery
        .of(context)
        .platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
      child: Scaffold(
          backgroundColor: darkTheme ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: darkTheme ? Colors.black : Colors.white,
              ),
            ),
            title: Text(
              "Search and set dropped Placed",
              style: TextStyle(
                color: darkTheme ? Colors.black : Colors.white,
              ),
            ),
            elevation: 0.0,
          ),
          body: Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white54,
                            blurRadius: 0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          )
                        ]
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.adjust_sharp,
                                  color: darkTheme ? Colors.black : Colors
                                      .white,
                                ),
                                SizedBox(height: 18,),
                                Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: TextField(
                                        onChanged: (value) {
                                          findPlaceAutoCompleteSearch(value);
                                        },
                                        decoration: InputDecoration(
                                            hintText: "Search location here..",
                                            fillColor: darkTheme
                                                ? Colors.black
                                                : Colors.white54,
                                            filled: true,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                              left: 11,
                                              top: 8,
                                              bottom: 8,
                                            )
                                        ),
                                      ),
                                    )
                                )
                              ],
                            )
                          ],

                        )
                    )
                ),
                (placesPredictedList.length > 0) ?
                Expanded(
                    child: ListView.separated(
                        itemCount: placesPredictedList.length,
                        itemBuilder: (context, index) {
                          return PlacePredictionTileDesign(
                            predictedPlace: placesPredictedList[index],
                          );
                        },
                        physics: ClampingScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                                height: 0,
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.blue,
                                thickness: 0
                            )
                    )
                ) : Container(),
              ]
          )
      ),
    );
  }
}
