// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showCustomToast(String message,
    {int duration = 4, ToastGravity gravity = ToastGravity.BOTTOM}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: duration == 4 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
    gravity: gravity,
    timeInSecForIosWeb: duration,
    backgroundColor: Colors.black.withOpacity(0.80),
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
