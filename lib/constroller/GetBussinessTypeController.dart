// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:Plastic4trade/utill/custom_toast.dart';

import '../api/api_interface.dart';
import 'package:Plastic4trade/model/GetBusinessType.dart' as bt;

class GetBussinessTypeController {
  List<bt.Result> buss = <bt.Result>[];

  Future<List<bt.Result>> getBussiness_Type() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getBussinessType(device);

    if (res['status'] == 1) {
      var jsonArray = res['result'];
      for (var data in jsonArray) {
        bt.Result record = bt.Result(
          businessTypeId: data['BusinessTypeId'],
          businessType: data['BusinessType'],
        );
        buss.add(record);
      }
    } else {
      showCustomToast(res['message']);
    }
    return buss;
  }
}
