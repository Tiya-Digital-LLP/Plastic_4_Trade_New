import 'dart:convert';
import 'dart:io';

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  bool? load;

  String? link;

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      getPrivacyPolicy();
    }
  }

  @override
  void initState() {
    super.initState();
    checknetowork();
  }

  @override
  Widget build(BuildContext context) {
    return init();
  }

  Widget init() {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          elevation: 0,
          title: const Text('Privacy Policy',
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
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.blackColor,
            ),
          ),
        ),
        body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: load == true
                ? Column(children: [
                    Container(
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        width: MediaQuery.of(context).size.width,
                        margin:
                            const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                        height: 150,
                        child: Image.asset(
                          'assets/plastic4trade logo final.png',
                        )),
                    Container(
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        width: MediaQuery.of(context).size.width,
                        margin:
                            const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Html(
                            data: link,
                            style: {
                              "p": Style(
                                fontSize: FontSize(12),
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.24,
                                fontFamily: 'Metropolis',
                              ),
                              "body": Style(
                                fontSize: FontSize(12),
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.24,
                                fontFamily: 'Metropolis',
                              ),
                            },
                          ),
                        )),
                  ])
                : Center(
                    child: CustomLottieContainer(
                      child: Lottie.asset(
                        'assets/loading_animation.json',
                      ),
                    ),
                  )));
  }

  Future<void> getPrivacyPolicy() async {
    var res = await getAppPrivacyPolicy();

    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');
        jsonArray = res['result'];

        link = jsonArray['staticDescription'];

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
