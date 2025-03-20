// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unrelated_type_equality_checks, camel_case_types, prefer_typing_uninitialized_variables, deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Plastic4trade/common/bottomSheetList.dart';
import 'package:Plastic4trade/model/Getbusiness_document_types.dart'
    as doc_type;
import 'package:Plastic4trade/model/Getmybusinessprofile.dart';
import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/model/Getmybusinessprofile.dart' as profile;
import 'package:Plastic4trade/model/getannualcapacity.dart' as cat;
import 'package:Plastic4trade/model/getannualturnovermaster.dart' as cat1;
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_interface.dart';
import '../../utill/constant.dart';
import 'Bussinessinfo.dart';

class Bussinessverification extends StatefulWidget {
  const Bussinessverification({Key? key}) : super(key: key);

  @override
  State<Bussinessverification> createState() => _BussinessverificationState();
}

class RadioModel {
  bool isSelected;
  final String buttonText;

  RadioModel(this.isSelected, this.buttonText);
}

class _BussinessverificationState extends State<Bussinessverification> {
  final _formKey = GlobalKey<FormState>();
  List<String> premiseTypes = ['Rent', 'Own'];
  final TextEditingController _usergst = TextEditingController();
  final TextEditingController _pannumber = TextEditingController();
  final TextEditingController _adhaarnumber = TextEditingController();
  final TextEditingController _exno = TextEditingController();
  final TextEditingController _useresiger = TextEditingController();
  final TextEditingController _prd_cap = TextEditingController();
  final TextEditingController _doctype = TextEditingController();
  Color _color1 = Colors.black45;
  Color _color2 = Colors.black45;
  Color _color3 = Colors.black45;
  Color _color4 = Colors.black45;
  Color _color5 = Colors.black45;
  Color _color6 = Colors.black45;

  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;

  List<Doc> get_doctype = [];
  List<File> select_doctype = [];
  List<SelectFilesLable> selectFilesLable = [];
  String? selectFilesLableName;
  String? docId;
  DateTime dateTime = DateTime.now();
  String _selectPremises = '';
  String? firstyear_currency, secondyear_currency, thirdyear_currency;
  String? firstyear_amount, secondyear_amount, thirdyear_amount;
  String? firstyear, secondYear, thirdYear;

  String? firstyear_amountID, secondyear_amountID, thirdyear_amountID;
  String imageName = "";
  int? gst_verification_status;

  String userId = "";

  Getmybusinessprofile getprofile = Getmybusinessprofile();

  List<cat1.Annual> production_turn = [];

  List<profile.Doc> resultList = [];

  bool? isload;

  List listrupes = ['₹', '\$', '€', '£', '¥'];

  File? _selectedFile;
  BuildContext? dialogContext;
  bool _isloading1 = false;
  String crown_color = '';
  String plan_name = '';

  @override
  void initState() {
    checknetowork();
    super.initState();
  }

