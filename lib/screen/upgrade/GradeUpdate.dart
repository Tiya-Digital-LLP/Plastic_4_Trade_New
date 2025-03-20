// ignore_for_file: camel_case_types, unnecessary_null_comparison, non_constant_identifier_names

import 'dart:io' show Platform;

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/model/GetCategoryGrade.dart' as grade;
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/text_capital.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constroller/GetCategoryGradeController.dart';

class Grade_update extends StatefulWidget {
  const Grade_update({Key? key}) : super(key: key);

  @override
  State<Grade_update> createState() => _Grade_updateState();
}

class _Grade_updateState extends State<Grade_update> {
  //bool category3 = false;
  bool? _isloading;
  bool _isloading1 = false;

  String grade_id = '';
  BuildContext? dialogContext;
  String crown_color = '';
  String plan_name = '';
  final TextEditingController _addgrade = TextEditingController();
  Color _color1 = Colors.black26; //name

  @override
  void initState() {
    super.initState();
    checknetwork();
  }

  Future<void> _updateGrade() async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (constanst.select_gradeId.isNotEmpty) {
      var response = await saveGrade(pref.getString('user_id').toString(),
          pref.getString('userToken').toString(), _addgrade.text);

      setState(() {
        _isloading1 = false;
      });

      if (response != null) {
        if (response['status'] == 1) {
          Navigator.pop(context);
          setState(() {});
          showCustomToast('Grade updated successfully');
        } else {
          showCustomToast(response['message'] ?? 'Failed to update Grade');
        }
      } else {
        showCustomToast('Error: No response from the server');
      }
    } else {
      showCustomToast('Select Minimum 1 Grade');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: GestureDetector(
          child: Image.asset('assets/back.png', height: 50, width: 60),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Update Grade',
          style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'assets/fonst/Metropolis-Black.otf')
              .copyWith(fontSize: 20.0),
        ),
        centerTitle: true, // Ensures the title is centered
        backgroundColor: Colors.white, // Set background color if needed
        scrolledUnderElevation: 0,
        elevation: 0, // Removes shadow if required
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SafeArea(
              top: true,
              left: true,
              right: true,
              maintainBottomViewPadding: true,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(27.0, 5.0, 5.0, 5.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Select Your Grade',
                        style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf')
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    shrinkWrap: true,
                    itemCount: constanst.cat_grade_data.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      grade.Result record = constanst.cat_grade_data[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (constanst.select_gradeId.contains(
                                    record.productgradeId.toString())) {
                                  constanst.select_gradeId
                                      .remove(record.productgradeId.toString());
                                  constanst.select_grade_id =
                                      constanst.select_gradeId.join(",");
                                } else {
                                  constanst.select_gradeId
                                      .add(record.productgradeId.toString());
                                  constanst.select_grade_id =
                                      constanst.select_gradeId.join(",");
                                }
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              height: 54,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13.05),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x3FA6A6A6),
                                    blurRadius: 16.32,
                                    offset: Offset(0, 3.26),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  constanst.select_gradeId.contains(
                                          record.productgradeId.toString())
                                      ? Icon(Icons.check_circle,
                                          color: AppColors.greenWithShade)
                                      : const Icon(Icons.circle_outlined,
                                          color: Colors.black45),
                                  const SizedBox(width: 12),
                                  Text(
                                    record.productGrade.toString(),
                                    style: const TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'assets/fonst/Metropolis-Black.otf',
                                            color: Colors.black)
                                        .copyWith(fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                        ],
                      );
                    },
                  ),
                  10.sbh,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _addgrade,
                      inputFormatters: [
                        CapitalizingTextInputFormatter(),
                        LengthLimitingTextInputFormatter(40),
                      ],
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: "Add Grade",
                        hintStyle: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf')
                            .copyWith(color: Colors.black45),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: _color1),
                            borderRadius: BorderRadius.circular(10.0)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: _color1),
                            borderRadius: BorderRadius.circular(10.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: _color1),
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  100.sbh,
                ],
              ),
            ),
          ),
          if (_isloading!)
            Center(
              child: CustomLottieContainer(
                child: Lottie.asset('assets/loading_animation.json'),
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          buttonText: 'Continue',
          onPressed: () async {
            if (constanst.select_gradeId.isEmpty) {
              showCustomToast('Please Select Grade');
              return;
            }

            setState(() {
              _isloading1 = true; // Start loader for button
            });

            bool success = await setGrade();

            // Close loading dialog
            if (dialogContext != null) {
              Navigator.of(dialogContext!).pop();
            }

            if (_addgrade.text.isNotEmpty) {
              await _updateGrade();
            } else {
              Navigator.pop(context);
            }

            // Navigate to MainScreen if successful
            if (success) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(4),
                ),
              ).then((_) => checknetwork());
            }
          },
          isLoading: _isloading1,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void get_data() async {
    GetCategoryGradeController bt = GetCategoryGradeController();
    constanst.cat_gradedata = bt.setGrade();
    setState(() {
      _isloading = true;
      constanst.cat_gradedata!.then((value) {
        for (var item in value) {
          constanst.cat_grade_data.add(item);
        }
        _isloading = false;
      });
    });
    //
  }

  Future checknetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _isloading = false;
      showCustomToast('Internet Connection not available');
    } else {
      clean_data();
      get_data();
      getProfiless();
    }
  }

  Future getProfiless() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getbussinessprofile(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
      pref.getString('user_id').toString(),
      context,
    );
    setState(() {
      if (res['status'] == 1) {
        grade_id = res['user']['grade_id'];
        constanst.select_gradeId = grade_id.split(",");
      } else {
        showCustomToast(res['message']);
      }
    });
  }

  clean_data() {
    constanst.catdata.clear();
    grade_id = "";
    constanst.cat_gradedata = null;
    constanst.cat_grade_data.clear();
    constanst.select_gradeId.clear();
    constanst.itemsCheck.clear();
    constanst.Type_itemsCheck.clear();
    constanst.Grade_itemsCheck.clear();
    constanst.select_gradname.clear();
    constanst.select_grade_id = "";
    constanst.select_grade_idx = 0;
  }

  Future<bool> setGrade() async {
    setState(() {
      _isloading1 = true; // Start loader
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';
    var stringGrade = constanst.select_gradeId.join(",");

    print('Device Name: $device');

    var res = await addProductgrade(
      pref.getString('user_id') ?? '',
      pref.getString('userToken') ?? '',
      stringGrade.trim(),
      '9',
      device,
    );

    bool isSuccess = res['status'] == 1;
    String message = res['message'] ?? 'An error occurred';

    showCustomToast(message);

    if (isSuccess) {
      clean_data();
    } else {
      setState(() {
        _isloading1 = false; // Stop loader on failure
      });
    }

    return isSuccess;
  }
}
