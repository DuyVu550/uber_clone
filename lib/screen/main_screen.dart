import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/Models/active_nearby_available_drivers.dart';
import 'package:uber_clone/screen/precis_pickup_location.dart';
import 'package:uber_clone/screen/search_placed_screen.dart';
import 'package:uber_clone/splashScreen/SplashScreen.dart';
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
import '../widgets/pay_fare_amount_dialog.dart';

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
  double suggestedRidesContainerHeight = 0.0;
  double searchingForDriverContainerHeight = 0.0;

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

  String selectedRideType = "";
  DatabaseReference? referenceRideRequest;

  String driverRideStatus = "Driver is on the way";
  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubscription;

  String userRideRequestStatus = "";
  bool requestPositionInfo = true;
  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];


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

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
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
      setState(() {});
    });
  }

  displayActiveDriverOnUserMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();
      Set<Marker> driverMarkersSet = Set<Marker>();
      for (ActiveNearbyAvailableDrivers eachDriver in GeofireAssistant
          .activeNearbyAvailableDriversList) {
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
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
          context, size: Size(2, 2));
      BitmapDescriptor.asset(imageConfiguration, "../image/car.jpg").then((
          value) {
        activeNearbyIcon = value;
      });
    }
  }

  Future<void> drawPolylineFromOrigintoDestination(bool darkTheme) async {
    var originPosition = Provider
        .of<AppInfo>(context, listen: false)
        .userPickUpLocation;
    var destinationPosition = Provider
        .of<AppInfo>(context, listen: false)
        .userDropOffLocation;
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
    var directionDetailsInfo = await AssistantMethod
        .obtainOriginToDestinationDirectionsDetails(
      originLatLng, destinationLatLng,);
    setState(() {
      tripDirectionsDetailsInfo = directionDetailsInfo;
    });
    Navigator.pop(context);
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList = pPoints.decodePolyline(
        directionDetailsInfo.e_points!);
    pLineCoordinatesList.clear();
    if (decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList.add(
            LatLng(pointLatLng.latitude, pointLatLng.longitude));
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
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(
              destinationLatLng.latitude, originLatLng.longitude));
    }
    else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(
              originLatLng.latitude, destinationLatLng.longitude));
    }
    else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }
    newGoogleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(boundsLatLng, 65));
    Marker originMarker = Marker(
      markerId: MarkerId("originId"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
          title: originPosition.locationName, snippet: "Origin"),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationId"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
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

  showSuggestedRidesContainer() {
    setState(() {
      suggestedRidesContainerHeight = 600;
      bottomPaddingOfMap = 400;
    });
  }

  showSearchingForDriversContainer() {
    setState(() {
      searchingForDriverContainerHeight = 600;
      bottomPaddingOfMap = 400;
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

  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo) {
      requestPositionInfo = false;
      LatLng userPickupPosition = LatLng(
          userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      var directionDetailsInfo = await AssistantMethod
          .obtainOriginToDestinationDirectionsDetails(
          driverCurrentPositionLatLng, userPickupPosition);

      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Driver is on the way" +
            directionDetailsInfo.duration_text.toString();
      });
      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropoffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo) {
      requestPositionInfo = false;
      var dropOffPosition = Provider
          .of<AppInfo>(context, listen: false)
          .userDropOffLocation;
      LatLng userDestinationPosition = LatLng(
        double.parse(dropOffPosition!.locationLatitude!),
        double.parse(dropOffPosition.locationLongtitude!),
      );
      var directionDetailsInfo = await AssistantMethod
          .obtainOriginToDestinationDirectionsDetails(
          driverCurrentPositionLatLng, userDestinationPosition);
      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Driver is on the way to your destination" +
            directionDetailsInfo.duration_text.toString();
      });
      requestPositionInfo = true;
    }
  }

  saveRideRequestInformation(String selectedCarType) {
    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("All Ride Request").push();
    var originLocation = Provider
        .of<AppInfo>(context, listen: false)
        .userPickUpLocation;
    var destinationLocation = Provider
        .of<AppInfo>(context, listen: false)
        .userDropOffLocation;

    Map originLocationMap = {
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongtitude.toString(),
    };

    Map destinationLocationMap = {
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongtitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "userAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };

    referenceRideRequest!.set(userInformationMap);

    tripRidesRequestInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async {
          if (eventSnap.snapshot.value == null) {
            return;
          }
          if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
            setState(() {
              driverCarDetails =
                  (eventSnap.snapshot.value as Map)["car_details"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["driverPhone"] != null) {
            setState(() {
              driverCarDetails =
                  (eventSnap.snapshot.value as Map)["driverPhone"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["driverName"] != null) {
            setState(() {
              driverCarDetails =
                  (eventSnap.snapshot.value as Map)["driverName"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["status"] != null) {
            setState(() {
              userRideRequestStatus =
                  (eventSnap.snapshot.value as Map)["status"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["driverLocation"] != null) {
            double driverCurrentPositionLat = double.parse(
                (eventSnap.snapshot.value as Map)["driverLocation"]["latitude"]
                    .toString());
            double driverCurrentPositionLng = double.parse(
                (eventSnap.snapshot.value as Map)["driverLocation"]["longitude"]
                    .toString());

            LatLng driverCurrentPositionLatLng = LatLng(
                driverCurrentPositionLat, driverCurrentPositionLng);

            if (userRideRequestStatus == "accepted") {
              updateArrivalTimeToUserPickupLocation(
                  driverCurrentPositionLatLng);
            }
            if (userRideRequestStatus == "arrived") {
              setState(() {
                driverRideStatus = "Driver has arrived";
              });
            }
            if (userRideRequestStatus == "ontrip") {
              setState(() {
                updateReachingTimeToUserDropoffLocation(
                    driverCurrentPositionLatLng);
              });
            }

            if (userRideRequestStatus == "ended") {
              if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
                double fareAmount = double.parse("0");
                var response = await showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        PayFareAmountDialog()
                );
                if (response == "Cash Paid") {
                  if ((eventSnap.snapshot.value as Map)["driverId"] != null) {
                    String assignedDriverId = (eventSnap.snapshot
                        .value as Map)["driverId"].toString();
                    // Navigator.push(context, MaterialPageRoute(builder: (c) => RateDriverScreen()));
                    referenceRideRequest!.onDisconnect();
                    tripRidesRequestInfoStreamSubscription!.cancel();
                  }
                }
              }
            }
          }
        });
    onlineNearByAvailableDriversList =
        GeofireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers(selectedCarType);
  }

  searchNearestOnlineDrivers(String selectedCarType) async {
    if (onlineNearByAvailableDriversList.length == 0) {
      referenceRideRequest!.remove();
      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCoordinatesList.clear();
      });
      Fluttertoast.showToast(msg: "No available drivers nearby");
      Fluttertoast.showToast(msg: "Search again");
      Future.delayed(Duration(milliseconds: 4000), () {
        referenceRideRequest!.remove();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => SplashScreen()));
      });
      return;
    }
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
    print("driversList: ${driversList.toString()}");
    for (int i = 0; i < driversList.length; i++) {
      if (driversList[i]["car_details"]["type"] == selectedCarType) {
        AssistantMethod.sendNotificationToDriver(
          driversList[i]["token"].toString(),
          referenceRideRequest!.key!.toString(),
          context,
        );
      }
    }
    Fluttertoast.showToast(msg: "notification sent to drivers");
    showSearchingForDriversContainer();
    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Request")
        .child(referenceRideRequest!.key!)
        .child("driverId")
        .onValue
        .listen((eventRideRequestSnapShot) {
      print("Event Ride Request SnapShot: ${eventRideRequestSnapShot.snapshot
          .value}");
      if (eventRideRequestSnapShot.snapshot.value != null) {
        if (eventRideRequestSnapShot.snapshot.value != "waiting") {
          showUIForAssignedDriverInfo();
        }
      }
    });
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchingForDriverContainerHeight = 0;
      assignedDriverInfoContainerHeight = 200;
      suggestedRidesContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }

  retrieveOnlineDriversInformation(
      List onlineNearByAvailableDriversList) async {
    driversList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for (int i = 0; i < onlineNearByAvailableDriversList.length; i++) {
      await ref.child(onlineNearByAvailableDriversList[i].driverId.toString())
          .once()
          .then((snap) {
        var driverKeyInfo = snap.snapshot.value;
        driversList.add(driverKeyInfo);
        print("driverKeyInfo: ${driversList.toString()}");
      });
    }
  }

////////////////
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery
        .of(context)
        .platformBrightness == Brightness.dark;
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
                  bottomPaddingOfMap = 300.0; // Adjust this value as needed
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
                      backgroundColor: darkTheme
                          ? Colors.amber.shade400
                          : Colors.white,
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
                                color: darkTheme
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                          color: darkTheme ? Colors.amber
                                              .shade400 : Colors.blue,),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text("From ", style: TextStyle(
                                                color: darkTheme ? Colors
                                                    .amber.shade400 : Colors
                                                    .blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                            Text(Provider
                                                .of<AppInfo>(context)
                                                .userPickUpLocation != null
                                                ? "37 Le long, District 1, HCM"
                                                : " Not getting address",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),)
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  Divider(
                                    height: 3,
                                    thickness: 2,
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.blue,
                                  ),
                                  SizedBox(height: 5,),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: GestureDetector(
                                      onTap: () async {
                                        var responseFromSearchScreen = await Navigator
                                            .push(context, MaterialPageRoute(
                                            builder: (c) =>
                                                SearchPlacedScreen()));
                                        if (responseFromSearchScreen ==
                                            "containedDropoff") {
                                          setState(() {
                                            openNavigationDrawer = false;
                                          });
                                        }
                                        await drawPolylineFromOrigintoDestination(
                                            darkTheme);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on_outlined,
                                            color: darkTheme ? Colors.amber
                                                .shade400 : Colors.blue,),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text("To ", style: TextStyle(
                                                  color: darkTheme ? Colors
                                                      .amber.shade400 : Colors
                                                      .blue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight
                                                      .bold)),
                                              Text(Provider
                                                  .of<AppInfo>(context)
                                                  .userDropOffLocation != null
                                                  ? Provider
                                                  .of<AppInfo>(context,)
                                                  .userDropOffLocation!
                                                  .locationName!
                                                  : " Where to?",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),)
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
                                    onPressed: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (c) =>
                                              PrecisePickupScreen()));
                                    },
                                    child: Text(
                                      "Change Pickup",
                                      style: TextStyle(
                                        color: darkTheme
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkTheme ? Colors
                                          .amber.shade400 : Colors.blue,
                                      textStyle: TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    )
                                ),
                                SizedBox(width: 10,),

                                ElevatedButton(
                                    onPressed: () {
                                      showSuggestedRidesContainer();
                                    },
                                    child: Text(
                                      "Show Fare",
                                      style: TextStyle(
                                        color: darkTheme
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkTheme ? Colors
                                          .amber.shade400 : Colors.blue,
                                      textStyle: TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.bold),
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
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                  height: suggestedRidesContainerHeight,
                  decoration: BoxDecoration(
                    color: darkTheme ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 15,),

                            Text(
                              Provider
                                  .of<AppInfo>(context)
                                  .userPickUpLocation != null
                                  ? (Provider
                                  .of<AppInfo>(context,)
                                  .userPickUpLocation!
                                  .locationName!).substring(0, 24) + "..."
                                  : " Not getting address",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 15,),

                            Text(
                              Provider
                                  .of<AppInfo>(context)
                                  .userDropOffLocation != null
                                  ? Provider
                                  .of<AppInfo>(context,)
                                  .userDropOffLocation!
                                  .locationName!
                                  : " Where to?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20,),

                        Text(
                          "Suggested Rides",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        SizedBox(height: 20,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedRideType = "Car";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedRideType == "Car"
                                      ? (darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue)
                                      : (darkTheme ? Colors.black54 : Colors
                                      .grey[100]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "../image/car.jpg", scale: 2.0,),

                                      SizedBox(height: 8,),

                                      Text(
                                        "car",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedRideType == "Car"
                                              ? (darkTheme
                                              ? Colors.black
                                              : Colors.white)
                                              : (darkTheme
                                              ? Colors.white
                                              : Colors.black),
                                        ),
                                      ),

                                      SizedBox(height: 2,),

                                      Text(
                                          tripDirectionsDetailsInfo != null
                                              ? '${AssistantMethod
                                              .calculateFareAmountFromOriginToDestination(
                                              tripDirectionsDetailsInfo!)}'
                                              : "0 USd",
                                          style: TextStyle(
                                            color: Colors.grey,
                                          )
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedRideType = "BMP";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedRideType == "BMP"
                                      ? (darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue)
                                      : (darkTheme ? Colors.black54 : Colors
                                      .grey[100]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "../image/car.jpg", scale: 2.0,),

                                      SizedBox(height: 8,),

                                      Text(
                                        "BMP",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedRideType == "BMP"
                                              ? (darkTheme
                                              ? Colors.black
                                              : Colors.white)
                                              : (darkTheme
                                              ? Colors.white
                                              : Colors.black),
                                        ),
                                      ),

                                      SizedBox(height: 2,),

                                      Text(
                                          tripDirectionsDetailsInfo != null
                                              ? '${AssistantMethod
                                              .calculateFareAmountFromOriginToDestination(
                                              tripDirectionsDetailsInfo!)}'
                                              : "0 USD",
                                          style: TextStyle(
                                            color: Colors.grey,
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20,),

                        Expanded(
                            child: GestureDetector(
                              onTap: () {
                                saveRideRequestInformation(selectedRideType);
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Request Ride",
                                    style: TextStyle(
                                      color: darkTheme ? Colors.black : Colors
                                          .white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                        )
                      ],
                    ),
                  )
              ),
            ),

            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: searchingForDriverContainerHeight,
                  decoration: BoxDecoration(
                    color: darkTheme ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                        ),
                        SizedBox(height: 10,),

                        Center(
                          child: Text(
                            "Searching for nearby drivers",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                            ),
                          ),
                        ),

                        SizedBox(height: 20,),

                        GestureDetector(
                          onTap: (){
                            referenceRideRequest!.remove();
                            setState(() {
                              searchingForDriverContainerHeight = 0;
                              suggestedRidesContainerHeight = 0;
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: darkTheme ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: Icon(Icons.close, size: 25,)
                          ),
                        ),

                        SizedBox(height: 15,),

                        Container(
                          width: double.infinity,
                          child: Text(
                            "Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        )

                      ],

                    ),
                  ),

                )
            )
          ],
        ),
      ),
    );
  }
}
