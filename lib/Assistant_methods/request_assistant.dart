import 'dart:convert';
import 'package:http/http.dart' as http;
class RequestAssistant{
  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));
    try{
      if(httpResponse.statusCode == 200){
        String responseData = httpResponse.body;
        var decodeResponseData = jsonDecode(responseData); // You can use jsonDecode if needed
        return decodeResponseData;
      } else {
        return "Error Occurred";
      }
    } catch (e) {
      return "Error Occurred";
    }
  }
}