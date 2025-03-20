import 'dart:io';

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static Future<String?> fetchGoogleKey() async {
    try {
      // Get the shared preferences instance
      SharedPreferences pref = await SharedPreferences.getInstance();
      String userToken = pref.getString('userToken') ?? '';

      // Determine the device type
      String device = Platform.isAndroid ? 'android' : 'ios';
      print('Device Name: $device');

      // Make the API call to fetch the key
      var response = await googlePlaceApiKey(userToken, device);

      if (response != null) {
        print('API response from fetchGoogleKey: $response');

        // Check the status of the response
        if (response['status'] == 1) {
          constanst.googleApikey = response['place_api_key'];
          print('Google Key: ${constanst.googleApikey}');
          return constanst.googleApikey;
        } else {
          print('Google key fetch failed: ${response['status']}');
        }
      }
    } catch (error) {
      print('Error fetching Google key: $error');
    }

    return null;
  }
}
