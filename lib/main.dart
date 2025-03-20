// @dart=2.19
// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';
import 'dart:io' show Platform;
import 'package:Plastic4trade/api/firebase_api.dart';
import 'package:Plastic4trade/screen/blog/BlogDetail.dart';
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/screen/buyer_seller/Buyer_sell_detail.dart';
import 'package:Plastic4trade/screen/exhibition/ExhitionDetail.dart';
import 'package:Plastic4trade/screen/liveprice/Liveprice.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/screen/news/NewsDetail.dart';
import 'package:Plastic4trade/screen/post/ManagePost.dart';
import 'package:Plastic4trade/screen/splash/splash_screen.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';

import 'package:android_id/android_id.dart';
import 'package:app_links/app_links.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utill/constant.dart';

final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        name: 'Plastic4Trade',
        options: const FirebaseOptions(
            apiKey: "AIzaSyCTqG3cUX04ACxu1U4tRhfTrI_odai_ZPY",
            appId: "1:929685037367:web:9b8d8a76c75d902292fab2",
            messagingSenderId: "929685037367",
            projectId: "plastic4trade-55372"));
  } else {
    if (Platform.isAndroid) {
      await Firebase.initializeApp();
      if (Platform.isAndroid) {
        const androidId = AndroidId();
        constanst.android_device_id = (await androidId.getId())!;
      }
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              sound: true, badge: true, alert: true);
      if (notification != null && android != null) {
        await _showNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
        );
      }
    } else if (Platform.isIOS) {
      await Firebase.initializeApp();
      if (Platform.isIOS) {
        final iosinfo = await deviceInfo.iosInfo;
        constanst.devicename = iosinfo.name;
        constanst.ios_device_id = iosinfo.identifierForVendor!;
      }
    }
  }
}

Future<void> _showNotification(
    {required String title, required String body}) async {}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('appOpenCount');
    int appOpenCount = await getAppOpenCount();
    print("appOpenCountd1 => $appOpenCount");
    saveAppOpenCount(appOpenCount);
  });
  runApp(MyApp());
}

Future<int> getAppOpenCount() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  constanst.appopencount = prefs.getInt('appOpenCount') ?? 1;
  return prefs.getInt('appOpenCount') ?? 0;
}

Future<void> saveAppOpenCount(int count) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('appOpenCount', count);
  print("appOpenCountd2 =>${prefs.getInt('appOpenCount')}");
}

Future<void> init(BuildContext context) async {
  await FirebaseApi(context, navigatorKey).initNotification(context);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('mipmap/ic_launcher');

  IOSInitializationSettings initializationSettingsios =
      const IOSInitializationSettings(
    defaultPresentBadge: true,
    defaultPresentAlert: true,
    defaultPresentSound: true,
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsios);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      if (payload != null) {}
    },
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri?>? _linkStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  Future<void> _initializeDeepLinks() async {
    _appLinks = AppLinks();

    final Uri? initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _navigateToScreen(initialLink);
    }

    _linkStreamSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _navigateToScreen(uri);
      }
    }, onError: (error) {
      print('Error receiving deep link: $error');
      showCustomToast('Error receiving deep link: $error');
    });
  }

  void _navigateToScreen(Uri link) {
    final String? screen = link.queryParameters['screen'];
    final String? data = link.queryParameters['data'];

    print('_navigateToScreenData: $data');
    print('_navigateToScreenType: $screen');

    Future.delayed(const Duration(seconds: 2), () {
      if (screen != null && screen.isNotEmpty) {
        if (data != null && data.isNotEmpty) {
          switch (screen) {
            case 'SalePost':
            case 'BuyPost':
              Navigator.push(
                navigatorKey.currentContext!,
                MaterialPageRoute(
                  builder: (context) => Buyer_sell_detail(
                    prod_id: data,
                    post_type: screen,
                  ),
                ),
              );
              break;

            case 'UserProfile':
              final String? userIdStr = data;

              if (userIdStr != null && userIdStr.isNotEmpty) {
                final int? userId = int.tryParse(userIdStr);

                if (userId != null) {
                  if (navigatorKey.currentContext != null) {
                    Navigator.push(
                      navigatorKey.currentContext!,
                      MaterialPageRoute(
                        builder: (context) => bussinessprofile(userId),
                      ),
                    );
                  } else {
                    print('Navigator context is null');
                  }
                } else {
                  print('Invalid userId: $data');
                }
              } else {
                print('Missing or empty userId: $data');
              }
              break;

            case 'News':
              final int? newsId = int.tryParse(data);
              if (navigatorKey.currentContext != null) {
                Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) =>
                        NewsDetail(news_id: newsId.toString()),
                  ),
                );
              } else {
                print('Invalid newsId: $data');
                showCustomToast('Invalid newsId: $data');
              }
              break;

            case 'Blog':
              final int? blogId = int.tryParse(data);
              if (navigatorKey.currentContext != null) {
                Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) =>
                        BlogDetail(blog_id: blogId.toString()),
                  ),
                );
              } else {
                print('Navigator context is null');
              }

              break;

            case 'Exhibition':
              final int? exhibitionId = int.tryParse(data);
              if (navigatorKey.currentContext != null) {
                Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExhitionDetail(blog_id: exhibitionId.toString()),
                  ),
                );
              } else {
                print('Invalid exhibitionId: $data');
              }
              break;

            case 'LivePrice':
              if (navigatorKey.currentContext != null) {
                Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) => const LivepriceScreen(),
                  ),
                );
              } else {
                print('Invalid LiveProce: $data');
              }
              break;

            default:
              print('Unknown screen type: $screen');
          }
        } else {
          print('Without Data for screen: $screen');
          switch (screen) {
            case 'plan_list':
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) => Premiun(),
                  ),
                );
              });
              break;
            case 'manage_sale_post':
            case 'manage_buy_post':
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) => Managepost(),
                  ),
                );
              });
              break;

            default:
              print('Unknown screen type: $screen');
          }
        }
      } else {
        print('Screen is missing in the link');
      }
    });
  }

  @override
  void dispose() {
    _linkStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    init(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.backgroundColor),
          ),
        ),
        colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
        primaryColor: AppColors.backgroundColor,
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: AppColors.backgroundColor),
        fontFamily: 'Metropolis',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          titleMedium: TextStyle(
              fontSize: 21.0,
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          titleSmall: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryColor,
              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          bodyMedium: TextStyle(
              fontSize: 15.0,
              fontFamily: 'assets/fonst/Metropolis-Black.otf',
              color: AppColors.primaryColor),
          bodySmall: TextStyle(
            fontSize: 15.0,
            color: AppColors.backgroundColor,
            fontFamily: 'assets/fonst/Metropolis-Black.otf',
          ),
          bodyLarge: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          displayLarge: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 0, 91, 148),
              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          displaySmall: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          displayMedium: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          headlineSmall: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          headlineMedium: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
              fontFamily: 'assets/fonst/Metropolis-SemiBold.otf'),
          labelSmall: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
        ),
        dialogTheme:
            DialogThemeData(backgroundColor: AppColors.backgroundColor),
      ),
      navigatorObservers: <NavigatorObserver>[MyApp.observer],
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: child!,
          ),
        );
      },
      home: SplashScreen(
        analytics: MyApp.analytics,
        observer: MyApp.observer,
      ),
    );
  }
}
