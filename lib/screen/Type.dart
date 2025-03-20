// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:Plastic4trade/constroller/GetCategoryTypeController.dart';
import 'package:Plastic4trade/model/GetCategoryType.dart' as type;
import 'package:Plastic4trade/screen/GradeScreen.dart';
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

import '../api/api_interface.dart';

class Type extends StatefulWidget {
  const Type({Key? key}) : super(key: key);

  @override
  State<Type> createState() => _TypeState();
}

class _TypeState extends State<Type> {
  bool? _isloading;
  bool _isloading1 = false;
  BuildContext? dialogContext;
  final TextEditingController _addtype = TextEditingController();
  Color _color1 = Colors.black26; //name

  @override
  void initState() {
    super.initState();

    checknetwork();
  }

  Future<void> _updateType() async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (constanst.select_typeId.isNotEmpty) {
      var response = await saveType(pref.getString('user_id').toString(),
          pref.getString('userToken').toString(), _addtype.text);

      setState(() {
        _isloading1 = false;
      });

      if (response != null) {
        if (response['status'] == 1) {
          Navigator.pop(context);
          setState(() {});
          showCustomToast('Type updated successfully');
        } else {
          showCustomToast(response['message'] ?? 'Failed to update Type');
        }
      } else {
        showCustomToast('Error: No response from the server');
      }
    } else {
      showCustomToast('Select Minimum 1 Type');
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
    constanst.cat_type_data.clear();
    constanst.cat_typedata = null;
  }

  void get_data() {
    GetCategoryTypeController bType = GetCategoryTypeController();
    constanst.cat_typedata = bType.setType();
    _isloading = true;
    constanst.cat_typedata!.then((value) {
      setState(() {
        for (var item in value) {
          constanst.cat_type_data.add(item);
        }
        _isloading = false;
      });
    });
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
          'Type',
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
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            top: true,
            left: true,
            right: true,
            maintainBottomViewPadding: true,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  _isloading == true
                      ? Center(
                          child: CustomLottieContainer(
                            child: Lottie.asset(
                              'assets/loading_animation.json',
                            ),
                          ),
                        )
                      : Column(children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(27.0, 5.0, 5.0, 5.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Select Your Type',
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              shrinkWrap: true,
                              itemCount: constanst.cat_type_data.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                type.Result record =
                                    constanst.cat_type_data[index];
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (constanst.select_typeId.contains(
                                              record.producttypeId
                                                  .toString())) {
                                            constanst.select_typeId.remove(
                                                record.producttypeId
                                                    .toString());
                                          } else {
                                            constanst.select_typeId.add(record
                                                .producttypeId
                                                .toString());
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
                                              color:
                                                  AppColors.boxShadowforshimmer,
                                              blurRadius: 16.32,
                                              offset: Offset(0, 3.26),
                                              spreadRadius: 0,
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            constanst.select_typeId.contains(
                                                    record.producttypeId
                                                        .toString())
                                                ? Icon(Icons.check_circle,
                                                    color: AppColors
                                                        .greenWithShade)
                                                : const Icon(
                                                    Icons.circle_outlined,
                                                    color:
                                                        AppColors.black45Color),
                                            const SizedBox(width: 12),
                                            Text(record.productType.toString(),
                                                style: const TextStyle(
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                              controller: _addtype,
                              inputFormatters: [
                                CapitalizingTextInputFormatter(),
                                LengthLimitingTextInputFormatter(40),
                              ],
                              keyboardType: TextInputType.text,
                              style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf'),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: "Add Type",
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
                        ]),
                ])),
          )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          buttonText: 'Continue',
          onPressed: () async {
            if (constanst.select_typeId.isEmpty) {
              showCustomToast('Select Minimum 1 Type');
            } else {
              setState(() {
                _isloading1 = true; // Start loader before calling setType
              });

              bool success = await setType();

              if (dialogContext != null) {
                Navigator.of(dialogContext!).pop();
              }

              if (_addtype.text.isNotEmpty) {
                await _updateType();
              } else {
                Navigator.pop(context);
              }

              // Navigate based on success
              if (success) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Grade()),
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

  Future<bool> setType() async {
    setState(() {
      _isloading1 = true; // Start loader
    });

    var Stringtype = constanst.select_typeId.join(",");
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    constanst.step = 8;

    var res = await addtype(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      Stringtype.trim(),
      constanst.step.toString(),
      device,
    );

    setState(() {
      _isloading1 = false; // Stop loader after operation
    });

    bool isSuccess = res['status'] == 1;

    if (isSuccess) {
      showCustomToast(res['message']);
      constanst.istype = false;
    } else {
      showCustomToast(res['message']);
    }

    return isSuccess;
  }

  checknetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _isloading = false;
      showCustomToast('Internet Connection not available');
    } else {
      clear_data();
      get_data();
    }
  }
}
