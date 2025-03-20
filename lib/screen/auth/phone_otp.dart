import 'dart:async';
import 'dart:io';

import 'package:Plastic4trade/main.dart';
import 'package:Plastic4trade/model/login_v2.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_auth/smart_auth.dart';

class PhoneOtp extends StatefulWidget {
  final String userId;
  final String phoneNo;
  final String countryCode;
  final String deviceId;

  const PhoneOtp({
    super.key,
    required this.userId,
    required this.phoneNo,
    required this.countryCode,
    required this.deviceId,
  });

  @override
  State<PhoneOtp> createState() => _PhoneOtpState();
}

class _PhoneOtpState extends State<PhoneOtp> {
  final TextEditingController _mblotp = TextEditingController();
  bool _isloading = false;
  final _formKey = GlobalKey<FormState>();
  String? deviceId;
  bool _isResendDisabled = true;
  int _start = 30;
  Timer? _timer;
  final smartAuth = SmartAuth();

  void getSmsCode() async {
    try {
      final res = await smartAuth.getSmsCode(useUserConsentApi: true);
      if (res.codeFound) {
        debugPrint('userConsent success: ${res.code}');
        // Autofill the TextField with the fetched code
        _mblotp.text = res.code!;
      } else {
        debugPrint('userConsent failed: ${res.toString()}');
        debugPrint('Code Found: ${res.codeFound}');
        debugPrint('SMS Received: ${res.sms}');
        debugPrint('Was it successful?: ${res.succeed}');
      }
    } catch (e) {
      debugPrint('Error occurred while getting SMS code: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    getSmsCode();
  }

  void startTimer() {
    setState(() {
      _isResendDisabled = true;
      _start = 30;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendDisabled = false;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> setResend() async {
    setState(() {
      _isloading = true;
    });

    try {
      var res = await login_resend_v2(
        widget.userId,
        widget.countryCode,
        widget.phoneNo,
      );

      print('countryCode: ${widget.countryCode}');
      print('phoneNo: ${widget.phoneNo}');

      setState(() {
        _isloading = false;
      });

      if (res['status'] == 1) {
        SharedPreferences _pref = await SharedPreferences.getInstance();
        await _pref.setString('user_id', res['user_id'].toString());
        await _pref.setString('phoneno', widget.phoneNo);
        await _pref.setString('countryCode', widget.countryCode);
        await _pref.setBool('islogin', true);
        await _pref.setBool('isWithoutLogin', false);

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
          await _pref.setString('device_id', deviceId!);
          print('Device ID saved: $deviceId');
        } else {
          print('Device ID is null.');
        }

        showCustomToast('OTP Resent Successfully on WhatsApp or Message');
        _mblotp.clear();
        startTimer();
      } else {
        showCustomToast('Mobile Field is required');
      }
    } catch (e) {
      setState(() {
        _isloading = false;
      });
    }
  }

  void _verifyPhoneOtp(String otp) async {
    if (otp.length != 4) return;

    String device = Platform.isAndroid ? 'android' : 'ios';
    setState(() {
      _isloading = true;
    });

    try {
      var res = await verifyPhone(
        widget.userId,
        device,
        widget.deviceId,
        widget.countryCode,
        widget.phoneNo,
        otp,
      );

      print('userId: ${widget.userId}');
      print('device: ${device}');
      print('deviceId: ${widget.deviceId}');
      print('countryCode: ${widget.countryCode}');
      print('phoneNo: ${widget.phoneNo}');
      print('otp: ${otp}');

      if (res['status'] == 1) {
        LoginV2 userResponse = LoginV2.fromJson(res);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', userResponse.userData.userToken);
        await prefs.setString(
            'step', userResponse.userData.stepCounter.toString());

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => MainScreen(0)),
          ModalRoute.withName('/'),
        );
        showCustomToast('Registration Successfully');

        print("User Token Saved: ${userResponse.userData.userToken}");
      } else {
        showCustomToast(res['message']);
      }
    } catch (e) {
      // showCustomToast('Error: $e');
      print('Error: $e');
    } finally {
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          child: Image.asset(
            'assets/back.png',
            height: 50,
            width: 60,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Otpverification.png',
                alignment: Alignment.topCenter,
                width: 100,
              ),
              25.sbh,
              Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                  fontFamily: 'assets/fonst/Metropolis-Black.otf',
                ),
              ),
              20.sbh,
              Text(
                'Enter OTP Sent To ${widget.countryCode} ${widget.phoneNo}',
                maxLines: 2,
                style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                        fontFamily: 'assets/fonst/Metropolis-Black.otf')
                    .copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.center,
              ),
              30.sbh,
              Pinput(
                controller: _mblotp,
                length: 4,
                onChanged: (pin) {
                  if (!_isloading) {
                    _verifyPhoneOtp(pin);
                  }
                },
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    color: Colors.blue,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Did’t Receive the OTP?',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackColor,
                      fontFamily: 'assets/fonst/Metropolis-Black.otf',
                    ),
                  ),
                  TextButton(
                    child: Text(_isResendDisabled
                        ? 'Resend OTP ($_start s)'
                        : 'Resend OTP'),
                    onPressed: _isResendDisabled ? null : setResend,
                  ),
                ],
              ),
              20.sbh,
              CustomButton(
                buttonText: 'Submit',
                onPressed: () {
                  if (_mblotp.text.length == 4 && !_isloading) {
                    _verifyPhoneOtp(_mblotp.text);
                  } else {
                    showCustomToast('Enter a valid OTP');
                  }
                },
                isLoading: _isloading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
