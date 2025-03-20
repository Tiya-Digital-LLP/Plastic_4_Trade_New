// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_interface.dart';
import 'package:Plastic4trade/model/GetCategoryGrade.dart' as grade;

class GetCategoryGradeController {
  List<grade.Result> cat_data = <grade.Result>[];
  Map<String, dynamic>? data;

  Future<List<grade.Result>> setGrade() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getCateGrade(
      device,
      pref.getString('user_id').toString(),
    );

    if (res['status'] == 1) {
      var jsonArray = res['result'];

      for (var data in jsonArray) {
        grade.Result record = grade.Result(
            productgradeId: data['productgradeId'],
            productGrade: data['ProductGrade']);

        cat_data.add(record);
      }
    } else {
      showCustomToast(res['message']);
    }
    return cat_data;
  }
}
