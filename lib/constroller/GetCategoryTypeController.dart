// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_interface.dart';
import 'package:Plastic4trade/model/GetCategoryType.dart' as type;

class GetCategoryTypeController {
  List<type.Result> cat_data = <type.Result>[];
  Map<String, dynamic>? data;

  Future<List<type.Result>> setType() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    String userId = pref.getString('user_id').toString();

    var res = await getCateType(
      device,
      userId,
    );

    if (res['status'] == 1) {
      var jsonArray = res['result'];

      for (var data in jsonArray) {
        type.Result record = type.Result(
            producttypeId: data['producttypeId'],
            productType: data['ProductType']);

        cat_data.add(record);
      }
    } else {
      showCustomToast(res['message']);
    }
    return cat_data;
  }
}
