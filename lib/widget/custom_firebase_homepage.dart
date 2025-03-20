import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/screen/blog/Blog.dart';
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/screen/buyer_seller/Buyer_sell_detail.dart';
import 'package:Plastic4trade/screen/chat/Chat.dart';
import 'package:Plastic4trade/screen/exhibition/Exhibition.dart';
import 'package:Plastic4trade/screen/Follower_Following.dart';
import 'package:Plastic4trade/screen/liveprice/Liveprice.dart';
import 'package:Plastic4trade/screen/video/Tutorial_Videos.dart';
import 'package:Plastic4trade/screen/video/Videos.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseInitializer {
  final BuildContext context;

  FirebaseInitializer(this.context);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _localNotification = FlutterLocalNotificationsPlugin();

  final _androidchannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notification',
      description: 'This channel is used for importance notification',
      importance: Importance.high);

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(); // Initialize Firebase

    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // Initialize SharedPreferences

    final firebaseMessaging = FirebaseMessaging.instance;

    if (Platform.isAndroid) {
      await firebaseMessaging.requestPermission();

      // Current date
      DateTime now = DateTime.now();

      // Retrieve the last token refresh date from SharedPreferences
      String? lastRefreshDateString = prefs.getString('lastTokenRefresh');
      DateTime? lastRefreshDate;
      if (lastRefreshDateString != null) {
        lastRefreshDate = DateTime.parse(lastRefreshDateString);
      }

      String? FCMToken;
      if (lastRefreshDate == null ||
          now.difference(lastRefreshDate).inDays >= 2) {
        // Refresh token if 2 days have passed or no refresh has been done yet
        FCMToken = await firebaseMessaging.getToken(
          vapidKey:
              "BC4eLOdjJWopUE-NEu_WCFLlByPe5-K5_AljnUINqx4QL7RmA3W5lC-__7WDfEWPJF0nVk05xpD3d4JjdrGnfVA",
        );

        print('FCM Token refreshed: $FCMToken');
        constanst.fcm_token = FCMToken.toString();

        // Save the current date as the last token refresh date
        await prefs.setString('lastTokenRefresh', now.toIso8601String());
      } else {
        print('Token refresh not needed yet.');
        FCMToken = await firebaseMessaging.getToken(); // Fetch current token
      }

      // Listen for Firebase-triggered token refreshes
      firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('Refreshed FCM Token: $newToken');
        constanst.fcm_token = newToken;

        // Update last refresh time
        prefs.setString('lastTokenRefresh', DateTime.now().toIso8601String());
      });

      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isIOS) {
      await firebaseMessaging.requestPermission();

      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      String? APNSToken;
      // Use the same 2-day logic for iOS as well
      DateTime now = DateTime.now();
      String? lastRefreshDateString = prefs.getString('lastTokenRefresh_iOS');
      DateTime? lastRefreshDate;
      if (lastRefreshDateString != null) {
        lastRefreshDate = DateTime.parse(lastRefreshDateString);
      }

      if (lastRefreshDate == null ||
          now.difference(lastRefreshDate).inDays >= 2) {
        // Refresh the APNS token if necessary
        APNSToken = await firebaseMessaging.getToken();
        print('APNS Token refreshed: $APNSToken');
        constanst.APNSToken = APNSToken.toString();

        // Save the current date as the last refresh date for iOS
        await prefs.setString('lastTokenRefresh_iOS', now.toIso8601String());
      } else {
        print('APNS token refresh not needed yet.');
        APNSToken = await firebaseMessaging.getToken();
      }

      // Listen for token refresh on iOS
      firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('Refreshed APNS Token: $newToken');
        constanst.APNSToken = newToken;

        // Update last refresh date
        prefs.setString(
            'lastTokenRefresh_iOS', DateTime.now().toIso8601String());
      });
    }
    if (FirebaseMessaging.instance.isAutoInitEnabled) {
    } else {}
    FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');

    const IOSInitializationSettings initializationSettingsios =
        IOSInitializationSettings(
      defaultPresentBadge: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsios);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        print("${payload}");
        // ignore: unnecessary_non_null_assertion
        final message = RemoteMessage.fromMap(jsonDecode(payload));
        String notificationType = message.data['type'];
        String userId = message.data['user_id'] ?? "";
        String postType = message.data['post_type'] ?? '';
        String postId = message.data['postId'] ?? '';

        switch (notificationType) {
          case "chat_notification":
            print("call notification on homepage");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Chat()));
            break;

          case "profile like":
          case "profile_view":
          case "Business profile dislike":
            if (userId.isNotEmpty) {
              try {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => bussinessprofile(int.parse(userId)),
                  ),
                );
              } catch (e) {
                print("Error navigating to profile: $e");
              }
            }
            break;

          case "profile_review":
            try {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          bussinessprofile(int.parse(userId))));
            } catch (e) {}
            break;

          case "follower_profile_like":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => bussinessprofile(
                        int.parse(constanst.notiuser.toString()))));
            break;

          case "post_view":
          case "post like":
          case "product_post":
            if (postType == "SalePost" && postId.isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Buyer_sell_detail(
                          post_type: postType, prod_id: postId)));
            } else if (postType == "BuyPost" && postId.isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Buyer_sell_detail(
                          post_type: postType, prod_id: postId)));
            }
            break;

          case "unfollowuser":
          case "followuser":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const follower(
                          initialIndex: 0,
                        )));
            break;

          case "live_price":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LivepriceScreen()));
            break;

          case "quick_news_notification":
          case "news":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MainScreen(3)));
            break;

          case "blog":
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Blog()));
            break;

          case "video":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Videos()));
            break;

          case "banner":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MainScreen(0)));
            break;

          case "tutorial_video":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Tutorial_Videos()));
            break;

          case "exhibition":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Exhibition()));
            break;

          case "quicknews":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MainScreen(3)));
            break;

          default:
            print("Unknown notification type: $notificationType");
        }
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {}
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        String userId = message.data['user_id'];
        String type = message.data['type'];

        switch (type) {
          case "chat_notification":
            print("call notification");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Chat()));
            break;

          case "profile like":
          case "profile_view":
            try {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          bussinessprofile(int.parse(userId.toString()))));
            } catch (e) {}
            break;

          case "profile_review":
            try {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          bussinessprofile(int.parse(userId))));
            } catch (e) {}
            break;

          case "follower_profile_like":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => bussinessprofile(
                        int.parse(constanst.notiuser.toString()))));
            break;

          case "Business profile dislike":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => bussinessprofile(
                        int.parse(constanst.notiuser.toString()))));
            break;

          case "post like":
          case "product_post":
          case "post_view":
            if (message.data['post_type'] == "SalePost" &&
                message.data['postId'].toString().isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Buyer_sell_detail(
                          post_type: 'post_type',
                          prod_id: message.data['postId'])));
            } else if (message.data['post_type'] == "BuyPost" &&
                message.data['postId'].toString().isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Buyer_sell_detail(
                          post_type: 'post_type',
                          prod_id: message.data['postId'])));
            }
            break;

          case "unfollowuser":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const follower(initialIndex: 0)));
            break;

          case "followuser":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const follower(initialIndex: 0)));
            break;

          case "live_price":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LivepriceScreen()));
            break;

          case "quick_news_notification":
          case "news":
          case "quicknews":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MainScreen(3)));
            break;

          case "blog":
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Blog()));
            break;

          case "video":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Videos()));
            break;

          case "banner":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MainScreen(0)));
            break;

          case "tutorial_video":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Tutorial_Videos()));
            break;

          case "exhibition":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Exhibition()));
            break;

          default:
            print("Unknown notification type");
            break;
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      //_context=context;
      final notification = message.notification;
      if (notification == null) return;
      final localNotificationImplementation =
          _localNotification.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (localNotificationImplementation != null) {
        localNotificationImplementation
            .createNotificationChannel(_androidchannel);
      }
      _localNotification.show(
        notification.hashCode,
        notification.title ?? '',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidchannel.id, // Provide a default value
            _androidchannel.name, // Provide a default value
            channelDescription:
                _androidchannel.description ?? 'Default Channel Description',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            styleInformation: const DefaultStyleInformation(true, true),
            icon: '@drawable/ic_launcher',
          ),
          iOS: const IOSNotificationDetails(),
        ),
        payload: jsonEncode(message.toMap()),
      );
      AndroidNotification? notification1 = message.notification?.android;
      if (notification1 != null) {}
    });
  }
}
