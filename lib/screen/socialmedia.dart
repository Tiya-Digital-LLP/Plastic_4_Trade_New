// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:convert';
import 'dart:io' show GZipCodec, Platform;

import 'package:Plastic4trade/screen/buisness_profile/Bussinessinfo.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_interface.dart';

class socialmedia extends StatefulWidget {
  const socialmedia({Key? key}) : super(key: key);

  @override
  State<socialmedia> createState() => _socialmediaState();
}

class _socialmediaState extends State<socialmedia> {
  bool isprofile = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController instat = TextEditingController();
  TextEditingController facebook = TextEditingController();
  TextEditingController youtube = TextEditingController();
  TextEditingController twitter = TextEditingController();
  TextEditingController telegram = TextEditingController();
  TextEditingController linkdn = TextEditingController();
  BuildContext? dialogContext;
  bool _isloading1 = false;
  String crown_color = '';
  String plan_name = '';

  @override
  void initState() {
    checknetowork();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return initwidget();
  }

  Widget initwidget() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 0,
        title: const Text('Social Media URLs',
            softWrap: false,
            style: TextStyle(
              fontSize: 20.0,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'Metropolis',
            )),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.blackColor,
          ),
        ),
      ),
      body: isprofile
          ? SingleChildScrollView(
              child: Column(
              children: [
                Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(children: [
                          SafeArea(
                            top: true,
                            left: true,
                            right: true,
                            maintainBottomViewPadding: true,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      25.0, 20.0, 25.0, 5.0),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      border: Border.all(
                                          color: AppColors.black45Color),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          width: 50,
                                          child: Image.asset(
                                            'assets/instagram.png',
                                            height: 20,
                                            width: 25,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 3.0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              115,
                                          child: TextFormField(
                                            controller: instat,
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.blackColor,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf'),
                                            keyboardType: TextInputType.text,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  AppColors.backgroundColor,
                                              hintText:
                                                  "Copy & Paste Instagram URL",
                                              hintStyle: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.blackColor,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(
                                                      color: AppColors
                                                          .black45Color),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      25.0, 5.0, 25.0, 5.0),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      border: Border.all(
                                          color: AppColors.black45Color),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          width: 50,
                                          child: Image.asset(
                                            'assets/YouTube (1).png',
                                            height: 20,
                                            width: 15,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 3.0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              115,
                                          child: TextFormField(
                                            controller: youtube,
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.blackColor,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf'),
                                            keyboardType: TextInputType.text,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  AppColors.backgroundColor,
                                              hintText:
                                                  "Copy & Paste YouTube URL",
                                              hintStyle: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.blackColor,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(
                                                      color: AppColors
                                                          .black45Color),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      25.0, 5.0, 25.0, 5.0),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      border: Border.all(
                                          color: AppColors.black45Color),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          width: 50,
                                          child: Image.asset(
                                            'assets/Facebook (1).png',
                                            height: 20,
                                            width: 15,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 3.0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              115,
                                          child: TextFormField(
                                            controller: facebook,
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.blackColor,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf'),
                                            keyboardType: TextInputType.text,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  AppColors.backgroundColor,
                                              hintText:
                                                  "Copy & Paste Facebook URL",
                                              hintStyle: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.blackColor,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(
                                                      color: AppColors
                                                          .black45Color),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      25.0, 5.0, 25.0, 5.0),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      border: Border.all(
                                          color: AppColors.black45Color),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          width: 50,
                                          child: Image.asset(
                                            'assets/LinkedIn.png',
                                            height: 20,
                                            width: 25,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 3.0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              115,
                                          child: TextFormField(
                                            controller: linkdn,
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.blackColor,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf'),
                                            keyboardType: TextInputType.text,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  AppColors.backgroundColor,
                                              hintText:
                                                  "Copy & Paste LinkedIn URL",
                                              hintStyle: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.blackColor,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(
                                                      color: AppColors
                                                          .black45Color),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      25.0, 5.0, 25.0, 5.0),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      border: Border.all(
                                          color: AppColors.black45Color),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Image.asset(
                                            'assets/xIcon.jpg',
                                            height: 28,
                                            width: 28,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 3.0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              115,
                                          child: TextFormField(
                                            controller: twitter,
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.blackColor,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf'),
                                            keyboardType: TextInputType.text,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  AppColors.backgroundColor,
                                              hintText:
                                                  "Copy & Paste Twitter URL",
                                              hintStyle: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.blackColor,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(
                                                      color: AppColors
                                                          .black45Color),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      25.0, 5.0, 25.0, 5.0),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      border: Border.all(
                                          color: AppColors.black45Color),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          width: 50,
                                          child: Image.asset(
                                            'assets/Telegram.png',
                                            height: 20,
                                            width: 25,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 3.0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              115,
                                          child: TextFormField(
                                            controller: telegram,
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.blackColor,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf'),
                                            keyboardType: TextInputType.text,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  AppColors.backgroundColor,
                                              hintText:
                                                  "Copy & Paste Telegram URL",
                                              hintStyle: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.blackColor,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(
                                                      color: AppColors
                                                          .black45Color),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]),
                      ),
                    )
                  ],
                ),
              ],
            ))
          : Center(
              child: CustomLottieContainer(
              child: Lottie.asset(
                'assets/loading_animation.json',
              ),
            )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          buttonText: 'Update',
          onPressed: () async {
            // Dismiss keyboard and show loading indicator
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            setState(() {
              _isloading1 = true;
            });

            // Call the add_SocialProfile function
            bool isSuccess = await add_SocialProfile();

            setState(() {
              _isloading1 = false;
            });

            if (isSuccess) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Bussinessinfo()),
              );
            }
          },
          isLoading: _isloading1,
        ),
      ),
    );
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      isprofile = true;
    } else {
      getProfiless();
    }
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

    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      instat.text = res['profile']['instagram_link'] ?? "";
      youtube.text = res['profile']['youtube_link'] ?? "";
      facebook.text = res['profile']['facebook_link'] ?? "";
      linkdn.text = res['profile']['linkedin_link'] ?? "";
      twitter.text = res['profile']['twitter_link'] ?? "";
      telegram.text = res['profile']['telegram_link'] ?? "";
      isprofile = true;

      /*Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen(0),),);*/
    } else {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(res['message']);
    }

    setState(() {});
  }

  Future<bool> add_SocialProfile() async {
    setState(() {
      _isloading1 = true; // Show loader when starting the process
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';

    print('Device Name: $device');

    // API call to update social media profile
    var res = await updatesocialmedia(
      pref.getString('user_id') ?? '',
      pref.getString('userToken') ?? '',
      instat.text.trim(),
      youtube.text.trim(),
      facebook.text.trim(),
      linkdn.text.trim(),
      twitter.text.trim(),
      telegram.text.trim(),
      device,
    );

    setState(() {
      _isloading1 = false; // Stop loader after the process completes
    });

    // Show response message
    String message = res['message'] ?? 'An error occurred';
    showCustomToast(message);

    return res['status'] == 1;
  }
}
