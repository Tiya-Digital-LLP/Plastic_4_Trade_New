// ignore_for_file: camel_case_types, non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'dart:core';
import 'package:Plastic4trade/main.dart';
import 'package:Plastic4trade/screen/Adwithus.dart';
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/screen/dynamic_link_share_app.dart';
import 'package:Plastic4trade/screen/invoice/invoice.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/screen/product_interested.dart';
import 'package:Plastic4trade/screen/splash/splash_screen.dart';

import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/utill/save_user_id.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_more_shimmer.dart';
import 'package:android_id/android_id.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/screen/Aboutplastic.dart';
import 'package:Plastic4trade/screen/blog/Blog.dart';
import 'package:Plastic4trade/screen/buisness_profile/Bussinessinfo.dart';
import 'package:Plastic4trade/screen/ContactUs.dart';
import 'package:Plastic4trade/screen/video/Videos.dart';
import 'package:Plastic4trade/screen/upgrade/updateCategoryScreen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/api_interface.dart';
import '../../utill/constant.dart';
import '../../widget/HomeAppbar.dart';
import '../../widget/MainScreen.dart';
import '../Directory.dart';
import '../exhibition/Exhibition.dart';
import '../exhibition/ExhibitorScreen.dart';
import '../Saved.dart';
import '../Follower_Following.dart';
import '../post/ManagePost.dart';
import '../notification/NotificationSettingsScreen.dart';
import '../member/Premum_member.dart';
import '../video/Tutorial_Videos.dart';

class more extends StatefulWidget {
  const more({Key? key}) : super(key: key);

  @override
  State<more> createState() => _moreState();
}

class Choice {
  const Choice({required this.title, required this.icon, required this.id});

  final String title;
  final String icon;
  final String id;
}

const List<Choice> allChoices = <Choice>[
  Choice(title: 'Business & Profile ', icon: 'assets/shop.png', id: '1'),
  Choice(title: 'Manage Post', icon: 'assets/shopping-cart.png', id: '2'),
  Choice(title: 'Interested In', icon: 'assets/bag-tick.png', id: '3'),
  Choice(title: 'Saved', icon: 'assets/Save_more_icon.png', id: '5'),
  Choice(
      title: 'Followers/Followings', icon: 'assets/profile-2user.png', id: '6'),
  Choice(
      title: 'Product Interested',
      icon: 'assets/Product_Interested.png',
      id: '7'),
  Choice(title: 'Blog', icon: 'assets/document-text.png', id: '9'),
  Choice(title: 'News', icon: 'assets/clipboard-text.png', id: '10'),
  Choice(title: 'Videos', icon: 'assets/video.png', id: '11'),
  Choice(title: 'Tutorial Video', icon: 'assets/play-circle.png', id: '12'),
  Choice(title: 'Exhibition', icon: 'assets/box.png', id: '13'),
  Choice(title: 'Directory', icon: 'assets/directbox-default.png', id: '14'),
  Choice(title: 'Exhibitor', icon: 'assets/Exhibitor_Icon.png', id: '15'),
  Choice(title: 'Premium Member', icon: 'assets/premium_mem.png', id: '16'),
  Choice(title: 'App Share', icon: 'assets/send-2.png', id: '17'),
  Choice(title: 'Premium Plan', icon: 'assets/award.png', id: '18'),
];

class _moreState extends State<more> with SingleTickerProviderStateMixin {
  String? packageName;
  PackageInfo? packageInfo;
  String? version;
  String? username, business_name, image_url, premium_plan_active;
  String? userId;
  String? whatsappUrl,
      facebookUrl,
      instagramUrl,
      linkedinUrl,
      youtubeUrl,
      telegramUrl,
      twitterUrl;
  bool? isload;
  String dummyImage = "https://image.pngaaa.com/892/6640892-middle.png";
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String crown_color = '';
  String plan_name = '';
  bool _isSharing = false;
  bool is_premium_active_android = false;
  bool is_premium_active_ios = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  String? deviceId;
  late SharedPreferences _pref;

