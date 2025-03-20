import 'dart:async';
import 'dart:io';

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/model/email_v2.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailOtp extends StatefulWidget {
  final String userId;
  final String userName;
  final String deviceId;
  final String device;
  final String email;
  final String userToken;

  const EmailOtp({
    super.key,
    required this.userId,
    required this.userName,
    required this.deviceId,
    required this.device,
    required this.email,
    required this.userToken,
  });

  @override
  State<EmailOtp> createState() => _EmailOtpState();
}

class _EmailOtpState extends State<EmailOtp> {
  final TextEditingController _emaillotp = TextEditingController();
  bool _isloading = false;
  final _formKey = GlobalKey<FormState>();

  bool _isResendDisabled = true;
  int _start = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
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

  setResend() async {
    setState(() {
      _isloading = true;
    });

    String device = Platform.isAndroid ? 'android' : 'ios';

    print('Device Name: $device');

    try {
      var res = await email_resend_v2(
        widget.userId,
        widget.userName,
        widget.userToken,
        widget.deviceId,
        device,
        widget.email,
      );

      setState(() {
        _isloading = false;
      });

      if (res['status'] == 1) {
        showCustomToast('OTP Resent Successfully Please Check Your Email');
        _emaillotp.clear();

        startTimer();
      } else {
        showCustomToast(res['message']);
      }
    } catch (e) {
      setState(() {
        _isloading = false;
      });
      // showCustomToast("An error occurred: $e");
    }
  }

  void _verifyEmailOtp(String otp) async {
    if (otp.length != 4) return;

    String device = Platform.isAndroid ? 'android' : 'ios';
    setState(() {
      _isloading = true;
    });

    try {
      var res = await verifyEmail(
        widget.userId,
        widget.userName,
        widget.deviceId,
        device,
        widget.email,
        widget.userToken,
        otp,
      );

      print('userId: ${widget.userId}');
      print('userName: ${widget.userName}');
      print('deviceId: ${widget.deviceId}');
      print('device: ${device}');
      print('email: ${widget.email}');
      print('userToken: ${widget.userToken}');
      print('otp: ${otp}');

      if (res['status'] == 1) {
        EmailV2 userResponse = EmailV2.fromJson(res);
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('step', userResponse.user.stepCounter.toString());

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => MainScreen(0)),
          ModalRoute.withName('/'),
        );
        showCustomToast('Your Email is Verified');
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
                'Enter OTP Sent To ${widget.email}',
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
                controller: _emaillotp,
                length: 4,
                onChanged: (pin) {
                  if (!_isloading) {
                    _verifyEmailOtp(pin);
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
                  if (_emaillotp.text.length == 4 && !_isloading) {
                    _verifyEmailOtp(_emaillotp.text);
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
