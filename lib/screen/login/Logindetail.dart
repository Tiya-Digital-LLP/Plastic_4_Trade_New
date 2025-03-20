// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:Plastic4trade/screen/splash/splash_screen.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_auth/smart_auth.dart';
import '../../api/api_interface.dart';
import '../../main.dart';

class LoginDetail extends StatefulWidget {
  const LoginDetail({Key? key}) : super(key: key);

  @override
  State<LoginDetail> createState() => _LoginDetailState();
}

class _LoginDetailState extends State<LoginDetail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bussmbl = TextEditingController();
  final TextEditingController _bussemail = TextEditingController();
  final TextEditingController _newpass = TextEditingController();
  final TextEditingController _confirpass = TextEditingController();
  final TextEditingController _mblotp = TextEditingController();
  final TextEditingController _emailotp = TextEditingController();
  bool _isValid = false;

  bool isloading1 = false;
  bool isloading2 = false;
  bool isloading3 = false;
  bool isloading4 = false;
  bool isloading5 = false;

  String? email, countrycode1, countrycode, phoneno;
  Color _color6 = Colors.black45;
  Color _color7 = Colors.black45;
  // ignore: unused_field
  Color _color1 = Colors.black45;

  int mbl_otp = 0;
  int email_otp = 0;

  bool? otp_sent;
  bool edit_mbl = false, edit_email = false, edit_pass = false;
  String defaultCountryCode = 'IN';

  //PhoneNumber number = PhoneNumber(isoCode: 'IN');
  Country? _selectedCountry, defaultCountry;
  bool isloading = false;
  BuildContext? dialogContext;
  bool _isResendButtonEnabled = false;
  bool _isResendButtonEnabled1 = false;
  final smartAuth = SmartAuth();

  Timer? _timer;
  int _countdown = 30;

  int _countdown1 = 30;

  @override
  void initState() {
    super.initState();
    initCountry();
    getBussinessProfile();
  }

  @override
  void dispose() {
    smartAuth.removeSmsListener();
    super.dispose();
  }

  void getSmsCode() async {
    try {
      final res = await smartAuth.getSmsCode(useUserConsentApi: true);
      if (res.codeFound) {
        debugPrint('userConsent success: ${res.code}');
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

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(
      context,
      cornerRadius: BorderSide.strokeAlignInside,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country;
        countrycode1 = country.callingCode.toString();
      });
    }
  }

  void initCountry() async {
    final country = await getCountryByCountryCode(context, defaultCountryCode);
    setState(() {
      _selectedCountry = country;
    });

    // Navigate to the PickerPage and pass the selected country

    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }

  Future<String> getCountryFromCallingCode(String callingCode) async {
    List<Country> list = await getCountries(context);
    for (var country in list) {
      if (country.callingCode == callingCode) {
        defaultCountry = country;
        _selectedCountry = country;
        return country.flag;
      }
    }
    return 'Country not found'; // Default return value if the calling code is not found
  }

  @override
  Widget build(BuildContext context) {
    return initwidget();
  }

  getBussinessProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getuser_Profile(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    if (res['status'] == 1) {
      var jsonArray = res['user'];

      email = jsonArray['email'];
      countrycode = jsonArray['countryCode'];
      phoneno = jsonArray['phoneno'];
      getCountryFromCallingCode(countrycode!);
      setState(() {});
      isloading = true;
    } else {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(res['message']);
    }
  }

  Widget initwidget() {
    final country = _selectedCountry;
    final country1 = defaultCountry;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: const Text('Login Details',
              softWrap: false,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: 'Metropolis',
              )),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        body: isloading
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        Form(
                            key: _formKey,
                            child: Container(
                                // height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.only(
                                    bottom: 10.0, top: 20),
                                child: Column(children: [
                                  SafeArea(
                                      top: true,
                                      left: true,
                                      right: true,
                                      maintainBottomViewPadding: true,
                                      child: isloading
                                          ? Column(
                                              children: [
                                                Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          20.0,
                                                          0.0,
                                                          20.0,
                                                          10.0),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10.0, 5.0, 5.0, 5.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                12)),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .fromLTRB(
                                                                        0.0,
                                                                        5.0,
                                                                        0.0,
                                                                        0.0),
                                                                    child: Text(
                                                                      ' Phone Number',
                                                                      style: const TextStyle(
                                                                              fontSize: 15.0,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Colors.black,
                                                                              fontFamily: 'assets/fonst/Metropolis-Black.otf')
                                                                          .copyWith(color: Colors.black45),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 3.0,
                                                                  ),
                                                                  Row(
                                                                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            const SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Image.asset(
                                                                              country1!.flag,
                                                                              package: countryCodePackageName,
                                                                              width: 30,
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 16,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 2,
                                                                            ),
                                                                            Text(
                                                                              '$countrycode',
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'assets/fonst/Metropolis-Black.otf').copyWith(fontWeight: FontWeight.w500),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 2,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                            phoneno
                                                                                .toString(),
                                                                            style:
                                                                                const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'assets/fonst/Metropolis-Black.otf').copyWith(fontWeight: FontWeight.w500)),
                                                                      ]),
                                                                  const SizedBox(
                                                                    height: 3.0,
                                                                  ),
                                                                ]),
                                                            edit_mbl
                                                                ? Center(
                                                                    child:
                                                                        Align(
                                                                      child:
                                                                          TextButton(
                                                                        child: Text(
                                                                            'Cancel',
                                                                            style:
                                                                                const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'assets/fonst/Metropolis-Black.otf').copyWith(color: AppColors.red)),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            edit_mbl =
                                                                                false;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Center(
                                                                    child:
                                                                        Align(
                                                                      child:
                                                                          TextButton(
                                                                        child: const Text(
                                                                            'Change'),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            edit_mbl =
                                                                                true;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  )
                                                          ]),
                                                      Visibility(
                                                          visible: edit_mbl,
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        16.0),
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                        height:
                                                                            55,
                                                                        //width: 130,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border: Border.all(
                                                                              width: 1,
                                                                              color: Colors.black45),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                        ),
                                                                        margin: const EdgeInsets
                                                                            .fromLTRB(
                                                                            5.0,
                                                                            5.0,
                                                                            5.0,
                                                                            5.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          //mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            GestureDetector(
                                                                              child: Row(
                                                                                children: [
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Image.asset(
                                                                                    country!.flag,
                                                                                    package: countryCodePackageName,
                                                                                    width: 30,
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 16,
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 2,
                                                                                  ),
                                                                                  Text(
                                                                                    country.callingCode,
                                                                                    textAlign: TextAlign.center,
                                                                                    style: const TextStyle(fontSize: 15),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 10,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              onTap: () {
                                                                                _onPressedShowBottomSheet();
                                                                              },
                                                                            )
                                                                          ],
                                                                        )),
                                                                    Container(
                                                                      //padding: EdgeInsets.only(bottom: 3.0),
                                                                      height:
                                                                          57,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          1.68,
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              0.0),
                                                                      child:
                                                                          CustomTextField(
                                                                        keyboardType:
                                                                            TextInputType.phone,
                                                                        controller:
                                                                            _bussmbl,
                                                                        labelText:
                                                                            "New Mobile Number",
                                                                        borderColor:
                                                                            _color6,
                                                                        inputFormatters: [
                                                                          LengthLimitingTextInputFormatter(
                                                                              13),
                                                                        ],
                                                                        onFieldSubmitted:
                                                                            (value) {
                                                                          var numValue =
                                                                              value.length;
                                                                          if (numValue >= 6 &&
                                                                              numValue < 13) {
                                                                            _color6 =
                                                                                AppColors.greenWithShade;
                                                                          } else {
                                                                            _color6 =
                                                                                AppColors.red;
                                                                            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                                                                            showCustomToast('Please Enter Correct Number');
                                                                          }
                                                                        },
                                                                        onChanged:
                                                                            (value) {
                                                                          if (value
                                                                              .isEmpty) {
                                                                            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                                                                            showCustomToast('Please Your Mobile Number');
                                                                            setState(() {
                                                                              _color6 = AppColors.red;
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              _color6 = AppColors.greenWithShade;
                                                                            });
                                                                          }
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              mbl_otp == 1
                                                                  ? Column(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 1.2,
                                                                          height:
                                                                              60,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(50.0),
                                                                              color: AppColors.primaryColor),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child: _isResendButtonEnabled && _countdown != 0
                                                                              ? Text(
                                                                                  '0:$_countdown',
                                                                                  style: const TextStyle(
                                                                                    fontSize: 15.0,
                                                                                    color: Colors.white,
                                                                                    fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                                                                  ).copyWith(fontWeight: FontWeight.w800, fontSize: 17),
                                                                                )
                                                                              : CustomButton(
                                                                                  buttonText: 'Resend OTP',
                                                                                  onPressed: () async {
                                                                                    var numValue = _bussmbl.text.length;
                                                                                    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                                                                                    if (_bussmbl.text.isEmpty) {
                                                                                      setState(() {
                                                                                        _color6 = Colors.red;
                                                                                        showCustomToast('Please Your Mobile Number');
                                                                                      });
                                                                                    } else if (numValue >= 6 && numValue < 13) {
                                                                                      _color6 = AppColors.greenWithShade;
                                                                                      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

                                                                                      await update_phone().then((value) {
                                                                                        if (dialogContext != null) {
                                                                                          Navigator.of(dialogContext!).pop();
                                                                                        }
                                                                                        if (value) {
                                                                                          _startTimer();
                                                                                        } else {}
                                                                                      });
                                                                                      isloading1 = false;
                                                                                    } else {
                                                                                      _color6 = AppColors.red;

                                                                                      showCustomToast('Please Enter Correct Number');
                                                                                    }
                                                                                    setState(() {});
                                                                                  },
                                                                                  isLoading: isloading1,
                                                                                ),
                                                                        ),
                                                                        10.sbh,
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .fromLTRB(
                                                                              25.0,
                                                                              0.0,
                                                                              25.0,
                                                                              0.0),
                                                                          child:
                                                                              Pinput(
                                                                            controller:
                                                                                _mblotp,
                                                                            length:
                                                                                4,
                                                                            onChanged:
                                                                                (pin) {
                                                                              setState(() {
                                                                                _mblotp.text = pin;
                                                                              });
                                                                            },
                                                                            onSubmitted:
                                                                                (pin) {
                                                                              setState(() {
                                                                                _mblotp.text = pin;
                                                                              });
                                                                            },
                                                                            defaultPinTheme:
                                                                                PinTheme(
                                                                              width: 56,
                                                                              height: 56,
                                                                              textStyle: TextStyle(
                                                                                fontSize: 22,
                                                                                color: Colors.black,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.grey[200],
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                            ),
                                                                            focusedPinTheme:
                                                                                PinTheme(
                                                                              width: 56,
                                                                              height: 56,
                                                                              textStyle: TextStyle(
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
                                                                        ),
                                                                        10.sbh,
                                                                        CustomButton(
                                                                          buttonText:
                                                                              'Verify',
                                                                          onPressed:
                                                                              () async {
                                                                            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                                                                            if (_mblotp.text.isEmpty) {
                                                                              showCustomToast("Please Enter OTP");
                                                                              _color1 = AppColors.red;
                                                                            } else {
                                                                              await register_mo_verifyotp(_mblotp.text.toString(), _bussmbl.text.toString(), "3").then((value) {
                                                                                if (dialogContext != null) {
                                                                                  Navigator.of(dialogContext!).pop();
                                                                                }
                                                                                if (value) {}
                                                                              });

                                                                              isloading1 = false;
                                                                            }
                                                                          },
                                                                          isLoading:
                                                                              isloading2,
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : CustomButton(
                                                                      buttonText:
                                                                          'Send OTP',
                                                                      onPressed:
                                                                          () async {
                                                                        var numValue = _bussmbl
                                                                            .text
                                                                            .length;
                                                                        WidgetsBinding
                                                                            .instance
                                                                            .focusManager
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                        if (_bussmbl
                                                                            .text
                                                                            .isEmpty) {
                                                                          setState(
                                                                              () {
                                                                            _color6 =
                                                                                AppColors.red;
                                                                            showCustomToast('Please Your Mobile Number');
                                                                          });
                                                                        } else if (numValue >=
                                                                                6 &&
                                                                            numValue <
                                                                                13) {
                                                                          _color6 =
                                                                              AppColors.greenWithShade;
                                                                          WidgetsBinding
                                                                              .instance
                                                                              .focusManager
                                                                              .primaryFocus
                                                                              ?.unfocus();

                                                                          await update_phone()
                                                                              .then((value) {
                                                                            if (dialogContext !=
                                                                                null) {
                                                                              Navigator.of(dialogContext!).pop();
                                                                            }
                                                                            if (value) {
                                                                              _startTimer();
                                                                            } else {}
                                                                          });
                                                                          isloading1 =
                                                                              false;
                                                                        } else {
                                                                          _color6 =
                                                                              AppColors.greenWithShade;

                                                                          showCustomToast(
                                                                              'Please Enter Correct Number');
                                                                        }
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                      isLoading:
                                                                          isloading1,
                                                                    ),
                                                            ],
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          20.0,
                                                          0.0,
                                                          20.0,
                                                          10.0),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5.0, 5.0, 5.0, 5.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                15)),
                                                  ),
                                                  child: Column(children: [
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          IntrinsicWidth(
                                                              child: Column(
                                                            children: [
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          10.0,
                                                                          5.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Email Address',
                                                                    style: const TextStyle(
                                                                            fontSize:
                                                                                15.0,
                                                                            fontWeight: FontWeight
                                                                                .w400,
                                                                            color: Colors
                                                                                .black,
                                                                            fontFamily:
                                                                                'assets/fonst/Metropolis-Black.otf')
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.black45),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10.0,
                                                                        2.0,
                                                                        0.0,
                                                                        2.0),
                                                                child: Text(
                                                                    email
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                            fontSize:
                                                                                15.0,
                                                                            fontWeight: FontWeight
                                                                                .w400,
                                                                            color: Colors
                                                                                .black,
                                                                            fontFamily:
                                                                                'assets/fonst/Metropolis-Black.otf')
                                                                        .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w500)),
                                                              )
                                                            ],
                                                          )),
                                                          edit_email
                                                              ? Center(
                                                                  child: Align(
                                                                    child:
                                                                        TextButton(
                                                                      child: Text(
                                                                          'Cancel',
                                                                          style:
                                                                              const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'assets/fonst/Metropolis-Black.otf').copyWith(color: AppColors.red)),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          edit_email =
                                                                              false;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                )
                                                              : Center(
                                                                  child: Align(
                                                                    child:
                                                                        TextButton(
                                                                      child: const Text(
                                                                          'Change'),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          edit_email =
                                                                              true;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                )
                                                        ]),
                                                    Visibility(
                                                        visible: edit_email,
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .fromLTRB(20,
                                                                  20, 20, 20),
                                                          child: Column(
                                                            children: [
                                                              CustomTextField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .emailAddress,
                                                                controller:
                                                                    _bussemail,
                                                                labelText:
                                                                    "New Email Address",
                                                                borderColor:
                                                                    _color7,
                                                                inputFormatters: [],
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    _color7 =
                                                                        AppColors
                                                                            .red;
                                                                  } else {
                                                                    _color7 =
                                                                        AppColors
                                                                            .greenWithShade;
                                                                  }

                                                                  return null;
                                                                },
                                                                onFieldSubmitted:
                                                                    (value) {},
                                                                onChanged:
                                                                    (value) {
                                                                  if (value
                                                                      .isEmpty) {
                                                                    WidgetsBinding
                                                                        .instance
                                                                        .focusManager
                                                                        .primaryFocus
                                                                        ?.unfocus();
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                'Please Your Email');
                                                                    setState(
                                                                        () {
                                                                      _color7 =
                                                                          AppColors
                                                                              .red;
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      _color7 =
                                                                          AppColors
                                                                              .greenWithShade;
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                              10.sbh,
                                                              (email_otp == 1)
                                                                  ? Column(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 1.2,
                                                                          height:
                                                                              60,
                                                                          margin: const EdgeInsets
                                                                              .all(
                                                                              20.0),
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(width: 1),
                                                                              borderRadius: BorderRadius.circular(50.0),
                                                                              color: AppColors.primaryColor.withOpacity(0.8)),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child: (_isResendButtonEnabled1 && _countdown1 != 0)
                                                                              ? Text(
                                                                                  '0:$_countdown1',
                                                                                  style: const TextStyle(
                                                                                    fontSize: 15.0,
                                                                                    color: Colors.white,
                                                                                    fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                                                                  ).copyWith(fontWeight: FontWeight.w800, fontSize: 17),
                                                                                )
                                                                              : CustomButton(
                                                                                  buttonText: 'Resend OTP',
                                                                                  onPressed: () {
                                                                                    log("_isResendButtonEnabled1 = $_isResendButtonEnabled1");
                                                                                    setState(() {
                                                                                      _isValid = EmailValidator.validate(_bussemail.text);
                                                                                      if (!_isValid) {
                                                                                        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                                                                                        showCustomToast('Enter Proper Email');
                                                                                        _color7 = AppColors.red;
                                                                                      } else {
                                                                                        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                                                                                        update_email().then((value) {
                                                                                          if (dialogContext != null) {
                                                                                            Navigator.of(dialogContext!).pop();
                                                                                          }
                                                                                          _email_startTimer();
                                                                                        });
                                                                                      }
                                                                                      isloading1 = false;
                                                                                      if (dialogContext != null) {
                                                                                        Navigator.of(dialogContext!).pop();
                                                                                      }
                                                                                    });
                                                                                  },
                                                                                  isLoading: isloading3,
                                                                                ),
                                                                        ),
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .fromLTRB(
                                                                              25.0,
                                                                              0.0,
                                                                              25.0,
                                                                              0.0),
                                                                          child:
                                                                              Pinput(
                                                                            controller:
                                                                                _emailotp,
                                                                            length:
                                                                                4, // Length of the PIN
                                                                            onChanged:
                                                                                (pin) {
                                                                              setState(() {
                                                                                _emailotp.text = pin;
                                                                              });
                                                                            },
                                                                            onSubmitted:
                                                                                (pin) {
                                                                              setState(() {
                                                                                _emailotp.text = pin;
                                                                              });
                                                                            },
                                                                            defaultPinTheme:
                                                                                PinTheme(
                                                                              width: 56,
                                                                              height: 56,
                                                                              textStyle: TextStyle(
                                                                                fontSize: 22,
                                                                                color: Colors.black,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.grey[200],
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                            ),
                                                                            focusedPinTheme:
                                                                                PinTheme(
                                                                              width: 56,
                                                                              height: 56,
                                                                              textStyle: TextStyle(
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
                                                                        ),
                                                                        10.sbh,
                                                                        CustomButton(
                                                                          buttonText:
                                                                              'Verify',
                                                                          onPressed:
                                                                              () {
                                                                            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                                                                            if (_emailotp.text.isEmpty) {
                                                                              _color1 = AppColors.red;
                                                                              showCustomToast("Please Enter OTP");
                                                                            } else {
                                                                              update_email_verifyotp(_emailotp.text.toString(), _bussemail.text.toString(), "2").then((value) {
                                                                                if (dialogContext != null) {
                                                                                  Navigator.of(dialogContext!).pop();
                                                                                }
                                                                              });
                                                                            }
                                                                            isloading1 =
                                                                                false;
                                                                          },
                                                                          isLoading:
                                                                              isloading4,
                                                                        )
                                                                      ],
                                                                    )
                                                                  : CustomButton(
                                                                      buttonText:
                                                                          'Send OTP',
                                                                      onPressed:
                                                                          () async {
                                                                        _isValid =
                                                                            EmailValidator.validate(_bussemail.text);
                                                                        if (!_isValid) {
                                                                          WidgetsBinding
                                                                              .instance
                                                                              .focusManager
                                                                              .primaryFocus
                                                                              ?.unfocus();
                                                                          showCustomToast(
                                                                              'Enter Proper Email');
                                                                          _color7 =
                                                                              AppColors.red;
                                                                        } else {
                                                                          WidgetsBinding
                                                                              .instance
                                                                              .focusManager
                                                                              .primaryFocus
                                                                              ?.unfocus();
                                                                          if (dialogContext !=
                                                                              null) {
                                                                            Navigator.of(dialogContext!).pop();
                                                                          }
                                                                          await update_email(); // Use await here instead of .then()

                                                                          _email_startTimer();
                                                                        }
                                                                        isloading1 =
                                                                            false;
                                                                        if (dialogContext !=
                                                                            null) {
                                                                          Navigator.of(dialogContext!)
                                                                              .pop();
                                                                        }
                                                                      },
                                                                      isLoading:
                                                                          isloading3,
                                                                    )
                                                            ],
                                                          ),
                                                        )),
                                                  ]),
                                                ),
                                                // Container(
                                                //     margin:
                                                //         const EdgeInsets.fromLTRB(
                                                //             20.0,
                                                //             0.0,
                                                //             20.0,
                                                //             20.0),
                                                //     padding: const EdgeInsets
                                                //         .fromLTRB(
                                                //         5.0, 5.0, 5.0, 5.0),
                                                //     decoration: BoxDecoration(
                                                //       color: Colors.white,
                                                //       borderRadius:
                                                //           const BorderRadius
                                                //               .all(
                                                //               Radius.circular(
                                                //                   15)),
                                                //     ),
                                                //     child: Column(
                                                //       children: [
                                                //         Row(
                                                //             mainAxisAlignment:
                                                //                 MainAxisAlignment
                                                //                     .spaceBetween,
                                                //             children: [
                                                //               Column(children: [
                                                //                 Image.asset(
                                                //                   'assets/password.png',
                                                //                   width: 120,
                                                //                   height: 40,
                                                //                 )
                                                //               ]),
                                                //               edit_pass
                                                //                   ? Center(
                                                //                       child:
                                                //                           Align(
                                                //                         child:
                                                //                             TextButton(
                                                //                           child: Text(
                                                //                               'Cancel',
                                                //                               style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'assets/fonst/Metropolis-Black.otf').copyWith(color: AppColors.red)),
                                                //                           onPressed:
                                                //                               () {
                                                //                             setState(() {
                                                //                               edit_pass = false;
                                                //                             });
                                                //                           },
                                                //                         ),
                                                //                       ),
                                                //                     )
                                                //                   : Center(
                                                //                       child:
                                                //                           Align(
                                                //                         child:
                                                //                             TextButton(
                                                //                           child:
                                                //                               const Text('Change'),
                                                //                           onPressed:
                                                //                               () {
                                                //                             setState(() {
                                                //                               edit_pass = true;
                                                //                             });
                                                //                           },
                                                //                         ),
                                                //                       ),
                                                //                     )
                                                //             ]),
                                                //         Visibility(
                                                //             visible: edit_pass,
                                                //             child: Column(
                                                //               children: [
                                                //                 Padding(
                                                //                   padding:
                                                //                       const EdgeInsets
                                                //                           .fromLTRB(
                                                //                           25.0,
                                                //                           5.0,
                                                //                           25.0,
                                                //                           10.0),
                                                //                   child:
                                                //                       EditTextPassword(
                                                //                     controller:
                                                //                         _newpass,
                                                //                     label:
                                                //                         'New Password',
                                                //                   ),
                                                //                 ),
                                                //                 Padding(
                                                //                   padding:
                                                //                       const EdgeInsets
                                                //                           .fromLTRB(
                                                //                           25.0,
                                                //                           5.0,
                                                //                           25.0,
                                                //                           10.0),
                                                //                   child:
                                                //                       EditTextPassword(
                                                //                     controller:
                                                //                         _confirpass,
                                                //                     label:
                                                //                         'confirm New Password',
                                                //                   ),
                                                //                 ),
                                                //                 CustomButton(
                                                //                   buttonText:
                                                //                       'Change Password',
                                                //                   onPressed:
                                                //                       () {
                                                //                     setState(
                                                //                         () {
                                                //                       WidgetsBinding
                                                //                           .instance
                                                //                           .focusManager
                                                //                           .primaryFocus
                                                //                           ?.unfocus();
                                                //                       if (_newpass
                                                //                           .text
                                                //                           .isEmpty) {
                                                //                         showCustomToast(
                                                //                             "Please Enter Password...");
                                                //                       } else if (_newpass
                                                //                               .text
                                                //                               .length <
                                                //                           6) {
                                                //                         showCustomToast(
                                                //                             "Password must have 6 digit...");
                                                //                       } else if (_confirpass
                                                //                           .text
                                                //                           .isEmpty) {
                                                //                         showCustomToast(
                                                //                             "Please Enter Confirm Password");
                                                //                       } else if (_confirpass
                                                //                               .text !=
                                                //                           _newpass
                                                //                               .text) {
                                                //                         showCustomToast(
                                                //                             "Password Doesn't Match");
                                                //                       } else {
                                                //                         isloading1 =
                                                //                             true;
                                                //                         WidgetsBinding
                                                //                             .instance
                                                //                             .focusManager
                                                //                             .primaryFocus
                                                //                             ?.unfocus();
                                                //                         change_password()
                                                //                             .then((value) {
                                                //                           if (dialogContext !=
                                                //                               null) {
                                                //                             Navigator.of(dialogContext!).pop();
                                                //                           }
                                                //                         });
                                                //                         isloading1 =
                                                //                             false;
                                                //                       }
                                                //                     });
                                                //                   },
                                                //                   isLoading:
                                                //                       isloading5,
                                                //                 )
                                                //               ],
                                                //             ))
                                                //       ],
                                                //     )),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            )
                                          : Center(
                                              child: CustomLottieContainer(
                                                child: Lottie.asset(
                                                  'assets/loading_animation.json',
                                                ),
                                              ),
                                            ))
                                ]))),
                      ],
                    ),
                    400.sbh,
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Are you sure ?"),
                              content: const Text(
                                "Are You Sure Want To Delete Your Account?"
                                "\n"
                                "After delete account you can't access the app and all of your data will erased",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    letterSpacing: 0.5),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    deleteMyAccount();
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Delete Account',
                          style: const TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf')
                              .copyWith(color: AppColors.red.withOpacity(0.3))),
                    ),
                  ],
                ),
              )
            : Center(
                child: CustomLottieContainer(
                child: Lottie.asset(
                  'assets/loading_animation.json',
                ),
              )));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        setState(() {});
      }
    });
  }

  void _email_startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown1 > 0) {
        setState(() {
          _countdown1--;
        });
      } else {
        _timer?.cancel();
        setState(() {});
      }
    });
  }

  Future<bool> update_phone() async {
    setState(() {
      isloading1 = true; // Show loader when starting the verification process
    });
    log("Button Pressed");

    SharedPreferences pref = await SharedPreferences.getInstance();
    // _isResendButtonEnabled = ;
    _countdown = 30;
    countrycode1 ??= countrycode;

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await updateUserPhoneno(
      _bussmbl.text.toString(),
      countrycode1!,
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    setState(() {
      isloading1 = false; // Show loader when starting the verification process
    });

    if (res['status'] == 1) {
      isloading1 = true;
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(res['message']);
      otp_sent = res['otp_sent'];
      mbl_otp = 1;
      getSmsCode();
      edit_mbl = true;
      if (otp_sent == false) {
        await register_mo_verifyotp("1234", _bussmbl.text.toString(), "3");
        Navigator.of(dialogContext!).pop();
        edit_mbl = false;
        setState(() {
          _isResendButtonEnabled = false;
        });
      } else {
        setState(() {
          _isResendButtonEnabled = true;
        });
      }
    } else {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(res['message']);
      setState(() {
        _isResendButtonEnabled = false;
      });
    }
    isloading1 = true;
    setState(() {});
    return isloading1;
  }

  Future<bool> update_email() async {
    setState(() {
      isloading3 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    _countdown1 = 30;
    var res = await updateUseremail(
      _bussemail.text.toString(),
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    setState(() {
      isloading3 = false;
    });

    log("RESPONSE ==  $res");

    if (res['status'] == 1) {
      showCustomToast(res['message']);
      setState(() {
        _isResendButtonEnabled1 = true;
      });

      email_otp = 1;
    } else {
      showCustomToast(res['message']);
      setState(() {
        _isResendButtonEnabled1 = true;
      });
    }
    isloading1 = true;
    setState(() {});
    return isloading1;
  }

  Future<bool> register_mo_verifyotp(
    String otp,
    String phoneno,
    String step,
  ) async {
    // Set loading state to true synchronously
    setState(() {
      isloading2 = true;
    });

    log("VERIFY Button Pressed");

    // Run async operations outside setState
    SharedPreferences pref = await SharedPreferences.getInstance();
    var res = await reg_mo_updateverifyotp(
        otp,
        pref.getString('user_id').toString(),
        phoneno,
        pref.getString('userToken').toString(),
        step);

    // Set loading state to false and handle response synchronously
    if (res['status'] == 1) {
      // Successful response handling
      setState(() {
        isloading2 = false;
        showCustomToast(res['message']);
        _bussmbl.clear();
        _mblotp.clear();
        edit_mbl = false;
        mbl_otp = 0;
        isloading1 = true;
      });
    } else {
      // Failure response handling
      setState(() {
        isloading2 = false;
        showCustomToast(res['message']);
        log("VALIDATION FAILED");
        isloading1 = true;
      });
    }

    // Async call outside setState to fetch business profile
    await getBussinessProfile();

    // Final UI update after async operation
    setState(() {});
    return isloading1;
  }

  Future<bool> update_email_verifyotp(
    String otp,
    String email,
    String step,
  ) async {
    setState(() {
      isloading4 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    var res = await reg_email_verifyotp(
      otp,
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      email,
      "2",
    );

    setState(() {
      isloading4 = false;
    });

    log("OTP RESPONSE == $res");

    if (res['status'] == 1) {
      showCustomToast(res['message']);
      _bussemail.clear();
      _emailotp.clear();
      edit_email = false;
      email_otp = 0;
      isloading1 = true;
    } else {
      showCustomToast(res['message']);
      _emailotp.clear();
      isloading1 = true;
    }
    getBussinessProfile();
    setState(() {});
    return isloading1;
  }

  Future<bool> change_password() async {
    setState(() {
      isloading5 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await changePassword(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      _newpass.text.toString(),
      device,
    );

    setState(() {
      isloading5 = false;
    });

    if (res['status'] == 1) {
      showCustomToast(res['message']);
      _newpass.clear();
      _confirpass.clear();
      edit_pass = false;
      isloading1 = true;
    } else {
      showCustomToast(res['message']);
      isloading1 = true;
    }
    getBussinessProfile();
    setState(() {});
    return isloading1;
  }

  Future<void> deleteMyAccount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var response = await deleteAccount(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
    );

    if (response['status'] == 1) {
      final pref = await SharedPreferences.getInstance();
      await pref.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SplashScreen(
            analytics: MyApp.analytics,
            observer: MyApp.observer,
          ),
        ),
      );
    } else {
      showCustomToast("Something went wrong..!");
    }
    setState(() {});
  }
}
