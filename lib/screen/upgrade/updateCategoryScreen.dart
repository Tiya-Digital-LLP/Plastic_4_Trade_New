// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

import 'dart:io';

import 'package:Plastic4trade/constroller/GetCategoryController.dart';
import 'package:Plastic4trade/model/GetCategory.dart' as cat;
import 'package:Plastic4trade/screen/upgrade/Type_update.dart';
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

class UpdateCategoryScreen extends StatefulWidget {
  const UpdateCategoryScreen({Key? key}) : super(key: key);

  @override
  State<UpdateCategoryScreen> createState() => _UpdateCategoryScreenState();
}

class RadioModel {
  bool isSelected;
  final String buttonText;

  RadioModel(this.isSelected, this.buttonText);
}

class _UpdateCategoryScreenState extends State<UpdateCategoryScreen> {
  List<RadioModel> sampleData = <RadioModel>[];
  List<RadioModel> sampleData1 = <RadioModel>[];

  bool? _isloading;
  bool _isloading1 = false;
  BuildContext? dialogContext;
  String crown_color = '';
  String plan_name = '';
  final TextEditingController _addcategory = TextEditingController();
  Color _color1 = Colors.black26; //name

  void get_data() async {
    GetCategoryController bt = GetCategoryController();
    constanst.cat_data = bt.setlogin();
    _isloading = true;
    constanst.cat_data!.then((value) {
      setState(() {
        for (var item in value) {
          constanst.catdata.add(item);
        }
        _isloading = false;
      });
    });
    //
  }

  clear_data() {
    constanst.selectcolor_id.clear();
    constanst.select_inserestlocation.clear();
    constanst.select_categotyType.clear();
    constanst.select_categotyId.clear();
    constanst.catdata.clear();
    constanst.cat_data = null;
  }

  @override
  initState() {
    super.initState();

    sampleData.add(RadioModel(false, 'Domestic'));
    sampleData.add(RadioModel(false, 'International'));
    sampleData1.add(RadioModel(false, 'Buy Post'));
    sampleData1.add(RadioModel(false, 'Sell Post'));
    constanst.select_cat_idx = -1;
    checknetwork();
  }