  String? get _errorText {
    final text = _usergst.value.text;
    final text1 = _useresiger.value.text;

    if (text.isEmpty && text1.isEmpty) {
      return null;
    }
    if (text.isNotEmpty && text1.isEmpty) {
      return '';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(
          () {
            // Reset document type selection
            constanst.Document_type_itemsCheck[0] = Icons.circle_outlined;
            constanst.select_document_type_id = "";
            constanst.Document_type_name = "";
            constanst.select_document_type_idx = -1;

            // Reset product capacity selection
            constanst.Prodcap_itemsCheck[0] = Icons.circle_outlined;
          },
        );
        return true;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.greyBackground,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            title: const Text(
              'Business Verification',
              softWrap: false,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: 'Metropolis',
              ),
            ),
            leading: InkWell(
              onTap: () {
                setState(
                  () {
                    constanst.Document_type_itemsCheck[0] =
                        Icons.circle_outlined;
                    constanst.select_document_type_id = "";
                    constanst.Document_type_name = "";
                    constanst.select_document_type_idx = -1;

                    constanst.Prodcap_itemsCheck[0] = Icons.circle_outlined;
                  },
                );

                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
          ),
          body: isload == true
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  SafeArea(
                                    top: true,
                                    left: true,
                                    right: true,
                                    maintainBottomViewPadding: true,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 18.0, 25.0, 10.0),
                                          child: CustomTextField(
                                            controller: _usergst,
                                            readOnly:
                                                gst_verification_status == 1,
                                            labelText: "GST/VAT/TAX Number",
                                            borderColor: _color1,
                                            keyboardType: TextInputType.text,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r"[a-zA-Z]+|\d"),
                                              ),
                                              LengthLimitingTextInputFormatter(
                                                  15),
                                              TextInputFormatter.withFunction(
                                                  (oldValue, newValue) {
                                                return TextEditingValue(
                                                  text: newValue.text
                                                      .toUpperCase(),
                                                  selection: newValue.selection,
                                                );
                                              }),
                                            ],
                                            onFieldSubmitted: (value) {
                                              var numValue = value.length;
                                              if (numValue == 15) {
                                                _color1 =
                                                    AppColors.greenWithShade;
                                              } else {
                                                _color1 = AppColors.red;
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Enter a GST/VAT/TAX Number');
                                              }
                                            },
                                            onChanged: (value) {
                                              if (value.isEmpty) {
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Your GST/VAT/TAX  Number');
                                                setState(() {
                                                  _color1 = AppColors.red;
                                                });
                                              } else {
                                                setState(
                                                  () {
                                                    _color1 = AppColors
                                                        .greenWithShade;
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 0.0, 25.0, 5.0),
                                          child: CustomTextField(
                                            controller: _useresiger,
                                            readOnly: true,
                                            labelText: "Registration Date",
                                            borderColor: _color2,
                                            suffixIcon: const Icon(
                                                Icons.calendar_month,
                                                color: AppColors.primaryColor),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r"[a-zA-Z]+|\d"),
                                              ),
                                            ],
                                            onTap: () async {
                                              final date = await showDatePicker(
                                                context: context,
                                                firstDate: DateTime(1960),
                                                initialDate: DateTime.now(),
                                                lastDate: DateTime(2100),
                                              );
                                              if (date != null) {
                                                setState(
                                                  () {
                                                    _useresiger.text =
                                                        DateFormat()
                                                            .add_yMMMd()
                                                            .format(date);
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 5.0, 25.0, 5.0),
                                          child: CustomTextField(
                                            controller: _pannumber,
                                            labelText: "Pan Number",
                                            borderColor: _color3,
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r"[a-zA-Z]+|\d"),
                                              ),
                                              LengthLimitingTextInputFormatter(
                                                10,
                                              ),
                                              TextInputFormatter.withFunction(
                                                  (oldValue, newValue) {
                                                return TextEditingValue(
                                                  text: newValue.text
                                                      .toUpperCase(),
                                                  selection: newValue.selection,
                                                );
                                              }),
                                            ],
                                            onFieldSubmitted: (value) {
                                              var numValue = value.length;
                                              if (numValue == 10) {
                                                _color3 =
                                                    AppColors.greenWithShade;
                                              } else {
                                                _color3 = AppColors.red;
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Enter Pan Number');
                                              }
                                            },
                                            onChanged: (value) {
                                              if (value.isEmpty) {
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Enter Your Pan Number');
                                                setState(
                                                  () {
                                                    _color3 = AppColors.red;
                                                  },
                                                );
                                              } else {
                                                setState(
                                                  () {
                                                    _color3 = AppColors
                                                        .greenWithShade;
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 5.0, 25.0, 5.0),
                                          child: CustomTextField(
                                            controller: _adhaarnumber,
                                            labelText:
                                                "National ID/ Aadhar/ Personal ID No.",
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            borderColor: _color6,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r"[a-zA-Z]+|\d"),
                                              ),
                                              LengthLimitingTextInputFormatter(
                                                12,
                                              ),
                                            ],
                                            onFieldSubmitted: (value) {
                                              var numValue = value.length;
                                              if (numValue == 10) {
                                                _color6 = Colors.green.shade600;
                                              } else {
                                                _color6 = Colors.red;
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Enter National ID/ Adhar/ Personal ID No.');
                                              }
                                            },
                                            onChanged: (value) {
                                              if (value.isEmpty) {
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Enter Your National ID/ Adhar/ Personal ID No.');
                                                setState(
                                                  () {
                                                    _color6 = AppColors.red;
                                                  },
                                                );
                                              } else {
                                                setState(
                                                  () {
                                                    _color6 = AppColors
                                                        .greenWithShade;
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 5.0, 25.0, 10.0),
                                          child: CustomTextField(
                                            controller: _exno,
                                            labelText: "Export Import Number",
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            borderColor: _color4,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r"[a-zA-Z]+|\d"),
                                              ),
                                              LengthLimitingTextInputFormatter(
                                                12,
                                              ),
                                            ],
                                            onFieldSubmitted: (value) {
                                              var numValue = value.length;
                                              if (numValue == 10) {
                                                _color4 =
                                                    AppColors.greenWithShade;
                                              } else {
                                                _color4 = AppColors.red;
                                                showCustomToast(
                                                    'Please Enter a Export Import Number');
                                              }
                                            },
                                            onChanged: (value) {
                                              if (value.isEmpty) {
                                                WidgetsBinding.instance
                                                    .focusManager.primaryFocus
                                                    ?.unfocus();
                                                showCustomToast(
                                                    'Please Your Export Import Number');
                                                setState(
                                                  () {
                                                    _color4 = AppColors.red;
                                                  },
                                                );
                                              } else {
                                                setState(
                                                  () {
                                                    _color4 = AppColors
                                                        .greenWithShade;
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 5.0, 25.0, 5.0),
                                          child: CustomTextField(
                                            controller: _prd_cap,
                                            readOnly: true,
                                            labelText: "Production Capacity",
                                            borderColor: _color2,
                                            suffixIcon: const Icon(
                                                Icons.arrow_drop_down_sharp),
                                            inputFormatters: [],
                                            onFieldSubmitted: (value) {
                                              var numValue = value.length;
                                              if (numValue == 10) {
                                                _color4 =
                                                    AppColors.greenWithShade;
                                              } else {
                                                _color4 = AppColors.red;
                                                showCustomToast(
                                                    'Please Enter a Export Import Number');
                                              }
                                            },
                                            onTap: () async {
                                              setState(
                                                () {},
                                              );
                                              final connectivityResult =
                                                  await Connectivity()
                                                      .checkConnectivity();

                                              if (connectivityResult ==
                                                  ConnectivityResult.none) {
                                                showCustomToast(
                                                    'Internet Connection not available');
                                              } else {
                                                ViewItem1(context);
                                              }
                                            },
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 5.0, 25.0, 2.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Annual Turnover',
                                                style: const TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black,
                                                        fontFamily:
                                                            'assets/fonst/Metropolis-Black.otf')
                                                    .copyWith(fontSize: 15),
                                              ),
                                              Image.asset(
                                                'assets/Line.png',
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.8,
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 5.0, 25.0, 10.0),
                                          child: Row(
                                            children: [
                                              Center(
                                                child: Text(
                                                  '$firstyear',
                                                  style: const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-Black.otf')
                                                      .copyWith(fontSize: 15),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16.0,
                                                    top: 5.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.5,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    color: Colors.white),
                                                child: DropdownButtonFormField(
                                                  hint: firstyear_currency !=
                                                              null &&
                                                          firstyear_currency!
                                                              .isNotEmpty &&
                                                          firstyear_currency !=
                                                              "null"
                                                      ? Text(
                                                          firstyear_currency
                                                              .toString(),
                                                          style: const TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-Black.otf')
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black),
                                                        )
                                                      : Text(
                                                          'Currency',
                                                          style: const TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-Black.otf')
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black45),
                                                        ),
                                                  dropdownColor: Colors.white,
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down),
                                                  iconSize: 15,
                                                  isExpanded: true,
                                                  items: listrupes.map(
                                                    (valueItem) {
                                                      return DropdownMenuItem(
                                                        value: valueItem,
                                                        child: Text(
                                                          valueItem,
                                                          style: const TextStyle(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf'),
                                                        ),
                                                      );
                                                    },
                                                  ).toList(),
                                                  onChanged: (value) {
                                                    setState(
                                                      () {
                                                        firstyear_currency =
                                                            null;
                                                        firstyear_currency =
                                                            value.toString();
                                                      },
                                                    );
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16.0,
                                                    top: 5.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.3,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    DropdownButtonFormField<
                                                        int>(
                                                      hint: firstyear_amount !=
                                                                  null &&
                                                              firstyear_amount!
                                                                  .isNotEmpty &&
                                                              firstyear_amount !=
                                                                  "null"
                                                          ? Text(
                                                              firstyear_amount
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-Black.otf',
                                                              ),
                                                            )
                                                          : Text(
                                                              'Amount',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black45,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-Black.otf',
                                                              ),
                                                            ),
                                                      dropdownColor:
                                                          Colors.white,
                                                      icon: const Icon(Icons
                                                          .arrow_drop_down),
                                                      iconSize: 15,
                                                      isExpanded: true,
                                                      items: production_turn
                                                          .map((cat1.Annual
                                                              annual) {
                                                        return DropdownMenuItem<
                                                            int>(
                                                          value: annual.id,
                                                          child: Text(
                                                            annual.name ?? '',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf',
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (int? selectedId) {
                                                        // Handle the selected id
                                                        if (selectedId !=
                                                            null) {
                                                          // Find the corresponding Annual object
                                                          cat1.Annual?
                                                              selectedAnnual =
                                                              production_turn.firstWhere(
                                                                  (annual) =>
                                                                      annual
                                                                          .id ==
                                                                      selectedId);
                                                          setState(() {
                                                            firstyear_amountID =
                                                                selectedAnnual
                                                                    .id
                                                                    .toString();
                                                            firstyear_amount =
                                                                selectedAnnual
                                                                        .name ??
                                                                    '';
                                                          });
                                                        }
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 5.0, 25.0, 10.0),
                                          child: Row(
                                            children: [
                                              Center(
                                                child: Text(
                                                  '$secondYear',
                                                  style: const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-Black.otf')
                                                      .copyWith(fontSize: 15),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16.0,
                                                    top: 5.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.5,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    color: Colors.white),
                                                child: Column(
                                                  children: [
                                                    DropdownButtonFormField(
                                                      // value: secondyear_currency,
                                                      hint: secondyear_currency !=
                                                                  null &&
                                                              secondyear_currency!
                                                                  .isNotEmpty &&
                                                              secondyear_currency !=
                                                                  "null"
                                                          ? Text(
                                                              secondyear_currency
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'assets/fonst/Metropolis-Black.otf')
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black),
                                                            )
                                                          : Text(
                                                              'Currency',
                                                              style: const TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'assets/fonst/Metropolis-Black.otf')
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black45),
                                                            ),
                                                      dropdownColor:
                                                          Colors.white,
                                                      icon: const Icon(Icons
                                                          .arrow_drop_down),
                                                      iconSize: 15,
                                                      isExpanded: true,
                                                      //underline: const SizedBox(),
                                                      items: listrupes.map(
                                                        (valueItem) {
                                                          return DropdownMenuItem(
                                                            value: valueItem,
                                                            child: Text(
                                                              valueItem,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-Black.otf'),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                      onChanged: (value) {
                                                        setState(
                                                          () {
                                                            secondyear_currency =
                                                                null;
                                                            secondyear_currency =
                                                                value
                                                                    .toString();
                                                          },
                                                        );
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16.0,
                                                    top: 5.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.3,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    color: Colors.white),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    DropdownButtonFormField<
                                                        int>(
                                                      hint: secondyear_amount !=
                                                                  null &&
                                                              secondyear_amount!
                                                                  .isNotEmpty &&
                                                              secondyear_amount !=
                                                                  "null"
                                                          ? Text(
                                                              secondyear_amount
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'assets/fonst/Metropolis-Black.otf')
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black),
                                                            )
                                                          : Text(
                                                              'Amount',
                                                              style: const TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'assets/fonst/Metropolis-Black.otf')
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black45),
                                                            ),
                                                      dropdownColor:
                                                          Colors.white,
                                                      icon: const Icon(Icons
                                                          .arrow_drop_down),
                                                      iconSize: 15,
                                                      isExpanded: true,
                                                      items:
                                                          production_turn.map(
                                                        (cat1.Annual annual) {
                                                          return DropdownMenuItem<
                                                              int>(
                                                            value: annual.id,
                                                            child: Text(
                                                              annual.name ?? '',
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-Black.otf'),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                      onChanged:
                                                          (int? selectedId) {
                                                        // Handle the selected id
                                                        if (selectedId !=
                                                            null) {
                                                          // Find the corresponding Annual object
                                                          cat1.Annual?
                                                              selectedAnnual =
                                                              production_turn.firstWhere(
                                                                  (annual) =>
                                                                      annual
                                                                          .id ==
                                                                      selectedId);
                                                          setState(
                                                            () {
                                                              secondyear_amountID =
                                                                  selectedAnnual
                                                                      .id
                                                                      .toString();
                                                              secondyear_amount =
                                                                  selectedAnnual
                                                                          .name ??
                                                                      '';
                                                            },
                                                          );
                                                        }
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 5.0, 25.0, 10.0),
                                          child: Row(
                                            children: [
                                              Center(
                                                child: Text(
                                                  '$thirdYear',
                                                  style: const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-Black.otf')
                                                      .copyWith(fontSize: 15),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16.0,
                                                    top: 5.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.5,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    color: Colors.white),
                                                child: Column(
                                                  children: [
                                                    DropdownButtonFormField(
                                                      // value: thirdyear_currency,
                                                      hint: thirdyear_currency !=
                                                                  null &&
                                                              thirdyear_currency!
                                                                  .isNotEmpty &&
                                                              thirdyear_currency !=
                                                                  "null"
                                                          ? Text(
                                                              thirdyear_currency
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'assets/fonst/Metropolis-Black.otf')
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black),
                                                            )
                                                          : Text(
                                                              'Currency',
                                                              style: const TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'assets/fonst/Metropolis-Black.otf')
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black45),
                                                            ),
                                                      dropdownColor:
                                                          Colors.white,
                                                      icon: const Icon(Icons
                                                          .arrow_drop_down),
                                                      iconSize: 15,
                                                      isExpanded: true,
                                                      //underline: const SizedBox(),
                                                      items: listrupes.map(
                                                        (valueItem) {
                                                          return DropdownMenuItem(
                                                            value: valueItem,
                                                            child: Text(
                                                              valueItem,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-Black.otf'),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                      onChanged: (value) {
                                                        setState(
                                                          () {
                                                            thirdyear_currency =
                                                                null;
                                                            thirdyear_currency =
                                                                value
                                                                    .toString();
                                                          },
                                                        );
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16.0,
                                                    top: 5.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.3,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    color: Colors.white),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    DropdownButtonFormField<
                                                        int>(
                                                      hint: thirdyear_amount !=
                                                                  null &&
                                                              thirdyear_amount!
                                                                  .isNotEmpty &&
                                                              thirdyear_amount !=
                                                                  "null"
                                                          ? Text(
                                                              thirdyear_amount
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'assets/fonst/Metropolis-Black.otf')
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black),
                                                            )
                                                          : Text(
                                                              'Amount',
                                                              style: const TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .black,
                                                                      fontFamily:
                                                                          'assets/fonst/Metropolis-Black.otf')
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black45),
                                                            ),
                                                      dropdownColor:
                                                          Colors.white,
                                                      icon: const Icon(Icons
                                                          .arrow_drop_down),
                                                      iconSize: 15,
                                                      isExpanded: true,
                                                      items:
                                                          production_turn.map(
                                                        (cat1.Annual annual) {
                                                          return DropdownMenuItem<
                                                              int>(
                                                            value: annual.id,
                                                            child: Text(
                                                              annual.name ?? '',
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-Black.otf'),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                      onChanged:
                                                          (int? selectedId) {
                                                        if (selectedId !=
                                                            null) {
                                                          cat1.Annual?
                                                              selectedAnnual =
                                                              production_turn.firstWhere(
                                                                  (annual) =>
                                                                      annual
                                                                          .id ==
                                                                      selectedId);
                                                          setState(
                                                            () {
                                                              thirdyear_amountID =
                                                                  selectedAnnual
                                                                      .id
                                                                      .toString();
                                                              thirdyear_amount =
                                                                  selectedAnnual
                                                                          .name ??
                                                                      '';
                                                            },
                                                          );
                                                        }
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              25.0, 10.0, 25.0, 5.0),
                                          padding: const EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.black45),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Column(
                                            children: [
                                              // Heading
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'Select Premise Type',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        'assets/fonst/Metropolis-Black.otf',
                                                  ).copyWith(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black38),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              // Options Row
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    child: Row(
                                                      children: [
                                                        // Custom Icon for Rent
                                                        _selectPremises ==
                                                                'Rent'
                                                            ? Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: Colors
                                                                    .green, // Check icon color when selected
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .circle_outlined,
                                                                color: Colors
                                                                    .black38, // Default circle when not selected
                                                              ),
                                                        const SizedBox(
                                                            width: 8),
                                                        // Rent Text
                                                        Text(
                                                          'Rent',
                                                          style: TextStyle(
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        _selectPremises =
                                                            'Rent'; // Update the selected premise
                                                        print(
                                                            'Selected: $_selectPremises'); // Debugging
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(width: 15),
                                                  GestureDetector(
                                                    child: Row(
                                                      children: [
                                                        _selectPremises == 'Own'
                                                            ? Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: Colors
                                                                    .green,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .circle_outlined,
                                                                color: Colors
                                                                    .black38,
                                                              ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          'Own',
                                                          style: TextStyle(
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        _selectPremises = 'Own';
                                                        print(
                                                            'Selected: $_selectPremises');
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 26,
                                          ),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'Upload Document',
                                              style: const TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        3.sbh,
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 0.0, 25.0, 15.0),
                                          child: CustomTextField(
                                            controller: _doctype,
                                            readOnly: true,
                                            labelText: "Document Type",
                                            keyboardType: TextInputType.text,
                                            borderColor: _color5,
                                            suffixIcon: const Icon(
                                                Icons.arrow_drop_down_sharp),
                                            inputFormatters: [],
                                            onFieldSubmitted: (value) {
                                              var numValue = value.length;
                                              if (numValue == 10) {
                                                _color5 =
                                                    AppColors.greenWithShade;
                                              } else {
                                                _color5 = AppColors.red;
                                                showCustomToast(
                                                    'Please Select Document Type');
                                              }
                                            },
                                            onTap: () async {
                                              setState(
                                                () {},
                                              );
                                              final connectivityResult =
                                                  await Connectivity()
                                                      .checkConnectivity();

                                              if (connectivityResult ==
                                                  ConnectivityResult.none) {
                                                showCustomToast(
                                                    'Internet Connection not available');
                                              } else {
                                                ViewItem2(context);
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              25.0, 0.0, 25.0, 10.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (_doctype.text.isEmpty) {
                                                _color5 = AppColors.red;
                                                showCustomToast(
                                                    'Please Select Document Type ');
                                              } else {
                                                _pickFile();
                                              }
                                            },
                                            child: Image.asset(
                                                'assets/add_document.png'),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 25),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                'Only PDF | JPG allowed',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-Black.otf',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Text(
                                                'Maximum Upload Size 2MB',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-Black.otf',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        if (filename != null)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                15.0, 0.0, 15.0, 10),
                                            child: document_display(),
                                          ),
                                        SizedBox(
                                          height: (get_doctype.isEmpty)
                                              ? 0
                                              : (get_doctype.isNotEmpty &&
                                                      get_doctype.length <= 3)
                                                  ? 60
                                                  : (get_doctype.length >= 4 &&
                                                          get_doctype.length <=
                                                              6)
                                                      ? 120
                                                      : 180,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                15.0, 0.0, 15.0, 0),
                                            child: uploadedImage(
                                                MediaQuery.of(context).size),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: CustomButton(
                                            buttonText: 'Update',
                                            onPressed: () async {
                                              // Set loading state
                                              setState(() {});

                                              // Check if there's an error in the registration date
                                              if (_errorText != null) {
                                                showCustomToast(
                                                    'Please Enter Registration Date');
                                              } else {
                                                vaild_data();
                                              }
                                            },
                                            isLoading:
                                                _isloading1, // Control button's loading state
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              : Center(
                  child: CustomLottieContainer(
                  child: Lottie.asset(
                    'assets/loading_animation.json',
                  ),
                ))),
    );
  }

  File? filename;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'pdf', 'jpeg'],
    );

    try {
      if (result != null) {
        File file = File(result.files.single.path!);
        String? fileExtension = result.files.single.extension;
        print("Selected file path: ${file.path}");
        print("File type: $fileExtension");

        // Get the file size
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 2) {
          showCustomToast("Selected File must be less than 2 MB");
          return; // Exit the function if the file is too large
        }

        if (['png', 'jpg', 'jpeg'].contains(fileExtension)) {
          if (fileSizeInMB > 1) {
            file = (await compressFile(file)) as File;
            print("File compressed.");
          }
        }

        setState(() {
          filename = file;
          _selectedFile = file;
          imageName = _doctype.text;

          select_doctype.add(_selectedFile!);
          selectFilesLable.add(SelectFilesLable(id: docId, lable: imageName));
        });
        print("Selected File successfully saved: $_selectedFile");
      } else {
        print("No file selected.");
      }
    } catch (e) {
      print("ERROR START === $e");
      showCustomToast("File selection failed. Please try again.");
    }
  }

  Future<XFile?> compressFile(File file) async {
    // Compress only image files
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp')); // Assuming jpg/jpeg
    final newPath = '${filePath.substring(0, lastIndex)}.compressed.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      newPath,
      quality: 70,
    );

    return result;
  }

  Widget document_display() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: selectFilesLable.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                // Preview the selected file
                getFilePreview(file: select_doctype[index]);
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(8.0),
                  height: 45,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "${selectFilesLable[index].lable}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 15,
              left: 15,
              child: Icon(
                Icons.note,
                color: AppColors.primaryColor,
                size: 35,
              ),
            ),
            Positioned(
              top: 15,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  // Remove the selected document
                  select_doctype.removeAt(index);
                  selectFilesLable.removeAt(index);
                  setState(() {});
                },
                child: const Icon(
                  Icons.delete,
                  color: AppColors.red,
                  size: 35,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? getFilePreview({required File file}) {
    // Check the file extension
    String extension = file.path.split('.').last.toLowerCase();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Container(
                height: 500,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16.0),
                child: (extension == 'jpg' ||
                        extension == 'png' ||
                        extension == 'jpeg')
                    ? Image.file(
                        file,
                        fit: BoxFit.cover, // To fit the image in the dialog
                      )
                    : (extension == 'pdf')
                        ? FutureBuilder<PDFView>(
                            future: _getPDFView(file),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                return snapshot.data!;
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text("Error loading PDF"),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          )
                        : const Icon(Icons.insert_drive_file,
                            size: 50, color: AppColors.verfirdColor),
              ),
              // Close button
              Positioned(
                right: 0.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.grey.withOpacity(0.5),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    return null;
  }

  Future<PDFView> _getPDFView(File file) async {
    return PDFView(
      filePath: file.path,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: true,
      pageFling: true,
      onRender: (pages) {
        print('PDF loaded with $pages pages');
      },
      onError: (error) {
        print(error.toString());
      },
      onPageError: (page, error) {
        print('Error on page: $page, error: $error');
      },
    );
  }

  Widget uploadedImage(Size size) {
    return ListView.builder(
      itemCount: (get_doctype.length / 2).ceil(),
      itemBuilder: (context, index) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 60,
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            // mainAxisSpacing: 1.0,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: get_doctype.length,
          itemBuilder: (context, gridIndex) {
            final doc = get_doctype[gridIndex];
            print("doc:-${doc.toJson()}");
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (doc.documentUrl != null) {
                      if (doc.documentUrl!.toLowerCase().endsWith('.pdf')) {
                        // Handle PDF
                        showPdfPreview(size, doc.documentUrl ?? "");
                      } else {
                        // Handle image
                        showImagePreview(size, doc.documentUrl ?? "");
                      }
                    }
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      height: 55,
                      width: size.width / 2 - 12, // Adjust the width as needed
                      child: Text(
                        doc.doctype!.name.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                    top: 20,
                    left: 5,
                    child: Icon(
                      Icons.note,
                      color: AppColors.primaryColor,
                      size: 20,
                    )),
                Positioned(
                    top: 20,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          //isload = false; // Show the circular progress indicator
                        });
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CommanDialog(
                              title: "Delete Document",
                              content:
                                  "Are You Sure Want to\n delete Document?",
                              onPressed: () {
                                Navigator.of(context).pop();
                                get_doctype.removeAt(index);
                                remove_document(doc.id.toString());
                              },
                            );
                          },
                        );
                      },
                      child: const Icon(
                        Icons.delete,
                        color: AppColors.red,
                        size: 20,
                      ),
                    ))
              ],
            );
          },
        );
      },
    );
  }

  void showImagePreview(size, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Container(
                height: 500,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl.toString(),
                ),
              ),
              Positioned(
                right: 0.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.transparent.withOpacity(0.1),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showPdfPreview(Size size, String pdfUrl) async {
    try {
      // Download the PDF from the URL
      final pdfFile = await downloadPdf(pdfUrl);

      if (pdfFile != null) {
        // Show PDF in Dialog after downloading
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Stack(
                children: [
                  SizedBox(
                    height: size.height * 0.8,
                    width: size.width * 0.8,
                    child: PDFView(
                      filePath: pdfFile.path,
                      autoSpacing: true,
                      swipeHorizontal: true,
                      onRender: (pages) {
                        setState(() {
                          isReady = true;
                        });
                      },
                      onError: (error) {
                        print("PDF Error: $error");
                      },
                    ),
                  ),
                  Positioned(
                    right: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.transparent.withOpacity(0.1),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // Handle failure to download the PDF
        print("Failed to download PDF");
      }
    } catch (e) {
      print("Error showing PDF: $e");
    }
  }

  Future<File?> downloadPdf(String url) async {
    try {
      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final path = "${dir.path}/temp_pdf.pdf";

      // Download the PDF file
      await Dio().download(url, path);

      return File(path);
    } catch (e) {
      print("Error downloading PDF: $e");
      return null;
    }
  }

  ViewItem1(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              return const type();
            },
          );
        },
      ),
    ).then(
      (value) {
        // Ensure the field updates correctly after selection
        setState(() {
          _prd_cap.text = constanst.Product_Capcity_name.join(', ');
          _color2 = AppColors.greenWithShade;
        });
      },
    );
  }

  ViewItem2(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          // <-- SEE HERE
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        // Initial height as a fraction of screen height
        builder: (BuildContext context, ScrollController scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              return const document_type();
            },
          );
        },
      ),
    ).then(
      (value) {
        if (constanst.select_document_type_idx != "") {
          _doctype.text = constanst.Document_type_name;
          docId = constanst.select_document_type_id;
          setState(
            () {
              _color5 = AppColors.greenWithShade;
            },
          );
        }
      },
    );
  }

  vaild_data() {
    if (_usergst.text.isEmpty &&
        _pannumber.text.isEmpty &&
        _adhaarnumber.text.isEmpty &&
        _exno.text.isEmpty &&
        _useresiger.text.isEmpty &&
        _prd_cap.text.isEmpty &&
        _doctype.text.isEmpty &&
        firstyear_amount == "" &&
        secondyear_amount == "" &&
        thirdyear_amount == "") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Bussinessinfo(),
        ),
      );
    } else if (constanst.select_document_type_id.isNotEmpty) {
      if (_selectedFile == null) {
        showCustomToast('Please Add Document');
      } else {
        update_BusinessVerification().then((value) {
          if (dialogContext != null) {
            Navigator.of(dialogContext!).pop();
          }

          if (value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Bussinessinfo(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Bussinessinfo(),
              ),
            );
          }
        });
      }
    } else {
      update_BusinessVerification().then((value) {
        if (dialogContext != null) {
          Navigator.of(dialogContext!).pop();
        }

        if (value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Bussinessinfo(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Bussinessinfo(),
            ),
          );
        }
      });
    }
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      //isprofile=true;
    } else {
      getProfiless();
      getannua_lcapacity();
      getannua_turnover();
      getdoc_type();
      // get_data();
    }
  }

  getannua_lcapacity() async {
    print("Fetching annual capacity...");

    var res = await getannual_capacity();
    var jsonArray;

    print("Response received: $res");

    if (res['status'] == 1) {
      jsonArray = res['annual'];
      print("Annual data found: $jsonArray");

      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      print("Clearing existing production capacity data...");
      constanst.production_cap.clear();
      constanst.Prodcap_itemsCheck.clear();

      for (var data in jsonArray) {
        print("Processing record: $data");
        cat.Annual record = cat.Annual(
          id: data['id'],
          name: data['name'],
        );
        constanst.production_cap.add(record);
      }

      setState(() {
        print("State updated with new production capacity data.");
      });

      for (int i = 0; i < constanst.production_cap.length; i++) {
        print("Adding icon for item at index $i");
        constanst.Prodcap_itemsCheck.add(Icons.circle_outlined);
      }

      isload = true;
      print("Data loading complete.");
    } else {
      isload = true;
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      print("Error occurred: ${res['message']}");
      showCustomToast(
        res['message'],
      );
    }

    print("Returning JSON Array: $jsonArray");
    return jsonArray;
  }

  getannua_turnover() async {
    var res = await getannual_turnover();
    var jsonArray;
    print('getannual_turnover Responce: $res');
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      jsonArray = res['annual'];
      production_turn.clear();
      for (var data in jsonArray) {
        cat1.Annual record = cat1.Annual(
          id: data['id'],
          name: data['name'],
        );
        production_turn.add(record);
      }
      setState(
        () {},
      );
      isload = true;
    } else {
      isload = true;
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(
        res['message'],
      );
    }
    return jsonArray;
  }

// Function to handle the update process dynamically
  Future<void> _updateAnnualTurnover(Map<String, dynamic> rowData) async {
    try {
      var res = await annual_turnover_Update(rowData);

      if (res != null) {
        if (res['status'] == 1) {
          // Handle success response
          print("Update Success: ${res['message']}");
        } else {
          // Handle failure response
          print("Update Failed: ${res['message']}");
        }
      } else {
        print("No response received.");
      }
    } catch (e) {
      print("Error during update: $e");
    }
  }

