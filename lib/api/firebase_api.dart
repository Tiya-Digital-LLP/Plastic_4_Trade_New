// ignore_for_file: unnecessary_null_comparison, non_constant_identifier_names, use_build_context_synchronously, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:Plastic4trade/screen/Follower_Following.dart';
import 'package:Plastic4trade/screen/Review.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/screen/post/ManagePost.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/blog/Blog.dart';
import '../screen/buisness_profile/BussinessProfile.dart';
import '../screen/buyer_seller/Buyer_sell_detail.dart';
import '../screen/chat/Chat.dart';
import '../screen/exhibition/Exhibition.dart';
import '../screen/liveprice/Liveprice.dart';
import '../screen/video/Tutorial_Videos.dart';
import '../screen/video/Videos.dart';
import '../widget/MainScreen.dart';

class FirebaseApi {
  final _androidchannel = const AndroidNotificationChannel(
      'high_impotance_channel', 'High Importance Notification',
      description: 'This channel is used for importance notification',
      importance: Importance.defaultImportance);
  final _localNotification = FlutterLocalNotificationsPlugin();
  final BuildContext context;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  FirebaseApi(this.context, this.navigatorKey) {
    initNotification(context);
  }
  //late BuildContext _context;

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    try {
      final data = message.data;
      if (data != null) {
        await notification_redirect(data, context);
      }
    } catch (e) {
      print("Error handling background message: $e");
    }
  }

  Future<void> initPushNotification(BuildContext context, String device) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened from background: ${message.data}');
      notification_redirect(message.data, context);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification == null) return;

      print(
          'Notification received: ${notification.title}, ${notification.body}');
      print('Notification data: ${message.data}');

      await _localNotification.show(
        notification.hashCode,
        notification.title ?? 'Notification',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidchannel.id,
            _androidchannel.name,
            channelDescription: _androidchannel.description,
            importance: Importance.max,
            priority: Priority.high,
            additionalFlags: Int32List.fromList(<int>[4]),
            playSound: true,
            styleInformation: const DefaultStyleInformation(true, true),
            icon: '@drawable/ic_launcher',
          ),
          iOS: const IOSNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        notification_redirect(message.data, context);
      }
    });
  }

  Future<void> initNotification(BuildContext context) async {
    await Firebase.initializeApp();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    if (Platform.isAndroid || Platform.isIOS) {
      await firebaseMessaging.requestPermission();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DateTime now = DateTime.now();

      String? lastRefreshDateString = prefs.getString('lastTokenRefresh');
      DateTime? lastRefreshDate = lastRefreshDateString != null
          ? DateTime.tryParse(lastRefreshDateString)
          : null;

      String? token = prefs.getString('fcmToken');

      if (lastRefreshDate == null ||
          now.difference(lastRefreshDate).inDays >= 2 ||
          token == null) {
        token = await firebaseMessaging.getToken();
        if (token != null) {
          await prefs.setString('fcmToken', token);
          await prefs.setString('lastTokenRefresh', now.toIso8601String());
          print('FCM Token refreshed and saved: $token');
        }
      } else {
        print('Using stored FCM Token: $token');
      }

      firebaseMessaging.onTokenRefresh.listen((String newToken) async {
        if (newToken.isNotEmpty) {
          await prefs.setString('fcmToken', newToken);
          await prefs.setString(
              'lastTokenRefresh', DateTime.now().toIso8601String());
          print('Refreshed and saved FCM Token: $newToken');
        }
      });

      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      String device = Platform.isAndroid ? 'android' : 'ios';
      print('Device Name: $device');
      await initPushNotification(context, device);
      await initLocalNotification(context);
    }
  }

  show_notification(String? title, String? body, Map<String, dynamic> data) {}

  Future<void> notification_redirect(
      Map<String, dynamic> data, BuildContext context) async {
    String notification_type = data['type'] ?? '';
    String post_type = data['post_type'] ?? '';
    String user_id = data['user_id'] ?? '';
    String post_id = data['postId'] ?? '';

    // Function to navigate to the actual screen after a delay
    void navigateToScreen(Widget screen) {
      Future.delayed(Duration(milliseconds: 500), () {
        navigatorKey.currentState!
            .push(MaterialPageRoute(builder: (context) => screen));
      });
    }

    switch (notification_type) {
      case "chat_notification":
        navigateToScreen(Chat());
        break;
      case "profile_view":
      case "profile like":
      case "Business profile dislike":
      case "profile_favorite":
      case "profile_share":
        if (user_id.isNotEmpty) {
          print('notification_tap');
          navigateToScreen(bussinessprofile(int.parse(user_id)));
        }
        break;
      case "profile_review":
        navigateToScreen(Review(user_id));
        break;
      case "follower_profile_like":
        if (user_id.isNotEmpty) {
          navigateToScreen(bussinessprofile(int.parse(user_id)));
        }
        break;
      case "post like":
      case "product_post":
      case "post_view":
      case "post_share":
        if (post_id.isNotEmpty) {
          navigateToScreen(
              Buyer_sell_detail(post_type: post_type, prod_id: post_id));
        }
        break;
      case "followuser":
      case "unfollowuser":
        navigateToScreen(const follower(initialIndex: 0));
        break;

      case "post_rejected":
        navigateToScreen(Managepost());
        break;

      case "live_price":
        navigateToScreen(const LivepriceScreen());
        break;
      case "quick_news_notification":
      case "news":
      case "quicknews":
        navigateToScreen(MainScreen(3));
        break;
      case "blog":
        navigateToScreen(const Blog());
        break;
      case "video":
        navigateToScreen(const Videos());

        break;
      case "banner":
        navigateToScreen(MainScreen(0));
        break;
      case "tutorial_video":
        navigateToScreen(const Tutorial_Videos());
        break;
      case "exhibition":
        navigateToScreen(const Exhibition());
        break;
      case "plan_list":
        navigateToScreen(Premiun());
        break;
      default:
        break;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notificationData', jsonEncode(data));
  }

  GlobalKey scaffoldKey = GlobalKey();

  Future initLocalNotification(context) async {
    const iOS = IOSInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const setting = InitializationSettings(android: android, iOS: iOS);
    await _localNotification.initialize(
      setting,
    );
    final platform = _localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidchannel);
  }

  @pragma('vm:entry-point')
  Future<String> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    await _handleMessage(initialMessage);

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    constanst.notificationtype = initialMessage?.data['type'] ?? '';
    constanst.notiuser = initialMessage?.data['user_id'] ?? '';
    constanst.notipostid = initialMessage?.data['postId'] ?? '';
    constanst.notypost_type = initialMessage?.data['post_type'] ?? '';

    if (initialMessage != null) {
      String notificationType = initialMessage.data['type'] ?? '';

      switch (notificationType) {
        case "chat_notification":
          navigatorKey.currentState!
              .push(MaterialPageRoute(builder: (context) => Chat()));
          break;
        case "profile_view":
        case "profile like":
        case "Business profile dislike":
        case "profile_favorite":
        case "profile_share":
        case "profile_review":
          String userId = initialMessage.data['user_id'] ?? '';
          if (userId.isNotEmpty) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => bussinessprofile(
                  int.parse(userId),
                ),
              ),
            );
          }
          break;

        case "follower_profile_like":
          navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (context) =>
                  bussinessprofile(int.parse(constanst.notiuser))));
          break;
        case "post like":
        case "product_post":
        case "post_view":
        case "post_share":
          String postType = initialMessage.data['post_type'] ?? '';
          String postId = initialMessage.data['postId'] ?? '';
          if (postType == "SalePost" || postType == "BuyPost") {
            navigatorKey.currentState!.push(MaterialPageRoute(
                builder: (context) =>
                    Buyer_sell_detail(post_type: postType, prod_id: postId)));
          }
          break;
        case "followuser":
        case "unfollowuser":
          navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (context) => const follower(initialIndex: 0)));
          break;
        case "post_rejected":
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => Managepost(),
            ),
          );
          break;
        case "live_price":
          navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => const LivepriceScreen()));
          break;
        case "quick_news_notification":
        case "news":
        case "quicknews":
          navigatorKey.currentState!
              .push(MaterialPageRoute(builder: (context) => MainScreen(3)));
          break;
        case "blog":
          navigatorKey.currentState!
              .push(MaterialPageRoute(builder: (context) => const Blog()));
          break;
        case "video":
          navigatorKey.currentState!
              .push(MaterialPageRoute(builder: (context) => const Videos()));
          break;
        case "banner":
          navigatorKey.currentState!
              .push(MaterialPageRoute(builder: (context) => MainScreen(0)));
          break;
        case "tutorial_video":
          navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => const Tutorial_Videos()));
          break;
        case "exhibition":
          navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => const Exhibition()));
          break;
        case "plan_list":
          navigatorKey.currentState!
              .push(MaterialPageRoute(builder: (context) => const Premiun()));
          break;
        default:
          break;
      }
    }
    return initialMessage!.data.toString();
  }

  static Future _handleMessage(RemoteMessage? message) async {
    return 3;
  }
}
