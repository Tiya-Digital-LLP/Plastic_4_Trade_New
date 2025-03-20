// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names

import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/back_icon.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/edittext.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Plastic4trade/screen/login/LoginScreen.dart';
import 'package:Plastic4trade/screen/OtpScreen.dart';
import 'package:slide_switcher/slide_switcher.dart';
import '../../api/api_interface.dart';
import 'package:email_validator/email_validator.dart';

class ForgetPasswprd extends StatefulWidget {
  const ForgetPasswprd();

  @override
  State<ForgetPasswprd> createState() => _ForgetPasswprdState();
}

class _ForgetPasswprdState extends State<ForgetPasswprd>
    with SingleTickerProviderStateMixin {
  final TextEditingController _useremail = TextEditingController();
  final TextEditingController _usermbl = TextEditingController();
  Color _color3 = Colors.black26;
  late AnimationController _animationController;
  int switcherIndex2 = 0;
  String country_code = '+91';
  String defaultCountryCode = 'IN';
  Country? _selectedCountry;
  BuildContext? dialogContext;
  bool isLoading = false;
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    initCountry();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initCountry() async {
    final country = await getCountryByCountryCode(context, defaultCountryCode);
    setState(() {
      _selectedCountry = country;
    });
  }

  Future<void> _onLoading() async {
    setState(() {
      isLoading = true;
    });
  }

  Future<void> _hideLoading() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return initwidget();
  }

  Widget initwidget() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          top: true,
          left: true,
          right: true,
          bottom: true,
          maintainBottomViewPadding: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  header(),
                  const SizedBox(
                    height: 10,
                  ),
                  SlideSwitcher(
                    containerColor: AppColors.primaryColor,
                    onSelect: (int index) =>
                        setState(() => switcherIndex2 = index),
                    containerHeight: 40,
                    containerWight: 350,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: switcherIndex2 == 0
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: switcherIndex2 == 0
                              ? AppColors.primaryColor
                              : Colors.white,
                        ),
                      ),
                      Text(
                        'Moblie',
                        style: TextStyle(
                          fontWeight: switcherIndex2 == 1
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: switcherIndex2 == 1
                              ? AppColors.primaryColor
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  switcherIndex2 == 0 ? email_otp() : phone_otp()
                ],
              ),
            ),
          )),
      bottomNavigationBar: Container(
        child: TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
          child: const Text('Log in',
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryColor,
                  fontFamily: 'assets/fonst/Metropolis-Black.otf')),
        ),
      ),
    );
  }

  Widget email_otp() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 10.0),
          child: EditText(
            controller: _useremail,
            label: 'Enter Your Email',
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        CustomButton(
          buttonText: 'Submit',
          onPressed: () async {
            bool _isValid = EmailValidator.validate(_useremail.text);

            if (_useremail.text.isNotEmpty) {
              if (_isValid) {
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                bool otpSuccess =
                    await get_otp('', '', _useremail.text.toString());

                if (otpSuccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => otp(
                        phone: '',
                        countrycode: '',
                        email: _useremail.text.toString(),
                      ),
                    ),
                  );
                }
              } else {
                showCustomToast('Please Enter Correct Email');
              }
            } else {
              showCustomToast('Please Enter Your Email');
            }
          },
          isLoading: isLoading,
        ),
      ],
    );
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

  Widget phone_otp() {
    final country = _selectedCountry;
    return Column(
      children: [
        const SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(
              height: 55,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black26),
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: const EdgeInsets.fromLTRB(25.0, 5.0, 5.0, 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      _onPressedShowBottomSheet();
                    },
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
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 57,
                margin: const EdgeInsets.only(right: 25),
                child: CustomTextField(
                  controller: _usermbl,
                  labelText: "Mobile Number *",
                  borderColor: _color3,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(11),
                  ],
                  onFieldSubmitted: (value) {
                    var numValue = value.length;
                    if (numValue >= 6 && numValue < 12) {
                      _color3 = AppColors.greenWithShade;
                    } else {
                      WidgetsBinding.instance.focusManager.primaryFocus
                          ?.unfocus();
                      _color3 = AppColors.red;
                      showCustomToast('Please Enter Correct Number');
                      setState(() {});
                    }
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      WidgetsBinding.instance.focusManager.primaryFocus
                          ?.unfocus();
                      showCustomToast('Please Enter Your Number');
                      setState(() {});
                    } else {
                      setState(() {
                        _color3 = AppColors.greenWithShade;
                      });
                    }
                  },
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        CustomButton(
          buttonText: 'Submit',
          onPressed: () async {
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            if (_usermbl.text.isNotEmpty) {
              var numValue = _usermbl.text.length;
              if (numValue >= 6 && numValue < 12) {
                setState(() {
                  _color3 = AppColors.greenWithShade;
                });
                bool otpSuccess =
                    await get_otp(country_code, _usermbl.text.toString(), '');

                if (otpSuccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => otp(
                        phone: _usermbl.text.toString(),
                        countrycode: country_code,
                        email: '',
                      ),
                    ),
                  );
                }
              } else {
                setState(() {
                  _color3 = AppColors.red;
                });
                showCustomToast('Please Enter Correct Number');
              }
            } else {
              showCustomToast('Please Enter Your Number');
              setState(() {
                _color3 = AppColors.red;
              });
            }
          },
          isLoading: isLoading,
        ),
      ],
    );
  }

  Future<bool> get_otp(String countryCode, String phone, String email) async {
    await _onLoading();
    var res = await forgotpassword_ME(phone, countryCode, email);

    if (res['status'] == 1) {
      showCustomToast(res['message']);
      await _hideLoading();
      return true;
    } else {
      showCustomToast(res['message']);
      await _hideLoading();
      return false;
    }
  }

  Widget header() {
    return Column(children: [
      Align(
        alignment: Alignment.topLeft,
        child: CustomBackIcon(),
      ),
      Image.asset(
        'assets/forgetPassword.png',
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width / 3.2,
        height: 170,
      ),
      const SizedBox(
        height: 35.0,
        child: Text('Forgot password?',
            style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: 'assets/fonst/Metropolis-Black.otf')),
      ),
      SizedBox(
        height: 20.0,
        width: MediaQuery.of(context).size.width / 1.09,
        child: Text('Enter your email/Moblie  for verification process',
            //maxLines: 2,
            style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'assets/fonst/Metropolis-Black.otf')
                .copyWith(fontWeight: FontWeight.w400)),
      ),
      SizedBox(
        height: 40.0,
        width: MediaQuery.of(context).size.width / 1.09,
        child: Text('we will send 4 digits code to your email/Moblie',
            //maxLines: 2,
            style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'assets/fonst/Metropolis-Black.otf')
                .copyWith(fontWeight: FontWeight.w400)),
      ),
    ]);
  }
}
