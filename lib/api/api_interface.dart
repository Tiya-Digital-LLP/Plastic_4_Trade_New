// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages, prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:Plastic4trade/main.dart';
import 'package:Plastic4trade/model/VersionCheckEntity.dart';
import 'package:Plastic4trade/model/active_plan_model.dart';
import 'package:Plastic4trade/model/add_business_directory.dart';
import 'package:Plastic4trade/model/core_business_model.dart';
import 'package:Plastic4trade/model/get_designation_model.dart';
import 'package:Plastic4trade/model/notification_settings_model.dart';
import 'package:Plastic4trade/screen/auth/login_registration.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/bussinessProfileModel/addbussiness_profile_model.dart';

String baseurl = 'https://plastic4trade.com/api/';

Future<VersionCheckEntity?> checkVersion(String platform) async {
  String versioncheck = 'checkversion';

  if (kDebugMode) {
    print('Step 1: Checking internet connectivity...');
  }
  final connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    if (kDebugMode) {
      print('Step 2: No internet connection detected.');
    }
    return null;
  }

  if (kDebugMode) {
    print('Step 2: Internet connection available.');
  }

  try {
    if (kDebugMode) {
      print('Step 3: Retrieving package information...');
    }

    if (kDebugMode) {
      print('Step 4: Platform detected: $platform');
    }

    if (kDebugMode) {
      print('Step 5: Sending version check request to server...');
    }
    final response = await http.post(
      Uri.parse(baseurl + versioncheck),
      body: {
        'version': constanst.version,
        'platform': platform,
      },
    );

    if (kDebugMode) {
      print('Step 6: Server response status code: ${response.statusCode}');
    }

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Step 7: Successfully received response from server.');
      }
      return VersionCheckEntity.fromJson(json.decode(response.body));
    } else {
      if (kDebugMode) {
        print(
            'Step 7: Failed to check version. Server responded with status code: ${response.statusCode}');
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Step 8: An error occurred: $e');
    }
    return null;
  }
}

// API function with improved error handling
Future searchonweb(
  String productname,
  String categoryname,
  String typename,
  String gradename,
  String offset,
) async {
  String loginUrl = 'getproductimages_google';
  try {
    final response = await http.post(Uri.parse(baseurl + loginUrl), headers: {
      "Accept": "application/json"
    }, body: {
      'product_name': productname,
      'category_name': categoryname,
      'type_name': typename,
      'grade_name': gradename,
      'offset': offset,
      'limit': '10',
    });

    print('Raw API Response: ${response.body}');

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);

      // Check if the response is valid
      if (decodedBody is List) {
        return decodedBody;
      } else {
        print('Error: Response is not a list');
        return [];
      }
    } else {
      print('Error: Unexpected status code: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error in searchonweb: $e');
    return [];
  }
}

Future login_user(
    String devicenm, String mbl, String password, String deviceId) async {
  String loginUrl = 'login';
  var res;

  final response = await http.post(Uri.parse(baseurl + loginUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'device': devicenm,
    'email': mbl,
    'password': password,
    'device_id': deviceId,
  });
  print("device: ${devicenm}");
  print("email: ${mbl}");
  print("password: ${password}");
  print("deviceId: ${deviceId}");

  print("Response Status Code: ${response.statusCode}");
  print("Full Response Body: ${response.body}");

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print("Decoded JSON Response: $res");
    if (res['status'] == 0) {
      showCustomToast(
        res['message'] ?? "An error occurred",
      );
    }
  }

  return res;
}

Future<Map<String, dynamic>> login_user_v2(
  String countrycode,
  String mbl,
  String? deviceId,
) async {
  String loginUrl = 'v2/step1';
  var res = <String, dynamic>{};

  print("login_user_v2: ${baseurl + loginUrl}");
  late SharedPreferences _pref;

  _pref = await SharedPreferences.getInstance();

  if (Platform.isAndroid) {
    try {
      final androidId = AndroidId();
      deviceId = await androidId.getId();
      print('Android Device ID: $deviceId');
    } on PlatformException {
      print('Failed to get Android Device ID.');
    }
  } else if (Platform.isIOS) {
    try {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
      print('iOS Device ID: $deviceId');
    } on PlatformException {
      print('Failed to get iOS Device ID.');
    }
  }

  if (deviceId != null) {
    await _pref.setString('device_id', deviceId);
    print('Device ID saved: $deviceId');
  } else {
    print('Device ID is null.');
  }

  final response = await http.post(
    Uri.parse(baseurl + loginUrl),
    headers: {"Accept": "application/json"},
    body: {
      'countryCode': countrycode,
      'phoneno': mbl,
      'app_version': constanst.version.toString(),
      'deviceid': deviceId,
      'device': Platform.isAndroid ? 'android' : 'ios',
    },
  );

  print("countryCode: $countrycode");
  print("phoneno: $mbl");
  print("app_version: ${constanst.version}");
  print("deviceid: $deviceId");

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print("res: $res");
  } else {
    res = jsonDecode(response.body);
    print("res: $res");
  }

  return res;
}

Future<Map<String, dynamic>> login_resend_v2(
  String userId,
  String countrycode,
  String mbl,
) async {
  String loginUrl = 'v2/step1_resendotp';
  var res;
  print("login_resend_v2: ${baseurl + loginUrl}");

  try {
    final response = await http.post(
      Uri.parse(baseurl + loginUrl),
      headers: {"Accept": "application/json"},
      body: {
        'user_id': userId,
        'countryCode': countrycode,
        'phoneno': mbl,
        'app_version': constanst.version.toString(),
      },
    );

    print("countryCode: $countrycode");
    print("phoneno: $mbl");

    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
      print("Decoded JSON Response: $res");

      if (res['status'] == 0) {
        showCustomToast(res['message'] ?? "An error occurred");
      }

      return res;
    } else {
      // showCustomToast("Failed to login, please try again later.");
      print("Failed to login, please try again later.");

      return {};
    }
  } catch (e) {
    print("Error: $e");
    return {};
  }
}

Future<Map<String, dynamic>> email_name_v2(
  String userId,
  String username,
  String usertoken,
  String deviceid,
  String device,
  String email,
) async {
  String loginUrl = 'v2/step2';
  var res = <String, dynamic>{};

  print("email_name_v2: ${baseurl + loginUrl}");

  final response = await http.post(
    Uri.parse(baseurl + loginUrl),
    headers: {"Accept": "application/json"},
    body: {
      'user_id': userId,
      'username': username,
      'userToken': usertoken,
      'device_id': deviceid,
      'device': device,
      'email': email,
      'app_version': constanst.version.toString(),
    },
  );

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  } else {
    res = jsonDecode(response.body);
  }

  return res;
}

Future<Map<String, dynamic>> email_resend_v2(
  String userId,
  String username,
  String usertoken,
  String deviceid,
  String device,
  String email,
) async {
  String loginUrl = 'v2/step2_resendotp';
  String fullUrl = baseurl + loginUrl;
  print("Calling API: $fullUrl");

  try {
    print("user_id: $userId");
    print("username: $username");
    print("userToken: $usertoken");
    print("device_id: $deviceid");
    print("device: $device");
    print("email: $email");
    print("app_version: ${constanst.version}");

    final response = await http.post(
      Uri.parse(fullUrl),
      headers: {"Accept": "application/json"},
      body: {
        'user_id': userId,
        'username': username,
        'userToken': usertoken,
        'device_id': deviceid,
        'device': device,
        'email': email,
        'app_version': constanst.version.toString(),
      },
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      print("Decoded JSON Response: $res");

      if (res['status'] == 0) {
        print("Error Message: ${res['message'] ?? "An error occurred"}");
        showCustomToast(res['message'] ?? "An error occurred");
      } else {
        print("OTP Resent Successfully");
      }

      return res;
    } else {
      print("Request failed with status: ${response.statusCode}");
      return {};
    }
  } catch (e) {
    print("Exception occurred: $e");
    return {};
  }
}