  Future<void> updateAnnualTurnoverData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    Map<String, dynamic> rowData = {
      "user_id": pref.getString('user_id').toString(),
      "data": [
        {
          "year": "$firstyear",
          "currency": "$firstyear_currency",
          "amount": firstyear_amount
        },
        {
          "year": "$secondYear",
          "currency": "$secondyear_currency",
          "amount": secondyear_amount
        },
        {
          "year": "$thirdYear",
          "currency": "$thirdyear_currency",
          "amount": thirdyear_amount
        },
      ]
    };

    print("Request Body: ${jsonEncode(rowData)}");
    await _updateAnnualTurnover(rowData);
  }

  getdoc_type() async {
    var res = await getbusiness_document_types();
    var jsonArray;

    if (res['status'] == 1) {
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      jsonArray = res['types'];
      constanst.doc_typess.clear();
      constanst.Document_type_itemsCheck.clear();
      for (var data in jsonArray) {
        doc_type.Types record = doc_type.Types(
          id: data['id'],
          name: data['name'],
        );
        constanst.doc_typess.add(record);
        isload = true;
      }

      for (int i = 0; i < constanst.doc_typess.length; i++) {
        constanst.Document_type_itemsCheck.add(Icons.circle_outlined);
      }
      setState(
        () {},
      );
    } else {
      isload = true;
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(
        res['message'],
      );
    }
    return jsonArray;
  }

  Future<bool> update_BusinessVerification() async {
    setState(() {
      _isloading1 = true;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    selectFilesLableName = selectFilesLable.map((e) => e.id).join(",");

    String device = Platform.isAndroid ? 'android' : 'ios';

    print('Device Name: $device');
    print("Aadhar Number: ${_adhaarnumber.text}");
    print("Pan Number: ${_pannumber.text}");

    var res = await updateBusinessVerification(
      userId: pref.getString('user_id').toString(),
      userToken: pref.getString('userToken').toString(),
      registrationDate: _useresiger.text,
      panNumber: _pannumber.text,
      aadharNumber: _adhaarnumber.text,
      exportImportNumber: _exno.text,
      premises: _selectPremises.toString(),
      gstTaxVat: _usergst.text,
      docType: constanst.select_document_type_id.toString(),
      productionCapacity: constanst.select_product_cap_id.join(","),
      filesList: select_doctype,
      selectFilesLables: selectFilesLableName.toString(),
      device: device,
    );

    updateAnnualTurnoverData();

    setState(() {
      _isloading1 = false;
    });

    String message = res['message'] ?? 'An error occurred';
    showCustomToast(message);

    return res['status'] == 1;
  }

  getProfiless() async {
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

    if (getprofile.doc != null && getprofile.doc!.isNotEmpty) {
      resultList = getprofile.doc!;
    } else {
      resultList = []; // Assign empty list if null
    }

    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      print("JFDJG $res");
      _usergst.text = res['profile']['gst_tax_vat'] ?? '';
      _exno.text = res['profile']['export_import_number'] ?? '';
      _useresiger.text = res['profile']['registration_date'] ?? '';
      _pannumber.text = res['profile']['pan_number'] ?? '';
      print('pannumber: $_pannumber');
      _adhaarnumber.text = res['profile']['aadhar_no'] ?? '';
      print("Aadhar Number: ${_adhaarnumber.text}");

      userId = res['profile']['user_id'] ?? '';
      gst_verification_status = res['profile']['gst_verification_status'];

      // Assuming `res` is your JSON response
      List<dynamic> annualTurnovers = res['profile']['annualTurnovers'] ?? [];

      print('annualTurnovers: $annualTurnovers');

      if (annualTurnovers.isNotEmpty) {
        firstyear = annualTurnovers[0]['year'] ?? '';
        secondYear =
            annualTurnovers.length > 1 ? annualTurnovers[1]['year'] ?? '' : '';
        thirdYear =
            annualTurnovers.length > 2 ? annualTurnovers[2]['year'] ?? '' : '';
      }

      if (annualTurnovers.isNotEmpty) {
        firstyear_currency = annualTurnovers[0]['currency'] ?? '';
        secondyear_currency = annualTurnovers.length > 1
            ? annualTurnovers[1]['currency'] ?? ''
            : '';
        thirdyear_currency = annualTurnovers.length > 2
            ? annualTurnovers[2]['currency'] ?? ''
            : '';
      }

      if (annualTurnovers.isNotEmpty) {
        firstyear_amount = annualTurnovers[0]['amount'] ?? '';
        secondyear_amount = annualTurnovers.length > 1
            ? annualTurnovers[1]['amount'] ?? ''
            : '';
        thirdyear_amount = annualTurnovers.length > 2
            ? annualTurnovers[2]['amount'] ?? ''
            : '';
      }

      // Assuming _prd_cap.text is a TextEditingController
      _prd_cap.text = res['profile']['annualcapacity'] != null
          ? res['profile']['annualcapacity']['name'].toString()
          : "";

      print("_prd_cap.text: ${_prd_cap.text}");

      constanst.select_product_cap_id = res['profile']['annualcapacity'] != null
          ? [res['profile']['annualcapacity']['id'].toString()]
          : [];

      print(
          "constanst.select_product_cap_id: ${constanst.select_product_cap_id}");

      if (res['profile']['premises'] is List &&
          res['profile']['premises'].isNotEmpty) {
        _selectPremises = res['profile']['premises'][0];
      } else {
        _selectPremises = res['profile']['premises']?.toString() ?? '';
      }
      print("_selectPremises: ${_selectPremises}");
      if (res['doc'] != null && res['doc'] != []) {
        var jsonArray = res['doc'];

        for (var data in jsonArray) {
          Doc record = Doc(
            id: data['id'],
            docType: data['doc_type'].toString(),
            documentUrl: data['document_url'],
            doctype: Amounts2021.fromJson(data['doctype']),
          );
          get_doctype.add(record);
        }
      }
      print("res['doc']:- ${res['doc']}");

      isload = true;
    } else {
      log("ELSE RUN");

      isload = true;
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(
        res['message'],
      );
    }

    setState(
      () {},
    );
  }

  Future<void> remove_document(String docId) async {
    isload = false;
    var res = await remove_docu(docId);
    if (res['status'] == 1) {
      if (mounted) {
        setState(
          () {},
        );
      }
    } else {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(
        res['message'],
      );
    }
    isload = true;
  }
}

