import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/screen/auth/email_otp.dart';
import 'package:Plastic4trade/screen/register/RegisterScreen.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailNameRegistration extends StatefulWidget {
  const EmailNameRegistration({super.key});

  @override
  State<EmailNameRegistration> createState() => _EmailNameRegistrationState();
}

class _EmailNameRegistrationState extends State<EmailNameRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernm = TextEditingController();
  final TextEditingController _useremail = TextEditingController();

  Color _color1 = Colors.black26;
  Color _color2 = Colors.black26;

  bool _isloading = false;
  String country_code = '+91';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Name & Email",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _usernm,
                labelText: "Your Name",
                borderColor: _color1,
                textCapitalization: TextCapitalization.words,
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
                    WidgetsBinding.instance.focusManager.primaryFocus
                        ?.unfocus();
                    showCustomToast('Name Should be 30 Character');
                  } else {
                    _color1 = AppColors.greenWithShade;
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.isEmpty) {
                    WidgetsBinding.instance.focusManager.primaryFocus
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
                    WidgetsBinding.instance.focusManager.primaryFocus
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
              10.sbh,
              CustomTextField(
                controller: _useremail,
                labelText: "Your Email",
                borderColor: _color2,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@._-]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return TextEditingValue(
                      text: newValue.text.toLowerCase(),
                      selection: newValue.selection,
                    );
                  }),
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    showCustomToast('Please Enter Your Email ');

                    _color2 = AppColors.red;
                  } else {}
                  return null;
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _color2 = AppColors.greenWithShade;
                    });
                  } else if (value.isEmpty) {
                    setState(() {
                      WidgetsBinding.instance.focusManager.primaryFocus
                          ?.unfocus();
                      _color2 = AppColors.red;
                    });
                  }
                },
                onFieldSubmitted: (value) {
                  if (!EmailValidator.validate(value)) {
                    _color2 = AppColors.red;
                    WidgetsBinding.instance.focusManager.primaryFocus
                        ?.unfocus();
                    showCustomToast('Please Enter Correct Email');
                  } else if (value.isNotEmpty) {
                    _color2 = AppColors.greenWithShade;
                  }
                },
              ),
              20.sbh,
              // Send OTP Button
              CustomButton(
                buttonText: 'Send OTP',
                onPressed: () async {
                  FocusScope.of(context).unfocus();

                  if (_formKey.currentState!.validate()) {
                    if (_usernm.text.isEmpty) {
                      showCustomToast('Please Enter Your Name');
                      setState(() {
                        _color1 = AppColors.red;
                      });
                    } else if (_useremail.text.isEmpty) {
                      showCustomToast('Please Enter Your Email');
                      setState(() {
                        _color2 = AppColors.red;
                      });
                    } else if (!EmailValidator.validate(_useremail.text)) {
                      showCustomToast('Please Enter Correct Email');
                      setState(() {
                        _color2 = AppColors.red;
                      });
                    } else {
                      setEmail();
                    }
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

  setEmail() async {
    setState(() {
      _isloading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    String? userId = pref.getString('user_id');
    String? apiToken = pref.getString('userToken');
    String? deviceId = pref.getString('device_id');
    String device = Platform.isAndroid ? 'android' : 'ios';

    print('Device Name: $device');

    var res = await email_name_v2(
      userId.toString(),
      _usernm.text.toString(),
      apiToken.toString(),
      deviceId.toString(),
      device,
      _useremail.text.toString(),
    );

    print('userId: $userId');
    print('userName: ${_usernm.text.toString()}');
    print('userToken: $apiToken');
    print('deviceId: $deviceId');
    print('device: $device');
    print('email: ${_useremail.text.toString()}');
    print('res: $res');

    setState(() {
      _isloading = false;
    });

    if (res['status'] == 1) {
      await pref.setString('appusername', _usernm.text.toString());
      showCustomToast('OTP Sent Successfully Please Check Your Email');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailOtp(
              userId: userId.toString(),
              userName: _usernm.text.toString(),
              deviceId: deviceId.toString(),
              device: device,
              email: _useremail.text.toString(),
              userToken: apiToken.toString(),
            ),
          ),
        );
      }
    } else {
      showCustomToast(res['message']);
    }
  }
}