Future verifyPhone(
  String userId,
  String device,
  String deviceId,
  String countryCode,
  String mbl,
  String otp,
) async {
  String loginUrl = 'v2/verifyphone';
  var res;

  final response = await http.post(Uri.parse(baseurl + loginUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'device': device,
    'device_id': deviceId,
    'countryCode': countryCode,
    'phoneno': mbl,
    'otp': otp,
    'app_version': constanst.version.toString(),
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('verifyPhone: ${response.body}');
  }
  return res;
}

Future verifyEmail(
  String userId,
  String userName,
  String device,
  String deviceId,
  String email,
  String userToken,
  String otp,
) async {
  String loginUrl = 'v2/verifyemail';
  var res;

  final response = await http.post(Uri.parse(baseurl + loginUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'username': userName,
    'device_id': deviceId,
    'device': device,
    'email': email,
    'userToken': userToken,
    'otp': otp,
    'app_version': constanst.version.toString(),
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('verifyEmail: ${response.body}');
  }
  return res;
}

Future androidDevice_Register(
  String fcmToken,
  String userid,
  String deviceid,
) async {
  String loginUrl = 'androidDeviceRegister';
  var res;

  print("regId fcm token: ${fcmToken}");
  print("userid: ${deviceid}");
  print("Device Token (APNS Token): ${deviceid}");

  final response = await http.post(Uri.parse(baseurl + loginUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'regId': fcmToken,
    'user_id': userid,
    'device_id': deviceid,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future iosDevice_Register(
  String fcmToken,
  String userid,
  String deviceid,
) async {
  String loginUrl = 'iosDeviceRegister';
  var res;

  print("User ID: ${userid}");
  print("Device UID (iOS Device ID): ${deviceid}");
  print("Device Token (APNS Token): ${fcmToken}");

  final response = await http.post(
    Uri.parse(baseurl + loginUrl),
    headers: {
      "Accept": "application/json",
    },
    body: {
      'user_id': userid,
      'deviceuid': deviceid,
      'devicetoken': fcmToken,
    },
  );

  print("Response Status Code: ${response.statusCode}");

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print("Response Data: $res");
  } else {
    print("Error registering device. Status code: ${response.statusCode}");
    print("Response Body: ${response.body}");
  }

  return res;
}

Future android_logout(deviceid) async {
  String loginUrl = 'logout';
  var res;

  final response = await http.post(Uri.parse(baseurl + loginUrl),
      headers: {"Accept": "application/json"}, body: {'deviceId': deviceid});

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print("Response Data android_logout: $res");
  } else {
    print("Error android_logout. Status code: ${response.statusCode}");
  }
  return res;
}

// Register with phone no
Future registerUserPhoneno(String phoneno, String countryCode, String userName,
    String device, String stepCounter) async {
  String registeruserphonenoUrl = 'registerUserPhoneno_v2';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + registeruserphonenoUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'phoneno': phoneno,
    'countryCode': countryCode,
    'userName': userName,
    'device': device,
    'step_counter': stepCounter,
    'app_version': constanst.version.toString(),
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('registerUserPhoneno: ${response.body}');
  }
  return res;
}

// Register with phone no with otp verify
Future reg_mo_verifyotp(String otp, String userId, String phone,
    String apiToken, String step) async {
  String verifyotp = 'verifyotp';
  var res;

  final response = await http.post(Uri.parse(baseurl + verifyotp), headers: {
    "Accept": "application/json"
  }, body: {
    'Otp': otp,
    'userId': userId,
    'phoneno': phone,
    'userToken': apiToken,
    'step_counter': step
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future reg_mo_updateverifyotp(String otp, String userId, String phone,
    String apiToken, String step) async {
  String verifyotp = 'verifyotp_phonenochange';
  var res;

  final response = await http.post(Uri.parse(baseurl + verifyotp), headers: {
    "Accept": "application/json"
  }, body: {
    'Otp': otp,
    'userId': userId,
    'phoneno': phone,
    'userToken': apiToken,
    'step_counter': step
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

//Register with phone no with resend otp
Future reg_mo_resendotp(
    String userId, String apiToken, String phone, String countryCode) async {
  String verifyotp = 'resendotp_v2';
  var res;

  final response = await http.post(Uri.parse(baseurl + verifyotp), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userId,
    'phoneno': phone,
    'userToken': apiToken,
    'countryCode': countryCode
  });

  print('userId: $userId');
  print('phoneno: $phone');
  print('userToken: $apiToken');
  print('countryCode: $countryCode');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('resendotp_v2: $res');
  }
  return res;
}

// Register with email
Future registerUserEmail(String userName, String email, String stepCounter,
    String apiToken, String userId, String device) async {
  String registeruseremailUrl = 'registerUser';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + registeruseremailUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'username': userName,
    'email': email,
    'step_counter': stepCounter,
    'userToken': apiToken,
    'userId': userId,
    'device': device
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

//Register with email  with resend otp
Future reg_email_resendotp(String userId, String apiToken, String email) async {
  String verifyotp = 'resendemailotp';
  var res;

  final response = await http.post(Uri.parse(baseurl + verifyotp),
      headers: {"Accept": "application/json"},
      body: {'userId': userId, 'userToken': apiToken, 'email': email});

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

//Register with email  with otp verify
Future reg_email_verifyotp(String otp, String userId, String apiToken,
    String email, String step) async {
  String verifyotp = 'verifyemailotp';
  var res;

  final response = await http.post(Uri.parse(baseurl + verifyotp), headers: {
    "Accept": "application/json"
  }, body: {
    'Otp': otp,
    'userId': userId,
    'userToken': apiToken,
    'email': email,
    'step_counter': step
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// final register
Future final_register(
  String email,
  String password,
  String countryCode,
  String phoneNumber,
  String device,
  String username,
  String stepCounter,
  String userid,
  String userToken,
  String version,
) async {
  String verifyotp = 'register_v2';
  var res;

  final response = await http.post(Uri.parse(baseurl + verifyotp), headers: {
    "Accept": "application/json"
  }, body: {
    'email': email,
    'password': password,
    'countryCode': countryCode,
    'phone_number': phoneNumber,
    'device': device,
    'username': username,
    'step_counter': stepCounter,
    'userId': userid,
    'userToken': userToken,
    'app_version': version,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  } else {}
  return res;
}

// forgot password using phone no && email
Future forgotpassword_ME(
    String phoneno, String countryCode, String email) async {
  String forgotMbl = 'forgotPasswordwithME';
  var res;

  final response = await http.post(Uri.parse(baseurl + forgotMbl),
      headers: {"Accept": "application/json"},
      body: {'phoneno': phoneno, 'countryCode': countryCode, 'email': email});

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// forgot password otp verify
Future verifyforgototp(
    String otp, String phoneno, String countryCode, String email) async {
  String registeruserphonenoUrl = 'verifyforgototp';
  var res;

  final response = await http.post(Uri.parse(baseurl + registeruserphonenoUrl),
      headers: {
        "Accept": "application/json"
      },
      body: {
        'otp': otp,
        'phoneno': phoneno,
        'countryCode': countryCode,
        'email': email
      });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// reset Paasword
Future resetPassword(
    String password, String countryCode, String phoneno, String email) async {
  String resetpasswordUrl = 'resetPassword';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + resetpasswordUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'password': password,
    'phoneno': phoneno,
    'countryCode': countryCode,
    'email': email
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// get Category

Future getCategoryList(String device, String userId) async {
  String getcategorylistUrl = 'getCategoryList';
  var res;

  final response = await http.get(Uri.parse(baseurl + getcategorylistUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// GetBusinessType
Future getBussinessType(String device) async {
  String getbussinesstypeUrl = 'getBusinessType';
  var res;

  final response = await http.get(Uri.parse(baseurl + getbussinesstypeUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// getcorebusiness

Future<CoreApiResponse?> getCoreBusiness(
  String userid,
  String search,
) async {
  String getCoreUrl = 'getcorebusiness';

  try {
    final response = await http.post(
      Uri.parse('$baseurl$getCoreUrl'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'userId': userid,
        'search': search,
      },
    );

    // Print out the response details for debugging
    print('Request URL: ${Uri.parse('$baseurl$getCoreUrl')}');
    print('Request Body: search=$search');
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return CoreApiResponse.fromJson(jsonResponse);
    } else {
      print('Error fetching core business data: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('Exception occurred: $e');
    return null;
  }
}

// getdesignation

Future<GetDesignationModel?> getDesignation() async {
  String getCoreUrl = 'getdesignation';

  final response = await http.post(
    Uri.parse('$baseurl$getCoreUrl'),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return GetDesignationModel.fromJson(jsonResponse);
  } else {
    print('Error fetching core business data: ${response.reasonPhrase}');
    return null;
  }
}

// Add Business Add
Future addbussiness({
  required AddBussinessProfileRequest addBussinessProfileRequest,
  File? file,
}) async {
  String addbussinessprofileUrl = 'addUserBusinessProfile';
  var res;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + addbussinessprofileUrl),
  );
  Map<String, String> headers = {"Content-type": "multipart/form-data"};
  request.files.add(
    http.MultipartFile(
      'profilePicture',
      file!.readAsBytes().asStream(),
      file.lengthSync(),
      filename: file.path,
    ),
  );
  request.headers.addAll(headers);
  request.fields.addAll(addBussinessProfileRequest.toJson());

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future addBusinessDirectory({
  required AddBusinessDirectory add_business_directory,
  File? file,
  String? imageUrl,
}) async {
  String addBusinessProfileUrl = 'save_and_update_business_directory';
  var res;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + addBusinessProfileUrl),
  );
  Map<String, String> headers = {"Content-type": "multipart/form-data"};
  request.headers.addAll(headers);

  // Add the business directory fields
  request.fields.addAll(add_business_directory.toJson());

  try {
    if (file != null) {
      // Reading file as a byte stream asynchronously
      final fileBytes = await file.readAsBytes();
      final fileLength = fileBytes.length; // Async method to get file length

      // Adding file to the request
      request.files.add(
        http.MultipartFile(
          'bussiness_logo',
          Stream.fromIterable([fileBytes]), // Wrap the bytes into a stream
          fileLength,
          filename: file.path.split('/').last,
        ),
      );
    }
  } catch (e) {
    print("Error reading the file: $e");
    showCustomToast("Failed to read the image file.");
    return null;
  }

  // Send the request and handle the response
  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print("Response: ${response.body}");
  } else {
    print("Request failed with status: ${response.statusCode}");
  }
  return res;
}

// Get Category Type

Future getCateType(String device, String userId) async {
  String getcatetypeUrl = 'getProducttypeList';
  var res;

  final response = await http.get(Uri.parse(baseurl + getcatetypeUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Category Grade

Future getCateGrade(String device, String userId) async {
  String getcategradeUrl = 'getProductgradeList';
  var res;

  final response = await http.get(Uri.parse(baseurl + getcategradeUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Add Category
Future addcategory(
  String userId,
  String userToken,
  String locationInterest,
  String postType,
  String categoryId,
  String stepCounter,
  String device,
) async {
  String registeruserphonenoUrl = 'addCategory';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + registeruserphonenoUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'location_interest': locationInterest,
    'post_type': postType,
    'category_id': categoryId,
    'step_counter': stepCounter,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// contact_us_button_click

Future contactUsBtnClick(
  String userId,
  String bannerType,
  String device,
) async {
  String registeruserphonenoUrl = 'saveadvertiseInquiry';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + registeruserphonenoUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userId,
    'banner_type': bannerType,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Add Type
Future addtype(String userId, String userToken, String typeId,
    String stepCounter, String device) async {
  String registeruserphonenoUrl = 'addProducttype';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + registeruserphonenoUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'type_id': typeId,
    'step_counter': stepCounter,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Add Grade
Future addgrade(String userId, String userToken, String gradeId,
    String stepCounter, String device) async {
  String registeruserphonenoUrl = 'addProductgrade';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + registeruserphonenoUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'grade_id': gradeId,
    'step_counter': stepCounter,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Bussiness Profile

Future getbussinessprofile(
  String userId,
  String userToken,
  String device,
  String profileId,
  BuildContext context,
) async {
  String getmybusinessprofileUrl = 'getbusinessprofile';
  var res;

  print('Sending request to: ${baseurl + getmybusinessprofileUrl}');
  print(
      'Request body: userId: $userId, userToken: $userToken, device: $device, profileId: $profileId');

  final response =
      await http.post(Uri.parse(baseurl + getmybusinessprofileUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userId,
    'userToken': userToken,
    'device': device,
    'profile_id': profileId,
  });

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('Decoded response: $res');
  } else if (response.statusCode == 401) {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setBool('islogin', false);
    await _pref.remove('islogin');
    showCustomToast('Session Expired. Please Login Again.');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginRegistration(),
      ),
    );
  } else {
    print('Error: Failed to fetch business profile');
  }

  return res;
}

// Get Colors

Future getColors(String device) async {
  String getcolorlistUrl = 'getColorList';
  var res;

  final response = await http.get(Uri.parse(baseurl + getcolorlistUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Unit

Future getUnit(String device) async {
  String getunitUrl = 'getUnitList';
  var res;

  final response = await http.get(Uri.parse(baseurl + getunitUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future addBuyPost(
  String userId,
  String userToken,
  String producttypeId,
  String productgradeId,
  String currency,
  String productPrice,
  String productQty,
  String colorId,
  String description,
  String unit,
  String unitPrice,
  String location,
  String latitude,
  String longitude,
  String imageCounter,
  String city,
  String state,
  String country,
  String stepCounter,
  String productName,
  String categoryId,
  String device,
  String version,
) async {
  String addbussinessprofileUrl = 'addBuyPost_v2';
  var res;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + addbussinessprofileUrl),
  );
  Map<String, String> headers = {"Content-type": "multipart/form-data"};
  int j = 0;
  for (int i = 0; i < constanst.imagesList.length; i++) {
    j = j + 1;
    request.files.add(
      http.MultipartFile(
        'image$j',
        constanst.imagesList[i].readAsBytes().asStream(),
        constanst.imagesList[i].lengthSync(),
        filename: constanst.imagesList[i].path,
      ),
    );
  }
  request.headers.addAll(headers);
  request.fields.addAll({
    'user_id': userId,
    'userToken': userToken,
    'producttype_id': producttypeId,
    'productgrade_id': productgradeId,
    'currency': currency,
    'product_price': productPrice,
    'unit': unit,
    'unit_of_price': unitPrice,
    'location': location,
    'product_qty': productQty,
    'color_id': colorId,
    'description': description,
    // 'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'image_counter': imageCounter,
    'city': city,
    'state': state,
    'country': country,
    'step_counter': stepCounter,
    'product_name': productName,
    'category_id': categoryId,
    'device': device,
    'app_version': version,
  });

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  print("buy post res:-$res}");
  return res;
}

Future addSalePost(
  String userId,
  String userToken,
  String producttypeId,
  String productgradeId,
  String currency,
  String productPrice,
  String productQty,
  String colorId,
  String description,
  String unit,
  String unitPrice,
  String location,
  String latitude,
  String longitude,
  String imageCounter,
  String city,
  String state,
  String country,
  String stepCounter,
  String productName,
  String categoryId,
  String device,
  String version,
) async {
  String addbussinessprofileUrl = 'addSalePost_v2';
  var res;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + addbussinessprofileUrl),
  );
  Map<String, String> headers = {"Content-type": "multipart/form-data"};
  int j = 0;
  for (int i = 0; i < constanst.imagesList.length; i++) {
    j = j + 1;
    request.files.add(
      http.MultipartFile(
        'image$j',
        constanst.imagesList[i].readAsBytes().asStream(),
        constanst.imagesList[i].lengthSync(),
        filename: constanst.imagesList[i].path,
      ),
    );
  }

  request.headers.addAll(headers);
  request.fields.addAll({
    'user_id': userId,
    'userToken': userToken,
    'producttype_id': producttypeId,
    'productgrade_id': productgradeId,
    'currency': currency,
    'product_price': productPrice,
    'unit': unit,
    'unit_of_price': unitPrice,
    'location': location,
    'product_qty': productQty,
    'color_id': colorId,
    'description': description,
    // 'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'image_counter': imageCounter,
    'city': city,
    'state': state,
    'country': country,
    'step_counter': stepCounter,
    'product_name': productName,
    'category_id': categoryId,
    'device': device,
    'app_version': version,
  });

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  print("res:-${response.body}");
  return res;
}

// Get Category Type

Future getuser_Profile(String userId, String userToken, String device) async {
  String registeruserphonenoUrl = 'getuserprofile';
  var res;

  print('Sending request getuser_Profile: ${baseurl + registeruserphonenoUrl}');

  final response =
      await http.post(Uri.parse(baseurl + registeruserphonenoUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userId,
    'userToken': userToken,
    'device': device,
  });

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Update Profile Picture
Future saveProfile(
    String userId, String userToken, File? file, String device) async {
  String registeruserphonenoUrl = 'saveprofilepicture';

  var res;
  Map<String, String> headers = {"Content-type": "multipart/form-data"};
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + registeruserphonenoUrl),
  );

  request.files.add(
    http.MultipartFile(
      'profilePicture',
      file!.readAsBytes().asStream(),
      file.lengthSync(),
      filename: file.path,
    ),
  );
  request.headers.addAll(headers);
  request.fields.addAll({
    'userId': userId,
    'userToken': userToken,
    'device': device,
  });

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Register with phone no
Future updateUserPhoneno(String phoneno, String countryCode, String userId,
    String userToken, String device) async {
  String registeruserphonenoUrl = 'updatephonenumber';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + registeruserphonenoUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userId,
    'userToken': userToken,
    'countryCode': countryCode,
    'phoneno': phoneno,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future updateUseremail(
    String email, String userId, String userToken, String device) async {
  String registeruserphonenoUrl = 'updateemail';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + registeruserphonenoUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'email': email,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// get my products api for phisical business directory

Future<Map<String, dynamic>> getmyproducts(
    String userId, String apiToken) async {
  String registeruserphonenoUrl = 'getmyproducts';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + registeruserphonenoUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': apiToken,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future changePassword(
  String userId,
  String userToken,
  String newPassword,
  String device,
) async {
  String resetpasswordUrl = 'changepassword';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + resetpasswordUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userId,
    'userToken': userToken,
    'new_password': newPassword,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future updatesocialmedia(
  String userId,
  String userToken,
  String instagramLink,
  String youtubeLink,
  String facebookLink,
  String linkedinLink,
  String twitterLink,
  String telegramLink,
  String device,
) async {
  String resetpasswordUrl = 'updatesocialmedia';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + resetpasswordUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userId,
    'userToken': userToken,
    'instagram_link': instagramLink,
    'youtube_link': youtubeLink,
    'facebook_link': facebookLink,
    'linkedin_link': linkedinLink,
    'twitter_link': twitterLink,
    'telegram_link': telegramLink,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future updateUserBusinessProfile(
  String userId,
  String userToken,
  String businessName,
  String businessType,
  String coreBusiness,
  String location,
  String longitude,
  String latitude,
  String otherMobile1,
  String country,
  String countryCode,
  String businessPhone,
  String stepCounter,
  String city,
  String email,
  String gst,
  String website,
  String aboutBusiness,
  String businessId,
  String state,
  String username,
  String device,
) async {
  String updateuserbusinessprofileUrl = 'updateUserBusinessProfile';
  var res;

  final response = await http
      .post(Uri.parse(baseurl + updateuserbusinessprofileUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userId,
    'userToken': userToken,
    'business_name': businessName,
    'business_type': businessType,
    'core_businesses': coreBusiness,
    'address': location,
    'latitude': latitude,
    'longitude': longitude,
    'other_mobile1': otherMobile1,
    'country': country,
    'countryCode': countryCode,
    'businessId': businessId,
    'business_phone': businessPhone,
    'step_counter': stepCounter,
    'city': city,
    'other_email': email,
    'gst_tax_vat': gst,
    'website': website,
    'about_business': aboutBusiness,
    'state': state,
    'username': username,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getannual_capacity() async {
  String getannualcapacityUrl = 'getannualcapacity';
  var res;

  final response = await http.get(Uri.parse(baseurl + getannualcapacityUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getannual_turnover() async {
  String getannualcapacityUrl = 'getannualturnovermaster';
  var res;

  final response = await http.get(Uri.parse(baseurl + getannualcapacityUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future annual_turnover_Update(Map<String, dynamic> rowData) async {
  String getannualcapacityUrl = 'updateturnoverdata';
  var res;

  // Debugging: print request body before sending
  print("Sending Request Body: ${jsonEncode(rowData)}");

  try {
    final response = await http.post(
      Uri.parse(baseurl + getannualcapacityUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(rowData),
    );

    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      print("Response: $res");
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (e) {
    print("Error: $e");
  }

  return res;
}

Future getbusiness_document_types() async {
  String getannualcapacityUrl = 'getbusiness_document_types';
  var res;

  final response = await http.get(Uri.parse(baseurl + getannualcapacityUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getpopupSlider(String userId, String apiToken, String device) async {
  String getsliderlistUrl = 'getHomePagePopup';
  var res;

  // Construct the full URL with query parameters
  final uri = Uri.parse(baseurl + getsliderlistUrl).replace(queryParameters: {
    'userToken': apiToken,
    'user_id': userId,
    'device': device,
  });

  final response = await http.get(uri);

  print(
      'getHomePagePopup data: ${uri.toString()}'); // Print the full URL for debugging

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  } else {
    print('Error: Received status code ${response.statusCode}');
    print('Response body: ${response.body}'); // Log the body for debugging
  }

  return res;
}

Future getSlider(
  String userId,
  String apiToken,
  String device,
  BuildContext context,
) async {
  String getsliderlistUrl = 'getBannerImage';
  var res;

  final response = await http.get(Uri.parse(baseurl + getsliderlistUrl));

  print('bannerdata: ${baseurl}${getsliderlistUrl}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setBool('islogin', false);
    await _pref.remove('islogin');
    showCustomToast('Session Expired. Please Login Again.');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginRegistration(),
      ),
    );
  }
  return res;
}

Future getfilterdata() async {
  String getsliderlistUrl = 'getfilterdata';
  var res;

  final response = await http.get(Uri.parse(baseurl + getsliderlistUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getfilterdata_liveprice() async {
  String getsliderlistUrl = 'getfilterdata_liveprice';
  var res;

  final response = await http.get(Uri.parse(baseurl + getsliderlistUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Home Product
Future getHome_Post(
  String userId,
  String apiToken,
  String offset,
  String categoryFilterId,
  String producttypeFilterId,
  String productgradeFilterId,
  String posttypeFilter,
  String businesstypeId,
  String coretypeId,
  String latitude,
  String longitude,
  String search,
  String device,
  BuildContext context,
) async {
  String gethomepostUrl =
      'getHomePost_v2?userId=$userId&userToken=$apiToken&offset=$offset&limit=20&category_filter_id=$categoryFilterId&producttype_filter_id=$producttypeFilterId&productgrade_filter_id=$productgradeFilterId&posttype_filter=$posttypeFilter&businesstype_id=$businesstypeId&core_businesses_filter_id=$coretypeId&latitude=$latitude&longitude=$longitude&search=$search&device=$device';
  var res;
  print('gethomepost url data: $gethomepostUrl');
  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('home post data: $res');
  } else if (response.statusCode == 401) {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setBool('islogin', false);
    await _pref.remove('islogin');
    showCustomToast('Session Expired. Please Login Again.');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginRegistration(),
      ),
    );
  }
  return res;
}

Future homePostWithoutLogin(String device) async {
  String endUrl =
      "getHomePost_v2?offset=0&category_id='" "'&limit=20&device=$device";
  var res;
  final response = await http.get(Uri.parse(baseurl + endUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Product Match Buyer
Future get_Product_Match_home(
  String userId,
  String apiToken,
  String offset,
  String categoryId,
  String categoryFilterId,
  String producttypeFilterId,
  String productgradeFilterId,
  String posttypeFilter,
  String businesstypeId,
  String coretypeId,
  String latitude,
  String longitude,
  String search,
  String device,
) async {
  String getsalepostUrl =
      'getIntrest_match?userId=$userId&userToken=$apiToken&offset=$offset&limit=20&category_id=$categoryId&category_filter_id=$categoryFilterId&producttype_filter_id=$producttypeFilterId&productgrade_filter_id=$productgradeFilterId&posttype_filter=$posttypeFilter&businesstype_id=$businesstypeId&core_businesses_filter_id=$coretypeId&latitude=$latitude&longitude=$longitude&search=$search&device=$device';
  var res;
  print('get_Product_Match data: ${baseurl + getsalepostUrl}');

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Product Match Seller
Future get_Product_Match_seller(
  String userId,
  String apiToken,
  String offset,
  String categoryId,
  String categoryFilterId,
  String producttypeFilterId,
  String productgradeFilterId,
  String posttypeFilter,
  String businesstypeId,
  String coretypeId,
  String latitude,
  String longitude,
  String search,
  String device,
) async {
  String getsalepostUrl =
      'getIntrest_match?userId=$userId&userToken=$apiToken&offset=$offset&limit=20&category_id=$categoryId&category_filter_id=$categoryFilterId&producttype_filter_id=$producttypeFilterId&productgrade_filter_id=$productgradeFilterId&posttype_filter=$posttypeFilter&businesstype_id=$businesstypeId&core_businesses_filter_id=$coretypeId&latitude=$latitude&longitude=$longitude&search=$search&device=$device';
  var res;
  print('get_Product_Match data: ${baseurl + getsalepostUrl}');

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Product Match Seller
Future get_Product_Match_buyer(
  String userId,
  String apiToken,
  String offset,
  String categoryId,
  String categoryFilterId,
  String producttypeFilterId,
  String productgradeFilterId,
  String posttypeFilter,
  String businesstypeId,
  String coretypeId,
  String latitude,
  String longitude,
  String search,
  String device,
) async {
  String getsalepostUrl =
      'getIntrest_match?userId=$userId&userToken=$apiToken&offset=$offset&limit=20&category_id=$categoryId&category_filter_id=$categoryFilterId&producttype_filter_id=$producttypeFilterId&productgrade_filter_id=$productgradeFilterId&posttype_filter=$posttypeFilter&businesstype_id=$businesstypeId&core_businesses_filter_id=$coretypeId&latitude=$latitude&longitude=$longitude&search=$search&device=$device';
  var res;
  print('get_Product_Match data: ${baseurl + getsalepostUrl}');

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Sale Post
Future getSale_Post(
  String userId,
  String apiToken,
  String limit,
  String offset,
  String categoryFilterId,
  String producttypeFilterId,
  String productgradeFilterId,
  String posttypeFilter,
  String businesstypeId,
  String coretypeId,
  String latitude,
  String longitude,
  String search,
  String device,
  BuildContext context,
) async {
  String getsalepostUrl =
      'getSalePost_v2?userId=$userId&userToken=$apiToken&category_id=""&profileId=""&limit=$limit&offset=$offset&category_filter_id=$categoryFilterId&producttype_filter_id=$producttypeFilterId&productgrade_filter_id=$productgradeFilterId&posttype_filter=$posttypeFilter&businesstype_id=$businesstypeId&core_businesses_filter_id=$coretypeId&latitude=$latitude&longitude=$longitude&search=$search&device=$device';
  var res;
  print('getsalePost url data: $getsalepostUrl');

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setBool('islogin', false);
    await _pref.remove('islogin');
    showCustomToast('Session Expired. Please Login Again.');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginRegistration(),
      ),
    );
  }
  return res;
}

Future sellPostWithoutLogin(String device) async {
  String endUrl =
      "getSalePost_v2?offset=0&category_id='" "'&limit=20&device=$device";
  var res;
  final response = await http.get(Uri.parse(baseurl + endUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Buyer Post
Future getBuyer_Post(
  String userId,
  String apiToken,
  String limit,
  String offset,
  String categoryFilterId,
  String producttypeFilterId,
  String productgradeFilterId,
  String posttypeFilter,
  String businesstypeId,
  String coretypeId,
  String latitude,
  String longitude,
  String search,
  String device,
  BuildContext context,
) async {
  String getsalepostUrl =
      'getBuyPost_v2?userId=$userId&userToken=$apiToken&profileId=""&limit=$limit&offset=$offset&category_filter_id=$categoryFilterId&producttype_filter_id=$producttypeFilterId&productgrade_filter_id=$productgradeFilterId&posttype_filter=$posttypeFilter&businesstype_id=$businesstypeId&core_businesses_filter_id=$coretypeId&latitude=$latitude&longitude=$longitude&search=$search&device=$device';
  var res;
  print('getBuyerPost url data: $getsalepostUrl');
  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));
  print("datares:P-${response.body}");
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setBool('islogin', false);
    await _pref.remove('islogin');
    showCustomToast('Session expired. Please login again.');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginRegistration(),
      ),
    );
  }
  return res;
}

Future buyPostWithoutLogin(String device) async {
  String endUrl =
      "getBuyPost_v2?offset=0&category_id='" "'&limit=20&device=$device";
  var res;
  final response = await http.get(Uri.parse(baseurl + endUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getHomeSearch_Post(
  String latitude,
  String longitude,
  String searchKeyword,
  String limit,
  String offset,
  String device,
  BuildContext context,
) async {
  String getsalepostUrl =
      'getHomePostSearch?latitude=$latitude&longitude=$longitude&searchKeyword=$searchKeyword&limit=$limit&offset=$offset&device=$device';
  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setBool('islogin', false);
    await _pref.remove('islogin');
    showCustomToast('Session Expired. Please Login Again.');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginRegistration(),
      ),
    );
  }
  return res;
}

Future getPost_datail(String userId, String apiToken, String productId,
    String notiId, String device, String crowncolor, String planname) async {
  String getpostdatailUrl =
      'getBuyPostDetail_v2?userId=$userId&userToken=$apiToken&productId=$productId&notiId=$notiId&device=$device';
  var res;
  print("getPost_datail:- ${baseurl + getpostdatailUrl}");
  final response = await http.get(Uri.parse(baseurl + getpostdatailUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getPost_datail1(String userId, String apiToken, String productId,
    String notiId, String device, String crowncolor, String planname) async {
  String getpostdatailUrl =
      'getSalePostDetail_v2?userId=$userId&userToken=$apiToken&productId=$productId&notiId=$notiId&device=$device&crown_color=$crowncolor&plan_name=$planname';
  var res;
  print("getPost_datail1:-${baseurl + getpostdatailUrl}");
  final response = await http.get(Uri.parse(baseurl + getpostdatailUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future similar_product_buyer(
    String productId, String limit, String offset, String device) async {
  String getpostdatailUrl =
      'relatedpost_for_buy?productId=$productId&limit=$limit&offset=$offset&device=$device';
  var res;
  print("similar_product_buyer:-${baseurl + getpostdatailUrl}");
  final response = await http.get(Uri.parse(baseurl + getpostdatailUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future similar_product_saler(
    String productId, String limit, String offset, String device) async {
  String getpostdatailUrl =
      'relatedpost_for_sale?productId=$productId&limit=$limit&offset=$offset&device=$device';
  var res;
  print("similar_product_saler:- ${baseurl + getpostdatailUrl}");
  final response = await http.get(Uri.parse(baseurl + getpostdatailUrl));
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  print("red:-${res}");
  return res;
}

Future getsaleSearch_Post(String latitude, String longitude,
    String searchKeyword, String limit, String offset, String device) async {
  String getsalepostUrl = 'searchSalepost';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'latitude': latitude,
    'longitude': longitude,
    'searchKeyword': searchKeyword,
    'limit': limit,
    'offset': offset,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future saveCoreBusiness(String userid, String userToken, String name) async {
  String getsalepostUrl = 'savecorebusiness';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userid,
    'userToken': userToken,
    'name': name,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future saveCategory(String userid, String userToken, String name) async {
  String getsalepostUrl = 'addOtherCategory';
  var res;

  try {
    final response = await http.post(
      Uri.parse(baseurl + getsalepostUrl),
      headers: {"Accept": "application/json"},
      body: {
        'user_id': userid,
        'userToken': userToken,
        'category_name': name,
      },
    );

    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
    } else {
      print('Failed to update category. Status code: ${response.statusCode}');
      res = null;
    }
  } catch (e) {
    print('Error occurred while updating category: $e');
    res = null;
  }

  return res;
}

Future saveType(String userid, String userToken, String name) async {
  String getsalepostUrl = 'addOtherProducttype';
  var res;

  try {
    final response = await http.post(
      Uri.parse(baseurl + getsalepostUrl),
      headers: {"Accept": "application/json"},
      body: {
        'user_id': userid,
        'userToken': userToken,
        'product_type': name,
      },
    );

    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
    } else {
      print('Failed to update product. Status code: ${response.statusCode}');
      res = null;
    }
  } catch (e) {
    print('Error occurred while updating product: $e');
    res = null;
  }

  return res;
}

Future saveGrade(String userid, String userToken, String name) async {
  String getsalepostUrl = 'addOtherProductgrade';
  var res;

  try {
    final response = await http.post(
      Uri.parse(baseurl + getsalepostUrl),
      headers: {"Accept": "application/json"},
      body: {
        'user_id': userid,
        'userToken': userToken,
        'product_grade': name,
      },
    );

    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
    } else {
      print('Failed to update grade. Status code: ${response.statusCode}');
      res = null;
    }
  } catch (e) {
    print('Error occurred while updating grade: $e');
    res = null;
  }

  return res;
}

Future getbuysearch_Post(String latitude, String longitude,
    String searchKeyword, String limit, String offset, String device) async {
  String getsalepostUrl = 'searchBuypost';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'latitude': latitude,
    'longitude': longitude,
    'searchKeyword': searchKeyword,
    'limit': limit,
    'offset': offset,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future gethomequicknew(String device) async {
  String gethomequicknewUrl = 'getHomeQuickNewsList';

  var res;
  final response = await http.get(Uri.parse(baseurl + gethomequicknewUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('gethomequicknews $res');
  }
  return res;
}

Future getnewss(String userId, String userToken, String limit, String offset,
    String device) async {
  String getsalepostUrl =
      'getNews?userId=$userId&userToken=$userToken&limit=$limit&offset=$offset&device=$device';

  var res;

  print("news baseurl:-${baseurl + getsalepostUrl}");
  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print("dataSavar:-${res}");
  }
  return res;
}

Future getQuicknews(
    String userId, String userToken, String offset, String device) async {
  String getsalepostUrl =
      'newnews?userId=$userId&userToken=$userToken&offset=$offset&limit=20&device=$device';

  var res;
  print('quick news: ${baseurl + getsalepostUrl}');
  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }

  return res;
}

Future news_like(
    String newsId, String userId, String userToken, String device) async {
  String getsalepostUrl = 'addNewsLike';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'news_id': newsId,
    'user_id': userId,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future product_like(
    String newsId, String userId, String userToken, String device) async {
  String getsalepostUrl = 'addProductLike';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'product_id': newsId,
    'user_id': userId,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future profile_like(
    String profileId, String userId, String userToken, String device) async {
  String getSalePostUrl = 'addProfileLike';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getSalePostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'profile_id': profileId,
    'user_id': userId,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('profile_like: $res');
  }
  return res;
}

Future getnewssdetail(
    String userId, String userToken, String blogid, String device) async {
  String getSalePostUrl =
      'getNewsDetails?userId=$userId&userToken=$userToken&newsId=$blogid&device=$device';
  print('newsdetail: $getSalePostUrl');

  var res;

  final response = await http.get(Uri.parse(baseurl + getSalePostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getblogs(String userId, String userToken, String device) async {
  String getSalePostUrl =
      'getBlog?userId=$userId&userToken=$userToken&device=$device';

  var res;

  print('blog: ${baseurl + getSalePostUrl}');

  final response = await http.get(Uri.parse(baseurl + getSalePostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getblogsdetail(
    String userId, String userToken, String blogid, String device) async {
  String getSalePostUrl =
      'getBlogDetails?userId=$userId&userToken=$userToken&blogId=$blogid&device=$device';

  var res;

  print('blogdetail: $getSalePostUrl');

  final response = await http.get(Uri.parse(baseurl + getSalePostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future blog_like(
    String blogId, String userId, String userToken, String device) async {
  String getSalePostUrl = 'addBlogLike';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getSalePostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'blog_id': blogId,
    'user_id': userId,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getFollowerLists(
  String userId,
  String userToken,
  String offset,
  String profileId,
  String search,
  String device,
) async {
  String getfollowerlistUrl =
      'getFollowerList?userId=$userId&userToken=$userToken&offset=$offset&limit=10&profileId=$profileId&search=$search&device=$device';
  var res;
  print("FollowerLists:- ${baseurl + getfollowerlistUrl}");

  final response = await http.get(Uri.parse(baseurl + getfollowerlistUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getOtherUserFollowerLists(
  String userId,
  String userToken,
  String offset,
  String profileId,
  String device,
) async {
  String getfollowerlistUrl =
      'getFollowerList?userId=$userId&userToken=$userToken&offset=$offset&limit=10&profileId=$profileId&device=$device';
  var res;
  print("FollowerLists:- ${baseurl + getfollowerlistUrl}");
  final response = await http.get(Uri.parse(baseurl + getfollowerlistUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getfollwingList(
  String userId,
  String userToken,
  String offset,
  String profileId,
  String search,
  String device,
) async {
  String getsalepostUrl =
      'getFollowingList?userId=$userId&userToken=$userToken&offset=$offset&limit=10&profileId=$profileId&search=$search&device=$device';
  var res;

  print("follwingList:-${baseurl + getsalepostUrl}");
  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getOtherUserFollowingList(
  String userId,
  String userToken,
  String offset,
  String profileId,
  String device,
) async {
  String getsalepostUrl =
      'getFollowingList?userId=$userId&userToken=$userToken&offset=$offset&limit=10&profileId=$profileId&device=$device';
  var res;
  print("follwingList:-${baseurl + getsalepostUrl}");
  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future followUnfollow(String isFollow, String otherUserId, String userid,
    String userToken, String device) async {
  String getsalepostUrl = 'followUnfollow';
  var res;
  print("isFollow:-${isFollow}");
  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'isFollow': isFollow,
    'otherUserId': otherUserId,
    'userid': userid,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  print("res:-${res}");
  return res;
}

Future bookmark(String userid, String profileid, String device) async {
  String getsalepostUrl = 'favoriteUser';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userid,
    'profile_id': profileid,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future addfav(
    String userid, String userToken, String productid, String device) async {
  String getsalepostUrl = 'addFavoriteproduct';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userid': userid,
    'userToken': userToken,
    'productid': productid,
    'device': device
  });

  print('save product: ${baseurl}${getsalepostUrl}');
  print('userid: $userid');
  print('userToken: $userToken');
  print('productid: $productid');
  print('device: $device');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future removefav(
  String userid,
  String userToken,
  String productid,
  String device,
) async {
  String getsalepostUrl = 'removeFavoriteproduct';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userid': userid,
    'userToken': userToken,
    'removeid': productid,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future removeProductInterest(
  String userid,
  String userToken,
  String productid,
  String device,
) async {
  String getsalepostUrl = 'removeFromIntrest';

  var res;

  print('removeProductInterest: ${baseurl}${getsalepostUrl}');

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userid,
    'userToken': userToken,
    'productid': productid,
    'device': device,
  });

  print('userid: $userid');
  print('userToken: $userToken');
  print('productid: $productid');
  print('device: $device');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('res: ${res}');
  }
  return res;
}

Future favListProduct(
  String userid,
  String userToken,
  String device,
  String offset,
) async {
  String getsalepostUrl =
      'getFavoriteproduct?user_id=$userid&userToken=$userToken&device=$device&offset=$offset&limit=20';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  print('getFavoriteproduct: ${baseurl + getsalepostUrl}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future interestedListProduct(
  String userid,
  String userToken,
  String device,
  String offset,
) async {
  String getsalepostUrl =
      'getIntrestedproduct?user_id=$userid&userToken=$userToken&device=$device&offset=$offset&limit=20';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  print('interestedListProduct: ${baseurl + getsalepostUrl}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future interestedListUser(
  String userid,
  String userToken,
  String device,
  String offset,
) async {
  String getsalepostUrl =
      'getIntrestedUser?user_id=$userid&userToken=$userToken&device=$device&offset=$offset&limit=10';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  print('interestedListUser: ${baseurl + getsalepostUrl}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('getIntrestedUser: $res');
  }
  return res;
}

Future favListUser(String userid, String device, String offset) async {
  String favUserUrl = 'getFavoriteUser';

  var res;

  Map<String, String> requestBody = {
    'user_id': userid,
    'device': device,
    'offset': offset,
    'limit': '10',
  };

  final response = await http.post(
    Uri.parse(baseurl + favUserUrl),
    body: requestBody,
  );

  print('getFavoriteUser: $requestBody');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getvideolist({
  required String userId,
  required String userToken,
  required String limit,
  required String offset,
  required String device,
}) async {
  String getsalepostUrl =
      'getvideolist?userId=$userId&userToken=$userToken&limit=$limit&offset=$offset&device=$device';

  var res;
  print("getvideolist:=${getsalepostUrl}");
  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future<Map<String, dynamic>> gettutorialvideo_screen(
    String screenId, String device) async {
  String getsalepostUrl =
      'tutorialvideo_screen?screen_id=$screenId&device=$device';
  print('Tutorial Video Url: $getsalepostUrl');

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load tutorial video');
  }
}

Future getSocialLinks() async {
  String socialLinks = 'getsocialmedia';

  var res;

  final response = await http.get(Uri.parse(baseurl + socialLinks));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future gettutorialvideolist(
    String userId, String userToken, String offset, String device) async {
  String getsalepostUrl =
      'gettutorialvideolist?user_id=$userId&userToken=$userToken&offset=$offset&limit=20&device=$device';
  print('Tutorial Video Url: $getsalepostUrl');

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getAllnotification({
  required String userId,
  required String userToken,
  required String offset,
  required String limit,
  required String device,
}) async {
  try {
    String getallnotificationUrl =
        'getallnotification?userId=$userId&limit=$limit&offset=$offset&device=$device';
    var res;
    final response = await http.get(
      Uri.parse(baseurl + getallnotificationUrl),
    );

    print("getallnotificationUrl:-${baseurl}${getallnotificationUrl}");

    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
    }
    return res;
  } catch (e) {
    print("getAllnotification:-${e}");
  }
}

Future getnotification(String userId, String userToken, String readStatus,
    String offset, String limit, String device) async {
  String getsalepostUrl =
      'getNotificationlist?userId=$userId&userToken=$userToken&user_type=1&offset=$offset&limit=$limit&device=$device';

  var res;
  print("url:-${baseurl + getsalepostUrl}");
  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  print("resdata:-$res");
  return res;
}

Future getadminnotification(String userId, String userToken, String readStatus,
    String offset, String limit, String device) async {
  String getsalepostUrl =
      'getadminNotificationlist?userId=$userId&userToken=$userToken&user_type=0&offset=$offset&limit=$limit&device=$device';

  var res;

  print("");
  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getContactDetails(String userId, String userToken, String device) async {
  String getsalepostUrl =
      'getContactDetails?userId=$userId&userToken=$userToken&device=$device';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future add_contact(
  String userid,
  String userToken,
  String feedback,
  String name,
  String email,
  String countryCode,
  String phonenumber,
  String message,
  String businessName,
  String contactBy,
  String device,
) async {
  String getsalepostUrl = 'addContactUs';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'userId': userid,
    'userToken': userToken,
    'feedback': feedback,
    'name': name,
    'email': email,
    'countryCode': countryCode,
    'phonenumber': phonenumber,
    'message': message,
    'business_name': businessName,
    'contact_by': contactBy,
    'device': device,
  });

  print('userid: $userid');
  print('userToken: $userToken');
  print('feedback: $feedback');
  print('name: $name');
  print('email: $email');
  print('countryCode: $countryCode');
  print('phonenumber: $phonenumber');
  print('message: $message');
  print('businessName: $businessName');
  print('contactBy: $contactBy');
  print('device: $device');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future remove_noty(
  String userid,
  String userToken,
  String notifId,
) async {
  String getsalepostUrl = 'deleteNotification';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'notificationId': notifId,
    'userId': userid,
    'userToken': userToken,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// isread notification

Future isread_noti(
  String userid,
  String userToken,
  String notifId,
) async {
  String getsalepostUrl = 'readsingleNotification';

  var res;

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'notificationId': notifId,
    'userId': userid,
    'userToken': userToken,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future adminremove_noty(String userid, String userToken, String notifId) async {
  String getsalepostUrl =
      'deleteadminnotification?notification_id=$notifId&user_id=$userid&userToken=$userToken';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future count_notify(String userid, String userToken, String device) async {
  String getsalepostUrl =
      'getNotificationCount?userId=$userid&userToken=$userToken&device=$device';
  var res;
  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  print("res:-${res}");
  return res;
}

Future getStaticPage() async {
  String getsalepostUrl = 'getStaticPage?staticId=6';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getAppTermsCondition() async {
  String getTermsCondition = 'getStaticPage?staticId=9';

  var res;

  final response = await http.get(Uri.parse(baseurl + getTermsCondition));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getAppPrivacyPolicy() async {
  String getTermsCondition = 'getStaticPage?staticId=8';

  var res;

  final response = await http.get(Uri.parse(baseurl + getTermsCondition));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getread_all(String userid, String userToken, String device) async {
  String getsalepostUrl =
      'readallnotification?userId=$userid&userToken=$userToken&device=$device';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getupcoming_exbition(String userId, String userToken, String offset,
    String limit, String categoryFilterId) async {
  String getsalepostUrl =
      'getupcommingexhibition?userId=$userId&userToken=$userToken&offset=$offset&limit=$limit&category_filter_id=$categoryFilterId';

  var res;

  print('getupcommingexhibition: $getsalepostUrl');

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getpast_exbition(String userId, String userToken, String offset,
    String limit, String categoryFilterId) async {
  String getsalepostUrl =
      'getpastexhibition?userId=$userId&userToken=$userToken&offset=$offset&limit=$limit&category_filter_id=$categoryFilterId';

  var res;
  print('getpastexhibition: $getsalepostUrl');

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future exbitionlike_like(String exId, String userId, String userToken) async {
  String getsalepostUrl =
      'addexhibitionlike?user_id=$userId&userToken=$userToken&ex_id=$exId';
  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getexbitiondetail(String userId, String userToken, String exId) async {
  String getsalepostUrl =
      'exhibitiondetail?userId=$userId&userToken=$userToken&ex_id=$exId';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getlive_price(
    String offset,
    String limit,
    String search,
    String category,
    String company,
    String country,
    String state,
    String date,
    String device) async {
  String getsalepostUrl =
      'getPriceList?offset=$offset&limit=$limit&search=$search&category=$category&company=$company&country=$country&state=$state&date=$date&device=$device';
  print('getPriceList: $getsalepostUrl');
  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_coderecord(String codeId, String offset) async {
  String getsalepostUrl =
      'getcoderecord?code_id=$codeId&offset=$offset&limit=20';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Get Sale Product List
Future getsale_PostList(String userId, String apiToken, String offset,
    String profileid, String device) async {
  String gethomepostUrl =
      'getSalePost_v2?userId=$userId&userToken=$apiToken&limit=20&offset=$offset&profileId=$profileid&device=$device';
  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future managesale_PostList(String userId, String apiToken, String offset,
    String profileid, String device) async {
  String gethomepostUrl =
      'managesalepost?userId=$userId&userToken=$apiToken&limit=20&offset=$offset&profileId=$profileid&device=$device';
  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  print('managesalepost: ${baseurl}${gethomepostUrl}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future save_prostatus(
    String productId, String productStatus, String device) async {
  String gethomepostUrl =
      'saveproductstatus?post_id=$productId&product_status=$productStatus&device=$device';
  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  print('saveproductstatus: ${baseurl}${gethomepostUrl}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future push_notification(
  String productId,
  String userId,
  String userToken,
  String device,
) async {
  String gethomepostUrl = 'pushnotification';
  var res;
  final response = await http.post(
    Uri.parse(baseurl + gethomepostUrl),
    headers: {"Accept": "application/json"},
    body: {
      'product_id': productId,
      'user_id': userId,
      'userToken': userToken,
      'device': device,
    },
  );
  print('boost_post: $baseurl$gethomepostUrl');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future premium_post_notification(
  String productId,
  String userId,
  String userToken,
  String device,
) async {
  String gethomepostUrl = 'makepaidpost';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + gethomepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'productId': productId,
    'user_id': userId,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future deletesalepost(
  String productId,
  String userId,
  String userToken,
  String device,
) async {
  String gethomepostUrl = 'deleteSalePost';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + gethomepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'productId': productId,
    'user_id': userId,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future deletebuypost(
  String productId,
  String userId,
  String userToken,
  String device,
) async {
  String gethomepostUrl = 'deleteBuyPost';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + gethomepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'productId': productId,
    'user_id': userId,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_postUser(String userId, String apiToken, String limit, String offset,
    String profileId, String device) async {
  String url = '${baseurl}getPostByUser';
  var res;

  try {
    Map<String, String> body = {
      'userId': userId,
      'userToken': apiToken,
      'limit': limit,
      'offset': offset,
      'profileId': profileId,
      'device': device,
    };

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    print('getPostByUser POST: $url');
    print('Payload: $body');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Handling response
    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Exception in get_postUser: $e');
  }

  return res;
}

Future managebuy_PostList(String userId, String apiToken, String offset,
    String profileid, String device) async {
  String gethomepostUrl =
      'managebuypost?userId=$userId&userToken=$apiToken&limit=20&offset=$offset&profileId=$profileid&device=$device';
  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));
  print('managebuypost: ${baseurl}${gethomepostUrl}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future deletePostSubImage(
  String subImageId,
  String userId,
  String userToken,
  String device,
) async {
  String gethomepostUrl = 'deletePostSubImage';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + gethomepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'subImageId': subImageId,
    'user_id': userId,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future addPostSubImage(
  String productId,
  String device,
  File? image1, // Nullable File
  File? image2, // Nullable File
  File? image3, // Nullable File
) async {
  String gethomepostUrl = 'addSalePostImage';
  var res;
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + gethomepostUrl),
  );

  Map<String, String> headers = {"Content-type": "multipart/form-data"};

  // Add provided images if they are not null
  if (image1 != null) {
    request.files.add(
      http.MultipartFile(
        'image1',
        image1.readAsBytes().asStream(),
        image1.lengthSync(),
        filename: image1.path.split('/').last,
      ),
    );
  }

  if (image2 != null) {
    request.files.add(
      http.MultipartFile(
        'image2',
        image2.readAsBytes().asStream(),
        image2.lengthSync(),
        filename: image2.path.split('/').last,
      ),
    );
  }

  if (image3 != null) {
    request.files.add(
      http.MultipartFile(
        'image3',
        image3.readAsBytes().asStream(),
        image3.lengthSync(),
        filename: image3.path.split('/').last,
      ),
    );
  }

  // If you want to add more images from constants.imagesList
  int j = 4;
  for (int i = 0; i < constanst.imagesList.length; i++) {
    request.files.add(
      http.MultipartFile(
        'image$j',
        constanst.imagesList[i].readAsBytes().asStream(),
        constanst.imagesList[i].lengthSync(),
        filename: constanst.imagesList[i].path.split('/').last,
      ),
    );
    j++;
  }

  request.headers.addAll(headers);
  request.fields.addAll({
    'productId': productId,
    'device': device,
  });

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }

  return res;
}

Future addBuyeSubImage(
  String userId,
  String userToken,
  String productId,
  String imageCounter,
  String device,
) async {
  String gethomepostUrl = 'addBuyPostImage';
  var res;
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + gethomepostUrl),
  );

  Map<String, String> headers = {"Content-type": "multipart/form-data"};
  int j = 0;
  print("sendsubimage:-${constanst.imagesList.length}");
  for (int i = 0; i < constanst.imagesList.length; i++) {
    j = j + 1;
    request.files.add(
      http.MultipartFile(
        'image$j',
        constanst.imagesList[i].readAsBytes().asStream(),
        constanst.imagesList[i].lengthSync(),
        filename: constanst.imagesList[i].path,
      ),
    );
  }
  request.headers.addAll(headers);
  request.fields.addAll({
    'user_id': userId,
    'userToken': userToken,
    'productId': productId,
    'image_counter': imageCounter,
    'device': device,
  });

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// update Post
Future updateSalePost(
  String userId,
  String userToken,
  String producttypeId,
  String productgradeId,
  String currency,
  String productPrice,
  String productQty,
  String colorId,
  String description,
  String unit,
  String unitPrice,
  String location,
  String latitude,
  String longitude,
  String imageCounter,
  String city,
  String state,
  String country,
  String stepCounter,
  String productName,
  String categoryId,
  String mainimage,
  String productid,
  String device,
  String version,
) async {
  String addbussinessprofileUrl = 'updateSalePost_v2';
  var res;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + addbussinessprofileUrl),
  );
  Map<String, String> headers = {"Content-type": "multipart/form-data"};

  request.headers.addAll(headers);
  request.fields.addAll({
    'user_id': userId,
    'userToken': userToken,
    'producttype_id': producttypeId,
    'productgrade_id': productgradeId,
    'currency': currency,
    'product_price': productPrice,
    'unit': unit,
    'unit_of_price': unitPrice,
    'location': location,
    'product_qty': productQty,
    'color_id': colorId,
    'description': description,
    // 'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'image_counter': imageCounter,
    'city': city,
    'state': state,
    'country': country,
    'step_counter': stepCounter,
    'product_name': productName,
    'category_id': categoryId,
    'productId': productid,
    'device': device,
    'app_version': version,
  });

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future updateBuyerPost(
  String userId,
  String userToken,
  String producttypeId,
  String productgradeId,
  String currency,
  String productPrice,
  String productQty,
  String colorId,
  String description,
  String unit,
  String unitPrice,
  String location,
  String latitude,
  String longitude,
  String imageCounter,
  String city,
  String state,
  String country,
  String stepCounter,
  String productName,
  String categoryId,
  String mainimage,
  File? file,
  String productid,
  String device,
  String version,
) async {
  String addbussinessprofileUrl = 'updateBuyPost_v2';
  var res;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + addbussinessprofileUrl),
  );
  Map<String, String> headers = {"Content-type": "multipart/form-data"};

  if (file != null) {
    request.files.add(
      http.MultipartFile(
        'mainproductImage',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.path,
      ),
    );
  }
  request.headers.addAll(headers);
  request.fields.addAll({
    'user_id': userId,
    'userToken': userToken,
    'producttype_id': producttypeId,
    'productgrade_id': productgradeId,
    'currency': currency,
    'product_price': productPrice,
    'unit': unit,
    'unit_of_price': unitPrice,
    'location': location,
    'product_qty': productQty,
    'color_id': colorId,
    'description': description,
    // 'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'image_counter': imageCounter,
    'city': city,
    'state': state,
    'country': country,
    'step_counter': stepCounter,
    'product_name': productName,
    'category_id': categoryId,
    'productId': productid,
    'device': device,
    'app_version': version,
  });

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future addProducttype(String userId, String userToken, String typeId,
    String stepCounter, String device) async {
  String gethomepostUrl = 'addProducttype';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + gethomepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'type_id': typeId,
    'step_counter': stepCounter,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future addProductgrade(String userId, String userToken, String gradeId,
    String stepCounter, String device) async {
  String gethomepostUrl = 'addProductgrade';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + gethomepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'grade_id': gradeId,
    'step_counter': stepCounter,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_directory(
    String userId,
    String apiToken,
    String offset,
    String categoryFilterId,
    String producttypeFilterId,
    String productgradeFilterId,
    String posttypeFilter,
    String businesstypeId,
    String coretypeId,
    String latitude,
    String longitude,
    String search,
    String device) async {
  String gethomepostUrl =
      'getdirectory?userId=$userId&userToken=$apiToken&offset=$offset&limit=20&category_filter_id=$categoryFilterId&producttype_filter_id=$producttypeFilterId&productgrade_filter_id=$productgradeFilterId&posttype_filter=$posttypeFilter&posttype_filter=$posttypeFilter&businesstype_id=$businesstypeId&core_businesses_filter_id=$coretypeId&latitude=$latitude&longitude=$longitude&search=$search&device=$device';
  print('directory_data_url: $gethomepostUrl');

  var res;
  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }

  return res;
}

Future get_exhibitor(
  String userid,
  String userToken,
  String offset,
  String categoryId,
  String gradeId,
  String typeId,
  String businesstypeId,
  String postType,
  String coretypeId,
  String latitude,
  String longitude,
  String search,
  String device,
) async {
  String gethomepostUrl =
      'getexhibitor?user_id=$userid&userToken=$userToken&offset=$offset&limit=20&category_id=$categoryId&grade_id=$gradeId&type_id=$typeId&businesstype_id=$businesstypeId&post_type=$postType&core_businesses_filter_id=$coretypeId&latitude=$latitude&longitude=$longitude&search=$search&device=$device';
  var res;

  print("exhibitor_data_urlˇ:-${baseurl + gethomepostUrl}");
  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future updateBusinessVerification({
  required String userId,
  required String userToken,
  required String registrationDate,
  required String panNumber,
  required String aadharNumber,
  required String exportImportNumber,
  required String premises,
  required String gstTaxVat,
  required String docType,
  required String productionCapacity,
  required List<File> filesList,
  required String selectFilesLables,
  required String device,
}) async {
  var res;
  try {
    String addbussinessprofileUrl = 'updateBusinessVerification';
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseurl + addbussinessprofileUrl),
    );
    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    request.headers.addAll(headers);
    request.fields.addAll({
      'userId': userId,
      'userToken': userToken,
      'registration_date': registrationDate,
      'pan_number': panNumber,
      'aadhar_no': aadharNumber,
      'export_import_number': exportImportNumber,
      'premises': premises,
      'gst_tax_vat': gstTaxVat,
      'doc_type': docType,
      'production_capacity': productionCapacity,
      'device': device,
      if (selectFilesLables.isNotEmpty) 'doc_types': selectFilesLables,
    });
    if (filesList.isNotEmpty) {
      for (int i = 0; i < filesList.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
            'documents[$i]', filesList[i].path));
      }
    }
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
    }
    print("rrs:-${response.body}");
  } catch (e) {
    rethrow;
  }

  return res;
}

Future get_productname() async {
  String gethomepostUrl = 'getProductName';

  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('object :$res');
  }
  return res;
}

Future get_deletedocument(String docuId) async {
  String gethomepostUrl = 'deletedocument?document_id=$docuId';

  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future remove_docu(String docuId) async {
  String getsalepostUrl = 'deletedocument?document_id=$docuId';

  var res;

  final response = await http.get(Uri.parse(baseurl + getsalepostUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_profileliked_user(
    String profileId, userId, int page, int limit) async {
  String gethomepostUrl =
      'getprofileliked_user?profile_id=$profileId&user_id=$userId&page=$page&limit=$limit';

  var res;
  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  print('like from other_user_profile: ${(baseurl + gethomepostUrl)}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getProductInterest(userId, userToken, productId, device) async {
  String productInterest =
      "getProductInterest?user_id=$userId&userToken=$userToken&product_id=$productId&device=$device";

  var res;

  final response = await http.get(Uri.parse(baseurl + productInterest));

  print('like from other_user_profile: ${(baseurl + productInterest)}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getProductView(
  productId,
  offset,
  userId,
  device,
) async {
  String productView =
      "getpostviewed_user?post_id=$productId&offset=$offset&limit=20&user_id=$userId&device=$device";

  var res;

  final response = await http.get(Uri.parse(baseurl + productView));

  print('View from other_user_profile: ${(baseurl + productView)}');
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getProductShareCount(userId, productId, device) async {
  String productShare =
      "countpostshare?user_id=$userId&post_id=$productId&device=$device";

  var res;

  final response = await http.get(Uri.parse(baseurl + productShare));
  print('send count: ${baseurl}${productShare}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getProductShare(userId, productId) async {
  String productShare = "getpostshareuser?user_id=$userId&post_id=$productId";

  var res;

  print('getpostshareuser: ${baseurl}${productShare}');

  final response = await http.get(Uri.parse(baseurl + productShare));
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_profileviewd_user(
  String profileId,
  String device,
  String offset,
  String userId,
) async {
  String gethomepostUrl =
      'getprofileviewed_user?profile_id=$profileId&device=$device&offset=$offset&limit=20&user_id=$userId';

  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  print('View from other_user_profile: ${(baseurl + gethomepostUrl)}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future share_count(String profileId, userId, String device) async {
  String gethomepostUrl =
      'countprofileshare?profile_id=$profileId&user_id=$userId&device=$device';

  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  print('Share: ${baseurl}${gethomepostUrl}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_profiles_share(
  String profileId,
  String device,
  String userId,
) async {
  String gethomepostUrl =
      'getprofileshare?profile_id=$profileId&device=$device&user_id=$userId';

  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl));

  print('Shared from other_user_profile: ${(baseurl + gethomepostUrl)}');

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getbusinessprofileDetail(
    String userId, String apiToken, String profileId, String device) async {
  String getpostdatailUrl = 'getbusinessprofile';
  var res;
  String url = baseurl +
      getpostdatailUrl +
      '?userId=$userId&userToken=$apiToken&profile_id=$profileId&device=$device';
  print('URL: $url');
  final response = await http.post(
    Uri.parse(url),
    body: {
      'userId': userId,
      'userToken': apiToken,
      'profile_id': profileId,
      'device': device,
    },
  );
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future addReview(String userId, String userToken, String profileId,
    String rating, String comment, File? file, String device) async {
  String addbussinessprofileUrl = 'addProfileComment_with_rating';
  var res;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + addbussinessprofileUrl),
  );

  Map<String, String> headers = {"Content-type": "multipart/form-data"};

  if (file != null) {
    request.files.add(
      http.MultipartFile(
        'com_image',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.path,
      ),
    );
  }
  request.headers.addAll(headers);
  request.fields.addAll({
    'user_id': userId,
    'userToken': userToken,
    'profile_id': profileId,
    'rating': rating,
    'comment': comment,
    'device': device,
  });

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future Getcomment({
  required String profileid,
  required String offset,
  required String limit,
  required String userId,
  required String userToken,
  required String device,
}) async {
  String getpostdatailUrl = 'getprofilereview';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + getpostdatailUrl), body: {
    'profile_id': profileid,
    'offset': offset,
    'limit': limit,
    'user_id': userId,
    'userToken': userToken,
    'device': device,
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future addReply(String userId, String userToken, String commentId,
    String profileId, String comment) async {
  String gethomepostUrl = 'addprofilesubcomment';
  var res;

  final response =
      await http.post(Uri.parse(baseurl + gethomepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'comment_id': commentId,
    'profile_id': profileId,
    'comment': comment
  });

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  print("Datar:-${res}");
  return res;
}

Future editReview(String userId, String userToken, String commentId,
    String rating, String comment, File? file) async {
  String addbussinessprofileUrl = 'editprofilereviewwithrating';
  var res;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + addbussinessprofileUrl),
  );

  Map<String, String> headers = {"Content-type": "multipart/form-data"};

  if (file != null) {
    request.files.add(
      http.MultipartFile(
        'com_image',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.path,
      ),
    );
  }

  request.headers.addAll(headers);
  request.fields.addAll({
    'user_id': userId,
    'userToken': userToken,
    'comment_id': commentId,
    'rating': rating,
    'comment': comment
  });

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future deletemyreview(String commentId) async {
  String gethomepostUrl = 'deletemyreview';
  var res;

  final response = await http.post(Uri.parse(baseurl + gethomepostUrl),
      headers: {"Accept": "application/json"}, body: {'comment_id': commentId});

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_databytimeduration(String codeId) async {
  String gethomepostUrl = 'getdatabytimeduration?code_id=$codeId';
  var res;

  final response = await http.get(Uri.parse(baseurl + gethomepostUrl),
      headers: {"Accept": "application/json"});

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future deleteAccount(userId, userToken) async {
  String deleteAccount = "deletemyaccount?userId=$userId&userToken=$userToken";
  var res;
  final response = await http.get(Uri.parse(baseurl + deleteAccount));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }

  return res;
}

Future<Map<String, dynamic>?> storePrimeButtonClick(
  String userId,
  String userToken,
  String planId,
) async {
  String buttonClick = 'storeprimebuttonclick';
  var res;
  print('Store Prime Button Click: $buttonClick');

  try {
    final response = await http.post(
      Uri.parse(baseurl + buttonClick),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        'userId': userId,
        'userToken': userToken,
        'planId': planId,
      }),
    );

    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print("Error: $e");
    return null;
  }

  print("Store Prime Button Click: $res");
  return res;
}

Future getPremiumPlan(
  String userid,
  String userToken,
  String device,
) async {
  String getsalepostUrl = 'v2/getallplan';

  var res;
  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userid,
    'userToken': userToken,
    'device': device,
  });
  print('Getpremiumplan: ${baseurl}${getsalepostUrl}');
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future<NotificationSettings?> getNotificationSettings(
    String userId, String userToken, String device) async {
  String getsalepostUrl = 'getNotificationSettings';

  final response = await http.post(
    Uri.parse(baseurl + getsalepostUrl),
    headers: {"Accept": "application/json"},
    body: {
      'userId': userId,
      'userToken': userToken,
      'device': device,
    },
  );

  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return NotificationSettings.fromJson(data);
  } else {
    print("Error: ${response.statusCode}");
    return null;
  }
}

Future<NotificationSettings?> updateNotificationSettings(
  String userId,
  String userToken,
  String device,
  int postComment,
  int favourite,
  int businessProfileLike,
  int userFollow,
  int userUnfollow,
  int livePrice,
  int quickNews,
  int news,
  int blog,
  int video,
  int banner,
  int chat,
  int salePost,
  int buyPost,
  int domestic,
  int international,
  int categoryTypeGradeMatch,
  int followers,
  int postInterested,
) async {
  String getsalepostUrl = 'updateNotificationSetting';

  final response = await http.post(
    Uri.parse(baseurl + getsalepostUrl),
    headers: {"Accept": "application/json"},
    body: {
      'userId': userId,
      'userToken': userToken,
      'device': device,
      'post_comment': postComment.toString(),
      'favourite': favourite.toString(),
      'business_profile_like': businessProfileLike.toString(),
      'user_follow': userFollow.toString(),
      'user_unfollow': userUnfollow.toString(),
      'live_price': livePrice.toString(),
      'quick_news': quickNews.toString(),
      'news': news.toString(),
      'blog': blog.toString(),
      'video': video.toString(),
      'banner': banner.toString(),
      'chat': chat.toString(),
      'sale_post': salePost.toString(),
      'buy_post': buyPost.toString(),
      'domestic': domestic.toString(),
      'international': international.toString(),
      'category_type_grade_match': categoryTypeGradeMatch.toString(),
      'followers': followers.toString(),
      'post_interested': postInterested.toString(),
    },
  );

  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return NotificationSettings.fromJson(data);
  } else {
    print("Error: ${response.statusCode}");
    return null;
  }
}

Future planclickregister(
  String userId,
  int planId,
  String device,
  String currency,
  String amount,
) async {
  String getsalepostUrl = 'plan_click_register';

  var res;
  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'plan_id': planId.toString(),
    'device': device,
    'currency': currency,
    'amount': amount,
  });
  print('plan_click_register: ${baseurl}${getsalepostUrl}');
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future<Map<String, dynamic>?> getorderid(
  int amountInPaise,
  String device,
) async {
  // Convert the amount from paise to INR
  double amountInINR = amountInPaise / 100;
  String getsalepostUrl = 'createrazorpayOrder_test';

  final response = await http.post(
    Uri.parse(baseurl + getsalepostUrl),
    headers: {"Accept": "application/json"},
    body: {
      'amount': amountInINR.toString(),
      'device': device,
    },
  );

  print('createrazorpayOrder: ${baseurl}${getsalepostUrl}');
  print('amount: ${amountInINR}');

  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    // Return the decoded JSON response directly
    return jsonDecode(response.body);
  } else {
    print('Error: Failed to fetch data from API');
    return null; // Return null for error
  }
}

Future<Map<String, dynamic>?> getorderforusd(
  int amountInusd,
  String device,
) async {
  // Convert the amount from paise to INR
  double amountInUsd = amountInusd / 100;
  String getsalepostUrl = 'createrazorpayOrder_for_usd';

  final response = await http.post(
    Uri.parse(baseurl + getsalepostUrl),
    headers: {"Accept": "application/json"},
    body: {
      'amount': amountInUsd.toString(),
      'device': device,
    },
  );

  print('createrazorpayOrder_for_usd: ${baseurl}${getsalepostUrl}');
  print('amount: ${amountInUsd}');

  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    // Return the decoded JSON response directly
    return jsonDecode(response.body);
  } else {
    print('Error: Failed to fetch data from API');
    return null; // Return null for error
  }
}

Future<ActivePlan?> getactivePlan(
  String userid,
  String userToken,
  String device,
) async {
  String getsalepostUrl = 'getactiveplan';
  final response = await http.post(
    Uri.parse(baseurl + getsalepostUrl),
    headers: {"Accept": "application/json"},
    body: {
      'user_id': userid,
      'userToken': userToken,
      'device': device,
    },
  );
  print('getactivePlan: ${baseurl}${getsalepostUrl}');
  print('user_id: ${userid}');
  print('userToken: ${userToken}');
  print('device: ${device}');

  print('Response Status: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    if (responseData['status'] == 1) {
      final activePlanJson = responseData['active_plan'];
      if (activePlanJson != null) {
        return ActivePlan.fromJson(activePlanJson);
      } else {
        return null;
      }
    }
  }
  return null;
}

Future activePlan(
  String userid,
  String userToken,
  String device,
) async {
  String getsalepostUrl = 'checkactiveplan';
  var res;
  print('user_id: $userid');
  print('userToken: $userToken');
  print('device: $device');

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userid,
    'userToken': userToken,
    'device': device,
  });
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

// Function to call the API and get the Razorpay key
Future<Map<String, dynamic>?> razerpayKey(
  String userToken,
  String device,
) async {
  String getsalepostUrl = 'getrazorpay_test_key';
  print('userToken From RazorPay: $userToken');
  print('device: $device');
  print('RazorPayKey Url: ${baseurl + getsalepostUrl}');

  // Making the POST request
  final response = await http.post(
    Uri.parse(baseurl + getsalepostUrl),
    headers: {
      "Accept": "application/json",
    },
    body: {
      'userToken': userToken,
      'device': device,
    },
  );

  // Check for a successful response
  if (response.statusCode == 200) {
    return jsonDecode(response.body); // Return decoded JSON response
  } else {
    print('Failed to fetch Razorpay key: ${response.statusCode}');
    return null; // Return null in case of failure
  }
}

// Google Place Api Key

Future<Map<String, dynamic>?> googlePlaceApiKey(
  String userToken,
  String device,
) async {
  String getsalepostUrl = 'getplace_api_key';
  print('userToken From RazorPay: $userToken');
  print('device: $device');
  print('googlePlaceApiKey Url: ${baseurl + getsalepostUrl}');

  // Making the POST request
  final response = await http.post(
    Uri.parse(baseurl + getsalepostUrl),
    headers: {
      "Accept": "application/json",
    },
    body: {
      'userToken': userToken,
      'device': device,
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print('Failed to fetch googlePlace key: ${response.statusCode}');
    return null;
  }
}

Future validatecoupon(
  String userid,
  String userToken,
  String coupon,
) async {
  String getsalepostUrl = 'validatecoupon';
  var res;
  print('user_id: $userid');
  print('userToken: $userToken');
  print('coupon: $coupon');

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userid,
    'userToken': userToken,
    'coupon': coupon,
  });
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future purchaseplan(
  String userid,
  String userToken,
  String primeid,
  String transactionid,
  String paidamount,
  String coupon,
  String device,
) async {
  String getsalepostUrl = 'purchaseplan';
  var res;
  print('user_id: $userid');
  print('userToken: $userToken');
  print('primeid: $primeid');
  print('transactionid: $transactionid');
  print('paidamount: $paidamount');
  print('coupon: $coupon');
  print('device: $device');

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userid,
    'userToken': userToken,
    'prime_plan_id': primeid,
    'transection_id': transactionid,
    'paid_amount': paidamount,
    'coupon': coupon,
    'device': device,
  });
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future getpurchasedplan(
  String userid,
  String userToken,
  String offset,
  String limit,
) async {
  String getsalepostUrl = 'purchasedplan';
  var res;
  print('user_id: $userid');
  print('userToken: $userToken');
  print('offset: $offset');
  print('limit: $limit');
  print('getpurchasedplan Url: ${baseurl}${getsalepostUrl}');

  final response =
      await http.post(Uri.parse(baseurl + getsalepostUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userid,
    'userToken': userToken,
    'offset': offset,
    'limit': limit,
  });
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_chatHistory({
  String? userId,
  String? userToken,
}) async {
  String getmychathistoryUrl = 'chat2/chatroom';
  var res;
  final response = await http.post(
    Uri.parse(baseurl + getmychathistoryUrl),
    headers: {"Accept": "application/json"},
    body: {
      'user_id': userId,
      'userToken': userToken,
    },
  );

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
    print('Response chat: $res');
  } else {
    print('Failed to load chat history: ${response.statusCode}');
  }

  return res;
}

Future get_chatDetails(
    {String? userId, String? userToken, String? chatId, int? page}) async {
  String getmychatdetailUrl = 'chat2/getmychatdetail';
  var res;
  final response = await http.post(
    Uri.parse(baseurl + getmychatdetailUrl),
    headers: {
      "Accept": "application/json",
    },
    body: {
      'user_id': userId,
      'userToken': userToken,
      'page': page?.toString(),
      if (chatId != null) 'chat_id': chatId.toString(),
    },
  );

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }

  return res;
}

Future get_SendChat({
  String? userId,
  String? userToken,
  String? toId,
  String? msg,
  String? comment,
  String? chatId,
  File? image,
}) async {
  String sendchatUrl = 'chat2/send';
  var res;

  // Create a multipart request
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl + sendchatUrl),
  );

  // Add form fields to the request
  request.fields['userToken'] = userToken ?? '';
  request.fields['user_id'] = userId ?? '';
  request.fields['image_comment'] = comment ?? '';
  request.fields['msg'] = msg ?? '';

  request.fields['toid'] = toId ?? '';
  if (chatId != null) {
    request.fields['chat_id'] = chatId;
  }

  // Attach the image file if provided
  if (image != null) {
    var imageStream = http.ByteStream(image.openRead());
    var imageLength = await image.length();
    var multipartFile = http.MultipartFile(
      'image',
      imageStream,
      imageLength,
      filename: image.path.split('/').last,
    );
    request.files.add(multipartFile);
  }

  // Send the request
  var streamedResponse = await request.send();

  // Parse the response
  if (streamedResponse.statusCode == 200) {
    var response = await http.Response.fromStream(streamedResponse);
    res = jsonDecode(response.body);
    print('${response.body}');
  }

  return res;
}

Future get_deletecChat({
  String? userId,
  String? userToken,
  String? chatId,
}) async {
  String deletechat = 'chat2/deletechat';
  var res;
  final response = await http.post(Uri.parse(baseurl + deletechat), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'chat_id': chatId,
  });
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_clearChat({
  String? userId,
  String? userToken,
  String? chatId,
}) async {
  String deletechat = 'chat2/clearchat';
  var res;
  final response = await http.post(Uri.parse(baseurl + deletechat), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'chat_id': chatId,
  });
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_newmessages(
    {String? userId,
    String? userToken,
    String? chatId,
    String? lastChatId}) async {
  String deletechat = 'chat2/getnewmessages';
  var res;
  final response = await http.post(Uri.parse(baseurl + deletechat), headers: {
    "Accept": "application/json"
  }, body: {
    'user_id': userId,
    'userToken': userToken,
    'chat_id': chatId,
    'last_id': lastChatId,
  });
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future get_PrimeMember({
  required String userId,
  required String apiToken,
  required String offset,
  String? categoryFilterId,
  String? producttypeFilterId,
  String? productgradeFilterId,
  String? posttypeFilter,
  String? businesstypeId,
  String? coretypeId,
  String? latitude,
  String? longitude,
  String? search,
}) async {
  String getPrimeuserUrl =
      'getPrimeuser?userId=$userId&offset=$offset&limit=20&category_filter_id=$categoryFilterId&producttype_filter_id=$producttypeFilterId&productgrade_filter_id=$productgradeFilterId&posttype_filter=$posttypeFilter&posttype_filter=$posttypeFilter&businesstype_id=$businesstypeId&core_businesses_filter_id=$coretypeId&latitude=$latitude&longitude=$longitude&search=$search';

  var res;
  print("getPrimeuserUrl:-$getPrimeuserUrl");
  final response = await http.get(Uri.parse(baseurl + getPrimeuserUrl));

  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future deleteMainProductImage({
  String? productId,
  String? subImageId,
}) async {
  String getmychathistoryUrl = 'delete_post_main_image';
  var res;
  final response =
      await http.post(Uri.parse(baseurl + getmychathistoryUrl), headers: {
    "Accept": "application/json"
  }, body: {
    'image_id': subImageId,
    'post_id': productId,
  });
  if (response.statusCode == 200) {
    res = jsonDecode(response.body);
  }
  return res;
}

Future<Map<String, dynamic>?> noPromotionCheck({File? image}) async {
  const String nopromotioncheckUrl = 'nopromotion_check';
  final String url = baseurl + nopromotioncheckUrl;
  print('noPromotionCheckUrl: $url');

  try {
    // Check if image is provided
    if (image == null) {
      throw Exception('Image file is required');
    }

    // Create a Multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add the image as a file
    var imageFile = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(imageFile);

    // Add headers if needed
    request.headers['Accept'] = 'application/json';

    // Send the request
    var response = await request.send();

    // Get the response body
    final res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>?;
    } else {
      print('Error: ${res.statusCode}, ${res.body}');
      return null;
    }
  } catch (e) {
    print('Exception occurred: $e');
    return null;
  }
}