class type extends StatefulWidget {
  const type({Key? key}) : super(key: key);

  @override
  State<type> createState() => _typeState();
}

class _typeState extends State<type> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Select Production Capacity',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              itemCount: constanst.production_cap.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final record = constanst.production_cap[index];
                return CommanBottomSheet(
                    title: record.name.toString(),
                    checked: constanst.select_product_cap_id
                        .contains(record.id.toString()),
                    onTap: () {
                      setState(() {
                        String idString = record.id.toString();
                        String nameString = record.name.toString();

                        if (constanst.select_product_cap_id
                            .contains(idString)) {
                          constanst.Product_Capcity_name.remove(nameString);
                          constanst.select_product_cap_id.remove(idString);
                        } else {
                          constanst.Product_Capcity_name.clear();
                          constanst.select_product_cap_id.clear();

                          constanst.Product_Capcity_name.add(nameString);
                          constanst.select_product_cap_id.add(idString);
                        }
                      });
                    });
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 1.2,
            height: 60,
            margin: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(50.0),
              color: AppColors.primaryColor,
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Update',
                style: TextStyle(
                  fontSize: 19.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class document_type extends StatefulWidget {
  const document_type({Key? key}) : super(key: key);

  @override
  State<document_type> createState() => _document_typeState();
}

class _document_typeState extends State<document_type> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Select Document Type',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              shrinkWrap: true,
              itemCount: constanst.doc_typess.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                doc_type.Types record = constanst.doc_typess[index];
                return GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          if (constanst.select_document_type_idx == index) {
                            constanst.Document_type_itemsCheck[index] =
                                Icons.circle_outlined;
                            constanst.select_document_type_id = "";
                            constanst.Document_type_name = "";
                            constanst.select_document_type_idx =
                                -1; // Unselect the item
                          } else {
                            constanst.select_document_type_idx = index;
                            constanst.Document_type_itemsCheck[index] =
                                Icons.check_circle_outline;
                            constanst.select_document_type_id =
                                record.id.toString();
                            constanst.Document_type_name =
                                record.name.toString();
                          }
                        },
                      );
                    },
                    child: CommanBottomSheet(
                      onTap: () {
                        setState(
                          () {
                            if (constanst.select_document_type_idx == index) {
                              constanst.Document_type_itemsCheck[index] =
                                  Icons.circle_outlined;
                              constanst.select_document_type_id = "";
                              constanst.Document_type_name = "";
                              constanst.select_document_type_idx =
                                  -1; // Unselect the item
                            } else {
                              constanst.select_document_type_idx = index;
                              constanst.Document_type_itemsCheck[index] =
                                  Icons.check_circle_outline;
                              constanst.select_document_type_id =
                                  record.id.toString();
                              constanst.Document_type_name =
                                  record.name.toString();
                            }
                          },
                        );
                      },
                      checked: constanst.select_document_type_idx == index,
                      title: record.name.toString(),
                    ));
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 1.2,
            height: 60,
            margin: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(50.0),
              color: AppColors.primaryColor,
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(
                  () {},
                );
              },
              child: const Text(
                'Update',
                style: TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'assets/fonst/Metropolis-Black.otf'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
