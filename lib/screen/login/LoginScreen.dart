// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, deprecated_member_use

import 'dart:io' show Platform;

import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/main.dart';
import 'package:Plastic4trade/screen/forgotpassword/ForgetPassword.dart';
import 'package:Plastic4trade/screen/login/device_id.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/edit_text_password_login.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:Plastic4trade/widget/edittext.dart';
import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_interface.dart';
import '../../api/firebase_api.dart';
import '../../model/Login.dart';
import '../../utill/constant.dart';
import '../register/RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userpass = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String device_name = '';
  final _formKey = GlobalKey<FormState>();
  String notificationMessge = 'Notification Waiting';
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Login login = Login();
  bool _isloading = false;
  BuildContext? dialogContext;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (!kIsWeb) {
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
      } else if (Platform.isIOS) {
        await Firebase.initializeApp();
      }
    }
  }

  void _trackLoginButtonPressed() {
    LoginScreen.analytics.logEvent(
      name: 'login_button_pressed',
      parameters: {
        'button_id': 'login_button',
        'time_stamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      device_name = 'android';
    } else if (Platform.isIOS) {
      device_name = 'ios';
    }
    init(context);
    return initwidget();
  }

  Future<bool> _onbackpress(BuildContext context) async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      showDialog(
          context: context,
          builder: (context) {
            return CommanDialog(
              title: "App",
              content: "Do You Want Exit App?",
              onPressed: () {
                SystemNavigator.pop();
              },
            );
          });
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(true);
  }

  Widget initwidget() {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _onbackpress(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SafeArea(
                    top: true,
                    left: true,
                    right: true,
                    maintainBottomViewPadding: true,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              'assets/plastic4trade logo final.png',
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 170,
                            )),
                        Text('Hello Again!',
                            style: TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily:
                                    'assets/fonst/Metropolis-Black.otf')),
                        Text('Log in into your account',
                            style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                            )),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 10.0),
                          child: EditText(
                            controller: emailController,
                            label: 'Enter Your Email/mobile',
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: EditTextPasswordLogin(
                            controller: _userpass,
                            label: 'Enter Your Password',
                          ),
                        ),
                        Center(
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgetPasswprd()));
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf',
                                    color: AppColors.primaryColor),
                              )),
                        ),
                        CustomButton(
                          buttonText: 'Login',
                          onPressed: () async {
                            final connectivityResult =
                                await Connectivity().checkConnectivity();
                            if (connectivityResult == ConnectivityResult.none) {
                              showCustomToast('Net Connection not available');
                            } else {
                              if (_formKey.currentState!.validate()) {
                                _trackLoginButtonPressed();
                                print(
                                    'login button with firebase: ${_trackLoginButtonPressed}');

                                print('login_button_pressed:  ');
                              }
                              setState(() {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                vaild_data();
                              });
                            }
                          },
                          isLoading: _isloading,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don' r"'" 't have an account?',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Register()));
                              },
                              child: const Text('Create an account',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryColor,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf',
                                  )),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: (Platform.isAndroid)
                          ? Container()
                          : Center(
                              child: TextButton(
                                  onPressed: () async {
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();
                                    constanst.isWithoutLogin = true;
                                    pref.setBool('isWithoutLogin', true);
                                    setState(() {});
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MainScreen(0)));
                                  },
                                  child: Text(
                                    'Skip',
                                    style: TextStyle(
                                        fontSize: 13.0,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf',
                                        color: AppColors.primaryColor
                                            .withOpacity(0.5)),
                                  )),
                            )),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Image.asset(
                        'assets/image 2.png',
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

  Future<void> init(BuildContext context) async {
    await FirebaseApi(context, navigatorKey).initNotification(context);
  }

  setlogin() async {
    setState(() {
      _isloading = true;
    });
    await saveDeviceId();

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    var res = await login_user(
      device_name,
      emailController.text.toString(),
      _userpass.text.toString(),
      deviceId ?? '',
    );

    print("deviceId: ${deviceId}");

    if (res['status'] == 1) {
      login = Login.fromJson(res);
      showCustomToast(res['message']);
      SharedPreferences pref = await SharedPreferences.getInstance();
      constanst.isWithoutLogin = false;
      pref.setBool('isWithoutLogin', false);
      setState(() {});
      constanst.userToken = login.result!.userToken.toString();
      constanst.userid = login.result!.userid.toString();
      constanst.step = login.result!.stepCounter!;
      constanst.image_url = login.result!.userImage.toString();
      init(context);

      print('device name from login: $device_name');
      if (Platform.isAndroid) {
        const androidId = AndroidId();
        constanst.android_device_id = (await androidId.getId())!;
        // add_android_device();
      } else if (Platform.isIOS) {
        final iosinfo = await deviceInfo.iosInfo;
        constanst.devicename = iosinfo.name;
        constanst.ios_device_id = iosinfo.identifierForVendor!;
        // add_ios_device();
      }
    } else {
      setState(() {
        _isloading = false;
      });
      showCustomToast(res['message']);
    }
  }

  // Future<bool> add_android_device() async {
  //   try {
  //     var res = await androidDevice_Register();
  //     if (res['status'] == 1) {
  //       constanst.usernm = emailController.text.toString();
  //       SharedPreferences pref = await SharedPreferences.getInstance();
  //       await pref.setString('user_id', login.result!.userid.toString());
  //       await pref.setString('name', login.result!.userName.toString());
  //       await pref.setString('email', login.result!.email.toString());
  //       await pref.setString('phone', login.result!.phoneno.toString());
  //       await pref.setString('userToken', login.result!.userToken.toString());
  //       await pref.setString('step', login.result!.stepCounter.toString());
  //       await pref.setString('userImage', login.result!.userImage.toString());
  //       await pref.setBool('islogin', true);
  //       _isloading = true;

  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (BuildContext context) => MainScreen(0)),
  //         ModalRoute.withName('/'),
  //       );
  //     } else {
  //       _isloading = false;
  //     }
  //   } catch (e) {
  //     print('Error occurred while adding Android device: $e');
  //     _isloading = false;
  //   }
  //   return _isloading;
  // }

  // Future<bool> add_ios_device() async {
  //   bool _isloading = false;

  //   try {
  //     var res = await iosDevice_Register(

  //     );

  //     if (res['status'] == 1) {
  //       constanst.usernm = emailController.text.toString();

  //       SharedPreferences pref = await SharedPreferences.getInstance();
  //       await pref.setString('user_id', login.result!.userid.toString());
  //       await pref.setString('name', login.result!.userName.toString());
  //       await pref.setString('email', login.result!.email.toString());
  //       await pref.setString('phone', login.result!.phoneno.toString());
  //       await pref.setString('userToken', login.result!.userToken.toString());
  //       await pref.setString('step', login.result!.stepCounter.toString());
  //       constanst.step = login.result!.stepCounter!;
  //       await pref.setString('userImage', login.result!.userImage.toString());
  //       await pref.setBool('islogin', true);

  //       _isloading = true;
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => MainScreen(0)),
  //         ModalRoute.withName('/'),
  //       );
  //     } else {
  //       _isloading = false;
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //     _isloading = false;
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('An error occurred. Please try again.'),
  //     ));
  //   }

  //   return _isloading;
  // }

  vaild_data() {
    if (emailController.text.isNotEmpty && _userpass.text.isNotEmpty) {
      setlogin().then((value) {
        Navigator.of(dialogContext!).pop();
        setState(() {
          _isloading = false;
        });
        if (value != null) {
          if (value) {
            _isloading = false;
          } else {
            _isloading = false;
          }
        }
      });
    } else if (emailController.text.isEmpty && _userpass.text.isEmpty) {
      setState(() {
        _isloading = true; // Show loader if fields are empty
      });
      setState(() {});
    }

    if (emailController.text.isEmpty) {
      setState(() {
        showCustomToast('Please Enter Your Email or Mobile');
        _isloading = false;
      });
    } else if (_userpass.text.isEmpty) {
      setState(() {
        showCustomToast('Please Enter Your Password');
        _isloading = false;
      });
    } else if (_userpass.text.isNotEmpty) {}
  }
}
