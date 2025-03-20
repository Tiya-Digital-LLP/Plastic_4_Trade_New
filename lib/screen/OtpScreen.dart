// ignore_for_file: no_logic_in_create_state, non_constant_identifier_names, camel_case_types, must_be_immutable

import 'dart:developer';

import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import 'package:Plastic4trade/screen/forgotpassword/ResetPassword.dart';
import '../api/api_interface.dart';

class otp extends StatefulWidget {
  late String phone, countrycode, email;
  String? myotp;

  otp(
      {Key? key,
      required this.phone,
      required this.countrycode,
      required this.email})
      : super(key: key);

  @override
  State<otp> createState() =>
      _otpState(phone1: phone, countrycode1: countrycode, email1: email);
}

class _otpState extends State<otp> {
  String? phone1, countrycode1, email1;

  TextEditingController otpController = TextEditingController();
  bool _isloading1 = false;

  var otp = "";
  var enteredOTP = "";
  bool otpError = false;

  BuildContext? dialogContext;
  bool isloading = false;
  final _formKey = GlobalKey<FormState>();

  _otpState({required phone1, required countrycode1, required email1});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          top: true,
          left: true,
          right: true,
          bottom: true,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      child:
                          Image.asset('assets/back.png', height: 50, width: 60),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Container(
                    //height: MediaQuery.of(context).size.height,
                    margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset('assets/Otpverification.png',
                              alignment: Alignment.topCenter,
                              height: 150,
                              width: 100),
                        ),
                        Column(children: [
                          const Padding(
                              padding: EdgeInsets.fromLTRB(0, 20.0, 0, 20.0),
                              child: Text('OTP Verification',
                                  style: TextStyle(
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.blackColor,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf'))),
                          widget.email.isEmpty
                              ? Container(
                                  height: 20.0,
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  alignment: Alignment.center,
                                  child: Text(
                                      'Enter OTP Sent To ${widget.countrycode}${widget.phone}',
                                      maxLines: 2,
                                      style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black45Color,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 17)),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Text(
                                      'Enter OTP Sent To ${widget.email}',
                                      maxLines: 2,
                                      style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.blackColor,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      textAlign: TextAlign.center),
                                ),
                          const SizedBox(
                            height: 30,
                          )
                        ]),
                        OtpTextField(
                          enabledBorderColor:
                              otpError ? AppColors.red : AppColors.black45Color,
                          onSubmit: (String verificationCode) {
                            setState(() {
                              enteredOTP = verificationCode;
                            });
                            log("VERIFICATION CODE == $verificationCode");
                          },
                          onCodeChanged: (code) {
                            otp = code;
                            setState(() {
                              otpError = false;
                            });
                          },
                          numberOfFields: 4,
                          fieldWidth: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          cursorColor: AppColors.black45Color,
                          borderRadius: BorderRadius.circular(7),
                          borderColor:
                              otpError ? AppColors.red : AppColors.black45Color,
                          focusedBorderColor: AppColors.verfirdColor,
                          showFieldAsBox: true,
                          textStyle: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Did’t Received the OTP?',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blackColor,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf')),
                            TextButton(
                              child: const Text(
                                'Resend Otp',
                              ),
                              onPressed: () {
                                get_otp(widget.phone, widget.countrycode,
                                        widget.email)
                                    .then((value) {
                                  if (dialogContext != null) {
                                    Navigator.of(dialogContext!).pop();
                                  }
                                  if (value) {
                                  } else {}
                                });
                              },
                            ),
                          ],
                        ),
                        CustomButton(
                          buttonText: 'Submit',
                          onPressed: () {
                            log("ENTERED OTP LENGTH = ${otp.length}");
                            log("ENTERED OTP = $otp");

                            if (enteredOTP.isEmpty || enteredOTP.length < 4) {
                              showCustomToast('Please Enter Your OTP');
                              setState(() {
                                otpError =
                                    true; // Set error to true if OTP is empty
                              });
                            } else {
                              WidgetsBinding.instance.focusManager.primaryFocus
                                  ?.unfocus();

                              verify_otp(enteredOTP.toString(), widget.phone,
                                      widget.countrycode, widget.email)
                                  .then(
                                (value) {
                                  if (dialogContext != null) {
                                    Navigator.of(dialogContext!).pop();
                                  }
                                  if (value) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ResetPassword(
                                                  country_code:
                                                      widget.countrycode,
                                                  phone: widget.phone,
                                                  email: widget.email,
                                                )));
                                  } else {}
                                },
                              );
                            }
                          },
                          isLoading: _isloading1,
                        ),
                      ],
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

  Future<bool> get_otp(phone, conutryCode, email) async {
    var res = await forgotpassword_ME(phone, conutryCode, email);

    if (res['status'] == 1) {
      isloading = true;
      showCustomToast(res['message']);
    } else {
      isloading = false;
      showCustomToast(res['message']);
    }
    return isloading;
  }

  Future<bool> verify_otp(myotp, phone, conutryCode, email) async {
    setState(() {
      _isloading1 = true;
    });
    var res = await verifyforgototp(myotp, phone, conutryCode, email);
    setState(() {
      _isloading1 = false;
    });

    if (res['status'] == 1) {
      showCustomToast(res['message']);
      isloading = true;
    } else {
      isloading = false;
      showCustomToast(res['message']);
    }
    return isloading;
  }
}
