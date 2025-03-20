// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:Plastic4trade/utill/custom_toast.dart';

import '../api/api_interface.dart';
import 'package:Plastic4trade/model/GetColors.dart' as color;

class GetColorsController {
  List<color.Result> color_data = <color.Result>[];
  Map<String, dynamic>? data;
  Future<List<color.Result>> setlogin() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getColors(device);

    if (res['status'] == 1) {
      var jsonArray = res['result'];
      for (var data in jsonArray) {
        color.Result record = color.Result(
          colorId: data['colorId'],
          colorName: data['ColorName'],
        );
        color_data.add(record);
      }
    } else {
      showCustomToast(res['message']);
    }
    return color_data;
  }
}
