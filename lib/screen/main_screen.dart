import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:uber_clone/global/Map.dart';

import '../Assistant_methods/assistant_method.dart';

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

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(10.762622, 106.660172), // TP.HCM
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
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
    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 15,
    );
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress = await AssistantMethod.searchAddressForGeographicCoordinates(cPosition, context);
    print("Your address: $humanReadableAddress");
  }
  getAddressFromLatLng() async {
   try{
     GeoData data = await Geocoder2.getDataFromCoordinates(
       latitude: pickLocation!.latitude,
       longitude: pickLocation!.longitude,
       googleMapApiKey: mapKey,
     );
     setState(() {
        address = data.address;
     });
   }
    catch (e) {
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
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
                if(pickLocation != position!.target) {
                  setState(() {
                    pickLocation = position.target;
                  });
                }
              },
              onCameraIdle: (){
                getAddressFromLatLng();
              },
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 35),
                  child: Image.asset(
                    "../image/pick.png",
                    height: 45,
                    width: 45,
                  )),
            ),
            Positioned(
               top: 40,
               right: 20,
              left: 20,
              child: Container(
               decoration: BoxDecoration(
                 border: Border.all(color: Colors.black),
                 color: Colors.white,
               ),
                padding: EdgeInsets.all(20),
                child: Text(address ?? "Select your pickup",
                 overflow: TextOverflow.visible, softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
