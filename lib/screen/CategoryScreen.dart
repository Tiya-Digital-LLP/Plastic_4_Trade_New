// ignore_for_file: unnecessary_null_comparison, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:developer';
import 'dart:io' show Platform;

import 'package:Plastic4trade/constroller/GetCategoryController.dart';
import 'package:Plastic4trade/model/GetCategory.dart' as cat;
import 'package:Plastic4trade/screen/Type.dart';
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

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class RadioModel {
  bool isSelected;
  final String buttonText;

  RadioModel(this.isSelected, this.buttonText);
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<RadioModel> sampleData = <RadioModel>[];
  List<RadioModel> sampleData1 = <RadioModel>[];

  bool? _isloading;
  bool _isloading1 = false;
  BuildContext? dialogContext;
  final TextEditingController _addcategory = TextEditingController();
  Color _color1 = Colors.black26; //name

  void get_data() {
    GetCategoryController bt = GetCategoryController();
    constanst.cat_data = bt.setlogin();

    _isloading = true;
    constanst.cat_data!.then((value) {
      for (var item in value) {
        constanst.catdata.add(item);
      }
      _isloading = false;
      setState(() {});
    });
  }

  checknetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isloading = false;
      });
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
  }

  @override
  initState() {
    super.initState();
    sampleData.add(RadioModel(false, 'Domestic'));
    sampleData.add(RadioModel(false, 'International'));
    sampleData1.add(RadioModel(false, 'Buy Post'));
    sampleData1.add(RadioModel(false, 'Sell Post'));
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
    return initwidget(context);
  }

  Future<bool> _onbackpress(BuildContext context) async {
    Navigator.pop(context);
    return Future.value(true);
  }

  Widget initwidget(BuildContext context) {
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
          'Category',
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            top: true,
            left: true,
            right: true,
            maintainBottomViewPadding: true,
            child: _isloading == true
                ? Align(
                    alignment: Alignment.center,
                    child: Center(
                      child: CustomLottieContainer(
                        child: Lottie.asset(
                          'assets/loading_animation.json',
                        ),
                      ),
                    ))
                : Column(
                    children: [
                      SizedBox(
                        height: 80,
                        child: Card(
                          color: AppColors.backgroundColor,
                          elevation: 2,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          margin:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: AppColors.backgroundColor,
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
                                  padding:
                                      EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 5.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        'Where would you like to do your business?',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.blackColor,
                                            fontFamily:
                                                'assets/fonst/Metropolis-Black.otf')),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            height: 30,
                                            width: 120,
                                            child: Row(children: [
                                              GestureDetector(
                                                child: Row(
                                                  children: [
                                                    sampleData.first
                                                                .isSelected ==
                                                            true
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: AppColors
                                                                .greenWithShade)
                                                        : const Icon(
                                                            Icons
                                                                .circle_outlined,
                                                            color: AppColors
                                                                .black45Color),
                                                    Text(
                                                        sampleData
                                                            .first.buttonText,
                                                        style: const TextStyle(
                                                                fontSize: 13.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-Black.otf')
                                                            .copyWith(
                                                                fontSize: 17)),
                                                  ],
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    if (sampleData
                                                            .first.isSelected ==
                                                        false) {
                                                      sampleData.first
                                                          .isSelected = true;
                                                      constanst
                                                          .select_inserestlocation
                                                          .add(sampleData.first
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
                                                  log("LOCATION LENGTH  == ${constanst.select_inserestlocation.length}");
                                                },
                                              )
                                            ])),
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
                                            child: Row(children: [
                                              sampleData.last.isSelected == true
                                                  ? Icon(Icons.check_circle,
                                                      color: AppColors
                                                          .greenWithShade)
                                                  : const Icon(
                                                      Icons.circle_outlined,
                                                      color: AppColors
                                                          .black45Color),
                                              Text(sampleData.last.buttonText,
                                                  style: const TextStyle(
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-Black.otf')
                                                      .copyWith(fontSize: 17))
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        child: Card(
                          color: AppColors.backgroundColor,
                          elevation: 2,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          margin:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: AppColors.backgroundColor,
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
                            child: Column(children: [
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
                                            color: AppColors.blackColor,
                                            fontFamily:
                                                'assets/fonst/Metropolis-Black.otf')
                                        .copyWith(fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        child: SizedBox(
                                          height: 30,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.5,
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                child: Row(children: [
                                                  sampleData1.first
                                                              .isSelected ==
                                                          true
                                                      ? Icon(Icons.check_circle,
                                                          color: AppColors
                                                              .greenWithShade)
                                                      : const Icon(
                                                          Icons.circle_outlined,
                                                          color: AppColors
                                                              .black45Color),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                      sampleData1
                                                          .first.buttonText,
                                                      style: const TextStyle(
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf')
                                                          .copyWith(
                                                              fontSize: 17))
                                                ]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (sampleData1.first.isSelected ==
                                                false) {
                                              sampleData1.first.isSelected =
                                                  true;

                                              constanst.select_categotyType.add(
                                                  sampleData1.first.buttonText);
                                            } else {
                                              sampleData1.first.isSelected =
                                                  false;
                                              constanst.select_categotyType
                                                  .remove(sampleData1
                                                      .first.buttonText);
                                            }
                                          });
                                        },
                                      ),
                                      GestureDetector(
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          height: 30,
                                          child: GestureDetector(
                                            child: Row(children: [
                                              sampleData1.last.isSelected ==
                                                      true
                                                  ? Icon(Icons.check_circle,
                                                      color: AppColors
                                                          .greenWithShade)
                                                  : const Icon(
                                                      Icons.circle_outlined,
                                                      color: AppColors
                                                          .black45Color),
                                              const SizedBox(width: 8),
                                              Text(sampleData1.last.buttonText,
                                                  style: const TextStyle(
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-Black.otf')
                                                      .copyWith(fontSize: 17))
                                            ]),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (sampleData1.last.isSelected ==
                                                false) {
                                              sampleData1.last.isSelected =
                                                  true;

                                              constanst.select_categotyType.add(
                                                  sampleData1.last.buttonText);
                                            } else {
                                              sampleData1.last.isSelected =
                                                  false;
                                              constanst.select_categotyType
                                                  .remove(sampleData1
                                                      .last.buttonText);
                                            }
                                          });
                                        },
                                      )
                                    ],
                                  ))
                            ]),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25.0, 5.0, 5.0, 5.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select Your Interest',
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
                      FutureBuilder(
                          future: constanst.cat_data,
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
                                      horizontal: 20),
                                  shrinkWrap: true,
                                  itemCount: constanst.catdata.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    cat.Result record =
                                        constanst.catdata[index];
                                    if (constanst.catdata.isEmpty) {
                                      return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
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
                                                if (constanst.select_categotyId
                                                    .contains(record.categoryId
                                                        .toString())) {
                                                  constanst.select_categotyId
                                                      .remove(record.categoryId
                                                          .toString());
                                                } else {
                                                  constanst.select_categotyId
                                                      .add(record.categoryId
                                                          .toString());
                                                }
                                              });
                                            },
                                            child: Container(
                                              height: 54,
                                              padding: const EdgeInsets.all(15),
                                              decoration: ShapeDecoration(
                                                color:
                                                    AppColors.backgroundColor,
                                                shape: RoundedRectangleBorder(
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
                                                  constanst.select_categotyId
                                                          .contains(record
                                                              .categoryId
                                                              .toString())
                                                      ? Icon(Icons.check_circle,
                                                          color: AppColors
                                                              .greenWithShade)
                                                      : const Icon(
                                                          Icons.circle_outlined,
                                                          color: AppColors
                                                              .black45Color),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Text(
                                                      record.categoryName
                                                          .toString(),
                                                      style: const TextStyle(
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf')
                                                          .copyWith(
                                                              fontSize: 17))
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 7,
                                          ),
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
                              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
        ),
      ),
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
                  'Select at least 1 Domestic / International or Select Both');
            } else if (constanst.select_categotyType.isEmpty) {
              showCustomToast(
                  'Select at least 1 Buy Post / Sell Post or Select Both');
            } else if (constanst.select_categotyId.isEmpty) {
              showCustomToast('Select Minimum 1 Category');
            } else {
              setState(() {
                _isloading1 = true; // Start loader
              });

              bool success = await setcategory();

              if (dialogContext != null) {
                Navigator.of(dialogContext!).pop();
              }

              if (_addcategory.text.isNotEmpty) {
                await _updateCategory();
              } else {
                Navigator.pop(context);
              }

              // Navigate if success
              if (success) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Type()),
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

  Future<bool> setcategory() async {
    setState(() {
      _isloading1 = true; // Show loader when starting process
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    constanst.step = 7;

    var stringCategory = constanst.select_categotyId.join(",");

    String stringtype = constanst.select_categotyType.length == 2
        ? 'Both'
        : constanst.select_categotyType.join(",");

    String stringList = constanst.select_inserestlocation.length == 2
        ? 'Both'
        : constanst.select_inserestlocation.join(",");

    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    var res = await addcategory(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      stringList,
      stringtype,
      stringCategory.trim(),
      constanst.step.toString(),
      device,
    );

    setState(() {
      _isloading1 = false; // Stop loader after operation
    });

    bool isSuccess = res['status'] == 1;

    if (isSuccess) {
      showCustomToast(res['message']);
      constanst.iscategory = false;
    } else {
      showCustomToast(res['message']);
    }

    return isSuccess;
  }
}
