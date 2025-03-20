// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:Plastic4trade/utill/custom_toast.dart';

import '../api/api_interface.dart';
import 'package:Plastic4trade/model/getUserProfile.dart' as user;

class GetUserProfileController {
  user.User? record;

  Future<user.User?> getUser_profile(String userId, String userToken) async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getuser_Profile(userId, userToken, device);

    if (res['status'] == 1) {
      var jsonArray = res['user'];

      // for (var data in  jsonArray) {

      user.User record = user.User(
          countryCode: jsonArray['countryCode'],
          phoneno: jsonArray['phoneno'],
          email: jsonArray['email'],
          password: jsonArray['password'],
          imageUrl: jsonArray['image_url']);

      // buss.add(record);
      // }
    } else {
      showCustomToast(res['message']);
    }

    return record;
  }
}
