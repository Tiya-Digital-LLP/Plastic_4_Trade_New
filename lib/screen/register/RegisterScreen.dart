// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, prefer_final_fields, depend_on_referenced_packages

import 'dart:async';
import 'dart:io' show Platform;

import 'package:Plastic4trade/main.dart';
import 'package:Plastic4trade/model/FinalRegister.dart';
import 'package:Plastic4trade/screen/login/LoginScreen.dart';
import 'package:Plastic4trade/screen/terms_condtion.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/edittext_password.dart';
import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../api/api_interface.dart';
import '../../api/firebase_api.dart';
import '../../model/RegisterUserPhoneno.dart';
import '../../utill/constant.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool passenable = true;
  var check_value = false;
  final TextEditingController _usernm = TextEditingController();
  final TextEditingController _usermbl = TextEditingController();
  final TextEditingController _useremail = TextEditingController();
  final TextEditingController _userpass = TextEditingController();
  final TextEditingController _mbloto = TextEditingController();
  final TextEditingController _emailotp = TextEditingController();
  final TextEditingController _usercpass = TextEditingController();
  Color _color1 = Colors.black26;
  Color _color2 = Colors.black26;
  Color _color3 = Colors.black26;
  // ignore: unused_field
  Color _color6 = Colors.black26;
  // ignore: unused_field
  Color _color7 = Colors.black26;
  String device_name = '';
  FinalRegister register = FinalRegister();
  late SharedPreferences _pref;
  bool _isloading = false;
  bool _isloading1 = false;
  bool _isloading2 = false;
  bool _isloading3 = false;
  bool _isloading4 = false;
  bool _isloading5 = false;
  bool _isloading6 = false;

  bool isloading = false;
  BuildContext? dialogContext;
  final _formKey = GlobalKey<FormState>();
  bool _isValid = false;
  String initialCountry = 'IN';
  String country_code = '+91';
  int verify_phone = 0;
  int mbl_otp = 0;
  int email_otp = 0;
  int verify_email = 0;
  int sms_mbl = 0;
  bool? otp_sent;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool _isResendButtonEnabled = false;
  Timer? _timer;
  int _countdown = 30;
  String defaultCountryCode = 'IN';
  Country? _selectedCountry;
  final smartAuth = SmartAuth();

  @override
  void initState() {
    super.initState();
    initCountry();
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
        // Autofill the TextField with the fetched code
        _mbloto.text = res.code!;
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isResendButtonEnabled = true;
        });
      }
    });
  }

  void initCountry() async {
    final country = await getCountryByCountryCode(context, defaultCountryCode);
    setState(() {
      _selectedCountry = country;
    });
  }

  @override
  Widget build(BuildContext context) {
    return initWidget();
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(
      context,
      cornerRadius: BorderSide.strokeAlignInside,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country;
        country_code = country.callingCode.toString();
      });
    }
  }

  Widget initWidget() {
    final country = _selectedCountry;
    if (Platform.isAndroid) {
      // Android-specific code
      device_name = 'android';
    } else if (Platform.isIOS) {
      device_name = 'ios';
    }

    init(context);
    return Material(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: SizedBox(
              // height: MediaQuery.of(context).size.height,
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
                        const SizedBox(
                          height: 40.0,
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily:
                                    'assets/fonst/Metropolis-Black.otf'),
                          ),
                        ),
                        const SizedBox(
                            height: 25.0,
                            child: Text(
                              'It' r"'" 's free and always',
                              style: TextStyle(
                                  fontSize: 21.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf'),
                            )),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _usernm,
                            labelText: "Your Name",
                            borderColor: _color1,
                            textCapitalization: TextCapitalization.words,
                            enabled: verify_phone == 1 ? false : true,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z]+|\s"),
                              ),
                              LengthLimitingTextInputFormatter(30),
                              CapitalizeWordsTextInputFormatter(),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                _color1 = AppColors.red;
                              } else if (value.length > 30) {
                                _color1 = AppColors.red;
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast('Name Should be 30 Character');
                              } else {
                                _color1 = AppColors.greenWithShade;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value.isEmpty) {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast('Please Enter Your Name');
                                setState(() {
                                  _color1 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color1 = AppColors.greenWithShade;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast('Please Enter Your Name');
                                setState(() {
                                  _color1 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color1 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                        AbsorbPointer(
                            absorbing: verify_phone == 1 ? true : false,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(
                                  25.0, 5.0, 5.0, 5.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    child: Container(
                                        height: 57,
                                        padding: const EdgeInsets.only(left: 2),
                                        decoration: BoxDecoration(
                                          border: verify_phone == 1
                                              ? Border.all(
                                                  width: 1, color: Colors.grey)
                                              : Border.all(
                                                  width: 1,
                                                  color: Colors.black26),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
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
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        )),
                                    onTap: () {
                                      _onPressedShowBottomSheet();
                                    },
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 57,
                                      margin: const EdgeInsets.only(
                                          left: 5.0, right: 25),
                                      child: CustomTextField(
                                        controller: _usermbl,
                                        labelText: "Mobile Number",
                                        borderColor: _color2,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        keyboardType: TextInputType.phone,
                                        enabled:
                                            verify_phone == 1 ? false : true,
                                        suffixIcon: verify_phone == 1
                                            ? Icon(
                                                Icons.check_circle_rounded,
                                                color: AppColors.greenWithShade,
                                              )
                                            : null,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(11),
                                        ],
                                        onFieldSubmitted: (value) {
                                          var numValue = value.length;
                                          if (numValue >= 6 && numValue < 12) {
                                            _color2 = AppColors.greenWithShade;
                                            setState(() {});
                                          } else {
                                            _color2 = AppColors.red;
                                            WidgetsBinding.instance.focusManager
                                                .primaryFocus
                                                ?.unfocus();
                                            showCustomToast(
                                                'Please Enter Correct Number');
                                            setState(() {});
                                          }
                                        },
                                        onChanged: (value) {
                                          if (value.isEmpty) {
                                            WidgetsBinding.instance.focusManager
                                                .primaryFocus
                                                ?.unfocus();
                                            showCustomToast(
                                                'Please Enter Your Number');
                                            setState(() {
                                              _color2 = AppColors.red;
                                            });
                                          } else {
                                            setState(() {
                                              _color2 =
                                                  AppColors.greenWithShade;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )),
                        mbl_otp == 1
                            ? Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: 60,
                                    margin: const EdgeInsets.only(top: 5),
                                    child: _isResendButtonEnabled &&
                                            _countdown != 0
                                        ? Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                color: AppColors.primaryColor),
                                            margin:
                                                const EdgeInsets.only(top: 5.0),
                                            // Set the height of the container
                                            alignment: Alignment.center,
                                            child: Text(
                                              '0:$_countdown',
                                              style: const TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.white,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf',
                                              ).copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 17),
                                            ))
                                        : CustomButton(
                                            buttonText: 'Resend OTP',
                                            onPressed: () async {
                                              if (_usernm.text.isEmpty) {
                                                _color1 = AppColors.red;
                                                setState(() {});
                                                showCustomToast(
                                                    'Please Enter Your Name');
                                              } else if (_usermbl
                                                  .text.isEmpty) {
                                                _color2 = AppColors.red;
                                                setState(() {});
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Enter Your Number ');
                                              } else if (_usermbl
                                                  .text.isNotEmpty) {
                                                if (_usermbl.text.length >= 6 &&
                                                    _usermbl.text.length < 12) {
                                                  _color2 =
                                                      AppColors.greenWithShade;
                                                  if (_usernm.text.isNotEmpty &&
                                                      _usermbl
                                                          .text.isNotEmpty) {
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    _isloading = false;
                                                    await register_mo_resendotp(
                                                            _pref
                                                                .getString(
                                                                    'user_id')
                                                                .toString(),
                                                            _usermbl.text
                                                                .toString(),
                                                            _pref
                                                                .getString(
                                                                    'userToken')
                                                                .toString(),
                                                            country_code)
                                                        .then((value) {
                                                      Navigator.of(
                                                              dialogContext!)
                                                          .pop();
                                                      if (value) {
                                                        _isloading = false;
                                                      } else {
                                                        _isloading = false;
                                                      }
                                                    });
                                                    setState(() {});
                                                  }
                                                } else {
                                                  _color2 = AppColors.red;
                                                  WidgetsBinding.instance
                                                      .focusManager.primaryFocus
                                                      ?.unfocus();
                                                  showCustomToast(
                                                      'Please Enter Your Correct Number');
                                                  setState(() {});
                                                }
                                              } else if (_usernm
                                                      .text.isNotEmpty &&
                                                  _usermbl.text.isNotEmpty) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                await register_mo_resendotp(
                                                        _pref
                                                            .getString(
                                                                'user_id')
                                                            .toString(),
                                                        _usermbl.text
                                                            .toString(),
                                                        _pref
                                                            .getString(
                                                                'userToken')
                                                            .toString(),
                                                        country_code)
                                                    .then((value) {
                                                  Navigator.of(dialogContext!)
                                                      .pop();
                                                  if (value) {
                                                    _isloading = false;
                                                  } else {
                                                    _isloading = false;
                                                  }
                                                });
                                                setState(() {});
                                              }
                                            },
                                            isLoading: _isloading2,
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Pinput(
                                      controller: _mbloto,
                                      length: 4, // Length of the PIN
                                      onChanged: (pin) {
                                        setState(() {
                                          _mbloto.text = pin;
                                        });
                                      },
                                      onSubmitted: (pin) {
                                        setState(() {
                                          _mbloto.text = pin;
                                        });
                                      },
                                      defaultPinTheme: PinTheme(
                                        width: 56,
                                        height: 56,
                                        textStyle: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      focusedPinTheme: PinTheme(
                                        width: 56,
                                        height: 56,
                                        textStyle: TextStyle(
                                          fontSize: 22,
                                          color: Colors.blue,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                  ),
                                  CustomButton(
                                    buttonText: 'Verify OTP',
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {}
                                      setState(() {
                                        if (_mbloto.text.isEmpty) {
                                          showCustomToast('Please Enter OTP');

                                          _color6 = AppColors.red;
                                        } else if (_mbloto.text.isNotEmpty &&
                                            _usermbl.text.isNotEmpty) {
                                          _isloading = false;
                                          register_mo_verifyotp(
                                                  _mbloto.text.toString(),
                                                  _pref
                                                      .getString('user_id')
                                                      .toString(),
                                                  _usermbl.text.toString(),
                                                  _pref
                                                      .getString('userToken')
                                                      .toString(),
                                                  "3")
                                              .then((value) {
                                            Navigator.of(dialogContext!).pop();
                                            if (value) {
                                              _isloading = false;
                                            } else {
                                              _isloading = false;
                                            }
                                          });
                                        }
                                      });
                                    },
                                    isLoading: _isloading1,
                                  ),
                                ],
                              )
                            : verify_phone == 0
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        35.0, 15.0, 35.0, 5.0),
                                    child: Column(
                                      children: [
                                        CustomButton(
                                          buttonText: 'Send OTP',
                                          onPressed: () async {
                                            // Check internet connection
                                            final connectivityResult =
                                                await Connectivity()
                                                    .checkConnectivity();

                                            if (connectivityResult ==
                                                ConnectivityResult.none) {
                                              WidgetsBinding.instance
                                                  .focusManager.primaryFocus
                                                  ?.unfocus();
                                              showCustomToast(
                                                  'Net Connection not available');
                                            } else {
                                              // Validation checks
                                              if (_usernm.text.isEmpty) {
                                                _color1 = AppColors.red;
                                                setState(() {});
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Enter Your Name');
                                              } else if (_usermbl
                                                  .text.isEmpty) {
                                                _color2 = AppColors.red;
                                                setState(() {});
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Enter Your Number');
                                              } else if (_usermbl
                                                  .text.isNotEmpty) {
                                                if (_usermbl.text.length >= 6 &&
                                                    _usermbl.text.length < 12) {
                                                  _color2 =
                                                      AppColors.greenWithShade;
                                                  if (_usernm.text.isNotEmpty &&
                                                      _usermbl
                                                          .text.isNotEmpty) {
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    setRegisterUserPhoneno()
                                                        .then((value) {
                                                      Navigator.of(
                                                              dialogContext!)
                                                          .pop();
                                                      setState(() {
                                                        _isloading = false;
                                                      });
                                                    });
                                                  }
                                                } else {
                                                  _color2 = AppColors.red;
                                                  WidgetsBinding.instance
                                                      .focusManager.primaryFocus
                                                      ?.unfocus();
                                                  showCustomToast(
                                                      'Please Enter Your Correct Number');
                                                  setState(() {});
                                                }
                                              }
                                            }
                                          },
                                          isLoading: _isloading,
                                        ),
                                      ],
                                    ))
                                : const SizedBox(),
                        verify_phone == 1
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    25.0, 5.0, 25.0, 5.0),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: _useremail,
                                      labelText: "Your Email",
                                      borderColor: _color3,
                                      keyboardType: TextInputType.emailAddress,
                                      enabled: verify_email == 1 ? false : true,
                                      suffixIcon: verify_email == 1
                                          ? Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.greenWithShade,
                                            )
                                          : null,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(50),
                                      ],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          //WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus();
                                          showCustomToast(
                                              'Please Enter Your Email ');

                                          _color3 = AppColors.red;
                                        } else {}
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            _color3 = AppColors.greenWithShade;
                                          });
                                        } else if (value.isEmpty) {
                                          setState(() {
                                            WidgetsBinding.instance.focusManager
                                                .primaryFocus
                                                ?.unfocus();
                                            _color3 = AppColors.red;
                                          });
                                        }
                                      },
                                      onFieldSubmitted: (value) {
                                        if (!EmailValidator.validate(value)) {
                                          _color3 = AppColors.red;
                                          WidgetsBinding.instance.focusManager
                                              .primaryFocus
                                              ?.unfocus();
                                          showCustomToast(
                                              'Please Enter Correct Email');
                                          // setState(() {});
                                        } else if (value.isNotEmpty) {
                                          // setState(() {
                                          _color3 = AppColors.greenWithShade;
                                          // });
                                        }
                                      },
                                    ),
                                    verify_email == 0
                                        ? email_otp == 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: CustomButton(
                                                  buttonText: 'Send OTP',
                                                  onPressed: () async {
                                                    final connectivityResult =
                                                        await Connectivity()
                                                            .checkConnectivity();

                                                    if (connectivityResult ==
                                                        ConnectivityResult
                                                            .none) {
                                                      //this.getData();
                                                      showCustomToast(
                                                          'Net Connection not available');
                                                    } else {
                                                      //this.getData();
                                                      if (_useremail
                                                          .text.isNotEmpty) {
                                                        _isValid =
                                                            EmailValidator
                                                                .validate(
                                                                    _useremail
                                                                        .text);
                                                        if (_isValid) {
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                          _isloading = false;
                                                          setRegisterUserEmail()
                                                              .then((value) {
                                                            Navigator.of(
                                                                    dialogContext!)
                                                                .pop();
                                                            if (value) {
                                                              _isloading =
                                                                  false;
                                                            } else {
                                                              _isloading =
                                                                  false;
                                                            }
                                                          });
                                                        } else {
                                                          _color3 =
                                                              AppColors.red;
                                                          WidgetsBinding
                                                              .instance
                                                              .focusManager
                                                              .primaryFocus
                                                              ?.unfocus();
                                                          showCustomToast(
                                                              'Please Enter Correct Email');
                                                          setState(() {});
                                                        }
                                                      } else {
                                                        _color3 = AppColors.red;
                                                        WidgetsBinding
                                                            .instance
                                                            .focusManager
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        showCustomToast(
                                                            'Please Enter Your Email');

                                                        setState(() {});
                                                      }
                                                    }
                                                  },
                                                  isLoading: _isloading3,
                                                ),
                                              )
                                            : Column(
                                                children: [
                                                  _isResendButtonEnabled &&
                                                          _countdown != 0
                                                      ? Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                          height: 60,
                                                          decoration: BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                      width: 1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50.0),
                                                              color: AppColors
                                                                  .primaryColor),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 5.0),
                                                          // Set the height of the container
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            '0:$_countdown',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15.0,
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf',
                                                            ).copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    fontSize:
                                                                        17),
                                                          ))
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10),
                                                          child: CustomButton(
                                                            buttonText:
                                                                'Resend OTP',
                                                            onPressed:
                                                                () async {
                                                              final connectivityResult =
                                                                  await Connectivity()
                                                                      .checkConnectivity();

                                                              if (connectivityResult ==
                                                                  ConnectivityResult
                                                                      .none) {
                                                                //this.getData();
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            'Net Connection not available');
                                                              } else {
                                                                //this.getData();
                                                                if (_useremail
                                                                    .text
                                                                    .isNotEmpty) {
                                                                  _isValid = EmailValidator
                                                                      .validate(
                                                                          _useremail
                                                                              .text);
                                                                  if (_isValid) {
                                                                    _isloading =
                                                                        false;
                                                                    register_email_resendotp(
                                                                            _pref.getString('user_id').toString(),
                                                                            _pref.getString('userToken').toString(),
                                                                            _useremail.text.toString())
                                                                        .then((value) {
                                                                      Navigator.of(
                                                                              dialogContext!)
                                                                          .pop();
                                                                      if (value) {
                                                                        _isloading =
                                                                            false;
                                                                      } else {
                                                                        _isloading =
                                                                            false;
                                                                      }
                                                                    });
                                                                  } else {
                                                                    _color3 =
                                                                        AppColors
                                                                            .red;
                                                                    WidgetsBinding
                                                                        .instance
                                                                        .focusManager
                                                                        .primaryFocus
                                                                        ?.unfocus();
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                'Please Enter Correct Email');
                                                                    setState(
                                                                        () {});
                                                                  }
                                                                }
                                                              }
                                                            },
                                                            isLoading:
                                                                _isloading4,
                                                          ),
                                                        ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Pinput(
                                                      controller: _emailotp,
                                                      length:
                                                          4, // Length of the PIN
                                                      onChanged: (pin) {
                                                        setState(() {
                                                          _emailotp.text = pin;
                                                        });
                                                      },
                                                      onSubmitted: (pin) {
                                                        setState(() {
                                                          _emailotp.text = pin;
                                                        });
                                                      },
                                                      defaultPinTheme: PinTheme(
                                                        width: 56,
                                                        height: 56,
                                                        textStyle: TextStyle(
                                                          fontSize: 22,
                                                          color: Colors.black,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      focusedPinTheme: PinTheme(
                                                        width: 56,
                                                        height: 56,
                                                        textStyle: TextStyle(
                                                          fontSize: 22,
                                                          color: Colors.blue,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  10.sbh,
                                                  CustomButton(
                                                    buttonText: 'Verify OTP',
                                                    onPressed: () async {
                                                      final connectivityResult =
                                                          await Connectivity()
                                                              .checkConnectivity();

                                                      if (connectivityResult ==
                                                          ConnectivityResult
                                                              .none) {
                                                        //this.getData();
                                                        showCustomToast(
                                                            'Net Connection not available');
                                                      } else {
                                                        //this.getData();
                                                        if (_emailotp
                                                            .text.isEmpty) {
                                                          showCustomToast(
                                                              "Please Enter OTP");
                                                        }

                                                        if (_formKey
                                                            .currentState!
                                                            .validate()) {
                                                          /* Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          "Data Proccess");*/
                                                        }
                                                        setState(() {
                                                          if (_emailotp.text
                                                                  .isNotEmpty &&
                                                              _useremail.text
                                                                  .isNotEmpty) {
                                                            // register_mo_verifyotp(_mbloto.text.toString(),_pref.getString('user_id').toString(),_pref.getString('phone').toString(),_pref.getString('userToken').toString(),"3");
                                                            _isloading = false;
                                                            register_email_verifyotp(
                                                                    _emailotp
                                                                        .text
                                                                        .toString(),
                                                                    _pref
                                                                        .getString(
                                                                            'user_id')
                                                                        .toString(),
                                                                    _pref
                                                                        .getString(
                                                                            'userToken')
                                                                        .toString(),
                                                                    _useremail
                                                                        .text
                                                                        .toString(),
                                                                    "2")
                                                                .then((value) {
                                                              Navigator.of(
                                                                      dialogContext!)
                                                                  .pop();
                                                              if (value) {
                                                                _isloading =
                                                                    false;
                                                              } else {
                                                                _isloading =
                                                                    false;
                                                              }
                                                            });
                                                          }
                                                        });
                                                      }
                                                    },
                                                    isLoading: _isloading5,
                                                  ),
                                                ],
                                              )
                                        : Container()
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        verify_email == 1
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        25.0, 5.0, 25.0, 5.0),
                                    child: EditTextPassword(
                                      controller: _userpass,
                                      label: 'Your Password',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        25.0, 5.0, 25.0, 5.0),
                                    child: EditTextPassword(
                                      controller: _usercpass,
                                      label: 'Confirm Password',
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            25.0, 0.0, 0, 10.0),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  check_value = !check_value;
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: check_value,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        check_value = value!;
                                                      });
                                                    },
                                                    checkColor: Colors.white,
                                                    activeColor:
                                                        AppColors.primaryColor,
                                                  ),
                                                  const Text(
                                                    'I agree with',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const AppTermsCondition(),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                  'Terms & Condition',
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  CustomButton(
                                    buttonText: 'Continue',
                                    onPressed: () async {
                                      final connectivityResult =
                                          await Connectivity()
                                              .checkConnectivity();

                                      if (connectivityResult ==
                                          ConnectivityResult.none) {
                                        //this.getData();
                                        showCustomToast(
                                            'Net Connection not available');
                                      } else {
                                        if (_formKey.currentState!
                                            .validate()) {}
                                        setState(() {
                                          vaild_data();
                                        });
                                      }
                                    },
                                    isLoading: _isloading6,
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have Account?',
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontFamily: 'assets/fonst/Metropolis-Black.otf')),
            TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                child: const Text('Log in',
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryColor,
                        fontFamily: 'assets/fonst/Metropolis-Black.otf'))),
          ],
        ),
      ),
    );
  }

  Future<void> init(BuildContext context) async {
    await FirebaseApi(context, navigatorKey).initNotification(context);
  }

  vaild_data() {
    _isValid = EmailValidator.validate(_useremail.text);
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    if (_userpass.text.isEmpty) {
      showCustomToast('Please Enter Your Password');
      setState(() {});
    } else if (_usercpass.text.isEmpty) {
      showCustomToast('Please Enter Confirm Password');
      setState(() {});
    } else if (_userpass.text.isNotEmpty) {
      if (_userpass.text.length < 6) {
        showCustomToast('Password must be 6 character');
      } else if (_userpass.text != _usercpass.text) {
        showCustomToast("Password and Confirm Password Doesn't Match");
      } else if (!check_value) {
        showCustomToast("Please Select Terms and Condition ");
      } else if (_usernm.text.isNotEmpty &&
          _useremail.text.isNotEmpty &&
          _usermbl.text.isNotEmpty &&
          _userpass.text.isNotEmpty &&
          _usercpass.text.isNotEmpty &&
          _isValid &&
          check_value) {
        _isloading = false;

        finalRegister(
                _useremail.text,
                _userpass.text,
                country_code,
                _usermbl.text,
                device_name,
                _usernm.text,
                "5",
                constanst.version)
            .then((value) {
          Navigator.of(dialogContext!).pop();
          if (value!) {
            _isloading = false;
          } else {
            _isloading = false;
          }
        });
      }
    } else if (_usernm.text.isNotEmpty &&
        _useremail.text.isNotEmpty &&
        _usermbl.text.isNotEmpty &&
        _userpass.text.isNotEmpty &&
        _usercpass.text.isNotEmpty &&
        _isValid &&
        check_value) {
      _isloading = false;

      finalRegister(_useremail.text, _userpass.text, country_code,
              _usermbl.text, device_name, _usernm.text, "5", constanst.version)
          .then((value) {
        Navigator.of(dialogContext!).pop();
        if (value!) {
          _isloading = false;
        } else {
          _isloading = false;
        }
      });
    } else {}
  }

  Future<bool?> setRegisterUserPhoneno() async {
    setState(() {
      _isloading = true; // Show loader when starting login process
    });
    print("METTHOD 1 CALLED...");
    RegisterUserPhoneno register = RegisterUserPhoneno();

    var res = await registerUserPhoneno(
      _usermbl.text,
      country_code.toString(),
      _usernm.text.toString(),
      device_name,
      '3',
    );

    setState(() {
      _isloading = false; // Show loader when starting login process
    });

    if (res['status'] == 1) {
      register = RegisterUserPhoneno.fromJson(res);
      showCustomToast(res['message']);
      _pref = await SharedPreferences.getInstance();
      _pref.setString('user_id', register.result!.userid.toString());
      _pref.setString('name', register.result!.userName.toString());
      _pref.setString('phone', register.result!.phoneno.toString());
      _pref.setString('userToken', register.result!.userToken.toString());
      _pref.setString('step', register.result!.stepCounter.toString());
      constanst.step = register.result!.stepCounter!;
      /* _pref.setBool('islogin', true);*/
      mbl_otp = 1;
      getSmsCode();
      otp_sent = register.otpSent;
      if (otp_sent == false) {
        mbl_otp = 0;
        verify_phone = 1;
      }
      sms_mbl = register.result!.smsCode!;
      print('otp: $sms_mbl');
      _isloading = true;
      setState(() {});
    } else {
      showCustomToast(res['message']);
      mbl_otp = 0;
      _isloading = false;
      setState(() {});
      return _isloading;
    }
    if (mbl_otp == 1) {
      _isResendButtonEnabled = true;
      _startTimer();
      setState(() {});
    }
    return null;
  }

  Future<bool> setRegisterUserEmail() async {
    setState(() {
      _isloading3 = true;
    });
    print("METHOD 2 CALLED...");

    var res = await registerUserEmail(
        _usernm.text.toString(),
        _useremail.text.toString(),
        '1',
        _pref.getString('userToken').toString(),
        _pref.getString('user_id').toString(),
        device_name);

    setState(() {
      _isloading3 = false;
    });

    print("RESPONSE  ==  $res");

    if (res['status'] == 1) {
      email_otp = 1;
      getSmsCode();

      _isloading = true;
      showCustomToast(res['message']);

      setState(() {});
    } else {
      _isloading = true;
      showCustomToast(res['message']);
      email_otp = 0;
      setState(() {});
    }
    if (email_otp == 1) {
      _countdown = 30;
      _isResendButtonEnabled = true;
      _startTimer();
      setState(() {});
    }
    return _isloading;
  }

  Future<bool> register_mo_verifyotp(
    String otp,
    String userId,
    String phoneno,
    String apiToken,
    String step,
  ) async {
    setState(() {
      _isloading1 = true;
    });
    var res = await reg_mo_verifyotp(otp, userId, phoneno, apiToken, step);
    setState(() {
      _isloading1 = false;
    });
    print("METHOD 3 CALLED...");
    if (res['status'] == 1) {
      showCustomToast(res['message']);
      verify_phone = 1;
      mbl_otp = 0;
      _isloading = true;
    } else {
      _isloading = true;
      showCustomToast(res['message']);
      _isResendButtonEnabled = false;
      _countdown = 30;
    }

    setState(() {});
    return _isloading;
  }

  Future<bool> register_mo_resendotp(
    String userId,
    String apiToken,
    String phoneno,
    countryCode,
  ) async {
    setState(() {
      _isloading2 = true;
    });
    var res = await reg_mo_resendotp(userId, phoneno, apiToken, countryCode);
    setState(() {
      _isloading2 = false;
    });
    print("METHOD 4 CALLED...");
    if (res['status'] == 1) {
      showCustomToast(res['message']);
      otp_sent = res['otp_sent'];
      //verify_phone=1;
      mbl_otp = 1;
      getSmsCode();
      if (otp_sent == false) {
        mbl_otp = 0;
        verify_phone = 1;
      }

      _isloading = true;
    } else {
      _isloading = true;
      showCustomToast(res['message']);
    }
    if (mbl_otp == 1) {
      _countdown = 30;
      _isResendButtonEnabled = true;
      _startTimer();
      setState(() {});
    }
    setState(() {});
    return _isloading;
  }

  Future<bool> register_email_resendotp(
      String userId, String apiToken, String email) async {
    setState(() {
      _isloading4 = true;
    });
    var res = await reg_email_resendotp(userId, apiToken, email);
    setState(() {
      _isloading4 = false;
    });
    print("METHOD 5 CALLED...");
    if (res['status'] == 1) {
      showCustomToast(res['message']);
      _isloading = true;
      //verify_phone=1;
      email_otp = 1;
      getSmsCode();
    } else {
      _isloading = true;
      showCustomToast(res['message']);
    }
    setState(() {});
    if (email_otp == 1) {
      _countdown = 30;
      _isResendButtonEnabled = true;
      _startTimer();
      setState(() {});
    }
    return _isloading;
  }

  Future<bool> register_email_verifyotp(
    String otp,
    String userId,
    String apiToken,
    String email,
    String step,
  ) async {
    setState(() {
      _isloading5 = true;
    });
    var res = await reg_email_verifyotp(otp, userId, apiToken, email, step);
    setState(() {
      _isloading5 = false;
    });
    print("METHOD 6 CALLED...");
    if (res['status'] == 1) {
      showCustomToast("Your Email is Verified");
      verify_email = 1;
      _isloading = true;
      email_otp = 1;
    } else {
      _isloading = true;
      showCustomToast(res['message']);
    }
    setState(() {});
    return _isloading;
  }

  finalRegister(
    String email,
    String password,
    String countryCode,
    String phoneNumber,
    String device,
    String username,
    String stepCounter,
    String version,
  ) async {
    setState(() {
      _isloading6 = true;
    });
    var res = await final_register(
      email,
      password,
      countryCode,
      phoneNumber,
      device,
      username,
      stepCounter,
      _pref.getString('user_id').toString(),
      _pref.getString('userToken').toString(),
      version,
    );
    setState(() {
      _isloading6 = false;
    });
    print("METHOD 7 CALLED...");

    if (res['status'] == 1) {
      register = FinalRegister.fromJson(res);
      showCustomToast(res['message']);
      _pref = await SharedPreferences.getInstance();
      _pref.setString('user_id', register.result!.userid.toString());
      _pref.setString('name', register.result!.userName.toString());
      _pref.setString('email', register.result!.email.toString());
      _pref.setString('userToken', register.result!.userToken.toString());
      _pref.setString('step', register.result!.stepCounter.toString());
      constanst.step = int.parse(register.result!.stepCounter.toString());
      _pref.setBool('islogin', true);
      _pref.setBool('isWithoutLogin', false);
      constanst.userToken = register.result!.userToken.toString();
      constanst.userid = register.result!.userid.toString();
      constanst.step = register.result!.stepCounter!;
      constanst.version.toString();
      constanst.isWithoutLogin == false;

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
      showCustomToast(res['message']);
    }
    setState(() {});
  }

  // Future<bool> add_android_device() async {
  //   /*_onLoading();*/
  //   var res = await androidDevice_Register();
  //   if (res['status'] == 1) {
  //     constanst.usernm = _usernm.text.toString();
  //     SharedPreferences pref = await SharedPreferences.getInstance();
  //     pref.setString('user_id', register.result!.userid.toString());
  //     pref.setString('name', register.result!.userName.toString());
  //     pref.setString('email', register.result!.email.toString());
  //     pref.setString('phone', register.result!.phoneno.toString());
  //     pref.setString('userToken', register.result!.userToken.toString());
  //     pref.setString('step', register.result!.stepCounter.toString());

  //     pref.setBool('islogin', true);

  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (BuildContext context) => MainScreen(0)),
  //         ModalRoute.withName('/'));
  //   } else {
  //     _isloading = true;
  //   }
  //   return _isloading;
  // }

  // Future<bool> add_ios_device() async {
  //   var res = await iosDevice_Register();

  //   if (res['status'] == 1) {
  //     constanst.usernm = _usernm.text.toString();

  //     SharedPreferences pref = await SharedPreferences.getInstance();
  //     pref.setString('user_id', register.result!.userid.toString());
  //     pref.setString('name', register.result!.userName.toString());
  //     pref.setString('email', register.result!.email.toString());
  //     pref.setString('phone', register.result!.phoneno.toString());
  //     pref.setString('userToken', register.result!.userToken.toString());
  //     pref.setString('step', register.result!.stepCounter.toString());
  //     constanst.step = register.result!.stepCounter!;
  //     // _pref.setString('userImage', register.result!.userImage.toString());
  //     pref.setBool('islogin', true);
  //     _isloading = true;
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (BuildContext context) => MainScreen(0)),
  //         ModalRoute.withName('/'));
  //   } else {
  //     _isloading = true;
  //     showCustomToast(res['message']);
  //   }
  //   return _isloading;
  // }
}

class CapitalizeWordsTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Capitalize the first letter of each word
    return TextEditingValue(
      text: toTitleCase(newValue.text),
      selection: newValue.selection,
    );
  }

  String toTitleCase(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text.split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1)}';
      } else {
        return '';
      }
    }).join(' ');
  }
}