  Future<void> _initializePreferences() async {
    _pref = await SharedPreferences.getInstance();
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
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
      await _pref.setString('device_id', deviceId.toString());
      print('Device ID saved: $deviceId');
    } else {
      print('Device ID is null.');
    }
  }

  @override
  void initState() {
    if (constanst.isWithoutLogin == true) {
      _initializePreferences();

      getPackage();
      getUnknownProfile();
      getSocialMedia();
      _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );

      _offsetAnimation = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _controller.forward();
    } else {
      _initializePreferences();

      getPackage();
      getProfiless();
      getSocialMedia();
      _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );

      _offsetAnimation = Tween<Offset>(
        begin: const Offset(0.0, 1.0), // Start from bottom
        end: Offset.zero, // End at actual position
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _controller.forward();
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (constanst.isFromNotification) {
      constanst.isFromNotification = false;
    }
    return init();
  }

  Widget init() {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _onbackpress(context);
      },
      child: RefreshIndicator(
        backgroundColor: AppColors.primaryColor,
        color: AppColors.backgroundColor,
        onRefresh: _refreshData,
        child: Scaffold(
          backgroundColor: AppColors.greyBackground,
          body: isload == true
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            constanst.redirectpage = "business_profile";

                            SharedPreferences pref =
                                await SharedPreferences.getInstance();

                            if (pref.getBool('isWithoutLogin') == true) {
                              showLoginDialog(context);
                              return;
                            }
                            print(
                                "Current step before switch: ${constanst.step}");
                            switch (constanst.step) {
                              case 3:
                                showEmailDialog(context);
                                break;
                              case 5:
                                showInformationDialog(context);
                                break;
                              case 6:
                              case 7:
                              case 8:
                                categoryDialog(context);
                                break;
                              case 9:
                                addPostDialog(context);
                                break;
                              case 10:
                                addPostDialog(context);
                                break;
                              case 11:
                                redirectToBussinessProfileScreen(context);
                                break;
                              default:
                                print("Unexpected value: ${constanst.step}");
                                break;
                            }
                          },
                          child: Container(
                            height: 75,
                            padding: const EdgeInsets.only(left: 17),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13.05),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: AppColors.boxShadowforshimmer,
                                  blurRadius: 16.32,
                                  offset: Offset(0, 3.26),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                image_url != null
                                    ? Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff7c94b6),
                                          border: Border.all(
                                            width: 2,
                                            color: Color(int.parse(
                                                    crown_color.substring(1),
                                                    radix: 16) |
                                                0xFF000000),
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: image_url.toString(),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/plastic4trade logo final 1 (2).png'
                                                  .toString(),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(50.0),
                                          ),
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        username ?? 'Username',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontFamily:
                                              'assets/fonts/Metropolis-Black.otf',
                                        ),
                                      ),
                                      business_name != null
                                          ? Text(
                                              business_name!,
                                              style: const TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                                fontFamily:
                                                    'assets/fonts/Metropolis-Black.otf',
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: category(),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactUs(),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 0.0, 8.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13.5),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(13.5)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.boxShadowforshimmer,
                                          blurRadius: 16.32,
                                          offset: Offset(0, 3.26),
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 55,
                                          child: Center(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Align(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 20.0),
                                                    child: Text(
                                                      'Contact Us/Feedback',
                                                      style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-SemiBold.otf'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ContactUs(),
                                              ),
                                            );
                                          },
                                          icon:
                                              Image.asset('assets/forward.png'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Platform.isIOS
                            ? (is_premium_active_ios
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Invoice(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.fromLTRB(
                                          5.0, 0.0, 8.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.05),
                                            ),
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13.05),
                                                ),
                                                shadows: [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .boxShadowforshimmer,
                                                    blurRadius: 16.32,
                                                    offset:
                                                        const Offset(0, 3.26),
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    height: 55,
                                                    child: Center(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                          Align(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          20.0),
                                                              child: Text(
                                                                'Subscriptions',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-SemiBold.otf',
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Invoice(),
                                                        ),
                                                      );
                                                    },
                                                    icon: Image.asset(
                                                        'assets/forward.png'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink())
                            : (is_premium_active_android
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Invoice(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.fromLTRB(
                                          5.0, 0.0, 8.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.05),
                                            ),
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13.05),
                                                ),
                                                shadows: [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .boxShadowforshimmer,
                                                    blurRadius: 16.32,
                                                    offset:
                                                        const Offset(0, 3.26),
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    height: 55,
                                                    child: Center(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                          Align(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          20.0),
                                                              child: Text(
                                                                'Subscriptions',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-SemiBold.otf',
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Invoice(),
                                                        ),
                                                      );
                                                    },
                                                    icon: Image.asset(
                                                        'assets/forward.png'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink()),
                        Platform.isIOS
                            ? (is_premium_active_ios
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Adwithus(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.fromLTRB(
                                          5.0, 0.0, 8.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.05),
                                            ),
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13.05),
                                                ),
                                                shadows: [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .boxShadowforshimmer,
                                                    blurRadius: 16.32,
                                                    offset:
                                                        const Offset(0, 3.26),
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    height: 55,
                                                    child: Center(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                          Align(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          20.0),
                                                              child: Text(
                                                                'Advertise with us',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-SemiBold.otf',
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Adwithus(),
                                                        ),
                                                      );
                                                    },
                                                    icon: Image.asset(
                                                        'assets/forward.png'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink())
                            : (is_premium_active_android
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Adwithus(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.fromLTRB(
                                          5.0, 0.0, 8.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.05),
                                            ),
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13.05),
                                                ),
                                                shadows: [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .boxShadowforshimmer,
                                                    blurRadius: 16.32,
                                                    offset:
                                                        const Offset(0, 3.26),
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    height: 55,
                                                    child: Center(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                          Align(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          20.0),
                                                              child: Text(
                                                                'Advertise with us',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-SemiBold.otf',
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Adwithus(),
                                                        ),
                                                      );
                                                    },
                                                    icon: Image.asset(
                                                        'assets/forward.png'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink()),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const Notificationsetting(),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 0.0, 8.0, 0.0),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(13.05),
                                    ),
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13.05),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color:
                                                AppColors.boxShadowforshimmer,
                                            blurRadius: 16.32,
                                            offset: Offset(0, 3.26),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              height: 55,
                                              child: Center(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Align(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            'Notification Settings',
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-SemiBold.otf'),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Notificationsetting(),
                                                  ),
                                                );
                                              },
                                              icon: Image.asset(
                                                  'assets/forward.png'),
                                            )
                                          ]),
                                    ),
                                  )
                                ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const aboutplastic(),
                                // builder: (context) => const AppTermsCondition(),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 0.0, 8.0, 0.0),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(13.05),
                                    ),
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13.05),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color:
                                                AppColors.boxShadowforshimmer,
                                            blurRadius: 16.32,
                                            offset: Offset(0, 3.26),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              height: 55,
                                              child: Center(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Align(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            'About Plastic4trade',
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-SemiBold.otf'),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const aboutplastic(),
                                                  ),
                                                );
                                              },
                                              icon: Image.asset(
                                                  'assets/forward.png'),
                                            )
                                          ]),
                                    ),
                                  )
                                ]),
                          ),
                        ),
                        (constanst.isWithoutLogin)
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  showlogoutDialog(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.fromLTRB(
                                      5.0, 0.0, 8.0, 0.0),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13.05),
                                          ),
                                          child: Container(
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        13.05),
                                              ),
                                              shadows: [
                                                BoxShadow(
                                                  color: AppColors
                                                      .boxShadowforshimmer,
                                                  blurRadius: 16.32,
                                                  offset: Offset(0, 3.26),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const SizedBox(
                                                    height: 55,
                                                    child: Center(
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Align(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20.0),
                                                                child: Text(
                                                                  'Logout',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'assets/fonst/Metropolis-SemiBold.otf'),
                                                                ),
                                                              ),
                                                            ),
                                                          ]),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      showlogoutDialog(context);
                                                    },
                                                    icon: Image.asset(
                                                        'assets/forward.png'),
                                                  )
                                                ]),
                                          ),
                                        )
                                      ]),
                                ),
                              ),
                        10.sbh,
                        const Center(
                          child: Text(
                            'Follow Plastic4trade',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  GtmUtil.logScreenView(
                                    'WhatsApp_Menu_click',
                                    'whatsappclick',
                                  );
                                  launchUrl(
                                    Uri.parse(whatsappUrl!),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: Image.asset(
                                  'assets/whatsapp.png',
                                  height: 26,
                                  width: 26,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  GtmUtil.logScreenView(
                                    'Linkdien_Menu_click',
                                    'linkdienclick',
                                  );
                                  launchUrl(
                                    Uri.parse(linkedinUrl!),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: Image.asset('assets/linkdin.png',
                                    height: 26, width: 26),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  GtmUtil.logScreenView(
                                    'Youtube_Menu_click',
                                    'youtubeclick',
                                  );
                                  launchUrl(
                                    Uri.parse(youtubeUrl!),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: Image.asset('assets/youtube.png',
                                    height: 26, width: 26),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  GtmUtil.logScreenView(
                                    'Facebook_Menu_click',
                                    'facebookclick',
                                  );
                                  launchUrl(
                                    Uri.parse(facebookUrl!),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: Image.asset('assets/facebook.png',
                                    height: 26, width: 26),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  GtmUtil.logScreenView(
                                    'Instagram_Menu_click',
                                    'instagramclick',
                                  );
                                  launchUrl(
                                    Uri.parse(instagramUrl!),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: Image.asset('assets/instagram.png',
                                    height: 26, width: 26),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  GtmUtil.logScreenView(
                                    'Telegram_Menu_click',
                                    'telegramclick',
                                  );
                                  launchUrl(
                                    Uri.parse(telegramUrl!),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: Image.asset('assets/Telegram.png',
                                    height: 26, width: 26),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  GtmUtil.logScreenView(
                                    'Twitter_Menu_click',
                                    'twitterclick',
                                  );
                                  launchUrl(
                                    Uri.parse(twitterUrl!),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: Image.asset('assets/xIcon.jpg',
                                    height: 26, width: 26),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'App Version $version',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf',
                                  color: Colors.black,
                                  fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () {
                                if (Platform.isAndroid) {
                                  _openGooglePlayStore();
                                } else if (Platform.isIOS) {
                                  _launchAppStore();
                                }
                              },
                              child: const Text(
                                'Check Latest Update',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w400,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf',
                                    fontSize: 13),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2,
                      ),
                      itemCount: allChoices.length,
                      itemBuilder: (context, index) {
                        return CustomGridItem();
                      },
                    ),
                  ),
                ),
          bottomNavigationBar: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                        0.2), // Optional shadow for elevation effect
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
              ),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();

                      if (pref.getBool('isWithoutLogin') == true) {
                        showLoginDialog(context);
                        return;
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Exhibitor(),
                            ));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: const Text(
                        'Exhibitor',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf',
                            fontSize: 10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();

                      if (pref.getBool('isWithoutLogin') == true) {
                        showLoginDialog(context);
                        return;
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const premum_member(),
                            ));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: const Text(
                        'Premium Member',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf',
                            fontSize: 10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();

                      if (pref.getBool('isWithoutLogin') == true) {
                        showLoginDialog(context);
                        return;
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Directory1(),
                            ));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: const Text(
                        'Directory',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf',
                            fontSize: 10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      GtmUtil.logScreenView(
                        'App_Share',
                        'App_Share',
                      );
                      shareApp(
                        url:
                            "https://play.google.com/store/apps/details?id=com.p4t.plastic4trade",
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: const Text(
                        'App Share ',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf',
                            fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void redirectToBussinessProfileScreen(BuildContext context) async {
    try {
      // Await the Future to get the actual value
      final userIdFuture = SharedPrefService.getUserId();
      final userId = await userIdFuture;

      if (userId == null || userId.isEmpty) {
        print("Error: User ID is null or empty.");
        return;
      }

      // Validate and parse the user ID
      if (RegExp(r'^\d+$').hasMatch(userId)) {
        final parsedUserId = int.parse(userId);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => bussinessprofile(parsedUserId),
          ),
        );
      } else {
        print("Invalid user ID: $userId");
      }
    } catch (e) {
      print("Error parsing user ID: $e");
    }
  }

  Future<bool> _onbackpress(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(0),
      ),
    );
    return Future.value(true);
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
    version = packageInfo!.version;
  }

  Future<void> showlogoutDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return CommanDialog(
            content: "Are You Sure Want To\n Log Out?",
            title: "Log Out",
            onPressed: () async {
              if (Platform.isAndroid) {
                SharedPreferences _pref = await SharedPreferences.getInstance();

                await _pref.setBool('islogin', false);
                await _pref.remove('islogin');
                String? deviceId = _pref.getString('device_id');
                logout_android_device(context, deviceId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SplashScreen(
                      analytics: MyApp.analytics,
                      observer: MyApp.observer,
                    ),
                  ),
                );
              } else if (Platform.isIOS) {
                SharedPreferences _pref = await SharedPreferences.getInstance();
                await _pref.setBool('islogin', false);
                await _pref.remove('islogin');
                String? deviceId = _pref.getString('device_id');
                logout_android_device(context, deviceId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SplashScreen(
                      analytics: MyApp.analytics,
                      observer: MyApp.observer,
                    ),
                  ),
                );
              }
            });
      },
    );
  }

  void _openGooglePlayStore() async {
    final String url =
        'https://play.google.com/store/apps/details?id=com.p4t.plastic4trade';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void shareApp({
    required String url,
  }) async {
    if (_isSharing) return; // Avoid sharing if already in progress
    _isSharing = true;

    try {
      final dynamicLink = await dynamicShareApp(
          'www.plastic4trade.com', 'AppShare', 'datashare');

      final ByteData bytesImage = await rootBundle.load('assets/appLogo.jpeg');
      final bytes = bytesImage.buffer.asUint8List();
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/image.jpg';
      File(path).writeAsBytesSync(bytes);

      await Share.shareFiles([path],
          text:
              'Plastic4trade is a B2B Plastic Business App, Buy & Sale your Products, Raw Material, Recycle Plastic Scrap, Plastic Machinery, Polymer Price, News, Update for Manufacturers, Traders, Exporters, Importers...' +
                  "\n" +
                  '\n' +
                  'Download App' +
                  '\n' +
                  dynamicLink);
    } catch (e) {
      print("Error creating dynamic link: $e");
      // Handle the error as needed
    } finally {
      _isSharing = false;
    }
  }

  void _launchAppStore() async {
    const String appStoreUrl = 'https://itunes.apple.com/us/app/app_id';
    if (await canLaunch(appStoreUrl)) {
      await launch(appStoreUrl);
    } else {
      throw 'Could not launch $appStoreUrl';
    }
  }

  logout_android_device(context, deviceid) async {
    var res = await android_logout(deviceid);

    print('deviceid: $deviceid');

    if (res['status'] == 1) {
      print('logoutDevice: ${res['message']}');
      showCustomToast(res['message']);
    } else {
      showCustomToast(res['message']);
    }
  }

  List<Choice> getFilteredChoices() {
    if (Platform.isIOS) {
      return is_premium_active_ios
          ? allChoices
          : allChoices.where((choice) => choice.id != '16').toList();
    } else {
      return is_premium_active_android
          ? allChoices
          : allChoices.where((choice) => choice.id != '16').toList();
    }
  }

  Widget category() {
    return FutureBuilder(
      future: TickerFuture.complete(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Choice> filteredChoices = getFilteredChoices();
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: MediaQuery.of(context).size.aspectRatio * 4.0,
              crossAxisCount: 2,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredChoices.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              Choice record = filteredChoices[index];
              return GestureDetector(
                onTap: (() async {
                  GtmUtil.logScreenView(
                    record.title,
                    'more',
                  );
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  if (record.id == '1') {
                    constanst.redirectpage = "edit_profile";

                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                      return;
                    }
                    print("Current step before switch: ${constanst.step}");
                    switch (constanst.step) {
                      case 3:
                        showEmailDialog(context);
                        break;
                      case 5:
                        showInformationDialog(context);
                        break;
                      case 6:
                      case 7:
                      case 8:
                        categoryDialog(context);
                        break;
                      case 9:
                        addPostDialog(context);
                        break;
                      case 10:
                        addPostDialog(context);
                        break;
                      case 11:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Bussinessinfo(),
                          ),
                        );
                        break;
                      default:
                        print("Unexpected value: ${constanst.step}");
                        break;
                    }
                  } else if (record.id == '2') {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();

                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                      return;
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Managepost(),
                        ),
                      );
                    }

                    constanst.redirectpage = "Manage_Sell_Posts";
                  } else if (record.id == '3') {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();

                    constanst.redirectpage = "update_category";

                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                      return;
                    }
                    print("Current step before switch: ${constanst.step}");
                    switch (constanst.step) {
                      case 3:
                        showEmailDialog(context);
                        break;
                      case 5:
                        showInformationDialog(context);
                        break;
                      case 6:
                      case 7:
                      case 8:
                        categoryDialog(context);
                        break;
                      case 9:
                        addPostDialog(context);
                        break;
                      case 10:
                        addPostDialog(context);
                        break;
                      case 11:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UpdateCategoryScreen(),
                          ),
                        );
                        break;
                      default:
                        print("Unexpected value: ${constanst.step}");
                        break;
                    }
                  } else if (record.id == '5') {
                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Saved(),
                        ),
                      );
                    }
                  } else if (record.id == '6') {
                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const follower(
                            initialIndex: 0,
                          ),
                        ),
                      );
                    }
                  } else if (record.id == '7') {
                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductInterested(),
                        ),
                      );
                    }
                  } else if (record.id == '9') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Blog(),
                      ),
                    );
                  } else if (record.id == '10') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(3),
                      ),
                    );
                  } else if (record.id == '11') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Videos(),
                      ),
                    );
                  } else if (record.id == '12') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Tutorial_Videos(),
                      ),
                    );
                  } else if (record.id == '13') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Exhibition(),
                      ),
                    );
                  } else if (record.id == '14') {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();

                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                      return;
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Directory1(),
                          ));
                    }
                  } else if (record.id == '15') {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();

                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                      return;
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Exhibitor(),
                          ));
                    }
                  } else if (record.id == '16') {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();

                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                      return;
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const premum_member(),
                          ));
                    }
                  } else if (record.id == '17') {
                    GtmUtil.logScreenView(
                      'App_Share',
                      'App_Share',
                    );
                    shareApp(
                      url:
                          "https://play.google.com/store/apps/details?id=com.p4t.plastic4trade",
                    );
                  } else if (record.id == '18') {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();

                    constanst.redirectpage = "update_category";

                    if (pref.getBool('isWithoutLogin') == true) {
                      showLoginDialog(context);
                      return;
                    }
                    print("Current step before switch: ${constanst.step}");
                    switch (constanst.step) {
                      case 3:
                        showEmailDialog(context);
                        break;
                      case 5:
                        showInformationDialog(context);
                        break;
                      case 6:
                      case 7:
                      case 8:
                        GtmUtil.logScreenView(
                          'Premium_Plan_Click',
                          'Premium_Plan_Click',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Premiun(),
                          ),
                        );
                        break;
                      case 9:
                        GtmUtil.logScreenView(
                          'Premium_Plan_Click',
                          'Premium_Plan_Click',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Premiun(),
                          ),
                        );
                        break;
                      case 10:
                        GtmUtil.logScreenView(
                          'Premium_Plan_Click',
                          'Premium_Plan_Click',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Premiun(),
                          ),
                        );
                        break;
                      case 11:
                        GtmUtil.logScreenView(
                          'Premium_Plan_Click',
                          'Premium_Plan_Click',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Premiun(),
                          ),
                        );
                        break;
                      default:
                        print("Unexpected value: ${constanst.step}");
                        break;
                    }
                  }
                }),
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13.05),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          record.icon,
                          height: 36,
                          fit: BoxFit.fill,
                        ),
                        5.sbh,
                        Text(
                          record.title,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> _refreshData() async {
    clear();
    await getProfiless();
    print('refresh data: $username $image_url $business_name');
    await getSocialMedia();
  }

  getProfiless() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getbussinessprofile(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
      pref.getString('user_id').toString(),
      context,
    );

    print('getbussinessprofile responce: $res');

    if (res['status'] == 1) {
      username = res['user']['username'] ?? '';
      if (res['is_plan_active'] != null) {
        is_premium_active_android = res['is_plan_active'];
        print('Is Premium Active Android: $is_premium_active_android');
      }
      if (res['is_plan_active_ios'] != null) {
        is_premium_active_ios = res['is_plan_active_ios'];
        print('Is Premium Active Ios: $is_premium_active_ios');
      }
      if (res['profile'] != null) {
        business_name = res['profile']['business_name'];
        crown_color = res['user']['crown_color'];
        image_url =
            res['user']['image_url'] ?? 'assets/plastic4trade logo final 1 (4)';
        pref.setString('userImage', image_url!).toString();
      }
      isload = true;
    } else {
      print('${res['message']}');
      showCustomToast(res['message']);
    }
    setState(() {});
  }

  getUnknownProfile() {
    username = "Unknown";
    business_name = "Unknown";
    isload = true;
    setState(() {});
  }

  getSocialMedia() async {
    var res = await getSocialLinks();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String username = pref.getString('name').toString();
    if (res['status'] == 1) {
      whatsappUrl = res['result']['site_whatsapp_url'] +
          '?text=Hello, I am $username \n I Want to Know Regarding Plastic4Tade App.';
      facebookUrl = res['result']['site_facebook_url'];
      instagramUrl = res['result']['site_instagram_url'];
      linkedinUrl = res['result']['site_linkedin_url'];
      youtubeUrl = res['result']['site_youtube_url'];
      telegramUrl = res['result']['site_telegram_url'];
      twitterUrl = res['result']['site_twitter_url'];
      setState(() {});
    } else {}
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
