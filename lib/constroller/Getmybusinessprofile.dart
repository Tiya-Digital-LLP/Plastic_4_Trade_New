// ignore_for_file: non_constant_identifier_names

import 'package:Plastic4trade/screen/auth/login_registration.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_interface.dart';
import 'dart:io';
import 'package:Plastic4trade/model/Getmybusinessprofile.dart' as profile;
import '../main.dart';
import '../model/Getmybusinessprofile.dart';

class GetmybusinessprofileController {
  profile.Getmybusinessprofile buss = profile.Getmybusinessprofile();
  String crown_color = '';
  String plan_name = '';

  Future<profile.Getmybusinessprofile?> Getmybusiness_profile({
    required String userId,
    required String apiToken,
    required BuildContext context,
    required String profileId,
  }) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }

    print('Device Name: $device');

    var res = await getbussinessprofile(
      userId,
      apiToken,
      device,
      profileId,
      context,
    );

    // Log the raw response to verify the structure
    print('Response from getbussinessprofile: $res');

    if (res != null) {
      // Check if status exists and is correct
      if (res['status'] == 1) {
        print('Status is 1, Profile fetched successfully.');

        buss = Getmybusinessprofile.fromJson(res);

        // Log profile data to verify
        print('Business Profile: ${buss.profile}');
        print('User: ${buss.user}');

        // Handle image URL and store it in shared preferences
        if (buss.user?.imageUrl != null) {
          pref.setString('userImage', buss.user!.imageUrl.toString());
          constanst.image_url = pref.getString('userImage').toString();
          print('User image URL: ${buss.user!.imageUrl}');
        } else {
          constanst.image_url = null;
          print('No user image URL found.');
        }

        // Check for profile, category, type, and grade IDs
        if (buss.profile == null) {
          constanst.isprofile = true;
          print('No profile found.');
        }
        if (buss.user!.categoryId == null) {
          constanst.iscategory = true;
          print('No category found.');
        }
        if (buss.user!.typeId == null) {
          constanst.istype = true;
          print('No type found.');
        }
        if (buss.user!.gradeId == null) {
          constanst.isgrade = true;
          print('No grade found.');
        }

        // Log the stepCounter value
        if (buss.user != null) {
          constanst.step = buss.user!.stepCounter ?? 0;
          print('Fetched stepCounter: ${buss.user!.stepCounter}');
        } else {
          print('buss.user is null');
        }
      } else {
        // Log failure if status is 0
        print('Failed to fetch profile, status: ${res['status']}');
        clear();
        if (Platform.isAndroid) {
          const androidId = AndroidId();
          constanst.android_device_id = (await androidId.getId())!;
          logout_android_device(context, constanst.android_device_id);
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.clear();
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginRegistration(),
            ),
          );
        } else if (Platform.isIOS) {
          final iosinfo = await deviceInfo.iosInfo;
          constanst.devicename = iosinfo.name;
          constanst.ios_device_id = iosinfo.identifierForVendor!;
          logout_android_device(context, constanst.ios_device_id);
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.clear();
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginRegistration(),
            ),
          );
        }
      }
      showCustomToast(res['message']);
    } else {
      // Log if the response is null
      print('Received null response');
    }

    // Ensure that step value is properly assigned if user is not null
    if (buss.user != null) {
      constanst.step = buss.user!.stepCounter ?? 0;
    }

    // Additional logic for app open count
    if (constanst.appopencount == 1) {
      if (!constanst.isgrade &&
          !constanst.istype &&
          !constanst.iscategory &&
          !constanst.isprofile &&
          constanst.step == 11) {
        // Log if all conditions are met
        print('App opened with all conditions met for step == 11.');
        // Additional logic if required
      }
    }

    return buss;
  }

  logout_android_device(context, deviceid) async {
    var res = await android_logout(deviceid);

    if (res['status'] == 1) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    } else {
      showCustomToast(res['message']);
    }
  }

  void clear() {
    constanst.usernm = "";
    constanst.Bussiness_nature = "";
    constanst.Bussiness_nature_name = "";
    constanst.select_Bussiness_nature = "";
    constanst.lstBussiness_nature = [];
    constanst.lstBussiness_nature_name = [];
    constanst.selectcategory_id = [];
    constanst.selectbusstype_id = [];
    constanst.selectgrade_id = [];
    constanst.selectcolor_id = [];
    constanst.selectcolor_name = [];
    constanst.select_color_id = "";
    constanst.select_color_name = "";
    constanst.select_cat_id = "";
    constanst.select_cat_name = "";
    constanst.select_cat_idx;
    constanst.select_type_id = "";
    constanst.select_type_idx;
    constanst.select_type_name = "";
    constanst.select_grade_id = "";
    constanst.select_gradname.clear();
    constanst.select_grade_idx;
    constanst.Product_color = "";
    constanst.select_prodcolor_idx;
    constanst.select = "";
    constanst.userToken = "";
    constanst.fcm_token = "";
    constanst.android_device_id = "";
    constanst.APNSToken = "";
    constanst.devicename = "";
    constanst.ios_device_id = "";
    constanst.userid = "";
    constanst.step = 0;
    constanst.appopencount = 0;
    constanst.appopencount1 = 1;
    constanst.imagesList = [];
    constanst.notification_count = 0;
    constanst.post_type = "";
    constanst.productId = "";
    constanst.redirectpage = "";
    constanst.catdata = [];
    constanst.itemsCheck = [];
    constanst.category_itemsCheck = [];
    constanst.category_itemsCheck1 = [];
    constanst.bussiness_type_itemsCheck = [];
    constanst.Type_itemsCheck = [];
    constanst.Type_itemsCheck1 = [];
    constanst.Grade_itemsCheck = [];
    constanst.Grade_itemsCheck1 = [];
    constanst.Color_itemsCheck = [];

    constanst.select_categotyId = [];
    constanst.select_categotyType = [];
    constanst.select_inserestlocation = [];

    // get Busssiness
    constanst.btype_data = [];
    constanst.bt_data = null;

    // Category Type
    constanst.cat_type_data = [];
    constanst.cat_typedata = null;
    constanst.select_typeId = [];

    // Category Grade

    constanst.cat_grade_data = [];
    constanst.cat_gradedata = null;
    constanst.select_gradeId = [];

    constanst.select_state = [];
    constanst.select_country = [];

    // Get Bussiness Profile

    constanst.isprofile = false;
    constanst.iscategory = false;
    constanst.istype = false;
    constanst.isgrade = false;
    constanst.getmyprofile;
    constanst.getuserprofile = null;

    // Get Colors

    constanst.colordata = [];
    constanst.colorsitemsCheck = [];
    constanst.color_data = null;

    // Get Unit

    constanst.unitdata = [];
    constanst.unit_data = null;

    constanst.lat = "";
    constanst.log = "";
    constanst.location = "";
    constanst.date = "";
    constanst.image_url = "";
  }
}
