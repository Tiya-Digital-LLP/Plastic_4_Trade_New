import 'dart:async';

import 'package:Plastic4trade/screen/auth/login_registration.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtm/gtm.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({
    Key? key,
    required this.analytics,
    required this.observer,
  }) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String notificationMessge = 'Notification Waiting ';
  String token = "";
  String? version;

  String? packageName;
  PackageInfo? packageInfo;
  final FacebookAppEvents facebookAppEvents = FacebookAppEvents();
  @override
  void initState() {
    super.initState();
    getPackage();
    initGtm();
    print("Logging Facebook event: SplashScreenView");
    facebookAppEvents.logEvent(name: 'SplashScreenView');
  }

  Future<void> initGtm() async {
    try {
      final gtm = await Gtm.instance;
      gtm.setCustomTagTypes([
        CustomTagType(
          'amplitude',
          handler: (eventName, parameters) {
            print('amplitude!');
            print(eventName);
            print(parameters);
          },
        ),
      ]);
      gtm.push(
        'splash_screen_view',
        parameters: {
          'screen_name': 'SplashScreen',
        },
      );
    } on PlatformException {
      print('exception occurred!');
    }
  }

  Future<void> redirect() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    await Future.delayed(const Duration(milliseconds: 500));

    bool isLoggedIn = pref.getBool('islogin') ?? false;
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginRegistration(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(0),
        ),
      );
    }
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
    version = packageInfo!.version;
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Image.asset(
                'assets/plastic4trade logo final.png',
                alignment: Alignment.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(
              'assets/image 1.png',
              alignment: Alignment.center,
              width: 300,
            ),
          )
        ]),
      ),
    );
  }
}
