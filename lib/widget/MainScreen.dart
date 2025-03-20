// ignore_for_file: use_build_context_synchronously, must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:Plastic4trade/screen/auth/login_registration.dart';
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/screen/menu/More.dart';
import 'package:Plastic4trade/screen/news/News.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gtm/gtm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../api/api_interface.dart';
import '../screen/blog/Blog.dart';
import '../screen/post/BuyerPost.dart';
import '../screen/buyer_seller/Buyer_sell_detail.dart';
import '../screen/exhibition/Exhibition.dart';
import '../screen/Follower_Following.dart';
import '../screen/home/HomePage.dart';
import '../screen/liveprice/Liveprice.dart';
import '../screen/post/SalePost.dart';
import '../screen/video/Tutorial_Videos.dart';
import '../screen/video/Videos.dart';
import '../utill/constant.dart';
import 'HomeAppbar.dart';
import 'bottombar.dart';

class MainScreen extends StatefulWidget {
  int select_idx;

  MainScreen(this.select_idx, {Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String title = 'Home';
  bool load = false;
  DateTime? currentBackPressTime;
  String notificationMessge = 'Notification Waiting ';
  List<Widget> pagelist = <Widget>[
    HomePage(),
    SalePost(),
    BuyerPost(),
    News(initialIndex: 0),
    more()
  ];

  @override
  void initState() {
    super.initState();

    checknetowork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainScreenBackgroundColor,
      appBar: CustomeApp(title),
      body: pagelist[widget.select_idx],
      bottomNavigationBar: BottomMenu(
        selectedIndex: widget.select_idx,
        onClicked: onClicked,
      ),
    );
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      get_notification();
      constanst.isFromNotification = true;
      if (constanst.notificationtype == "profile like") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => bussinessprofile(
                    int.parse(constanst.notiuser.toString()))));
      } else if (constanst.notificationtype == "follower_profile_like") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => bussinessprofile(
              int.parse(
                constanst.notiuser.toString(),
              ),
            ),
          ),
        );
      } else if (constanst.notificationtype == "profile_review") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => bussinessprofile(
              int.parse(
                constanst.notiuser.toString(),
              ),
            ),
          ),
        );
      } else if (constanst.notificationtype == "Business profile dislike") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => bussinessprofile(
              int.parse(
                constanst.notiuser.toString(),
              ),
            ),
          ),
        );
      } else if (constanst.notificationtype == "post like") {
        if (constanst.notypost_type.toString() == "SalePost") {
          if (constanst.notipostid.toString().isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Buyer_sell_detail(
                    post_type: 'SalePost', prod_id: constanst.notipostid),
              ),
            );
          }
        } else {
          if (constanst.notypost_type.toString() == "BuyPost") {
            if (constanst.notipostid.toString().isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Buyer_sell_detail(
                      post_type: 'BuyPost', prod_id: constanst.notipostid),
                ),
              );
            }
          }
        }
      } else if (constanst.notificationtype == "unfollowuser") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const follower(),
          ),
        );
      } else if (constanst.notificationtype == "followuser") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const follower(),
          ),
        );
      } else if (constanst.notificationtype == "profile_review") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => bussinessprofile(
              int.parse(
                constanst.notiuser.toString(),
              ),
            ),
          ),
        );
      } else if (constanst.notificationtype == "live_price") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LivepriceScreen(),
          ),
        );
      } else if (constanst.notificationtype == "quick_news_notification") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(3),
          ),
        );
      } else if (constanst.notificationtype == "news") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen(3)));
      } else if (constanst.notificationtype == "blog") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Blog()));
      } else if (constanst.notificationtype == "video") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Videos()));
      } else if (constanst.notificationtype == "banner") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen(0)));
      } else if (constanst.notificationtype == "tutorial_video") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Tutorial_Videos()));
      } else if (constanst.notificationtype == "exhibition") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Exhibition()));
      } else if (constanst.notificationtype == "quicknews") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen(3)));
      }
    }
  }

  void onClicked(int index) {
    setState(() {
      widget.select_idx = index;

      // Assign titles based on the selected index
      if (widget.select_idx == 0) {
        title = 'Home';
      } else if (widget.select_idx == 1) {
        title = 'Seller';
      } else if (widget.select_idx == 2) {
        title = 'Buyer';
      } else if (widget.select_idx == 3) {
        title = 'News';
      } else if (widget.select_idx == 4) {
        title = 'More';
      }

      if (title == 'More') {
        print("Current step before switch: ${constanst.step}");

        switch (constanst.step) {
          case 3:
            showEmailDialog(context);
            return;
        }
      }

      pushTrackingEvents(title);
    });
  }

// Function to push events to GTM and Firebase Analytics
  void pushTrackingEvents(String screenName) async {
    try {
      // Push event to GTM
      final gtm = await Gtm.instance;
      gtm.push(
        screenName,
        parameters: {
          'screen_name': screenName, // Send the dynamic screen name
        },
      );
      print('GTM event pushed for $screenName');

      // Push event to Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: screenName,
        parameters: {
          'screen_name': screenName, // Send the dynamic screen name
        },
      );
      print('Firebase Analytics event pushed for $screenName');
    } on PlatformException {
      print('Exception occurred while pushing events for $screenName');
    }
  }

  Future<void> get_notification() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await count_notify(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    if (res['status'] == 1) {
      setState(() {
        constanst.notification_count = res['NotificationCount'];
        constanst.chat_count = res['totalUnreadMessages'];
      });
    } else if (res['status'] == 401) {
      showCustomToast("Session expired. Please log in again.");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LoginRegistration(),
        ),
      );
    } else {
      showCustomToast(res['message']);
    }

    return res;
  }

  logout_android_device(context, deviceid) async {
    var res = await android_logout(deviceid);

    if (res['status'] == 1) {
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
