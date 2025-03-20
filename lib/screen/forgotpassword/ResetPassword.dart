// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:Plastic4trade/screen/login/LoginScreen.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:flutter/material.dart';

import '../../api/api_interface.dart';

class ResetPassword extends StatefulWidget {
  String? phone;
  String? country_code;
  String? email;
  ResetPassword(
      {Key? key,
      required this.country_code,
      required this.phone,
      required this.email})
      : super(key: key);

  @override
  State<ResetPassword> createState() => _RecentPasswordState();
}

class _RecentPasswordState extends State<ResetPassword> {
  final TextEditingController _userpass = TextEditingController();
  final TextEditingController _usercpass = TextEditingController();
  bool _passwordVisible = false;
  bool _cpasswordVisible = false;
  Color _color4 = Colors.black26;
  Color _color5 = Colors.black26;
  BuildContext? dialogContext;
  bool isloading = false;
  bool _isloading1 = false;

  @override
  Widget build(BuildContext context) {
    return initwidget();
  }

  Widget initwidget() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
            top: true,
            left: true,
            right: true,
            bottom: true,
            child: Column(
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        child: Image.asset('assets/back.png',
                            height: 50, width: 60),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const LoginScreen()),
                              ModalRoute.withName('/'));
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.3,
                      alignment: Alignment.topLeft,
                      child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Reset Password",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          )),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                      child: CustomTextField(
                        controller: _userpass,
                        labelText: "New Password *",
                        obscureText: !_passwordVisible,
                        borderColor: _color4,
                        inputFormatters: [],
                        suffixIcon: IconButton(
                          icon: _passwordVisible
                              ? Image.asset('assets/hidepassword.png')
                              : Image.asset(
                                  'assets/Vector.png',
                                  width: 20.0,
                                  height: 20.0,
                                ),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            _color4 = AppColors.red;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            showCustomToast('Please Enter Your Password');
                            setState(() {
                              _color4 = AppColors.red;
                            });
                          } else {
                            setState(() {
                              _color4 = AppColors.greenWithShade;
                            });
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (value.isEmpty) {
                            showCustomToast('Please Enter Your Password');
                            setState(() {
                              _color4 = AppColors.red;
                            });
                          } else {
                            setState(() {
                              _color4 = AppColors.greenWithShade;
                            });
                          }
                          var numValue = value.length;
                          if (numValue < 6) {
                            showCustomToast(
                                'Your Password Require Minimum 6 Character');
                            _color4 = AppColors.red;
                          } else {
                            _color4 = AppColors.greenWithShade;
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                      child: CustomTextField(
                        controller: _usercpass,
                        labelText: "Confirm Password *",
                        obscureText: !_cpasswordVisible,
                        borderColor: _color5,
                        inputFormatters: [],
                        suffixIcon: IconButton(
                          icon: _cpasswordVisible
                              ? Image.asset('assets/hidepassword.png')
                              : Image.asset(
                                  'assets/Vector.png',
                                  width: 20.0,
                                  height: 20.0,
                                ),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _cpasswordVisible = !_cpasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            _color5 = AppColors.red;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            showCustomToast('Please Enter Your Password');
                            setState(() {
                              _color5 = AppColors.red;
                            });
                          } else {
                            setState(() {
                              _color5 = AppColors.greenWithShade;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          buttonText: 'Save & Continue',
          onPressed: () {
            vaild_data();
          },
          isLoading: _isloading1,
        ),
      ),
    );
  }

  vaild_data() {
    var numValue = _userpass.text.length;

    if (_userpass.text.isEmpty && _usercpass.text.isEmpty) {
      _color4 = AppColors.red;
      _color5 = AppColors.red;
      setState(() {});
    }
    if (_userpass.text.isEmpty) {
      _color4 = AppColors.red;
      setState(() {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        showCustomToast('Please Enter Your Password');
      });
    } else if (_userpass.text.isNotEmpty) {
      if (numValue < 6) {
        showCustomToast('Your Password Require Minimum 6 Character ');
        _color4 = AppColors.red;
        setState(() {});
      } else if (_usercpass.text.isEmpty) {
        _color5 = AppColors.red;
        setState(() {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          showCustomToast('Please Enter Your Confirm Password');
        });
      } else if (_userpass.text != _usercpass.text) {
        showCustomToast("Password and Confirm Password Doesn't Match");
      } else if (_userpass.text.isNotEmpty && _usercpass.text.isNotEmpty) {
        reset_password(_userpass.text.toString(), widget.country_code,
                widget.phone, widget.email)
            .then((value) {
          if (dialogContext != null) {
            Navigator.of(dialogContext!).pop();
          }
          if (value) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const LoginScreen()),
                ModalRoute.withName('/'));
          } else {}
        });
      }
    } else if (_usercpass.text.isEmpty) {
      _color5 = AppColors.red;
      setState(() {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        showCustomToast('Please Enter Your Confirm Password');
      });
    } else if (_userpass.text != _usercpass.text) {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast("Password and Confirm Password Doesn't Match");
    } else if (_userpass.text.isNotEmpty && _usercpass.text.isNotEmpty) {
      reset_password(_userpass.text.toString(), widget.country_code,
              widget.phone, widget.email)
          .then((value) {
        if (dialogContext != null) {
          Navigator.of(dialogContext!).pop();
        }
        if (value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const LoginScreen()),
              ModalRoute.withName('/'));
        } else {}
      });
    }
  }

  Future<bool> reset_password(password, countryCode, phoneno, email) async {
    setState(() {
      _isloading1 = true; // Show loader when starting login process
    });
    var res = await resetPassword(password, countryCode, phoneno, email);
    setState(() {
      _isloading1 = false; // Show loader when starting login process
    });
    String? msg = res['message'];
    showCustomToast("$msg");
    if (res['status'] == 1) {
      isloading = true;
      showCustomToast(res['message']);
    } else {
      showCustomToast(res['message']);
      isloading = false;
    }
    return isloading;
  }
}
