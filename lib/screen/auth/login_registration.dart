import 'dart:io';
import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/main.dart';
import 'package:Plastic4trade/screen/auth/phone_otp.dart';
import 'package:Plastic4trade/screen/privacy_policy.dart';
import 'package:Plastic4trade/screen/terms_condtion.dart';

import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:android_id/android_id.dart';
import 'package:country_calling_code_picker/country.dart';
import 'package:country_calling_code_picker/country_code_picker.dart';
import 'package:country_calling_code_picker/functions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRegistration extends StatefulWidget {
  const LoginRegistration({super.key});

  @override
  State<LoginRegistration> createState() => _LoginRegistrationState();
}

class _LoginRegistrationState extends State<LoginRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usermbl = TextEditingController();

  Color _color1 = Colors.black26;
  bool _isloading = false;
  String country_code = '+91';
  String? deviceId;

  Country? _selectedCountry;
  String defaultCountryCode = 'IN';
  late SharedPreferences _pref;

  @override
  void initState() {
    super.initState();
    initCountry();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _pref = await SharedPreferences.getInstance();
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
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
      await _pref.setString('device_id', deviceId.toString());
      print('Device ID saved: $deviceId');
    } else {
      print('Device ID is null.');
    }
  }

  void initCountry() async {
    final country = await getCountryByCountryCode(context, defaultCountryCode);
    setState(() {
      _selectedCountry = country;
    });
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

  @override
  Widget build(BuildContext context) {
    final country = _selectedCountry;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Column(
                    children: [
                      20.sbh,
                      // Skip Button
                      if (!Platform.isAndroid)
                        InkWell(
                          onTap: () async {
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            constanst.isWithoutLogin = true;
                            pref.setBool('isWithoutLogin', true);
                            setState(() {});
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainScreen(0)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: AppColors.gray,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: AppColors.gray,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // App Logo
                      Image.asset(
                        'assets/plastic4trade logo final.png',
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 140,
                      ),
                      // Title
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf',
                        ),
                      ),
                      Text(
                        'Log in into your account',
                        style: TextStyle(
                          fontSize: 21.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf',
                        ),
                      ),
                      35.sbh,
                      // Mobile Number Input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _onPressedShowBottomSheet,
                              child: Container(
                                height: 55,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: AppColors.gray,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      country!.flag,
                                      package: countryCodePackageName,
                                      width: 30,
                                    ),
                                    2.sbw,
                                    Text(
                                      country.callingCode,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                    2.sbw,
                                    Icon(Icons.keyboard_arrow_down_outlined)
                                  ],
                                ),
                              ),
                            ),
                            8.sbw,
                            Expanded(
                              child: AutofillGroup(
                                child: CustomTextField(
                                  controller: _usermbl,
                                  labelText: "Mobile Number",
                                  borderColor: _color1,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  autofillHints: [
                                    AutofillHints.telephoneNumber,
                                  ],
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    TextInput.finishAutofillContext();
                                    if ((country_code == '+91' &&
                                            value.length == 10) ||
                                        (country_code != '+91' &&
                                            value.length >= 6)) {
                                      setState(() =>
                                          _color1 = AppColors.greenWithShade);
                                    } else {
                                      setState(() => _color1 = AppColors.red);
                                      showCustomToast(
                                          'Please Enter a Valid Mobile Number');
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      if (country_code == '+91') {
                                        _color1 = value.length == 10
                                            ? AppColors.greenWithShade
                                            : AppColors.red;
                                      } else {
                                        _color1 = value.length >= 6
                                            ? AppColors.greenWithShade
                                            : AppColors.red;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      10.sbh,
                      CustomButton(
                        buttonText: 'Send OTP',
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (validateMobileNumber()) {
                            if (_formKey.currentState!.validate()) {
                              setlogin();
                            }
                          }
                        },
                        isLoading: _isloading,
                      ),
                    ],
                  ),
                  10.sbh,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: RichText(
                      text: TextSpan(
                        text: 'By continuing, you agree to Plastic4Trade ',
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf',
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms & Condition ',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryColor,
                              fontFamily: 'assets/fonts/Metropolis-Black.otf',
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AppTermsCondition(),
                                  ),
                                );
                              },
                          ),
                          TextSpan(
                            text: ' and ',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: 'assets/fonts/Metropolis-Black.otf',
                            ),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryColor,
                              fontFamily: 'assets/fonts/Metropolis-Black.otf',
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PrivacyPolicy(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Image.asset('assets/image 2.png'),
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

  bool validateMobileNumber() {
    String mobile = _usermbl.text.trim();

    if (country_code == '+91') {
      if (mobile.length != 10) {
        showCustomToast('Please enter a valid 10-digit mobile number.');
        return false;
      }
    } else {
      if (mobile.length < 6) {
        showCustomToast('Please enter a valid mobile number (min 6 digits).');
        return false;
      }
    }
    return true;
  }

  setlogin() async {
    setState(() {
      _isloading = true;
    });

    var res = await login_user_v2(
      _selectedCountry!.callingCode.toString(),
      _usermbl.text.toString(),
      deviceId.toString(),
    );

    print('countrycode:${_selectedCountry!.callingCode}');
    print('phone:${_usermbl.text}');

    setState(() {
      _isloading = false;
    });

    if (res['status'] == 1) {
      _pref = await SharedPreferences.getInstance();
      await _pref.setString('user_id', res['user_id'].toString());
      await _pref.setString('phoneno', _usermbl.text.toString());
      await _pref.setString(
          'countryCode', _selectedCountry!.callingCode.toString());
      await _pref.setBool('islogin', true);
      await _pref.setBool('isWithoutLogin', false);

      if (Platform.isAndroid) {
        androidDevice_Register(
          _pref.getString('fcmToken').toString(),
          _pref.getString('user_id').toString(),
          deviceId.toString(),
        );
      } else if (Platform.isIOS) {
        iosDevice_Register(
          _pref.getString('fcmToken').toString(),
          _pref.getString('user_id').toString(),
          deviceId.toString(),
        );
      }

      print('user_id: ${_pref.getString('user_id').toString()}');
      print('deviceid: ${deviceId.toString()}');

      showCustomToast('OTP Sent Successfully on WhatsApp or Message');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneOtp(
              userId: res['user_id'].toString(),
              phoneNo: _usermbl.text.toString(),
              countryCode: _selectedCountry!.callingCode.toString(),
              deviceId: deviceId.toString(),
            ),
          ),
        );
      }
    } else {
      showCustomToast(res['message']);
    }
  }
}
