// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_dot_loader.dart';
import 'package:Plastic4trade/widget/Tutorial_Videos_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ContactUs.dart';

class Adwithus extends StatefulWidget {
  const Adwithus({Key? key}) : super(key: key);

  @override
  State<Adwithus> createState() => _AdwithusState();
}

class Choice {
  const Choice(
      {required this.title,
      required this.type,
      required this.price,
      required this.size,
      required this.icon});

  final String title;
  final String type;
  final String price;
  final String size;
  final String icon;
}

const List<Choice> choices = <Choice>[
  Choice(
      title: 'Homepage Banner Advertisement',
      type: 'Image or Video',
      price: '₹25000/- Per Month',
      size: '360 * 162',
      icon: 'assets/adWithUs1.jpg'),
  Choice(
      title: 'Pop-up Banner Advertisement',
      type: 'Image',
      price: '₹50000/- Per Month',
      size: '350 * 350',
      icon: 'assets/adWithUs2.jpg'),
  Choice(
      title: 'Paid Post',
      type: 'Image',
      price: '₹5000/- Per Month',
      size: '168 * 250',
      icon: 'assets/adWithUs3.png'),
  Choice(
      title: 'Notification Ads',
      type:
          'Send Notifications to All Users or Customize Users with Locations in terms of Sale Post, Buy Post, Company Promotions, and Any other type of Notification ad.',
      price: '₹3000/- Per Notification',
      size: '',
      icon: 'assets/adWithUs4.jpg'),
  Choice(
      title: 'Email, WhatsApp, SMS Marketing to Users',
      type:
          'Send Email, WhatsApp, SMS to All Users or Customize Users with Locations in terms of Sale Post, Buy Post, Company Promotions, and Any other type of Notification ad.',
      price: 'Customize As Per Requirement',
      size: '',
      icon: 'assets/adWithUs5.jpg'),
];

class _AdwithusState extends State<Adwithus> {
  String screen_id = "0";

  String title = 'AddwithUs';
  bool isButtonLoading = false;
  @override
  Widget build(BuildContext context) {
    return initwidget();
  }

  Widget initwidget() {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              'Advertise With Us',
              softWrap: false,
              style: TextStyle(
                fontSize: 20.0,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Metropolis',
              ),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.blackColor,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                  onTap: () {
                    showTutorial_Video(context, title);
                  },
                  child: Image.asset(
                    'assets/Play.png',
                    width: 40,
                    height: 40,
                  )),
            ),
          ],
        ),
        body: category());
  }

  Future<void> showTutorial_Video(BuildContext context, String title) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Tutorial_Videos_dialog(title, screen_id);
      },
    );
  }

  Widget category() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemCount: choices.length,
        itemBuilder: (context, index) {
          Choice record = choices[index];
          return Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                  ]),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      record.size.isNotEmpty
                          ? Container(
                              width: 112.68,
                              height: 228,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(13.05)),
                                  image: DecorationImage(
                                      image: AssetImage('assets/bgAd.jpg'),
                                      fit: BoxFit.cover)),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(13.05)),
                                  child: Image(
                                    image: AssetImage(record.icon),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: 134,
                              height: 152.11,
                              margin: EdgeInsets.only(
                                  top: 22, left: 10, bottom: 20, right: 6),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(record.icon),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.title,
                                style: const TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.24,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              record.size.isNotEmpty
                                  ? const SizedBox(
                                      height: 15,
                                      child: Text('Type:',
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: -0.24,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf'),
                                          maxLines: 2,
                                          softWrap: false))
                                  : SizedBox(),
                              Text(
                                record.type,
                                style: record.size.isNotEmpty
                                    ? const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.blackColor,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf')
                                    : TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 9,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.24,
                                      ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              record.size.isNotEmpty
                                  ? const Text(
                                      'Size:',
                                      style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.24,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf'),
                                    )
                                  : SizedBox(),
                              record.size.isNotEmpty
                                  ? Text(record.size,
                                      style: const TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.24,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf'))
                                  : SizedBox(),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                'Price:',
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf'),
                              ),
                              Text(record.price,
                                  style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.24,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf')),
                            ],
                          ),
                        ),
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(50.0),
                      color: AppColors.primaryColor,
                    ),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return TextButton(
                          onPressed: isButtonLoading
                              ? null
                              : () async {
                                  setState(
                                    () {
                                      isButtonLoading = true;
                                    },
                                  );

                                  try {
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();

                                    String device =
                                        Platform.isAndroid ? 'android' : 'ios';
                                    print('Device Name: $device');

                                    var result = await contactUsBtnClick(
                                      pref.getString('user_id').toString(),
                                      record.title,
                                      device,
                                    );

                                    print('Contact us: $result');

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ContactUs(),
                                      ),
                                    );
                                  } catch (e) {
                                    print('Error occurred: $e');
                                  } finally {
                                    setState(() {
                                      isButtonLoading =
                                          false; // Stop showing loader
                                    });
                                  }
                                },
                          child: isButtonLoading
                              ? Center(
                                  child: CustomDotLoader(
                                    child: Lottie.asset(
                                      'assets/Dot_Lottie.json',
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Contact us',
                                  style: TextStyle(
                                    fontSize: 19.0,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.backgroundColor,
                                    fontFamily:
                                        'assets/fonts/Metropolis-Black.otf',
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ]));
        });
  }
}
