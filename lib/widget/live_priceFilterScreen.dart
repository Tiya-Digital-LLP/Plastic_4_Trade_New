// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../api/api_interface.dart';
import 'package:Plastic4trade/model/Get_Filter_live_Price.dart' as filter;
import 'package:Plastic4trade/utill/constant.dart';

class live_priceFilterScreen extends StatefulWidget {
  const live_priceFilterScreen({Key? key}) : super(key: key);

  @override
  State<live_priceFilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<live_priceFilterScreen> {
  String? assignedName;
  bool gender = false;
  bool? iscategory,
      iscompany,
      iscountry,
      isstate,
      ispost_type,
      islocation,
      isload;
  String category_id = '',
      grade_id = '',
      type_id = '',
      bussinesstype = '',
      post_type = '';
  List<filter.Category> category_data = [];
  List<filter.Company> company_data = [];
  List<filter.State> state_data = [];
  List<filter.Country> country_data = [];
  List<String> select_categotyId = [];

  String? location, search;

  Color _color1 = AppColors.blackColor;
  Color _color2 = AppColors.blackColor;
  Color _color3 = AppColors.blackColor;
  Color _color4 = AppColors.blackColor;
  Color _color5 = AppColors.blackColor;

  @override
  void initState() {
    super.initState();

    checknetowork();
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      //isprofile=true;
    } else {
      clear();
      get_Filterdata();
    }
  }

  clear() {
    category_data.clear();
    company_data.clear();
    country_data.clear();
    state_data.clear();
    constanst.category_itemsCheck.clear();
    constanst.Type_itemsCheck.clear();
    constanst.Grade_itemsCheck.clear();
    constanst.bussiness_type_itemsCheck.clear();
  }

