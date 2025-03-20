// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:Plastic4trade/model/active_plan_model.dart';
import 'package:Plastic4trade/screen/auth/email_name_registration.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/AddPost_dialog.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:flutter/material.dart';
import 'package:Plastic4trade/screen/chat/Chat.dart';
import 'package:Plastic4trade/screen/liveprice/Liveprice.dart';
import 'package:Plastic4trade/screen/notification/Notifications.dart';
import 'package:badges/badges.dart' as badges;
import 'package:Plastic4trade/utill/constant.dart';
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_interface.dart';
import 'BussinesPro_dialog.dart';
import 'Category_dialog.dart';
import 'Tutorial_Videos_dialog.dart';
import 'login_dialog.dart';

class CustomeApp extends StatefulWidget implements PreferredSizeWidget {
  String title = '';
  CustomeApp(this.title, {Key? key}) : super(key: key);

  @override
  State<CustomeApp> createState() => _CustomeAppState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _CustomeAppState extends State<CustomeApp> {
  String? assignedName;
  bool? load;
  bool availble = false;
  String link = "";
  String content = "";
  String screen_id = "0";
  List<String> videolist = [];
  List<String> videocontent = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    get_notification();
    get_videolistScreen();
  }

  @override
  void didUpdateWidget(covariant CustomeApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      get_videolistScreen();
    }
  }

  Future<void> get_videolistScreen() async {
    print('Fetching video list for: ${widget.title}');

    switch (widget.title) {
      case 'Home':
        screen_id = "1";
        break;
      case 'Seller':
      case 'Buyer':
        screen_id = "17";
        break;
      case 'News':
        screen_id = "2";
        break;
      case 'More':
        screen_id = "14";
        break;
      case 'Exhibition':
        screen_id = "5";
        break;
      case 'Directory':
        screen_id = "4";
        break;
      case 'PremiumMember':
        screen_id = "16";
        break;
      case 'Saved':
        screen_id = "8";
        break;
      case 'Videos':
        screen_id = "6";
        break;
      case 'Tutorial_Video':
        screen_id = "15";
        break;
      case 'ContactUs':
        screen_id = "7";
        break;
      case 'Exhibitor':
        screen_id = "10";
        break;
      case 'AddwithUs':
        screen_id = "9";
        break;
      case 'Chat':
        screen_id = "11";
        break;
      case 'Premium':
        screen_id = "18";
        break;
      case 'LivePrice':
        screen_id = "12";
        break;
      case 'ManagePost':
        screen_id = "3";
        break;
      case 'PhysicalBusinessDirectory':
        screen_id = "19";
        break;
      default:
        screen_id = "0";
        break;
    }

    print('Screen ID: $screen_id');

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }

    print('Device: $device');

    var res = await gettutorialvideo_screen(screen_id, device);
    print('Response get_videolistScreen: $res');

    if (res['status'] == 1) {
      if (res['result'] != null && res['result'] is List) {
        var jsonArray = res['result'];
        print('Video List Found: ${jsonArray.length} items');

        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));
        int sizeInBytes = compressedData.length;
        print('Compressed Data Size: $sizeInBytes bytes');

        videolist.clear();
        videocontent.clear();

        for (var data in jsonArray) {
          print('Processing video: ${data['title']}');

          String videoLink = data['video_link'] ?? "";

          if (videoLink.contains("watch?v=")) {
            link = videoLink.split("watch?v=").last;
          } else if (videoLink.contains("youtu.be/")) {
            link = videoLink.split("youtu.be/").last;
          } else {
            continue;
          }

          content = data['title'] ?? "";
          videolist.add(link);
          print("Video List Length: ${videolist.length}");

          videocontent.add(content);
        }

        load = true;
      } else if (res['result'] != null && res['result'] is Map) {
        var jsonArray = [res['result']];
        print('Single Video Found');

        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));
        int sizeInBytes = compressedData.length;
        print('Compressed Data Size: $sizeInBytes bytes');

        videolist.clear();
        videocontent.clear();

        String videoLink = jsonArray[0]['video_link'] ?? "";

        if (videoLink.contains("watch?v=")) {
          link = videoLink.split("watch?v=").last;
        } else if (videoLink.contains("youtu.be/")) {
          link = videoLink.split("youtu.be/").last;
        } else {
          print('Invalid video link format');
          return;
        }

        content = jsonArray[0]['title'] ?? "";
        videolist.add(link);
        videocontent.add(content);
        print("Video List Length: ${videolist.length}");

        load = true;
      } else {
        // Handle case where result is null
        videolist.clear();
        videocontent.clear();
        load = true; // Ensure UI updates
        print('No videos found.');
      }
    } else {
      showCustomToast(res['message']);
      print('Error: ${res['message']}');
    }

    setState(() {}); // Ensure UI updates
  }

  @override
  Widget build(BuildContext context) {
    print("AppBar Title: ${widget.title}");
    return myAppbar(widget.title, context);
  }

  Widget myAppbar(String title, context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (title == 'Home')
            Image.asset('assets/plastic4trade logo final.png',
                height: 50, width: MediaQuery.of(context).size.width / 2.9)
          else if (title == 'Seller')
            const Text('Sale Post',
                softWrap: false,
                style: TextStyle(
                  fontSize: 20.0,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Metropolis',
                )),
          if (title == 'Buyer')
            const Text('Buy Post',
                softWrap: false,
                style: TextStyle(
                  fontSize: 20.0,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Metropolis',
                )),
          if (title == 'News')
            const Text('News',
                softWrap: false,
                style: TextStyle(
                  fontSize: 20.0,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Metropolis',
                )),
          if (title == 'More')
            const Text('More',
                softWrap: false,
                style: TextStyle(
                  fontSize: 20.0,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Metropolis',
                )),
          if (title == 'Exhibition')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: AppColors.blackColor)),
                const Text('Exhibition',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'Directory')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Directory',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'PremiumMember')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Premium Member',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'Saved')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Saved',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'Product Interested')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Product Interested',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'User Interested')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('User Interested',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'Product Match')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Product Match',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'Videos')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Videos',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'Tutorial_Video')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                      size: 20,
                    )),
                const Text('Tutorial Video',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'ContactUs')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Contact Us',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'Exhibitor')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Exhibitor',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'LiveHome')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Live Seller & Buyer',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'LiveSeller')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Live Seller',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'LiveBuyer')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Live Buyer',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
          if (title == 'Subscription')
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.blackColor,
                    )),
                const Text('Subscription',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Metropolis',
                    )),
              ],
            ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (title != 'Videos' && videolist.isNotEmpty)
              GestureDetector(
                onTap: () {
                  showTutorial_Video(context, title, screen_id);
                },
                child: Image.asset(
                  'assets/Play.png',
                  width: 40,
                  height: 40,
                ),
              ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  constanst.redirectpage = "live_price";

                  if (constanst.isWithoutLogin == true) {
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
                            builder: (context) => const LivepriceScreen(),
                          ));
                      break;
                    default:
                      print("Unexpected value: ${constanst.step}");
                      break;
                  }
                },
                child: Image.asset(
                  'assets/homeprice.png',
                  width: 40,
                  height: 40,
                )),
            const SizedBox(
              width: 10,
            ),
            Align(
              child: GestureDetector(
                onTap: _handleTap,
                child: _isLoading
                    ? SizedBox(
                        width: 40,
                        height: 40,
                        child: CustomLottieContainer(
                          child: Lottie.asset(
                            'assets/loading_animation.json',
                          ),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.asset(
                            'assets/homemsg.png',
                            width: 40,
                            height: 40,
                          ),
                          if (constanst.chat_count > 0)
                            badges.Badge(
                              position:
                                  badges.BadgePosition.topEnd(top: 0, end: 3),
                              badgeStyle: const badges.BadgeStyle(
                                  badgeColor: AppColors.red),
                              badgeAnimation: const badges.BadgeAnimation.slide(
                                animationDuration: Duration(milliseconds: 300),
                              ),
                              badgeContent: Text(
                                constanst.chat_count.toString(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                GtmUtil.logScreenView(
                  'Notification_Screen',
                  'Notification',
                );
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const notification()))
                    .then((value) {
                  get_notification();
                });
              },
              child: Align(
                child: constanst.notification_count > 0
                    ? badges.Badge(
                        position: badges.BadgePosition.topEnd(top: 0, end: 3),
                        badgeStyle:
                            const badges.BadgeStyle(badgeColor: AppColors.red),
                        badgeAnimation: const badges.BadgeAnimation.slide(
                            animationDuration: Duration(milliseconds: 300)),
                        badgeContent: Text(
                            constanst.notification_count.toString(),
                            style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.backgroundColor)),
                        child: Image.asset(
                          'assets/Notification.png',
                          width: 40,
                          height: 40,
                        ),
                      )
                    : Image.asset(
                        'assets/Notification.png',
                        width: 40,
                        height: 40,
                      ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        )
      ],
    );
  }

  Future<void> _handleTap() async {
    GtmUtil.logScreenView('Messages', 'chat');

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String userId = pref.getString('user_id') ?? '';
      String userToken = pref.getString('userToken') ?? '';
      String device = Platform.isAndroid ? 'android' : 'ios';

      print('Device Name: $device');

      if (pref.getBool('isWithoutLogin') == true) {
        showLoginDialog(context);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print("Current step before switch: ${constanst.step}");

      bool handled = true;
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
        case 10:
          addPostDialog(context);
          break;
        case 11:
          await _redirectUser(userId, userToken, device);
          break;
        default:
          handled = false;
          break;
      }

      if (handled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _redirectUser(userId, userToken, device);
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _redirectUser(
      String userId, String userToken, String device) async {
    try {
      final ActivePlan? plan = await getactivePlan(userId, userToken, device);

      if (plan == null || plan.chat != 'YES') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Premiun()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Chat()),
        ).then((value) {
          get_notification();
        });
      }
    } catch (e) {
      print('An error occurred in _redirectUser: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    } else {
      showCustomToast(res['message']);
    }
    return res;
  }
}

Future<void> showEmailDialog(BuildContext context) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const EmailNameRegistration(),
  );
}

Future<void> showInformationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const BussinessPro_dialog();
    },
  );
}

Future<void> showLoginDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const LoginDialog();
    },
  );
}

Future<void> categoryDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Category_dialog();
    },
  );
}

Future<void> addPostDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AddPost_dialog();
    },
  );
}

Future<void> showTutorial_Video(
    BuildContext context, String title, String screenid) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return Tutorial_Videos_dialog(title, screenid);
    },
  );
}
