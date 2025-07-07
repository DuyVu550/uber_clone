import 'dart:async';
import 'package:uber_clone/themeProvider/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:uber_clone/Models/directions.dart';
import 'package:uber_clone/global/Map.dart';
import 'package:uber_clone/global/global.dart';

import '../Assistant_methods/assistant_method.dart';
import '../InfoHandler/app_info.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? address;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.762622, 106.660172), // TP.HCM
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220.0;
  double waitingResponseFromDriverContainerHeight = 0.0;
  double assignedDriverInfoContainerHeight = 0.0;

  GoogleMapController? newGoogleMapController;
  Position? userCurrentPosition;
  var geolocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0.0;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "";
  String userEmail = "";

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeyLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userCurrentPosition = cPosition;
    LatLng latLngPosition = LatLng(
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
    );
    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 15,
    );
    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    String humanReadableAddress =
        await AssistantMethod.searchAddressForGeographicCoordinates(
          cPosition,
          context,
        );
    print("Your address: $humanReadableAddress");
    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;
  }

  getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: pickLocation!.latitude,
        longitude: pickLocation!.longitude,
        googleMapApiKey: '',
      );
      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = pickLocation!.latitude.toString();
        userPickUpAddress.locationLongtitude = pickLocation!.longitude.toString();
        userPickUpAddress.locationName = data.address;
        Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
        address = data.address;
      });
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
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
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {
                  // bottomPaddingOfMap = 300.0; // Adjust this value as needed
                });
                locateUserPosition();
              },
              onCameraMove: (CameraPosition? position) {
                // Handle camera movement if needed
                if (pickLocation != position!.target) {
                  setState(() {
                    pickLocation = position.target;
                  });
                }
              },
              onCameraIdle: () {
                getAddressFromLatLng();
              },
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Image.asset("../image/pick.png", height: 45, width: 45),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 10, 880),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: darkTheme ? Colors.grey.shade900 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, color: darkTheme ? Colors.amber.shade400 : Colors.blue,),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("From ", style: TextStyle(color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                          fontSize: 12, fontWeight: FontWeight.bold)),
                                          Text(Provider.of<AppInfo>(context).userPickUpLocation != null
                                              ? (Provider.of<AppInfo>(context,).userPickUpLocation!.locationName!).substring(0, 24) + "..."
                                              : " Not getting address",
                                          style: TextStyle(color: Colors.grey, fontSize: 14),)
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Divider(
                                  height: 3,
                                  thickness: 2,
                                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                ),
                                SizedBox(height: 5,),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () {

                                    },
                                    child: Row(
                                      children: [
                                      Icon(Icons.location_on_outlined, color: darkTheme ? Colors.amber.shade400 : Colors.blue,),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("To ", style: TextStyle(color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                              fontSize: 12, fontWeight: FontWeight.bold)),
                                          Text(Provider.of<AppInfo>(context).userDropOffLocation != null
                                              ? (Provider.of<AppInfo>(context,).userDropOffLocation!.locationName!).substring(0, 24) + "..."
                                              : " Where to?",
                                            style: TextStyle(color: Colors.grey, fontSize: 14),)
                                        ],
                                      ),
                                     ],
                                    ),
                                  ),
                                )

                              ],
                            ),
                          )
                        ],
                      )
                    )
                  ],
                ),
              ),
            )
            /*Positioned(
              top: 40,
              right: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  Provider.of<AppInfo>(context).userPickUpLocation != null
                      ? (Provider.of<AppInfo>(context,).userPickUpLocation!.locationName!).substring(0, 24) + "..."
                      : " Not getting address",
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