  get_Filterdata() async {
    var res = await getfilterdata_liveprice();
    var jsonarray;
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonarray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      for (var item in res['category']) {
        category_data.add(filter.Category.fromJson(item));
      }

      for (var item in res['company']) {
        company_data.add(filter.Company.fromJson(item));
      }

      for (var item in res['state']) {
        state_data.add(filter.State.fromJson(item));
      }

      for (var item in res['country']) {
        country_data.add(filter.Country.fromJson(item));
      }

      for (int i = 0; i < category_data.length; i++) {
        constanst.category_itemsCheck.add(Icons.circle_outlined);
      }

      for (int i = 0; i < company_data.length; i++) {
        constanst.Type_itemsCheck.add(Icons.circle_outlined);
      }

      for (int i = 0; i < country_data.length; i++) {
        constanst.Grade_itemsCheck.add(Icons.circle_outlined);
      }

      for (int i = 0; i < company_data.length; i++) {
        constanst.bussiness_type_itemsCheck.add(Icons.circle_outlined);
      }
      isload = true;
      //category_data=res['category'];

      setState(() {});
    } else {
      showCustomToast(res['message']);
    }
    return jsonarray;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: Column(
            children: [
              const SizedBox(height: 5),
              Image.asset(
                'assets/hori_line.png',
                width: 150,
                height: 5,
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Filter',
                  style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                      fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                ),
              ),
              const SizedBox(height: 15),
              //-------CircularCheckBox()
              const Divider(color: AppColors.gray),
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        alignment: Alignment.center,
                        child: ScreenA()),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 60,
                      child: const VerticalDivider(
                        thickness: 1,
                        color: AppColors.gray,
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.60,
                        height: MediaQuery.of(context).size.height / 1.50,
                        child: isload == true ? ScreenB() : Container()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2.3,
            height: 60,
            margin: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: TextButton(
              onPressed: () {
                constanst.select_categotyId.clear();
                constanst.select_typeId.clear();
                constanst.select_gradeId.clear();
                constanst.selectbusstype_id.clear();
                constanst.select_categotyType.clear();
                constanst.select_state.clear();
                constanst.select_country.clear();
                constanst.date = "";
                Navigator.pop(context);
              },
              child: const Text('Cancel',
                  style: TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor,
                      fontFamily: 'assets/fonst/Metropolis-Black.otf')),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2.3,
            height: 60,
            margin: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(50.0),
                color: AppColors.primaryColor),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply',
                  style: TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.backgroundColor,
                      fontFamily: 'assets/fonst/Metropolis-Black.otf')),
            ),
          ),
        ],
      ),
    );
  }

  Widget ScreenA() {
    return Column(children: [
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = true;
                  iscompany = false;
                  iscountry = false;
                  isstate = false;
                  ispost_type = false;
                  islocation = false;
                  _color1 = AppColors.primaryColor;
                  _color2 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;
                  _color5 = AppColors.blackColor;

                  setState(() {});
                },
                child: Text(
                  'Category',
                  style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color1),
                ))),
      ),
      const Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  iscompany = true;
                  iscountry = false;
                  isstate = false;
                  ispost_type = false;
                  islocation = false;
                  _color2 = AppColors.primaryColor;
                  _color1 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;
                  _color5 = AppColors.blackColor;

                  setState(() {});
                },
                child: Text(
                  'Company',
                  style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color2),
                ))),
      ),
      const Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  iscompany = false;
                  iscountry = true;
                  isstate = false;
                  ispost_type = false;
                  islocation = false;
                  _color3 = AppColors.primaryColor;
                  _color1 = AppColors.blackColor;
                  _color2 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;
                  _color5 = AppColors.blackColor;

                  setState(() {});
                },
                child: Text(
                  'Country',
                  style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color3),
                ))),
      ),
      const Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  iscompany = false;
                  iscountry = false;
                  isstate = true;
                  ispost_type = false;
                  islocation = false;
                  _color4 = AppColors.primaryColor;
                  _color1 = AppColors.blackColor;
                  _color2 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;
                  _color5 = AppColors.blackColor;

                  setState(() {});
                },
                child: Text(
                  'State',
                  style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color4),
                ))),
      ),
      const Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  iscompany = false;
                  iscountry = false;
                  isstate = false;
                  ispost_type = true;
                  islocation = false;
                  _color5 = AppColors.primaryColor;
                  _color1 = AppColors.blackColor;
                  _color2 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;

                  setState(() {});
                },
                child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1960),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(2100));
                      if (date != null) {
                        setState(() {
                          String data1 = DateFormat("yyyy-MM-dd").format(date);
                          data1 = data1.replaceAll("/", '-');
                          constanst.date = data1;
                        });
                      }
                    },
                    child: Text(
                      'Date',
                      style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: AppColors.blackColor,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf')
                          .copyWith(
                              fontWeight: FontWeight.w500, color: _color5),
                    )))),
      ),
      const Divider(color: AppColors.gray),
      SizedBox(
        height: MediaQuery.of(context).size.height / 6.5,
      )
    ]);
  }

  Widget ScreenB() {
    return SizedBox(
        child: iscategory == true
            ? category()
            : iscompany == true
                ? Company()
                : iscountry == true
                    ? Country()
                    : isstate == true
                        ? State()
                        : Container());
  }

  Widget category() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: category_data.length,
        // physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          filter.Category category = category_data[index];
          return GestureDetector(
            onTap: () {
              gender = true;
              if (constanst.category_itemsCheck[index] ==
                  Icons.circle_outlined) {
                if (constanst.select_categotyId.length <= 2) {
                  constanst.category_itemsCheck[index] =
                      Icons.check_circle_outline;

                  category_id = category.id.toString();
                  constanst.select_categotyId.add(category_id);
                } else {
                  showCustomToast('You Can Select Maximum 3 Category');
                }
                setState(() {});
              } else {
                constanst.category_itemsCheck[index] = Icons.circle_outlined;
                category_id = category.id.toString();
                constanst.select_categotyId.remove(category_id);
                setState(() {});
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 4.0,
              decoration: const BoxDecoration(color: AppColors.transperent),
              child: Row(
                children: [
                  IconButton(
                      icon: constanst.category_itemsCheck[index] ==
                              Icons.circle_outlined
                          ? const Icon(Icons.circle_outlined,
                              color: AppColors.black45Color)
                          : Icon(Icons.check_circle,
                              color: AppColors.greenWithShade),
                      onPressed: () {
                        //setState(() {
                        gender = true;
                        if (constanst.category_itemsCheck[index] ==
                            Icons.circle_outlined) {
                          if (constanst.select_categotyId.length <= 2) {
                            constanst.category_itemsCheck[index] =
                                Icons.check_circle_outline;

                            category_id = category.id.toString();
                            constanst.select_categotyId.add(category_id);
                          } else {
                            showCustomToast(
                                'You Can Select Maximum 3 Category');
                          }
                          setState(() {});
                          //print('sdrsr $category_id');
                        } else {
                          constanst.category_itemsCheck[index] =
                              Icons.circle_outlined;
                          category_id = category.id.toString();
                          constanst.select_categotyId.remove(category_id);
                          setState(() {});
                        }
                        //});
                      }),
                  Text(category.categoryName.toString(),
                      style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        });
  }

  Widget Company() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: company_data.length,
        // physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          filter.Company category = company_data[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                gender = true;
                if (constanst.Type_itemsCheck[index] == Icons.circle_outlined) {
                  constanst.Type_itemsCheck[index] = Icons.check_circle_outline;
                  type_id = category.id.toString();
                  constanst.select_typeId.add(type_id);
                } else {
                  constanst.Type_itemsCheck[index] = Icons.circle_outlined;
                  type_id = category.id.toString();
                  constanst.select_typeId.remove(type_id);
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 4.0,
              decoration: const BoxDecoration(color: AppColors.transperent),
              child: Row(
                children: [
                  IconButton(
                      icon: constanst.Type_itemsCheck[index] ==
                              Icons.circle_outlined
                          ? const Icon(Icons.circle_outlined,
                              color: AppColors.black45Color)
                          : Icon(Icons.check_circle,
                              color: AppColors.greenWithShade),
                      onPressed: () {
                        setState(() {
                          gender = true;
                          if (constanst.Type_itemsCheck[index] ==
                              Icons.circle_outlined) {
                            constanst.Type_itemsCheck[index] =
                                Icons.check_circle_outline;
                            type_id = category.id.toString();
                            constanst.select_typeId.add(type_id);
                          } else {
                            constanst.Type_itemsCheck[index] =
                                Icons.circle_outlined;
                            type_id = category.id.toString();
                            constanst.select_typeId.remove(type_id);
                          }
                        });
                      }),
                  Text(category.companyName.toString(),
                      style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                      softWrap: false,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        });
    // ignore: dead_code
    ;
  }

  Widget Country() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: country_data.length,
        // physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          filter.Country category = country_data[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                gender = true;
                if (constanst.Grade_itemsCheck[index] ==
                    Icons.circle_outlined) {
                  constanst.Grade_itemsCheck[index] =
                      Icons.check_circle_outline;

                  constanst.select_country.add(category.country.toString());
                } else {
                  constanst.Grade_itemsCheck[index] = Icons.circle_outlined;

                  constanst.select_country.remove(category.country.toString());
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 4.0,
              decoration: const BoxDecoration(color: AppColors.transperent),
              child: Row(
                children: [
                  IconButton(
                      icon: constanst.Grade_itemsCheck[index] ==
                              Icons.circle_outlined
                          ? const Icon(Icons.circle_outlined,
                              color: AppColors.black45Color)
                          : Icon(Icons.check_circle,
                              color: AppColors.greenWithShade),
                      onPressed: () {
                        setState(() {
                          gender = true;
                          if (constanst.Grade_itemsCheck[index] ==
                              Icons.circle_outlined) {
                            constanst.Grade_itemsCheck[index] =
                                Icons.check_circle_outline;

                            constanst.select_country
                                .add(category.country.toString());
                          } else {
                            constanst.Grade_itemsCheck[index] =
                                Icons.circle_outlined;

                            constanst.select_country
                                .remove(category.country.toString());
                          }
                        });
                      }),
                  Text(category.country.toString(),
                      style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        });
  }

  Widget State() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: state_data.length,
        // physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          filter.State category = state_data[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                gender = true;
                if (constanst.bussiness_type_itemsCheck[index] ==
                    Icons.circle_outlined) {
                  constanst.bussiness_type_itemsCheck[index] =
                      Icons.check_circle_outline;

                  constanst.select_state.add(category.state.toString());
                  setState(() {});
                } else {
                  constanst.Grade_itemsCheck[index] = Icons.circle_outlined;

                  constanst.selectbusstype_id.remove(category.state.toString());
                  setState(() {});
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 4.0,
              decoration: const BoxDecoration(color: AppColors.transperent),
              child: Row(
                children: [
                  IconButton(
                      icon: constanst.bussiness_type_itemsCheck[index] ==
                              Icons.circle_outlined
                          ? const Icon(Icons.circle_outlined,
                              color: AppColors.black45Color)
                          : Icon(Icons.check_circle,
                              color: AppColors.greenWithShade),
                      onPressed: () {
                        setState(() {
                          gender = true;
                          if (constanst.bussiness_type_itemsCheck[index] ==
                              Icons.circle_outlined) {
                            constanst.bussiness_type_itemsCheck[index] =
                                Icons.check_circle_outline;

                            constanst.select_state
                                .add(category.state.toString());
                          } else {
                            constanst.Grade_itemsCheck[index] =
                                Icons.circle_outlined;

                            constanst.selectbusstype_id
                                .remove(category.state.toString());
                          }
                        });
                      }),
                  Text(category.state.toString(),
                      style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        });
  }
}
