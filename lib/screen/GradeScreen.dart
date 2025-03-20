// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

import 'dart:io' show Platform;

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/model/GetCategoryGrade.dart' as grade;
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/text_capital.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constroller/GetCategoryGradeController.dart';
import '../widget/MainScreen.dart';

class Grade extends StatefulWidget {
  const Grade({Key? key}) : super(key: key);

  @override
  State<Grade> createState() => _TypeState();
}

class _TypeState extends State<Grade> {
  //bool category3 = false;
  bool? _isloading;
  //String grade_id = '';
  BuildContext? dialogContext;
  bool _isloading1 = false;
  final TextEditingController _addgrade = TextEditingController();
  Color _color1 = Colors.black26; //name

  @override
  void initState() {
    super.initState();

    checknetwork();
  }

  Future<bool> _onbackpress(BuildContext context) async {
    Navigator.pop(context);
    return Future.value(true);
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
          'Grade',
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
      // ignore: deprecated_member_use
      body: PopScope(
        canPop: false,
        // ignore: deprecated_member_use
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          _onbackpress(context);
        },
        child: _isloading == true
            ? Align(
                alignment: Alignment.center,
                child: Center(
                  child: CustomLottieContainer(
                    child: Lottie.asset(
                      'assets/loading_animation.json',
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
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
                                    color: AppColors.blackColor,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf')
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: constanst.cat_grade_data.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            grade.Result record =
                                constanst.cat_grade_data[index];
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      //category3 = true;
                                      if (constanst.select_gradeId.contains(
                                          record.productgradeId.toString())) {
                                        //constanst.Grade_itemsCheck1[index] = Icons.check_circle_outline;
                                        constanst.select_gradeId.remove(
                                            record.productgradeId.toString());
                                      } else {
                                        //constanst.Grade_itemsCheck1[index] = Icons.circle_outlined;
                                        constanst.select_gradeId.add(
                                            record.productgradeId.toString());
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 54,
                                    padding: const EdgeInsets.all(15),
                                    decoration: ShapeDecoration(
                                      color: AppColors.backgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(13.05),
                                      ),
                                      shadows: [
                                        BoxShadow(
                                          color: AppColors.boxShadowforshimmer,
                                          blurRadius: 16.32,
                                          offset: Offset(0, 3.26),
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        constanst.select_gradeId.contains(record
                                                .productgradeId
                                                .toString())
                                            ? Icon(Icons.check_circle,
                                                color: AppColors.greenWithShade)
                                            : const Icon(Icons.circle_outlined,
                                                color: AppColors.black45Color),
                                        const SizedBox(width: 12),
                                        Text(record.productGrade.toString(),
                                            style: const TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        'assets/fonst/Metropolis-Black.otf')
                                                .copyWith(fontSize: 17))
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 7),
                              ],
                            );
                          }),
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
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf')
                                .copyWith(color: Colors.black45),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: _color1),
                                borderRadius: BorderRadius.circular(10.0)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: _color1),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: _color1),
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                        ),
                      ),
                      100.sbh,
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          buttonText: 'Continue',
          onPressed: () async {
            if (constanst.select_gradeId.isEmpty) {
              showCustomToast('Please Select Grade');
            } else {
              setState(() {
                _isloading1 = true; // Show loader
              });

              bool success = await setGrade();

              setState(() {
                _isloading1 = false; // Hide loader after setGrade completes
              });

              if (dialogContext != null) {
                Navigator.of(dialogContext!).pop();
              }
              if (_addgrade.text.isNotEmpty) {
                await _updateGrade();
              } else {
                Navigator.pop(context);
              }
              if (success) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(0),
                  ),
                );
              }
            }
          },
          isLoading: _isloading1,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void get_data() async {
    // Clear the existing cat_grade_data list
    constanst.cat_grade_data.clear();

    GetCategoryGradeController bt = GetCategoryGradeController();
    constanst.cat_gradedata = bt.setGrade();
    _isloading = true;
    constanst.cat_gradedata!.then((value) {
      for (var item in value) {
        constanst.cat_grade_data.add(item);
      }
      _isloading = false;
      setState(() {});
    });
  }

  checknetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      constanst.catdata.clear();
      _isloading = false;
      showCustomToast('Internet Connection not available');
    } else {
      clear_data();
      get_data();
    }
  }

  clear_data() {
    constanst.selectcolor_id.clear();
    constanst.select_inserestlocation.clear();
    constanst.select_categotyType.clear();
    constanst.select_categotyId.clear();
    constanst.catdata.clear();
    constanst.cat_data = null;
    constanst.select_typeId.clear();
    constanst.select_gradeId.clear();
    constanst.cat_type_data.clear();
    constanst.cat_typedata = null;
  }

  Future<bool> setGrade() async {
    setState(() {
      _isloading1 = true; // Show loader at the start
    });

    var stringGrade = constanst.select_gradeId.join(",");
    constanst.step = 9;

    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    var res = await addgrade(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      stringGrade.trim(),
      constanst.step.toString(),
      device,
    );

    setState(() {
      _isloading1 = false; // Hide loader when process completes
    });

    bool isSuccess = res['status'] == 1;

    if (isSuccess) {
      showCustomToast('Interest Selected Successfully');
      constanst.isgrade = false;
    } else {
      showCustomToast(res['message']);
    }

    return isSuccess;
  }
}
