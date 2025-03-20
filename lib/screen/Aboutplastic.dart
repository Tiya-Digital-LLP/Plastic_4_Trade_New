// ignore_for_file: unused_local_variable, import_of_legacy_library_into_null_safe, prefer_typing_uninitialized_variables, non_constant_identifier_names, camel_case_types

import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../api/api_interface.dart';

class aboutplastic extends StatefulWidget {
  const aboutplastic({Key? key}) : super(key: key);

  @override
  State<aboutplastic> createState() => _aboutplasticState();
}

class _aboutplasticState extends State<aboutplastic> {
  bool? load;

  String? link;
  String? linkForIos;

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection Not Available');
    } else {
      get_aboutus();
    }
  }

  @override
  void initState() {
    super.initState();
    checknetowork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 0,
        title: const Text('About Us',
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
      body: load == true
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                Container(
                    height: 110,
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
                    child: Image.asset(
                      'assets/plastic4trade logo final.png',
                    )),
                Container(
                  decoration: ShapeDecoration(
                    color: AppColors.backgroundColor,
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
                  margin: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  child: Html(
                    data: Platform.isIOS ? linkForIos : link,
                    style: {
                      "p": Style(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.24,
                        fontFamily: 'Metropolis',
                      ),
                      "body": Style(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.24,
                        fontFamily: 'Metropolis',
                      ),
                    },
                    onLinkTap:
                        (String? url, Map<String, String> attributes, _) async {
                      if (url != null) {
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open the link')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ]))
          : Center(
              child: CustomLottieContainer(
                child: Lottie.asset(
                  'assets/loading_animation.json',
                ),
              ),
            ),
    );
  }

  Future<void> get_aboutus() async {
    var res = await getStaticPage();
    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        jsonArray = res['result'];
        link = jsonArray['staticDescription'];
        if (Platform.isIOS) {
          linkForIos = jsonArray['description_for_ios'];
        }
        load = true;
        if (mounted) {
          setState(() {});
        }
      } else {
        load = true;
      }
    } else {
      showCustomToast(res['message']);
    }
    return jsonArray;
  }
}
