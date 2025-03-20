// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:Plastic4trade/utill/custom_toast.dart';

import '../api/api_interface.dart';

class GetUnitController {
  Future<List<String>> setunit() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getUnit(device);
    var jsonArray;
    if (res['status'] == 1) {
      jsonArray = res['result'][0]['Unit'].cast<String>();
    } else {
      showCustomToast(res['message']);
    }
    return jsonArray;
  }
}
