// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:Plastic4trade/constroller/GetCategoryTypeController.dart';
import 'package:Plastic4trade/model/GetCategoryType.dart' as type;
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

import '../../api/api_interface.dart';
import 'GradeUpdate.dart';

class Type_update extends StatefulWidget {
  const Type_update({Key? key}) : super(key: key);

  @override
  State<Type_update> createState() => _Type_updateState();
}

class _Type_updateState extends State<Type_update> {
  //bool category3 = false;
  //String type_id = '';
  bool? _isloading;
  bool _isloading1 = false;
  BuildContext? dialogContext;
  String crown_color = '';
  String plan_name = '';
  final TextEditingController _addtype = TextEditingController();
  Color _color1 = Colors.black26; //name

  @override
  void initState() {
    super.initState();

    checknetwork();
  }

  void get_data() async {
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
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      setState(() {
        constanst.select_type_id = res['user']['type_id'];
        constanst.select_typeId = constanst.select_type_id.split(",");
      });
    } else {
      showCustomToast(res['message']);
    }
    return res;
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
          'Update Type',
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
          child: _isloading == true
              ? Center(
                  child: CustomLottieContainer(
                  child: Lottie.asset(
                    'assets/loading_animation.json',
                  ),
                ))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 5.0, 5.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Select Your Type',
                          style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf')
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        shrinkWrap: true,
                        itemCount: constanst.cat_type_data.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          type.Result record = constanst.cat_type_data[index];
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (constanst.select_typeId.contains(
                                        record.producttypeId.toString())) {
                                      constanst.select_typeId.remove(
                                          record.producttypeId.toString());
                                      constanst.select_type_id =
                                          constanst.select_typeId.join(",");
                                    } else {
                                      constanst.select_typeId
                                          .add(record.producttypeId.toString());
                                      constanst.select_type_id =
                                          constanst.select_typeId.join(",");
                                    }
                                  });
                                },
                                child: Container(
                                  height: 54,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
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
                                  child: Row(children: [
                                    constanst.select_typeId.contains(
                                            record.producttypeId.toString())
                                        ? Icon(Icons.check_circle,
                                            color: AppColors.greenWithShade)
                                        : const Icon(Icons.circle_outlined,
                                            color: Colors.black45),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Text(record.productType.toString(),
                                        style: const TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf',
                                                color: Colors.black)
                                            .copyWith(fontSize: 17))
                                  ]),
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
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
                            fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          buttonText: 'Continue',
          onPressed: () async {
            if (constanst.select_typeId.isEmpty) {
              showCustomToast('Select Minimum 1 Type');
              return;
            }

            setState(() {
              _isloading1 = true; // Start loader for button
            });

            bool success = await setType();

            // Close dialog
            if (dialogContext != null) {
              Navigator.of(dialogContext!).pop();
            }

            if (_addtype.text.isNotEmpty) {
              await _updateType();
            } else {
              Navigator.pop(context);
            }

            // Navigate to next screen if successful
            if (success) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Grade_update(),
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

  Future<bool> setType() async {
    setState(() {
      _isloading1 = true; // Start loader
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    var res = await addProducttype(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      constanst.select_type_id.trim(),
      '7',
      device,
    );

    setState(() {
      _isloading1 = false; // Start loader
    });

    bool isSuccess = res['status'] == 1;
    String message = res['message'] ?? 'An error occurred';

    showCustomToast(message);

    if (isSuccess) {
      clear_data();
      _isloading1 = false;
    } else {
      setState(() {
        _isloading1 = false; // Stop loader on failure
      });
    }

    return isSuccess;
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
      getProfiless();
    }
  }

  clear_data() {
    constanst.selectcolor_id.clear();
    constanst.select_inserestlocation.clear();
    constanst.select_categotyType.clear();
    constanst.select_categotyId.clear();
    constanst.catdata.clear();
    constanst.cat_data = null;
    constanst.select_type_id = "";
    constanst.select_typeId.clear();
    constanst.select_gradeId.clear();
    constanst.cat_type_data.clear();
    constanst.cat_typedata = null;
  }
}
