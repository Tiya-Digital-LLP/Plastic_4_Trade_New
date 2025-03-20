import 'package:Plastic4trade/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:android_id/android_id.dart';
import 'dart:io' show Platform;

Future<void> saveDeviceId() async {
  String? deviceId;

  final prefs = await SharedPreferences.getInstance();

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
    await prefs.setString('device_id', deviceId);
    print('Device ID saved: $deviceId');
  } else {
    print('Device ID is null.');
  }
}