  Future<void> _updateCategory() async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (constanst.select_categotyType.isNotEmpty) {
      var response = await saveCategory(pref.getString('user_id').toString(),
          pref.getString('userToken').toString(), _addcategory.text);

      setState(() {
        _isloading1 = false;
      });

      if (response != null) {
        if (response['status'] == 1) {
          Navigator.pop(context);
          setState(() {});
          showCustomToast('Category updated successfully');
        } else {
          showCustomToast(response['message'] ?? 'Failed to update Category');
        }
      } else {
        showCustomToast('Error: No response from the server');
      }
    } else {
      showCustomToast('Select Minimum 1 Category');
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
          'Update Category',
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
      body: _isloading == false
          ? SingleChildScrollView(
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
                          SizedBox(
                            height: 80,
                            child: Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              margin: const EdgeInsets.fromLTRB(
                                  25.0, 5.0, 25.0, 10.0),
                              child: Container(
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13.05),
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
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        8.0,
                                        8.0,
                                        0.0,
                                        0.0,
                                      ),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'Where would you like to do your business?',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf'),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            width: 120,
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (sampleData.first
                                                              .isSelected ==
                                                          false) {
                                                        sampleData.first
                                                            .isSelected = true;

                                                        constanst
                                                            .select_inserestlocation
                                                            .add(sampleData
                                                                .first
                                                                .buttonText);
                                                      } else {
                                                        sampleData.first
                                                            .isSelected = false;
                                                        constanst
                                                            .select_inserestlocation
                                                            .remove(sampleData
                                                                .first
                                                                .buttonText);
                                                      }
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      sampleData.first
                                                                  .isSelected ==
                                                              true
                                                          ? Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color: AppColors
                                                                  .greenWithShade)
                                                          : const Icon(
                                                              Icons
                                                                  .circle_outlined,
                                                              color: Colors
                                                                  .black38),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        sampleData
                                                            .first.buttonText,
                                                        style: const TextStyle(
                                                                fontSize: 13.0,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-Black.otf')
                                                            .copyWith(
                                                                fontSize: 17),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 150,
                                            height: 30,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (sampleData
                                                          .last.isSelected ==
                                                      false) {
                                                    sampleData.last.isSelected =
                                                        true;

                                                    constanst
                                                        .select_inserestlocation
                                                        .add(sampleData
                                                            .last.buttonText);
                                                  } else {
                                                    sampleData.last.isSelected =
                                                        false;
                                                    constanst
                                                        .select_inserestlocation
                                                        .remove(sampleData
                                                            .last.buttonText);
                                                  }
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  sampleData.last.isSelected ==
                                                          true
                                                      ? Icon(Icons.check_circle,
                                                          color: AppColors
                                                              .greenWithShade)
                                                      : const Icon(
                                                          Icons.circle_outlined,
                                                          color:
                                                              Colors.black38),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    sampleData.last.buttonText,
                                                    style: const TextStyle(
                                                            fontSize: 13.0,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf')
                                                        .copyWith(fontSize: 17),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            child: Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              margin: const EdgeInsets.fromLTRB(
                                  25.0, 5.0, 25.0, 10.0),
                              child: Container(
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
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 8.0, 0.0, 0.0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'You’re like to do?',
                                          style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-Black.otf')
                                              .copyWith(
                                                  fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3.5,
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (sampleData1.first
                                                              .isSelected ==
                                                          false) {
                                                        sampleData1.first
                                                            .isSelected = true;

                                                        constanst
                                                            .select_categotyType
                                                            .add(sampleData1
                                                                .first
                                                                .buttonText);
                                                      } else {
                                                        sampleData1.first
                                                            .isSelected = false;
                                                        constanst
                                                            .select_categotyType
                                                            .remove(sampleData1
                                                                .first
                                                                .buttonText);
                                                      }
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      sampleData1.first
                                                                  .isSelected ==
                                                              true
                                                          ? Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color: AppColors
                                                                  .greenWithShade)
                                                          : const Icon(
                                                              Icons
                                                                  .circle_outlined,
                                                              color: Colors
                                                                  .black38),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        sampleData1
                                                            .first.buttonText,
                                                        style: const TextStyle(
                                                                fontSize: 13.0,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-Black.otf')
                                                            .copyWith(
                                                                fontSize: 17),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.5,
                                            height: 30,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (sampleData1
                                                          .last.isSelected ==
                                                      false) {
                                                    sampleData1
                                                        .last.isSelected = true;
                                                    setState(() {});

                                                    constanst
                                                        .select_categotyType
                                                        .add(sampleData1
                                                            .last.buttonText);
                                                  } else {
                                                    sampleData1.last
                                                        .isSelected = false;
                                                    constanst
                                                        .select_categotyType
                                                        .remove(sampleData1
                                                            .last.buttonText);
                                                  }
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  sampleData1.last.isSelected ==
                                                          true
                                                      ? Icon(Icons.check_circle,
                                                          color: AppColors
                                                              .greenWithShade)
                                                      : const Icon(
                                                          Icons.circle_outlined,
                                                          color:
                                                              Colors.black38),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    sampleData1.last.buttonText,
                                                    style: const TextStyle(
                                                            fontSize: 13.0,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf')
                                                        .copyWith(fontSize: 17),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(23.0, 5.0, 5.0, 5.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Select Your Interest',
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
                          FutureBuilder(
                              future: constanst.cat_data,
                              //future: load_subcategory(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    snapshot.hasData == null) {
                                  return Center(
                                    child: CustomLottieContainer(
                                      child: Lottie.asset(
                                        'assets/loading_animation.json',
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      shrinkWrap: true,
                                      itemCount: constanst.catdata.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        cat.Result record =
                                            constanst.catdata[index];

                                        if (constanst.catdata.isEmpty) {
                                          return Padding(
                                              padding: EdgeInsets.only(top: 20),
                                              child: Center(
                                                child: CustomLottieContainer(
                                                  child: Lottie.asset(
                                                    'assets/loading_animation.json',
                                                  ),
                                                ),
                                              ));
                                        } else {
                                          return Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (constanst
                                                        .select_categotyId
                                                        .contains(
                                                      record.categoryId
                                                          .toString(),
                                                    )) {
                                                      constanst
                                                          .select_categotyId
                                                          .remove(
                                                        record.categoryId
                                                            .toString(),
                                                      );
                                                      constanst.select_cat_id =
                                                          constanst
                                                              .select_categotyId
                                                              .join(",");
                                                    } else {
                                                      constanst
                                                          .select_categotyId
                                                          .add(
                                                        record.categoryId
                                                            .toString(),
                                                      );
                                                      constanst.select_cat_id =
                                                          constanst
                                                              .select_categotyId
                                                              .join(",");
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  height: 54,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15),
                                                  decoration: ShapeDecoration(
                                                    color: Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              13.05),
                                                    ),
                                                    shadows: [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .boxShadowforshimmer,
                                                        blurRadius: 16.32,
                                                        offset: Offset(0, 3.26),
                                                        spreadRadius: 0,
                                                      )
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      constanst
                                                              .select_categotyId
                                                              .contains(
                                                        record.categoryId
                                                            .toString(),
                                                      )
                                                          ? Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color: AppColors
                                                                  .greenWithShade)
                                                          : const Icon(
                                                              Icons
                                                                  .circle_outlined,
                                                              color: Colors
                                                                  .black45),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        record.categoryName
                                                            .toString(),
                                                        style: const TextStyle(
                                                                fontSize: 13.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-Black.otf',
                                                                color: Colors
                                                                    .black)
                                                            .copyWith(
                                                                fontSize: 17),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 7),
                                            ],
                                          );
                                        }
                                      });
                                }
                              }),
                          10.sbh,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
                              controller: _addcategory,
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
                                hintText: "Add Category",
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
            )
          : Center(
              child: CustomLottieContainer(
              child: Lottie.asset(
                'assets/loading_animation.json',
              ),
            )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          buttonText: 'Continue',
          onPressed: () async {
            final connectivityResult = await Connectivity().checkConnectivity();

            if (connectivityResult == ConnectivityResult.none) {
              showCustomToast('Net Connection not available');
            } else if (constanst.select_inserestlocation.isEmpty) {
              showCustomToast(
                  'Select Atleast 1 Domestic / International or Select Both');
            } else if (constanst.select_categotyType.isEmpty) {
              showCustomToast(
                  'Select Atleast 1 Buy Post / Sell Post or Select Both');
            } else if (constanst.select_categotyId.isEmpty) {
              showCustomToast('Select Minimum 1 Category');
            } else {
              setState(() {
                _isloading1 = true; // Show loader when button is pressed
              });

              bool success = await setcategory();

              setState(() {
                _isloading1 = false; // Hide loader after setcategory completes
              });

              if (_addcategory.text.isNotEmpty) {
                await _updateCategory();
              } else {
                Navigator.pop(context);
              }

              if (success) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Type_update(),
                  ),
                ).then((value) => checknetwork());
              }
            }
          },
          isLoading: _isloading1,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future getProfiless() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    constanst.itemsCheck.clear();

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
        print("getProfiless:-${res}");

        if (res['user']['posttype'] == "Both") {
          sampleData1.first.isSelected = true;
          sampleData1.last.isSelected = true;
          constanst.select_categotyType.add('Buy Post');
          constanst.select_categotyType.add('Sell Post');
        } else if (res['user']['posttype'] == "Buy Post") {
          sampleData1.first.isSelected = true;
          constanst.select_categotyType.add(res['user']['posttype']);
        } else if (res['user']['posttype'] == "Sell Post") {
          sampleData1.last.isSelected = true;
          constanst.select_categotyType.add(res['user']['posttype']);
        }

        if (res['user']['location_interest'] == "Both") {
          sampleData.first.isSelected = true;
          sampleData.last.isSelected = true;
          constanst.select_inserestlocation.add("Domestic");
          constanst.select_inserestlocation.add("International");
        } else if (res['user']['location_interest'] == "Domestic") {
          sampleData.first.isSelected = true;
          constanst.select_inserestlocation
              .add(res['user']['location_interest']);
        } else if (res['user']['location_interest'] == "International") {
          sampleData.last.isSelected = true;
          constanst.select_inserestlocation
              .add(res['user']['location_interest']);
        }
        print(
            'getProfiless from updatecategory ${res['user']['location_interest']}');
        constanst.select_categotyId = res['user']['category_id'].split(",");
      } else {
        showCustomToast(
          res['message'],
        );
      }
    });
    return res;
  }

  Future<bool> setcategory() async {
    setState(() {
      _isloading1 = true; // Show loader when starting the setcategory process
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    String stringCategory = constanst.select_categotyId.join(",");
    String locationInterest = constanst.select_inserestlocation.length == 2
        ? 'Both'
        : constanst.select_inserestlocation.join(",");
    String postType = constanst.select_categotyType.length == 2
        ? 'Both'
        : constanst.select_categotyType.join(",");
    String device = Platform.isAndroid ? 'android' : 'ios';

    print('Device Name: $device');

    if (constanst.select_inserestlocation.isNotEmpty &&
        constanst.select_categotyType.isNotEmpty &&
        constanst.select_categotyId.isNotEmpty) {
      var res = await addcategory(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        locationInterest,
        postType,
        stringCategory.trim(),
        '7',
        device,
      );

      setState(() {
        _isloading1 = false; // Hide loader after process completes
      });

      if (res['status'] == 1) {
        showCustomToast(res['message']);
        return true; // Return true for successful completion
      } else {
        showCustomToast(res['message']);
        return false; // Return false for failed process
      }
    }

    setState(() {
      _isloading1 = false; // Hide loader if prerequisites are not met
    });
    return false; // Return false if conditions not met
  }

  checknetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      constanst.catdata.clear();
      _isloading = true;
      showCustomToast('Internet Connection not available');
    } else {
      clear_data();
      get_data();
      getProfiless();
    }
  }
}
