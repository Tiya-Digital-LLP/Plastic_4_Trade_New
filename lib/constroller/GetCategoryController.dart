import 'dart:io';

import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_interface.dart';
import 'package:Plastic4trade/model/GetCategory.dart' as cat;

class GetCategoryController {
  List<cat.Result> cat_data = <cat.Result>[];
  Map<String, dynamic>? data;
  Future<List<cat.Result>> setlogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    String userId = pref.getString('user_id').toString();

    var res = await getCategoryList(
      device,
      userId,
    );

    if (res['status'] == 1) {
      var jsonarray = res['result'];
      for (var data in jsonarray) {
        cat.Result record = cat.Result(
          categoryId: data['categoryId'],
          categoryName: data['CategoryName'],
        );
        cat_data.add(record);
      }
    } else {
      showCustomToast(res['message']);
    }
    return cat_data;
  }
}
