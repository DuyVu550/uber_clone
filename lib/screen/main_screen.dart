import 'dart:async';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:uber_clone/Models/active_nearby_available_drivers.dart';
import 'package:uber_clone/screen/precis_pickup_location.dart';
import 'package:uber_clone/screen/search_placed_screen.dart';
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
import 'package:uber_clone/widgets/progress_dialog.dart';
import '../Assistant_methods/geofire_assistant.dart';
import '../screen/drawer_screen.dart';
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
  GoogleMapController? newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.762622, 106.660172), // TP.HCM
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220.0;
  double waitingResponseFromDriverContainerHeight = 0.0;
  double assignedDriverInfoContainerHeight = 0.0;

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

    initializeGeoFireListener();
  }

  initializeGeoFireListener(){
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
     .listen((map) {
       print(map);
       if(map != null) {
         var callBack = map["callBack"];
         switch (callBack) {
           //whenever any driver become active
           case Geofire.onKeyEntered:
             ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers = ActiveNearbyAvailableDrivers();
             activeNearbyAvailableDrivers.locationLongitude = map["longitude"];
             activeNearbyAvailableDrivers.locationLatitude = map["latitude"];
             activeNearbyAvailableDrivers.driverId = map["key"];
             GeofireAssistant.activeNearbyAvailableDriversList.add(
                 activeNearbyAvailableDrivers);
             if (activeNearbyDriverKeyLoaded) {
               displayActiveDriverOnUserMap();
             }
             break;
            //whenever any driver become offline
           case Geofire.onKeyExited:
             GeofireAssistant.deleteOfflineDriverFromList(map["key"]);
             displayActiveDriverOnUserMap();
             break;
            //whenever driver move and update driver's location
           case Geofire.onKeyMoved:
             ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers = ActiveNearbyAvailableDrivers();
             activeNearbyAvailableDrivers.locationLongitude = map["longitude"];
             activeNearbyAvailableDrivers.locationLatitude = map["latitude"];
             activeNearbyAvailableDrivers.driverId = map["key"];
             GeofireAssistant.updateActiveNearbyAvailableDriverLocation(
                 activeNearbyAvailableDrivers);
             displayActiveDriverOnUserMap();
             break;
         //display those online drivers on user's map
           case Geofire.onGeoQueryReady:
             activeNearbyDriverKeyLoaded = true;
             displayActiveDriverOnUserMap();
             break;
         }
       }
       setState(() {

       });
    });

  }

  displayActiveDriverOnUserMap(){
    setState(() {
      markerSet.clear();
      circleSet.clear();
      Set<Marker> driverMarkersSet = Set<Marker>();
      for(ActiveNearbyAvailableDrivers eachDriver in GeofireAssistant.activeNearbyAvailableDriversList) {
        LatLng driverActivePosition = LatLng(
          eachDriver.locationLatitude!,
          eachDriver.locationLongitude!,
        );
        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: driverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );
        driverMarkersSet.add(marker);
      }

      setState(() {
        markerSet = driverMarkersSet;
      });
    });
  }

  createActiveByDriverIconMarker() async {
    if(activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.asset(imageConfiguration, "image/car.jpg").then((value) {
        activeNearbyIcon = value;
      });
    }
  }

  Future<void> drawPolylineFromOrigintoDestination(bool darkTheme) async{
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
    var originLatLng = LatLng(
      double.parse(originPosition!.locationLatitude!),
      double.parse(originPosition.locationLongtitude!),
    );
    var destinationLatLng = LatLng(
      double.parse(destinationPosition!.locationLatitude!),
      double.parse(destinationPosition.locationLongtitude!),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Please wait...");
        });
    var directionDetailsInfo = await AssistantMethod.obtainOriginToDestinationDirectionsDetails(originLatLng, destinationLatLng,);
    setState(() {
      tripDirectionsDetailsInfo = directionDetailsInfo;
    });
    Navigator.pop(context);
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);
    pLineCoordinatesList.clear();
    if(decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polylineSet.add(polyline);
    });
    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude));
    }
    else if(originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude));
    }
    else {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
    Marker originMarker = Marker(
      markerId: MarkerId("originId"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationId"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
    );
    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });
    Circle originCircle = Circle(
      circleId: CircleId("originId"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId("destinationId"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );
    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
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
        key: scaffoldKey,
        drawer: DrawerScreen(),
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
            ),
            //drawer
            Positioned(
              top: 50,
              left: 20,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      scaffoldKey.currentState!.openDrawer();
                    },
                    child: CircleAvatar(
                      backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white,
                      child: Icon(
                        Icons.menu,
                        color: darkTheme ? Colors.black : Colors.lightBlue,
                      ),
                    ),
                  ),
                )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 70, 20),
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
                                    onTap: () async {
                                      var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c) => SearchPlacedScreen()));
                                      if(responseFromSearchScreen == "containedDropoff") {
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }
                                      await drawPolylineFromOrigintoDestination(darkTheme);
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
                                              ? Provider.of<AppInfo>(context,).userDropOffLocation!.locationName!
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
                          ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (c) => PrecisePickupScreen()));
                                  },
                                  child: Text(
                                    "Change Pickup",
                                    style: TextStyle(
                                      color: darkTheme ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  )
                              ),
                              SizedBox(width: 10,),

                              ElevatedButton(
                                  onPressed: (){

                                  },
                                  child: Text(
                                    "Request a ride",
                                    style: TextStyle(
                                      color: darkTheme ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  )
                              ),
                            ],
                          )
                        ],
                      )
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
