import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uber_clone/Models/directions_details_info.dart';

import '../Models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;
UserModel? userModelCurrentInfo;
String? userDropOffAddress = "";
DirectionsDetailsInfo? tripDirectionsDetailsInfo;
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";

double countRatingStars = 0.0;
String titleStarsRating = "";
List driversList = [];
String cloudMessagingServerToken = 'key=DJcUKSd0_Yi4Mx_P41Jn8n2D6t1MoNYR1M--RVfurxs';