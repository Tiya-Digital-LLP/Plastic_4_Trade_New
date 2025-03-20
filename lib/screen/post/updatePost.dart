// ignore_for_file: must_be_immutable, non_constant_identifier_names, list_remove_unrelated_type, unnecessary_null_comparison, use_build_context_synchronously, prefer_typing_uninitialized_variables, camel_case_types, depend_on_referenced_packages, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/common/commom_dialog_reupload.dart';
import 'package:Plastic4trade/model/search_image_web_model.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_api_google_plac_api.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_text_field_price.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/utill/text_capital.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Plastic4trade/constroller/GetColorsController.dart';
import 'package:Plastic4trade/constroller/GetUnitController.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'dart:io' as io;
import 'package:Plastic4trade/model/CommonPostdetail.dart' as postdetail;
import 'package:Plastic4trade/model/GetCategory.dart' as cat;
import 'package:Plastic4trade/model/GetCategoryType.dart' as type;
import 'package:Plastic4trade/model/GetCategoryGrade.dart' as grade;
import 'package:Plastic4trade/model/GetColors.dart' as color;
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Plastic4trade/model/GetProductName.dart' as pnm;
import '../../api/api_interface.dart';
import '../../common/bottomSheetList.dart';
import '../../constroller/GetCategoryController.dart';
import '../../constroller/GetCategoryGradeController.dart';
import '../../constroller/GetCategoryTypeController.dart';
import '../../model/CommonPostdetail.dart';
import '../../model/GetProductName.dart';
import 'package:http/http.dart' as http;

class UpdatePOst extends StatefulWidget {
  String? post_type;
  String? prod_id;

  UpdatePOst(this.post_type, this.prod_id, {Key? key}) : super(key: key);

  @override
  State<UpdatePOst> createState() => _UpdatePOstState();
}

class RadioModel {
  bool isSelected;
  final String buttonText;

  RadioModel(this.isSelected, this.buttonText);
}

class _UpdatePOstState extends State<UpdatePOst> {
  List<RadioModel> sampleData1 = <RadioModel>[];
  final TextEditingController _prodnm = TextEditingController();
  final TextEditingController _prod_cate = TextEditingController();
  final TextEditingController _prod_type = TextEditingController();
  final TextEditingController _prod_grade = TextEditingController();
  final TextEditingController _prodprice = TextEditingController();
  final TextEditingController _prodcolor = TextEditingController();
  final TextEditingController _prodqty = TextEditingController();
  final TextEditingController _loc = TextEditingController();
  final TextEditingController _proddetail = TextEditingController();
  List<String> _suggestions = [];
  List<postdetail.SubproductImage> subProductImageList = [];
  String alterMainImageUrl = "";
  Color _color1 = Colors.black26;
  Color _color2 = Colors.black26;
  Color _color3 = Colors.black26;
  Color _color4 = Colors.black26;
  Color _color5 = Colors.black26;
  Color _color6 = Colors.black26;
  Color _color7 = Colors.black26;
  Color _color8 = Colors.grey;
  final Color _color9 = Colors.grey;
  Color _color10 = Colors.grey;
  final Color _color12 = Colors.grey;
  String crown_color = '';
  String plan_name = '';

  final _formKey = GlobalKey<FormState>();
  //PickedFile? _imagefiles, _imagefiles1, _imagefiles2;
  io.File? file, file1, file2;
  bool? _isloading = false;
  String notiId = "",
      main_product = "",
      main_product1 = "",
      main_product2 = "",
      // image_id = "",
      image1_id = "",
      image2_id = "";
  CommonPostdetail? commonPostdetail;
  late double? lat;
  late double? log;
  String? state, country_code, city, country;
  final ImagePicker _picker = ImagePicker();
  bool category1 = false;
  String type_post = "";
  bool _isloading1 = false;
  BuildContext? dialogContext;
  String? _select_postType = "";
  String? _selectitem4;
  String? _selectitem5 = "";
  String? _selectitem6 = "";
  String? _tempSelectitem5 = "";
  String? _tempSelectitem6 = "";

  CameraPosition? cameraPosition;
  LatLng startLocation = const LatLng(0, 0);
  String location = "Search Location";

  List<String> listrupes = ['₹', '\$', '€', '£', '¥'];

  bool isLoading = false;
  int offset = 0;
  List<SearchImageWebModel> imageList = [];
  SearchImageWebModel? selectedImage;

  // Pagination variables
  int _currentPage = 0;
  int _limit = 10;
  bool _hasMoreImages = true;
  bool _isLoadingMore = false;

  // Scroll controller for pagination
  late ScrollController _scrollController;

  bool is_search_image_active = false;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);

    super.initState();
    _initializeGoogleApiKey();
    _selectitem5 = _tempSelectitem5;
    _selectitem6 = _tempSelectitem6;
    sampleData1.add(
      RadioModel(false, 'Buy Post'),
    );
    sampleData1.add(
      RadioModel(false, 'Sell Post'),
    );
    checknetwork();
  }

  // Function to initialize the Google API Key
  Future<void> _initializeGoogleApiKey() async {
    String? apiKey = await ApiKeyService.fetchGoogleKey();
    if (mounted) {
      setState(() {
        constanst.googleApikey = apiKey ?? '';
      });
    }
  }

  clear_data() {
    _selectitem4 = null;
    _selectitem5 = null;
    _selectitem6 = null;
    _tempSelectitem5 = null;
    _tempSelectitem6 = null;
    constanst.unitdata.clear();
    constanst.colorsitemsCheck.clear();
    constanst.category_itemsCheck.clear();
    constanst.itemsCheck.clear();
    constanst.color_id_list.clear();
    constanst.color_name_list.clear();
    constanst.select_typeId.clear();
    constanst.select_typename.clear();
    constanst.select_categotyType.clear();
    constanst.select_categotyId.clear();
    constanst.select_gradname.clear();
    constanst.select_gradeId.clear();
    constanst.category_itemsCheck1.clear();
    constanst.Type_itemsCheck.clear();
    constanst.Type_itemsCheck1.clear();
    constanst.Grade_itemsCheck.clear();
    constanst.Grade_itemsCheck1.clear();
    constanst.imagesList.clear();
    constanst.select_color_id = "";
    constanst.select_color_name = "";
    constanst.select_cat_id = "";
    constanst.select_cat_name = "";
    constanst.select_cat_idx;
    constanst.select_type_id = "";
    constanst.select_type_idx;
    constanst.select_type_name = "";
    constanst.select_grade_id = "";
    constanst.select_gradname.clear();
    constanst.select_grade_idx;
    constanst.Product_color = "";
    constanst.colorsitemsCheck.clear();
    constanst.selectcolor_name.clear();
    constanst.selectcolor_id.clear();
    constanst.select_prodcolor_idx = 0;
    constanst.unit_data = null;
    constanst.color_data = null;
    constanst.cat_typedata = null;
    constanst.cat_gradedata = null;
    constanst.cat_data = null;
  }

  @override
  void dispose() {
    _scrollController.dispose();

    clear_data();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoadingMore && _hasMoreImages) {
        setState(() {});
        _loadMoreImages();
      }
    }
  }

  Future<void> _searchImageOnWeb({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _currentPage = 0;
        imageList.clear();
        _hasMoreImages = true;
      });
    }

    if (!_hasMoreImages || _isLoadingMore) return;

    setState(() {
      isLoading = !loadMore;
      _isLoadingMore = loadMore;
    });

    try {
      final res = await searchonweb(
        _prodnm.text,
        _prod_cate.text,
        _prod_type.text,
        _prod_grade.text,
        (_currentPage * _limit).toString(),
      );

      if (!mounted) return;

      if (res is List) {
        final newImages =
            res.map((json) => SearchImageWebModel.fromJson(json)).toList();

        setState(() {
          if (newImages.isEmpty) {
            _hasMoreImages = false;
          } else {
            imageList = List.from(imageList)..addAll(newImages);
            _currentPage++;
          }
        });
      } else {
        print('Error: Unexpected API response format.');
        setState(() {
          _hasMoreImages = false;
        });
      }
    } catch (e) {
      print('Error fetching images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching images: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _loadMoreImages() {
    if (_hasMoreImages && !_isLoadingMore) {
      _searchImageOnWeb(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: true,
        left: true,
        right: true,
        maintainBottomViewPadding: true,
        child: SingleChildScrollView(
          child: _isloading == false
              ? Center(
                  child: CustomLottieContainer(
                    child: Lottie.asset(
                      'assets/loading_animation.json',
                    ),
                  ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          child: Image.asset('assets/back.png',
                              height: 50, width: 60),
                          onTap: () {
                            Navigator.pop(context);
                            clear_data();
                          },
                        ),
                        const SizedBox(
                          width: 80.0,
                        ),
                        Center(
                          child: Text(
                            'Update Post',
                            style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf')
                                .copyWith(fontSize: 20.0),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Align(
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
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black38),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  child: SizedBox(
                                    height: 30,
                                    width: 120,
                                    child: Row(
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              child: sampleData1
                                                          .first.isSelected ==
                                                      true
                                                  ? Icon(Icons.check_circle,
                                                      color: AppColors
                                                          .greenWithShade)
                                                  : const Icon(
                                                      Icons.circle_outlined,
                                                      color: Colors.black38),
                                              onTap: () {
                                                setState(() {
                                                  sampleData1.first.isSelected =
                                                      true;
                                                  type_post = sampleData1
                                                      .first.buttonText;
                                                  sampleData1.last.isSelected =
                                                      false;
                                                  category1 = true;
                                                });
                                              },
                                            ),
                                            5.sbw,
                                            Text(sampleData1.first.buttonText,
                                                style: const TextStyle(
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                        fontFamily:
                                                            'assets/fonst/Metropolis-Black.otf')
                                                    .copyWith(fontSize: 17))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      sampleData1.first.isSelected = true;
                                      type_post = sampleData1.first.buttonText;
                                      sampleData1.last.isSelected = false;
                                      category1 = true;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: SizedBox(
                                      width: 150,
                                      height: 30,
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            child:
                                                sampleData1.last.isSelected ==
                                                        true
                                                    ? Icon(Icons.check_circle,
                                                        color: AppColors
                                                            .greenWithShade)
                                                    : const Icon(
                                                        Icons.circle_outlined,
                                                        color: Colors.black38),
                                            onTap: () {
                                              setState(() {
                                                sampleData1.last.isSelected =
                                                    true;
                                                sampleData1.first.isSelected =
                                                    false;
                                                category1 = true;
                                                type_post =
                                                    sampleData1.last.buttonText;
                                              });
                                            },
                                          ),
                                          5.sbw,
                                          Text(sampleData1.last.buttonText,
                                              style: const TextStyle(
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(fontSize: 17))
                                        ],
                                      )),
                                  onTap: () {
                                    setState(() {
                                      sampleData1.last.isSelected = true;
                                      sampleData1.first.isSelected = false;
                                      category1 = true;
                                      type_post = sampleData1.last.buttonText;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _color1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: SizedBox(
                          height: 55,
                          child: TypeAheadField<String>(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: _prodnm,
                              style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf'),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  WidgetsBinding
                                      .instance.focusManager.primaryFocus
                                      ?.unfocus();
                                  showCustomToast(
                                      'Please Add Your Product Name');
                                  _color1 = AppColors.red;
                                } else if (value.length > 40) {
                                  showCustomToast(
                                      'Product name cannot exceed 40 characters');
                                  _prodnm.value = TextEditingValue(
                                    text: value.substring(0, 40).toUpperCase(),
                                    selection: TextSelection.fromPosition(
                                      TextPosition(offset: 40),
                                    ),
                                  );
                                } else {
                                  final upperCaseValue = value.toUpperCase();
                                  _prodnm.value = TextEditingValue(
                                    text: upperCaseValue,
                                    selection: TextSelection.fromPosition(
                                      TextPosition(
                                          offset: upperCaseValue.length),
                                    ),
                                  );
                                }
                              },
                              onSubmitted: (value) {
                                if (value.isEmpty) {
                                  _color1 = AppColors.red;
                                  setState(() {});
                                } else if (value.length > 40) {
                                  showCustomToast(
                                      'Product name cannot exceed 40 characters');
                                  _prodnm.value = TextEditingValue(
                                    text: value.substring(0, 40).toUpperCase(),
                                    selection: TextSelection.fromPosition(
                                      TextPosition(offset: 40),
                                    ),
                                  );
                                  _color1 = AppColors.greenWithShade;
                                  setState(() {});
                                } else if (value.isNotEmpty) {
                                  _color1 = AppColors.greenWithShade;
                                  setState(() {});
                                }
                              },
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: "Product Name *",
                                labelStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                filled: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                fillColor: Colors.white,
                                border: InputBorder.none,
                              ),
                            ),
                            suggestionsCallback: (pattern) {
                              if (pattern.isNotEmpty) {
                                return _getSuggestions(pattern);
                              }
                              return [];
                            },
                            itemBuilder: (context, suggestion) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.search,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        suggestion,
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf',
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.north_west,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              );
                            },
                            onSuggestionSelected: (suggestion) async {
                              if (suggestion.length > 40) {
                                showCustomToast(
                                    'Product name cannot exceed 40 characters');
                                _prodnm.text =
                                    suggestion.substring(0, 40).toUpperCase();
                              } else {
                                _prodnm.text = suggestion.toUpperCase();
                              }
                              _color1 = AppColors.greenWithShade;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                      child: CustomTextField(
                          readOnly: true,
                          controller: _prod_cate,
                          labelText: "Product Category *",
                          borderColor: _color2,
                          suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                          inputFormatters: [],
                          validator: (value) {
                            if (value!.isEmpty) {
                              _color2 = AppColors.red;
                            } else {}
                            return null;
                          },
                          onTap: () {
                            Viewproduct(context);
                          },
                          onFieldSubmitted: (value) {
                            if (value.isEmpty) {
                              showCustomToast('Please Your Product Category');
                              setState(() {});
                            } else if (value.isNotEmpty) {
                              setState(() {});
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                      child: CustomTextField(
                          readOnly: true,
                          controller: _prod_type,
                          labelText: "Product Type *",
                          borderColor: _color3,
                          suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                          inputFormatters: [],
                          onTap: () {
                            Viewtype(context);
                          },
                          onFieldSubmitted: (value) {
                            if (value.isEmpty) {
                              showCustomToast(
                                  'Please Your Product CategoryType');
                              setState(() {});
                            } else if (value.isNotEmpty) {
                              setState(() {});
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                      child: CustomTextField(
                          readOnly: true,
                          controller: _prod_grade,
                          labelText: "Product Grade *",
                          borderColor: _color4,
                          suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                          inputFormatters: [],
                          onTap: () {
                            Viewgrade(context);
                          },
                          onFieldSubmitted: (value) {
                            if (value.isEmpty) {
                              _color4 = AppColors.red;
                              showCustomToast('Please Your Product Category');
                              setState(() {});
                            } else if (value.isNotEmpty) {
                              setState(() {});
                            }
                          }),
                    ),
                    Container(
                      height: 62,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: _color8),
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.9,
                            child: CustomTextFieldPrice(
                              keyboardType: TextInputType.number,
                              controller: _prodprice,
                              labelText: "Price *",
                              borderColor: _color4,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r"\d"),
                                ),
                                LengthLimitingTextInputFormatter(9)
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                } else {}
                                return null;
                              },
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {});
                                }
                              },
                              onFieldSubmitted: (value) {
                                if (value.isEmpty) {
                                  setState(() {});
                                } else {
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                          const VerticalDivider(
                            width: 1,
                            color: Colors.black38,
                          ),
                          Unit_dropdown(constanst.unitdata, "Unit", false,
                              _selectitem5, _tempSelectitem5),
                          const VerticalDivider(
                            width: 1,
                            color: Colors.black38,
                          ),
                          rupess_dropdown(listrupes, 'Currency'),
                        ],
                      ),
                    ),
                    Container(
                      height: 62,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _color10),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 1.7,
                            padding: const EdgeInsets.only(
                                top: 3, bottom: 3.0, left: 2.0),
                            child: CustomTextFieldPrice(
                              keyboardType: TextInputType.number,
                              controller: _prodqty,
                              labelText: "Qty *",
                              borderColor: _color4,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r"\d"),
                                ),
                                LengthLimitingTextInputFormatter(5)
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                } else {}
                                return null;
                              },
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {});
                                }
                              },
                              onFieldSubmitted: (value) {
                                if (value.isEmpty) {
                                  setState(() {});
                                } else {
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                          const VerticalDivider(
                            width: 1,
                            color: Colors.black38,
                          ),
                          Unit_dropdown(constanst.unitdata, "Unit", true,
                              _selectitem6, _tempSelectitem6),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                      child: CustomTextField(
                          controller: _prodcolor,
                          labelText: "Color *",
                          readOnly: true,
                          suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                          borderColor: _color5,
                          inputFormatters: [],
                          validator: (value) {
                            if (value!.isEmpty) {
                              _color5 = AppColors.red;
                            } else {}
                            return null;
                          },
                          onTap: () {
                            ViewItem(context);
                          },
                          onFieldSubmitted: (value) {
                            if (value.isEmpty) {
                              _color5 = AppColors.red;
                              setState(() {});
                            } else if (value.isNotEmpty) {
                              setState(() {});
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                      child: CustomTextField(
                        controller: _loc,
                        labelText: "Location/ Address / City *",
                        readOnly: true,
                        borderColor: _color6,
                        inputFormatters: [],
                        onTap: () async {
                          var place = await PlacesAutocomplete.show(
                              context: context,
                              apiKey: constanst.googleApikey,
                              mode: Mode.overlay,
                              types: ['geocode', 'establishment'],
                              strictbounds: false,
                              onError: (err) {});

                          if (place != null) {
                            setState(() {
                              location = place.description.toString();
                              _loc.text = location;
                              _color5 = AppColors.greenWithShade;
                            });
                            final plist = GoogleMapsPlaces(
                              apiKey: constanst.googleApikey,
                              apiHeaders:
                                  await const GoogleApiHeaders().getHeaders(),
                            );
                            String placeid = place.placeId ?? "0";
                            final detail =
                                await plist.getDetailsByPlaceId(placeid);
                            setState(() {
                              for (var component
                                  in detail.result.addressComponents) {
                                for (var type in component.types) {
                                  if (type == "administrative_area_level_1") {
                                    state = component.longName;
                                    print("State: ${component.longName}");
                                  } else if (type == "locality") {
                                    city = component.longName;
                                    print("City: ${component.longName}");
                                  } else if (type == "country") {
                                    country = component.longName;
                                    print("Country: ${component.longName}");
                                  }
                                }
                              }
                              final geometry = detail.result.geometry!;
                              lat = geometry.location.lat;
                              log = geometry.location.lng;
                            });
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            _color6 = AppColors.red;
                          } else {}
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              _color6 = AppColors.red;
                            });
                          } else if (value.isNotEmpty) {
                            setState(() {
                              _color6 = AppColors.greenWithShade;
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _color7,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: SizedBox(
                          height: 120,
                          child: TextFormField(
                            controller: _proddetail,
                            keyboardType: TextInputType.multiline,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily:
                                    'assets/fonst/Metropolis-Black.otf'),
                            maxLines: 4,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Product Detail Description & Uses *",
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                _color7 = AppColors.red;
                              } else {}
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                showCustomToast(
                                    'Please Add Your Product Description');
                                _color7 = AppColors.red;
                                setState(() {});
                              } else if (value.isNotEmpty) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildImageContainer(
                            imageUrl: main_product,
                            file: file,
                            isFirstImage: true,
                            onDelete: () {
                              // setState(() {
                              //   subProductImageList.removeWhere(
                              //       (e) => e.subImageUrl == main_product);
                              //   main_product = "";
                              //   file = null;
                              // });

                              showCustomToast(
                                  'You Can not delete first post you can change it');
                            },
                            onTap: () {
                              if (file == null) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => bottomsheet(),
                                );
                              }
                            },
                          ),
                          _buildImageContainer(
                            imageUrl: main_product1,
                            file: file1,
                            isFirstImage: false,
                            onDelete: () {
                              setState(() {
                                if (file1 != null) {
                                  print(
                                      "Removing file from imagesList: $file1");
                                  constanst.imagesList.remove(file1);
                                  file1 = null;
                                } else {
                                  main_product1 = "";
                                }

                                delete_subimage(image1_id).then((value) {
                                  if (value == true) {
                                    subProductImageList.removeWhere(
                                        (e) => e.productImageId == image1_id);
                                    main_product1 = "";
                                    image1_id = "";
                                    file1 = null;
                                  }
                                });
                              });
                            },
                            onTap: () {
                              // Clear the old image before opening the bottom sheet for replacement
                              setState(() {
                                file1 = null; // Clear the file reference
                                main_product1 =
                                    ""; // Clear the main product image
                              });

                              delete_subimage(image1_id).then((value) {
                                if (value == true) {
                                  subProductImageList.removeWhere(
                                      (e) => e.productImageId == image1_id);
                                  main_product1 = "";
                                  image1_id = "";
                                  file1 = null;
                                }
                              });

                              showModalBottomSheet(
                                context: context,
                                builder: (context) => bottomsheet1(),
                              );
                            },
                          ),
                          _buildImageContainer(
                            imageUrl: main_product2,
                            file: file2,
                            isFirstImage: false,
                            onDelete: () {
                              setState(() {
                                if (file2 != null) {
                                  print(
                                      "Removing file from imagesList: $file2");
                                  constanst.imagesList.remove(file2);
                                  file2 = null;
                                } else {
                                  main_product2 = "";
                                }
                                delete_subimage(image2_id).then((value) {
                                  if (value == true) {
                                    subProductImageList.removeWhere(
                                        (e) => e.productImageId == image2_id);
                                    main_product2 = "";
                                    image2_id = "";
                                    file2 = null;
                                  }
                                });
                              });
                            },
                            onTap: () {
                              setState(() {
                                file2 = null; // Clear the file reference
                                main_product2 =
                                    ""; // Clear the main product image
                              });
                              delete_subimage(image2_id).then((value) {
                                if (value == true) {
                                  subProductImageList.removeWhere(
                                      (e) => e.productImageId == image2_id);
                                  main_product2 = "";
                                  image2_id = "";
                                  file2 = null;
                                }
                              });
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => bottomsheet2(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    10.sbh,
                    CustomButton(
                      buttonText: 'Update',
                      onPressed: () async {
                        GtmUtil.logScreenView(
                          'UpdatePost',
                          'UpdatePost',
                        );
                        if (_formKey.currentState!.validate()) {}
                        setState(() {
                          if (city != null &&
                              city!.isNotEmpty &&
                              city != "-" &&
                              state != null &&
                              state!.isNotEmpty &&
                              state != "-" &&
                              country != null &&
                              country!.isNotEmpty &&
                              country != "-" &&
                              log != null &&
                              log != 0.0 &&
                              lat != null &&
                              lat != 0.0) {
                            if (constanst.imagesList.isEmpty &&
                                subProductImageList.isEmpty &&
                                file == null &&
                                (main_product == null ||
                                    main_product == "" ||
                                    main_product == "null" ||
                                    main_product.isEmpty)) {
                              showCustomToast('Please Add Your Product Image');
                            } else {
                              vaild_data();
                            }
                          } else {
                            showCustomToast('Please Re-Enter Stock Location');
                          }
                        });
                      },
                      isLoading: _isloading1,
                    ),
                    10.sbh,
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageContainer({
    required String imageUrl,
    required File? file,
    required VoidCallback onDelete,
    required VoidCallback onTap,
    required bool isFirstImage,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13.05),
      child: imageUrl.isNotEmpty || file != null
          ? Stack(
              children: [
                GestureDetector(
                  child: file != null
                      ? Image.file(
                          file,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          imageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                  onTap: onTap,
                ),
                Visibility(
                  visible: file != null || imageUrl.isNotEmpty,
                  child: Positioned(
                    bottom: -5,
                    left: 25,
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(2.0),
                      child: Card(
                        shape: const CircleBorder(),
                        child: GestureDetector(
                          child: Icon(
                            isFirstImage
                                ? Icons.replay_circle_filled
                                : Icons.delete,
                            color: isFirstImage ? Colors.blue : AppColors.red,
                          ),
                          onTap: onDelete,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          : Stack(
              children: [
                GestureDetector(
                  child: Image.asset(
                    'assets/addphoto1.png',
                    height: 100,
                    width: 100,
                  ),
                  onTap: onTap,
                ),
              ],
            ),
    );
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

    if (res['status'] == 1) {
      setState(() {
        if (res['product_image_suggetion'] != null) {
          is_search_image_active = res['product_image_suggetion'];
          print('Is product_image_suggetion: $is_search_image_active');
        }

        print("${res['profile']}");
      });
    } else {
      showCustomToast(res['message']);
    }
    return res;
  }

  List<String> _getSuggestions(String query) {
    if (query.isEmpty) {
      return _suggestions;
    }

    List<String> matches = _suggestions.where((suggestion) {
      return suggestion.toLowerCase().contains(query.toLowerCase());
    }).toList();

    matches.sort((a, b) {
      bool aStartsWithQuery = a.toLowerCase().startsWith(query.toLowerCase());
      bool bStartsWithQuery = b.toLowerCase().startsWith(query.toLowerCase());

      if (aStartsWithQuery && !bStartsWithQuery) return -1;
      if (bStartsWithQuery && !aStartsWithQuery) return 1;

      String aLastWord = a.split(' ').last;
      String bLastWord = b.split(' ').last;

      bool aLastWordStartsWithQuery =
          aLastWord.toLowerCase().startsWith(query.toLowerCase());
      bool bLastWordStartsWithQuery =
          bLastWord.toLowerCase().startsWith(query.toLowerCase());

      if (aLastWordStartsWithQuery && !bLastWordStartsWithQuery) return -1;
      if (bLastWordStartsWithQuery && !aLastWordStartsWithQuery) return 1;

      bool aEndsWithQuery = a.toLowerCase().endsWith(query.toLowerCase());
      bool bEndsWithQuery = b.toLowerCase().endsWith(query.toLowerCase());

      if (aEndsWithQuery && !bEndsWithQuery) return -1;
      if (bEndsWithQuery && !aEndsWithQuery) return 1;

      if (a.length == 1 && b.length > 1) return -1;
      if (b.length == 1 && a.length > 1) return 1;

      return a.compareTo(b);
    });

    return matches;
  }

  Future<bool> update_SalePost() async {
    setState(() {
      _isloading1 = true; // Show loader when starting login process
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    constanst.step = 11;
    print("fileList:-${constanst.imagesList.length}");
    print("imagesList:-${subProductImageList.length}");
    // Condition to handle file changes and logging
    if (constanst.imagesList.isNotEmpty &&
        subProductImageList.isEmpty &&
        file == null &&
        (main_product == null ||
            main_product == "" ||
            main_product == "null" ||
            main_product.isEmpty)) {
      print("Entering file handling condition");

      if (file1 != null) {
        file = file1;
        constanst.imagesList.remove(file1!);
        file1 = null;
        print(
            "File1 is set. Updated fileList length: ${constanst.imagesList.length}");
      } else if (file2 != null) {
        file = file2;
        constanst.imagesList.remove(file2!);
        file2 = null;
        print(
            "File2 is set. Updated fileList length: ${constanst.imagesList.length}");
      } else {
        print("Neither file1 nor file2 is available");
      }
    } else {
      print("Conditions for file handling not met");
    }
    // if (constanst.imagesList.isNotEmpty && main_product.isNotEmpty) {
    //   print("Images list is not empty. Calling add_salesubimage.");
    //   constanst.imagesList.remove(file!);
    //   add_salesubimage(prod_id: widget.prod_id.toString());
    // }
    if (constanst.imagesList.isNotEmpty &&
        subProductImageList.isEmpty &&
        file == null &&
        (main_product == null ||
            main_product == "" ||
            main_product == "null" ||
            main_product.isEmpty)) {
      print("Images list is not empty. Calling delete_mainProductImage.");
      delete_mainProductImage(
          subImageId: subProductImageList.first.productImageId!);
    } else {
      print("Images list is empty. Skipping delete_mainProductImage.");
    }
    print("fileList1:-${constanst.imagesList.length}");
    print("imagesList2:-${subProductImageList.length}");

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await updateSalePost(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      constanst.select_typeId.join(","),
      constanst.select_gradeId.join(","),
      _selectitem4.toString(),
      _prodprice.text.toString(),
      _prodqty.text.toString(),
      constanst.color_id_list.join(","),
      _proddetail.text.toString(),
      _selectitem5.toString(),
      _selectitem6.toString(),
      _loc.text.toString(),
      lat.toString(),
      log.toString(),
      '0',
      city!,
      state!,
      country!,
      constanst.step.toString(),
      _prodnm.text.toString(),
      constanst.select_categotyId.join(","),
      alterMainImageUrl,
      widget.prod_id.toString(),
      device,
      constanst.version,
    );

    if (res['status'] == 1) {
      showCustomToast(
        res['message'],
      );
      clear_data();
    } else {
      setState(() {
        _isloading1 = false; // Show loader when starting login process
      });
      showCustomToast(
        res['message'],
      );
      clear_data();
    }
    setState(() {
      _isloading1 = true;
    });
    return _isloading1;
  }

  Future addimage({
    required String prod_id,
    required List<File?> images,
  }) async {
    String device = Platform.isAndroid ? 'android' : 'ios';

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseurl + 'updatePostImage'),
    );

    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    request.headers.addAll(headers);
    request.fields.addAll({
      'post_id': prod_id,
      'device': device,
    });

    int maxSize = 2 * 1024 * 1024; // 2 MB

    for (int i = 0; i < images.length; i++) {
      var imageFile = images[i];
      if (imageFile == null) {
        print('Image ${i + 1} is null');
        continue; // Skip null images
      }

      int fileSize = await imageFile.length();
      if (fileSize > maxSize) {
        print(
            'Image ${i + 1} exceeds size limit (${fileSize / (1024 * 1024)} MB)');
        continue; // Skip large files
      }

      print('Adding image ${i + 1}: ${imageFile.path}');

      request.files.add(
        http.MultipartFile(
          'image${i + 1}',
          imageFile.readAsBytes().asStream(),
          fileSize,
          filename: imageFile.path.split('/').last,
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      print('Request sent. Status code: ${streamedResponse.statusCode}');

      var response = await http.Response.fromStream(streamedResponse);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  Future<bool> update_BuyPost() async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    var addImageResult = await addimage(
      prod_id: widget.prod_id.toString(),
      images: [file, file1, file2],
    );

    if (addImageResult == null) {
      print('Failed to add images');
      return false;
    }

    // Device type logging
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    // API call and response logging
    var res = await updateBuyerPost(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      constanst.select_typeId.join(","),
      constanst.select_gradeId.join(","),
      _selectitem4.toString(),
      _prodprice.text.toString(),
      _prodqty.text.toString(),
      constanst.color_id_list.join(","),
      _proddetail.text.toString(),
      _selectitem5.toString(),
      _selectitem6.toString(),
      _loc.text.toString(),
      lat.toString(),
      log.toString(),
      '0',
      city!,
      state!,
      country!,
      "11",
      _prodnm.text.toString(),
      constanst.select_categotyId.join(","),
      alterMainImageUrl,
      file,
      widget.prod_id.toString(),
      device,
      constanst.version,
    );

    print("API Response: $res");

    if (res['status'] == 1) {
      showCustomToast(
        res['message'],
      );
      clear_data();
    } else {
      setState(() {
        _isloading1 = false; // Show loader when starting login process
      });
      showCustomToast(
        res['message'],
      );
      clear_data();
    }

    setState(() {
      _isloading1 = true;
    });

    return _isloading1;
  }

  Widget bottomsheet() {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.clear),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Choose Profile Photo",
                        style: TextStyle(
                            fontSize: 18.0, color: AppColors.blackColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  is_search_image_active
                      ? TextButton.icon(
                          onPressed: () {
                            GtmUtil.logScreenView(
                              'Search_Web',
                              'SearchWeb',
                            );
                            if (_prodnm.text.isEmpty) {
                              _color1 = AppColors.red;
                              setState(() {});
                              showCustomToast('Please Add Product Name First');
                              Navigator.pop(context);
                            } else {
                              _showBottomSheet(context);
                            }
                          },
                          icon: Icon(Icons.web, color: AppColors.primaryColor),
                          label: Text(
                            'Search Web',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        )
                      : SizedBox.shrink(),
                  TextButton.icon(
                    onPressed: () {
                      takephoto(
                        ImageSource.gallery,
                      );
                    },
                    icon: Icon(Icons.image, color: AppColors.primaryColor),
                    label: Text(
                      'Gallary',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                  TextButton.icon(
                      onPressed: () {
                        takephoto(
                          ImageSource.camera,
                        );
                      },
                      icon: Icon(Icons.camera, color: AppColors.primaryColor),
                      label: Text(
                        'Camera',
                        style: TextStyle(color: AppColors.primaryColor),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) async {
    await _searchImageOnWeb();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey,
                        ),
                      ),
                      10.sbh,
                      Text(
                        'Select an Image',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _prodnm,
                        labelText: 'Search',
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (value) async {
                          await _searchImageOnWeb();
                          setModalState(() {});
                        },
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              _loadMoreImages();
                              setModalState(() {});
                            }
                            return false;
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  controller: _scrollController,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                  ),
                                  itemCount: imageList.length,
                                  itemBuilder: (context, index) {
                                    final imageItem = imageList[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedImage = imageItem;
                                        });
                                        Navigator.pop(context);
                                        _redirectToProcessing();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: selectedImage == imageItem
                                              ? Colors.blue.shade100
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: selectedImage == imageItem
                                              ? Border.all(
                                                  color: Colors.blue, width: 2)
                                              : null,
                                        ),
                                        child: Image.network(
                                          imageItem.link,
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                                child: Icon(Icons.error));
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<io.File?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/downloaded_image.jpg';
        final file = io.File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Failed to download image');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  void _redirectToProcessing() async {
    if (selectedImage != null) {
      final imageUrl = selectedImage!.link;

      final downloadedFile = await _downloadImage(imageUrl);
      if (downloadedFile != null) {
        final croppedImage = await _cropImage(downloadedFile);
        if (croppedImage != null) {
          print('Image cropped successfully');

          final compressedImage = await _compressImage(croppedImage);
          if (compressedImage != null) {
            print('Image compressed successfully');

            constanst.imagesList.add(compressedImage);

            setState(() {
              file = compressedImage;
            });
            Navigator.of(context).pop();
          } else {
            print('Image compression failed');
          }
        } else {
          print('Image cropping failed');
        }
      } else {
        print('Failed to download image');
      }
    } else {
      print('No image selected');
    }
  }

  void takephoto(ImageSource imageSource) async {
    print('Step 1: Starting the takephoto method');

    final pickedfile =
        await _picker.pickImage(source: imageSource, imageQuality: 100);
    print(
        'Step 2: Image picked: ${pickedfile != null ? pickedfile.path : 'No image selected'}');

    if (pickedfile != null) {
      io.File imageFile = io.File(pickedfile.path);
      print('Step 3: Image file created from picked image path');

      int fileSizeInBytes = imageFile.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024;
      print('Step 4: Original image size is $fileSizeInKB KB');

      if (fileSizeInKB > 5000) {
        showCustomToast('Please Select an image below 5 MB');
        print('Step 5: Image size exceeds 5 MB, stopping process');
        return;
      }

      io.File? processedFile = imageFile;
      print('Step 6: Processing image, starting cropping');

      if (fileSizeInKB <= 100) {
        processedFile = await _cropImage(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
      } else if (fileSizeInKB > 100) {
        processedFile = await _cropImage(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
        processedFile = await _compressImage(processedFile);
      }
      print('Step 9: Image compression complete');

      double processedFileSizeInKB = processedFile!.lengthSync() / 1024;
      print('Step 10: Processed image size: $processedFileSizeInKB KB');

      if (mounted) {
        setState(() {
          file = processedFile;
          print('Step 11: Image assigned to file variable');
        });

        if (file != null) {
          constanst.imagesList.add(file!);
          print('Step 12: Image added to imagesList');
        }
      }

      var response = await noPromotionCheck(image: processedFile);
      if (response != null) {
        int status = response['status'];

        if (status == 1) {
          print('Status 1: not show image');
          Navigator.of(context).pop();
          return;
        } else if (status == 2) {
          showCustomToast('Warning: Text detected in the image');
          Navigator.of(context).pop();
          return;
        } else if (status == 3) {
          Navigator.of(context).pop();
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return CommomDialogReupload(
                  title: "Uplaod Image",
                  content:
                      "Not Allowed in Image Business cards, phone number, email Id and company name.",
                  onPressed: () {
                    setState(() {
                      constanst.imagesList.remove(file);
                      file = null;
                    });
                    Navigator.of(context).pop();
                  },
                );
              });
          return;
        }
      } else {
        showCustomToast('API response was null');
      }
    } else {
      showCustomToast('Please select an image');
      print('Step 14: No image selected, returning');
      return;
    }
  }

  Future<io.File?> _cropImage(io.File imageFile) async {
    print('Step 6a: Starting the cropping process');

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedFile != null) {
      print('Step 6b: Cropping successful');
      return io.File(croppedFile.path);
    } else {
      print('Step 6c: Cropping failed');
      return null;
    }
  }

  Future<io.File?> _compressImage(io.File imageFile) async {
    print('Step 9a: Starting image compression');

    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/temp.jpg';
    print('Step 9b: Temporary directory path set: $targetPath');

    int quality = 90;
    io.File? compressedFile;
    double fileSizeInKB;

    // Prevent infinite loop by setting a max iteration count
    const maxIterations = 10;
    int currentIteration = 0;

    while (currentIteration < maxIterations) {
      currentIteration++;

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
      );

      if (result == null) {
        print('Step 9c: Compression failed, returning null');
        return null;
      }

      compressedFile = io.File(result.path);
      fileSizeInKB = compressedFile.lengthSync() / 1024;
      print(
          'Step 9d: Compressed image size: $fileSizeInKB KB at quality $quality');

      if (fileSizeInKB <= 100) {
        // If file size is <= 100 KB, aim for a size of 20 to 30 KB
        if (fileSizeInKB <= 30) {
          print(
              'Step 9e: Image size within acceptable range, stopping compression');
          break;
        } else {
          quality = (quality - 10)
              .clamp(0, 100); // Reduce quality to decrease file size
          print('Step 9f: Decreasing quality to $quality');
        }
      } else {
        // If file size is > 100 KB, aim for a size around 100 KB
        if (fileSizeInKB <= 100) {
          print(
              'Step 9g: Image size within acceptable range, stopping compression');
          break;
        } else {
          quality = (quality - 10)
              .clamp(0, 100); // Reduce quality to decrease file size
          print('Step 9h: Decreasing quality to $quality');
        }
      }

      if (quality <= 0 || quality >= 100) {
        print('Step 9i: Quality out of range, breaking loop');
        break;
      }
    }

    if (currentIteration == maxIterations) {
      print('Step 9j: Max iterations reached, stopping compression');
    }

    return compressedFile;
  }

  Widget bottomsheet1() {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.clear),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Choose Profile Photo",
                        style: TextStyle(
                            fontSize: 18.0, color: AppColors.blackColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  is_search_image_active
                      ? TextButton.icon(
                          onPressed: () {
                            GtmUtil.logScreenView(
                              'Search_Web',
                              'SearchWeb',
                            );
                            if (_prodnm.text.isEmpty) {
                              _color1 = AppColors.red;
                              setState(() {});
                              showCustomToast('Please Add Product Name First');
                              Navigator.pop(context);
                            } else {
                              _showBottomSheet1(context);
                            }
                          },
                          icon: Icon(Icons.web, color: AppColors.primaryColor),
                          label: Text(
                            'Search Web',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        )
                      : SizedBox.shrink(),
                  TextButton.icon(
                    onPressed: () {
                      takephoto1(ImageSource.gallery);
                    },
                    icon:
                        const Icon(Icons.image, color: AppColors.primaryColor),
                    label: const Text(
                      'Gallary',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                  TextButton.icon(
                      onPressed: () {
                        takephoto1(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera,
                          color: AppColors.primaryColor),
                      label: const Text(
                        'Camera',
                        style: TextStyle(color: AppColors.primaryColor),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet1(BuildContext context) async {
    await _searchImageOnWeb();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey,
                        ),
                      ),
                      10.sbh,
                      Text(
                        'Select an Image',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _prodnm,
                        labelText: 'Search',
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (value) async {
                          await _searchImageOnWeb();
                          setModalState(() {});
                        },
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              _loadMoreImages();
                              setModalState(() {});
                            }
                            return false;
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  controller: _scrollController,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                  ),
                                  itemCount: imageList.length,
                                  itemBuilder: (context, index) {
                                    final imageItem = imageList[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedImage = imageItem;
                                        });
                                        Navigator.pop(context);
                                        _redirectToProcessing1();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: selectedImage == imageItem
                                              ? Colors.blue.shade100
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: selectedImage == imageItem
                                              ? Border.all(
                                                  color: Colors.blue, width: 2)
                                              : null,
                                        ),
                                        child: Image.network(
                                          imageItem.link,
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                                child: Icon(Icons.error));
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<io.File?> _downloadImage1(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/downloaded_image.jpg';
        final file = io.File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Failed to download image');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  void _redirectToProcessing1() async {
    if (selectedImage != null) {
      final imageUrl = selectedImage!.link;

      final downloadedFile = await _downloadImage1(imageUrl);
      if (downloadedFile != null) {
        final croppedImage = await _cropImage1(downloadedFile);
        if (croppedImage != null) {
          print('Image cropped successfully');

          final compressedImage = await _compressImage1(croppedImage);
          if (compressedImage != null) {
            print('Image compressed successfully');

            constanst.imagesList.add(compressedImage);

            setState(() {
              file1 = compressedImage;
            });
            Navigator.of(context).pop();
          } else {
            print('Image compression failed');
          }
        } else {
          print('Image cropping failed');
        }
      } else {
        print('Failed to download image');
      }
    } else {
      print('No image selected');
    }
  }

  void takephoto1(ImageSource imageSource) async {
    final pickedfile =
        await _picker.pickImage(source: imageSource, imageQuality: 100);
    if (pickedfile != null) {
      io.File imageFile = io.File(pickedfile.path);
      int fileSizeInBytes = imageFile.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024;

      if (kDebugMode) {
        print('Original image size: $fileSizeInKB KB');
      }

      if (fileSizeInKB > 5000) {
        showCustomToast('Please Select an image below 5 MB');
        return;
      }

      io.File? processedFile = imageFile;

      if (fileSizeInKB <= 100) {
        processedFile = await _cropImage1(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
      } else if (fileSizeInKB > 100) {
        processedFile = await _cropImage1(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
        processedFile = await _compressImage1(processedFile);
      }

      double processedFileSizeInKB = processedFile!.lengthSync() / 1024;
      if (kDebugMode) {
        print('Processed image size: $processedFileSizeInKB KB');
      }

      if (mounted) {
        setState(() {
          file1 = processedFile;
        });

        if (file1 != null) {
          constanst.imagesList.add(file1!);

          add_buysubimage(prod_id: widget.prod_id.toString());
        }
      }
      var response = await noPromotionCheck(image: processedFile);
      if (response != null) {
        int status = response['status'];

        if (status == 1) {
          print('Status 1: not show image');

          Navigator.of(context).pop();

          return;
        } else if (status == 2) {
          showCustomToast('Warning: Text detected in the image');

          Navigator.of(context).pop();

          return;
        } else if (status == 3) {
          Navigator.of(context).pop();

          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return CommomDialogReupload(
                  title: "Uplaod Image",
                  content:
                      "Not Allowed in Image Business cards, phone number, email Id and company name.",
                  onPressed: () {
                    setState(() {
                      constanst.imagesList.remove(file1);
                      file1 = null;
                    });
                    Navigator.of(context).pop();
                  },
                );
              });
          return;
        }
        constanst.imagesList.remove(file!);
      } else {
        showCustomToast('API response was null');
      }
      constanst.imagesList.remove(file!);
    } else {
      showCustomToast('Please select an image');
      return;
    }
  }

  Future<io.File?> _cropImage1(io.File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedFile != null) {
      return io.File(croppedFile.path);
    } else {
      return null;
    }
  }

  Future<io.File?> _compressImage1(io.File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/temp1.jpg'; // Different path for bottomsheet1

    int quality = 90;
    io.File? compressedFile;
    double fileSizeInKB;

    // Prevent infinite loop by setting a max iteration count
    const maxIterations = 10;
    int currentIteration = 0;

    while (currentIteration < maxIterations) {
      currentIteration++;

      // Compress the image
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
      );

      // Check if the compression failed
      if (result == null) {
        return null;
      }

      compressedFile = io.File(result.path);
      fileSizeInKB = compressedFile.lengthSync() / 1024; // Get file size in KB

      // Logic to compress based on file size
      if (fileSizeInKB <= 100) {
        // Compress to 20-30 KB if <= 100 KB
        if (fileSizeInKB <= 30) {
          print('Compression complete: File size <= 30KB');
          break; // Stop if within 20-30 KB
        } else {
          quality =
              (quality - 10).clamp(0, 100); // Reduce quality to decrease size
          print('Reducing quality to $quality for size <= 100 KB');
        }
      } else {
        // Compress to around 100 KB if > 100 KB
        if (fileSizeInKB <= 100) {
          print('Compression complete: File size ~100KB');
          break; // Stop if within ~100 KB
        } else {
          quality =
              (quality - 10).clamp(0, 100); // Reduce quality to decrease size
          print('Reducing quality to $quality for size > 100 KB');
        }
      }

      // Stop if quality reaches extreme values
      if (quality <= 0 || quality >= 100) {
        print('Quality out of range, stopping compression');
        break;
      }
    }

    if (currentIteration == maxIterations) {
      print('Max iterations reached, stopping compression');
    }

    return compressedFile;
  }

  Widget bottomsheet2() {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.clear),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Choose Profile Photo",
                        style: TextStyle(
                            fontSize: 18.0, color: AppColors.blackColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  is_search_image_active
                      ? TextButton.icon(
                          onPressed: () {
                            GtmUtil.logScreenView(
                              'Search_Web',
                              'SearchWeb',
                            );
                            if (_prodnm.text.isEmpty) {
                              _color1 = AppColors.red;
                              setState(() {});
                              showCustomToast('Please Add Product Name First');
                              Navigator.pop(context);
                            } else {
                              _showBottomSheet2(context);
                            }
                          },
                          icon: Icon(Icons.web, color: AppColors.primaryColor),
                          label: Text(
                            'Search Web',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        )
                      : SizedBox.shrink(),
                  TextButton.icon(
                    onPressed: () {
                      takephoto2(ImageSource.gallery);
                    },
                    icon:
                        const Icon(Icons.image, color: AppColors.primaryColor),
                    label: const Text(
                      'Gallary',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                  TextButton.icon(
                      onPressed: () {
                        takephoto2(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera,
                          color: AppColors.primaryColor),
                      label: const Text(
                        'Camera',
                        style: TextStyle(color: AppColors.primaryColor),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet2(BuildContext context) async {
    await _searchImageOnWeb();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey,
                        ),
                      ),
                      10.sbh,
                      Text(
                        'Select an Image',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _prodnm,
                        labelText: 'Search',
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (value) async {
                          await _searchImageOnWeb();
                          setModalState(() {});
                        },
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              _loadMoreImages();
                              setModalState(() {});
                            }
                            return false;
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  controller: _scrollController,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                  ),
                                  itemCount: imageList.length,
                                  itemBuilder: (context, index) {
                                    final imageItem = imageList[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedImage = imageItem;
                                        });
                                        Navigator.pop(context);
                                        _redirectToProcessing2();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: selectedImage == imageItem
                                              ? Colors.blue.shade100
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: selectedImage == imageItem
                                              ? Border.all(
                                                  color: Colors.blue, width: 2)
                                              : null,
                                        ),
                                        child: Image.network(
                                          imageItem.link,
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                                child: Icon(Icons.error));
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<io.File?> _downloadImage2(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/downloaded_image.jpg';
        final file = io.File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Failed to download image');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  void _redirectToProcessing2() async {
    if (selectedImage != null) {
      final imageUrl = selectedImage!.link;

      final downloadedFile = await _downloadImage2(imageUrl);
      if (downloadedFile != null) {
        final croppedImage = await _cropImage2(downloadedFile);
        if (croppedImage != null) {
          print('Image cropped successfully');

          final compressedImage = await _compressImage2(croppedImage);
          if (compressedImage != null) {
            print('Image compressed successfully');

            constanst.imagesList.add(compressedImage);

            setState(() {
              file2 = compressedImage;
            });
            Navigator.of(context).pop();
          } else {
            print('Image compression failed');
          }
        } else {
          print('Image cropping failed');
        }
      } else {
        print('Failed to download image');
      }
    } else {
      print('No image selected');
    }
  }

  void takephoto2(ImageSource imageSource) async {
    final pickedfile =
        await _picker.pickImage(source: imageSource, imageQuality: 100);
    if (pickedfile != null) {
      io.File imageFile = io.File(pickedfile.path);
      int fileSizeInBytes = imageFile.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024;

      if (kDebugMode) {
        print('Original image size: $fileSizeInKB KB');
      }

      if (fileSizeInKB > 5000) {
        showCustomToast('Please Select an image below 5 MB');
        return;
      }

      io.File? processedFile = imageFile;

      if (fileSizeInKB <= 100) {
        processedFile = await _cropImage2(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
      } else if (fileSizeInKB > 100) {
        processedFile = await _cropImage2(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
        processedFile = await _compressImage2(processedFile);
      }

      double processedFileSizeInKB = processedFile!.lengthSync() / 1024;
      if (kDebugMode) {
        print('Processed image size: $processedFileSizeInKB KB');
      }

      if (mounted) {
        setState(() {
          file2 = processedFile;
        });

        if (file2 != null) {
          constanst.imagesList.add(file2!);
          add_buysubimage(prod_id: widget.prod_id.toString());
        }
      }
      var response = await noPromotionCheck(image: processedFile);
      if (response != null) {
        int status = response['status'];

        if (status == 1) {
          print('Status 1: not show image');
          Navigator.of(context).pop();
          return;
        } else if (status == 2) {
          showCustomToast('Warning: Text detected in the image');
          Navigator.of(context).pop();
          return;
        } else if (status == 3) {
          Navigator.of(context).pop();
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return CommomDialogReupload(
                  title: "Uplaod Image",
                  content:
                      "Not Allowed in Image Business cards, phone number, email Id and company name.",
                  onPressed: () {
                    setState(() {
                      constanst.imagesList.remove(file2);

                      file2 = null;
                    });
                    Navigator.of(context).pop();
                  },
                );
              });
          return;
        }
        constanst.imagesList.remove(file1!);
      } else {
        showCustomToast('API response was null');
      }
      constanst.imagesList.remove(file1!);
    } else {
      showCustomToast('Please select an image');
      return;
    }
  }

  Future<io.File?> _cropImage2(io.File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedFile != null) {
      return io.File(croppedFile.path);
    } else {
      return null;
    }
  }

  Future<io.File?> _compressImage2(io.File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/temp2.jpg'; // Different path for bottomsheet2

    int quality = 90;
    io.File? compressedFile;
    double fileSizeInKB;

    // Prevent infinite loop by setting a max iteration count
    const maxIterations = 10;
    int currentIteration = 0;

    while (currentIteration < maxIterations) {
      currentIteration++;

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
      );

      if (result == null) {
        return null;
      }

      compressedFile = io.File(result.path);
      fileSizeInKB = compressedFile.lengthSync() / 1024; // Get file size in KB

      // Stop if file size is between 200 and 250 KB
      if (fileSizeInKB <= 250 && fileSizeInKB >= 200) {
        print('Compression complete: File size is within 200-250 KB');
        break;
      }

      if (fileSizeInKB <= 100) {
        // If file size is <= 100 KB, aim for a size of 20 to 30 KB
        if (fileSizeInKB <= 30) {
          print(
              'Step 9e: Image size within acceptable range, stopping compression');
          break;
        } else {
          quality = (quality - 10)
              .clamp(0, 100); // Reduce quality to decrease file size
          print('Step 9f: Decreasing quality to $quality');
        }
      } else {
        // If file size is > 100 KB, aim for a size around 100 KB
        if (fileSizeInKB <= 100) {
          print(
              'Step 9g: Image size within acceptable range, stopping compression');
          break;
        } else {
          quality = (quality - 10)
              .clamp(0, 100); // Reduce quality to decrease file size
          print('Step 9h: Decreasing quality to $quality');
        }
      }

      // Stop if quality reaches extreme values
      if (quality <= 0 || quality >= 100) {
        print('Quality out of range, stopping compression');
        break;
      }
    }

    if (currentIteration == maxIterations) {
      print('Max iterations reached, stopping compression');
    }

    return compressedFile;
  }

  Widget Unit_dropdown(List<String> listitem, String hint, bool isUnit,
      String? unitValue, String? unitOfPriceValue) {
    return Container(
      width: MediaQuery.of(context).size.width / 4.1,
      height: 55,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 18.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              if (isUnit) {
                _selectitem5 = value;
                _tempSelectitem5 = value;
              } else {
                _selectitem6 = value;
                _tempSelectitem6 = value;
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isUnit ? _selectitem5 ?? hint : _selectitem6 ?? hint,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: (isUnit ? _selectitem5 : _selectitem6) != null
                      ? Colors.black // Set to black if selected
                      : (isUnit
                          ? _color9
                          : _color12), // Use colors defined in your app
                  fontFamily: 'assets/fonts/Metropolis-Black.otf',
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          itemBuilder: (BuildContext context) {
            return listitem.map((valueItem) {
              return PopupMenuItem<String>(
                value: valueItem,
                child: Text(
                  valueItem,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontFamily: 'assets/fonts/Metropolis-Black.otf',
                  ),
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget rupess_dropdown(List<String> listitem, String hint) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.88,
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      color: Colors.white,
      child: Align(
        alignment: Alignment.centerLeft,
        child: PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              _selectitem4 = value; // Update selected item
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectitem4 ?? hint, // Display selected item or hint
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: _selectitem4 != null
                      ? Colors.black
                      : Colors.grey, // Change color based on selection
                  fontFamily: 'assets/fonts/Metropolis-Black.otf',
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          itemBuilder: (BuildContext context) {
            return listitem.map((valueItem) {
              return PopupMenuItem<String>(
                value: valueItem,
                child: Text(
                  valueItem,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontFamily: 'assets/fonts/Metropolis-Black.otf',
                  ),
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  vaild_data() async {
    if (_prodprice.text.isNotEmpty &&
        _selectitem5 == null &&
        _selectitem4 == null) {
      _color8 = AppColors.red;
      setState(() {
        _selectitem5 = _tempSelectitem5;
      });
    }

    if (_selectitem6 == null && _prodqty.text.isNotEmpty) {
      _color10 = AppColors.red;
      setState(() {
        _selectitem6 = _tempSelectitem6;
      });
    }
    if (category1 == false) {
      showCustomToast('Please Select Sale Post or Buy Post');
    } else if (_prodnm.text.isEmpty) {
      showCustomToast('Please Add Your Product Name');
      _color1 = AppColors.red;
      setState(() {});
    } else if (_prod_cate.text.isEmpty) {
      showCustomToast('Please Select Category');
      _color2 = AppColors.red;
      setState(() {});
    } else if (_prod_type.text.isEmpty) {
      showCustomToast('Please Select Type');
      _color3 = AppColors.red;
      setState(() {});
    } else if (_prod_grade.text.isEmpty) {
      showCustomToast('Please Select Grade');
      _color4 = AppColors.red;
      setState(() {});
    } else if (_prodprice.text.isEmpty) {
      showCustomToast('Please Add Your Product Price');
      _color8 = AppColors.red;
      setState(() {});
    } else if (_selectitem5 == null) {
      showCustomToast('Select Product Unit');
      _color8 = AppColors.red;
      setState(() {});
    } else if (_selectitem4 == null) {
      showCustomToast('Please Select Currency Sign');
      _color8 = AppColors.red;
      setState(() {});
    } else if (_prodqty.text.isEmpty) {
      showCustomToast("Please Add Your Product Quantity");
      _color10 = AppColors.red;
      setState(() {});
    } else if (_selectitem6 == null) {
      showCustomToast('Select Product Unit');
      _color10 = AppColors.red;
    } else if (_prodcolor.text.isEmpty) {
      showCustomToast('Please Select Product Colour');
      _color5 = AppColors.red;
    } else if (_loc.text.isEmpty) {
      showCustomToast("Please Add Stock Location");
      _color6 = AppColors.red;
      setState(() {});
    } else if (_proddetail.text.isEmpty) {
      showCustomToast("Please Add Your Product Description");
      _color7 = AppColors.red;
      setState(() {});
    } else if (_proddetail.text.isEmpty) {
      showCustomToast("Please Add Your Product Description");
      _color7 = AppColors.red;
      setState(() {});
    }

    if (_prodprice.text.isNotEmpty &&
        _selectitem5 != null &&
        _selectitem4 != null) {
      _color8 = AppColors.greenWithShade;
      setState(() {});
    }
    if (_selectitem6 != null && _prodqty.text.isNotEmpty) {
      _color10 = AppColors.greenWithShade;
      setState(() {});
    }

    if (_prodnm.text.isNotEmpty) {
      _color1 = AppColors.greenWithShade;
      setState(() {});
    }
    if (_prod_cate.text.isNotEmpty) {
      _color2 = AppColors.greenWithShade;
      setState(() {});
    }
    if (_prod_type.text.isNotEmpty) {
      _color3 = AppColors.greenWithShade;
      setState(() {});
    }
    if (_prod_grade.text.isNotEmpty) {
      _color4 = AppColors.greenWithShade;
      setState(() {});
    }
    if (_prodcolor.text.isNotEmpty) {
      _color5 = AppColors.greenWithShade;
      setState(() {});
    }
    if (_loc.text.isNotEmpty) {
      _color6 = AppColors.greenWithShade;
      setState(() {});
    }
    if (_proddetail.text.isNotEmpty) {
      _color7 = AppColors.greenWithShade;
      setState(() {});
    }
    if (type_post == 'SalePost') {
      if (constanst.imagesList.isEmpty) {
        if (_prodqty.text.isNotEmpty &&
            category1 &&
            _prodnm.text.isNotEmpty &&
            _prod_cate.text.isNotEmpty &&
            _prod_type.text.isNotEmpty &&
            _prodprice.text.isNotEmpty &&
            _prodcolor.text.isNotEmpty &&
            _selectitem5 != null &&
            _selectitem4 != null &&
            _prodqty.text.isNotEmpty &&
            _selectitem6 != null &&
            _loc.text.isNotEmpty &&
            _proddetail.text.isNotEmpty) {
          setState(() {
            _isloading1 = false;
          });
          update_SalePost().then((value) {
            if (dialogContext != null) {
              Navigator.of(dialogContext!).pop();
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(0),
              ),
            );
          });
        }
      } else {
        if (_prodqty.text.isNotEmpty &&
            category1 &&
            _prodnm.text.isNotEmpty &&
            _prod_cate.text.isNotEmpty &&
            _prod_type.text.isNotEmpty &&
            _prodcolor.text.isNotEmpty &&
            _prodprice.text.isNotEmpty &&
            _selectitem5 != null &&
            _selectitem4 != null &&
            _prodqty.text.isNotEmpty &&
            _selectitem6 != null &&
            _loc.text.isNotEmpty &&
            _proddetail.text.isNotEmpty) {
          setState(() {
            _isloading1 = false;
          });
          update_SalePost().then((value) {
            if (dialogContext != null) {
              Navigator.of(dialogContext!).pop();
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(0),
              ),
            );
          });
        }
      }
    } else if (type_post == 'BuyPost') {
      if (constanst.imagesList.isNotEmpty) {
        if (_prodqty.text.isNotEmpty &&
            category1 &&
            _prodnm.text.isNotEmpty &&
            _prod_cate.text.isNotEmpty &&
            _prod_type.text.isNotEmpty &&
            _prodcolor.text.isNotEmpty &&
            _prodprice.text.isNotEmpty &&
            _selectitem5 != null &&
            _selectitem4 != null &&
            _prodqty.text.isNotEmpty &&
            _selectitem6 != null &&
            _loc.text.isNotEmpty &&
            _proddetail.text.isNotEmpty) {
          setState(() {
            _isloading1 = false;
          });
          update_BuyPost().then((value) {
            if (dialogContext != null) {
              Navigator.of(dialogContext!).pop();
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(0),
              ),
            );
          });
        }
      } else {
        if (_prodqty.text.isNotEmpty &&
            category1 &&
            _prodnm.text.isNotEmpty &&
            _prod_cate.text.isNotEmpty &&
            _prod_type.text.isNotEmpty &&
            _prodprice.text.isNotEmpty &&
            _prodcolor.text.isNotEmpty &&
            _selectitem5 != null &&
            _selectitem4 != null &&
            _prodqty.text.isNotEmpty &&
            _selectitem6 != null &&
            _loc.text.isNotEmpty &&
            _proddetail.text.isNotEmpty) {
          setState(() {
            _isloading1 = false;
          });
          update_BuyPost().then((value) {
            if (dialogContext != null) {
              Navigator.of(dialogContext!).pop();
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(0),
              ),
            );
          });
        }
      }
    }
    if (_prodprice.text.isEmpty) {
      _color8 = Colors.red;
    }
    if (_prodqty.text.isEmpty) {}
  }

  ViewItem(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.80,
          builder: (BuildContext context, ScrollController scrollController) {
            return const selectcolor();
          }),
    ).then(
      (value) {
        _prodcolor.text = constanst.color_name_list.join(", ");
      },
    );
  }

  Viewproduct(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.90,
          builder: (BuildContext context, ScrollController scrollController) {
            return const SelectCategory();
          }),
    ).then(
      (value) {
        setState(() {
          _prod_cate.text = constanst.select_categotyType.join(", ");
        });
      },
    );
  }

  Viewtype(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.90,
          builder: (BuildContext context, ScrollController scrollController) {
            return const selectType();
          }),
    ).then(
      (value) {
        setState(() {
          _prod_type.text = constanst.select_typename.join(", ");
        });
      },
    );
  }

  Viewgrade(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.90,
            builder: (BuildContext context, ScrollController scrollController) {
              return const selectGrade();
            })).then(
      (value) {
        setState(() {
          _prod_grade.text = constanst.select_gradname.join(", ");
        });
      },
    );
  }

  void get_data1() async {
    GetCategoryTypeController b_type = GetCategoryTypeController();
    constanst.cat_typedata = b_type.setType();

    constanst.cat_typedata!.then((value) {
      for (var item in value) {
        constanst.cat_type_data.add(item);
      }
      for (int i = 0; i < constanst.cat_type_data.length; i++) {
        constanst.Type_itemsCheck.add(Icons.circle_outlined);
      }

      setState(() {});
    });
  }

  void get_data2() async {
    GetCategoryGradeController bt = GetCategoryGradeController();
    constanst.cat_gradedata = bt.setGrade();

    constanst.cat_gradedata!.then((value) {
      for (var item in value) {
        constanst.cat_grade_data.add(item);
      }
      for (int i = 0; i < constanst.cat_grade_data.length; i++) {
        constanst.Grade_itemsCheck.add(Icons.circle_outlined);
      }
    });
    _isloading = true;
    setState(() {});
  }

  void get_data4() async {
    GetUnitController b_type = GetUnitController();
    constanst.unit_data = b_type.setunit();

    constanst.unit_data!.then((value) {
      for (var item in value) {
        constanst.unitdata.add(item);
      }
      _isloading = true;
      setState(() {});
    });
  }

  Future get_product_name() async {
    GetProductName getdir = GetProductName();

    var res = await get_productname();

    getdir = GetProductName.fromJson(res);
    List<pnm.Result>? results = getdir.result;
    if (results != null) {
      _suggestions = results.map((result) => result.productName ?? "").toList();
      return _suggestions;
    } else {
      return [];
    }
  }

  checknetwork() async {
    clear_data();
    final connectivityResult = await Connectivity().checkConnectivity();
    constanst.catdata.clear();
    constanst.colordata.clear();
    constanst.cat_grade_data.clear();
    constanst.cat_type_data.clear();
    constanst.selectcolor_name.clear();
    constanst.selectcolor_id.clear();
    _isloading = false;
    if (connectivityResult == ConnectivityResult.none) {
      constanst.catdata.clear();
      constanst.colordata.clear();
      constanst.cat_grade_data.clear();
      constanst.cat_type_data.clear();
      _isloading = false;
      showCustomToast('Internet Connection not available');
    } else {
      clear_data();
      if (widget.post_type == 'SalePost') {
        getProfiless();
        get_SalePostDatil();
        get_product_name();
        get_data();
        get_data1();
        get_data2();
        get_data3();
        get_data4();
      } else if (widget.post_type == 'BuyPost') {
        getProfiless();
        get_product_name();
        get_BuyPostDatil();
        get_data();
        get_data1();
        get_data2();
        get_data3();
        get_data4();
      }
    }
  }

  get_SalePostDatil() async {
    commonPostdetail = CommonPostdetail();
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getPost_datail1(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.prod_id.toString(),
      notiId.toString(),
      device,
      crown_color,
      plan_name,
    );
    var jsonArray, color_array, sub_image;
    // List<postdetail.SubproductImage> image = [];

    if (res['status'] == 1) {
      commonPostdetail = CommonPostdetail.fromJson(res);
      if (res['result'] != null) {
        jsonArray = res['result'];
        for (var data in jsonArray) {
          print("Data:-$data");
          _prod_cate.text = data['CategoryName'];
          _prod_grade.text = data['ProductGrade'];
          _prod_type.text = data['ProductType'];
          _prodqty.text = data['PostQuntity'];
          _proddetail.text = data['Description'];

          _prodprice.text = data['ProductPrice'];
          _prodnm.text = data['PostName'];

          _selectitem4 = data['Currency'];
          _selectitem5 = data['Unit'];
          _selectitem6 = data['unit_of_price'];
          _loc.text = data['Location'];
          _select_postType = data['PostType'];
          category1 = true;
          type_post = data['PostType'];
          color_array = data['PostHaxCodeColor'];
          if (data['CategoryId'] != null) {
            constanst.select_categotyId = data['CategoryId'].split(",");
            constanst.select_categotyType = data['CategoryName'].split(",");
          }
          if (data['productTypeId'] != null) {
            constanst.select_typeId = data['productTypeId'].split(",");
            constanst.select_typename = data['ProductType'].split(",");
          }
          if (data['ProductGradeId'] != null) {
            constanst.select_gradeId = data['ProductGradeId'].split(",");
            constanst.select_gradname = data['ProductGrade'].split(",");
          }
          if (data['Latitude'] != null &&
              data['Latitude'] != "null" &&
              data['Latitude'] != "") {
            lat = double.parse(data['Latitude'].toString());
          }
          if (data['Longitude'] != null &&
              data['Longitude'] != "null" &&
              data['Longitude'] != "") {
            log = double.parse(data['Longitude'].toString());
          }
          main_product = data['mainproductImage'];
          state = data['State'];
          city = data['City'];
          country = data['Country'];

          sub_image = data['subproductImage'];

          if (sub_image != null) {
            for (var data in sub_image) {
              postdetail.SubproductImage record = postdetail.SubproductImage(
                productImageId: data['productImageId'],
                subImageUrl: data['sub_image_url'],
              );
              subProductImageList.add(record);
            }

            if (subProductImageList.length == 1) {
              main_product1 = subProductImageList[0].subImageUrl.toString();
              image1_id = subProductImageList[0].productImageId.toString();
            }
            if (subProductImageList.length >= 2) {
              main_product1 = subProductImageList[0].subImageUrl.toString();
              image1_id = subProductImageList[0].productImageId.toString();
              main_product2 = subProductImageList[1].subImageUrl.toString();
              image2_id = subProductImageList[1].productImageId.toString();
            }
          }
        }
        if (color_array != null) {
          for (var data in color_array) {
            constanst.color_id_list.add(
              data['colorId'],
            );
            constanst.color_name_list.add(
              data['colorName'],
            );
          }
          _prodcolor.text = constanst.color_name_list.join(", ");
        }
        if (_select_postType == "Sell Post" ||
            _select_postType == "SellPost" ||
            _select_postType == "SalePost") {
          sampleData1.last.isSelected = true;
        } else if (_select_postType == "Buy Post" ||
            _select_postType == "BuyPost") {
          sampleData1.first.isSelected = true;
        }
      }
      setState(() {
        _isloading = true;
      });
    } else {
      _isloading = true;
      print(
        res['message'],
      );
    }

    return jsonArray;
  }

  get_BuyPostDatil() async {
    commonPostdetail = CommonPostdetail();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getPost_datail(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.prod_id.toString(),
      notiId.toString(),
      device,
      crown_color,
      plan_name,
    );
    var jsonArray, color_array, sub_image;

    if (res['status'] == 1) {
      commonPostdetail = CommonPostdetail.fromJson(res);
      if (res['result'] != null) {
        jsonArray = res['result'];
        for (var data in jsonArray) {
          print("Data:-$data");
          _prod_cate.text = data['CategoryName'];
          _prod_grade.text = data['ProductGrade'];
          _prod_type.text = data['ProductType'];
          _prodqty.text = data['PostQuntity'];
          _proddetail.text = data['Description'];

          _prodprice.text = data['ProductPrice'];
          _prodnm.text = data['PostName'];

          _selectitem4 = data['Currency'];
          _selectitem5 = data['Unit'];
          _selectitem6 = data['unit_of_price'];
          _loc.text = data['Location'];
          _select_postType = data['PostType'];
          category1 = true;
          type_post = data['PostType'];
          color_array = data['PostHaxCodeColor'];
          if (data['CategoryId'] != null) {
            constanst.select_categotyId = data['CategoryId'].split(",");
            constanst.select_categotyType = data['CategoryName'].split(",");
          }
          if (data['productTypeId'] != null) {
            constanst.select_typeId = data['productTypeId'].split(",");
            constanst.select_typename = data['ProductType'].split(",");
          }
          if (data['ProductGradeId'] != null) {
            constanst.select_gradeId = data['ProductGradeId'].split(",");
            constanst.select_gradname = data['ProductGrade'].split(",");
          }
          if (data['Latitude'] != null &&
              data['Latitude'] != "null" &&
              data['Latitude'] != "") {
            lat = double.parse(data['Latitude'].toString());
          }
          if (data['Longitude'] != null &&
              data['Longitude'] != "null" &&
              data['Longitude'] != "") {
            log = double.parse(data['Longitude'].toString());
          }

          main_product = data['mainproductImage'];

          state = data['State'];
          city = data['City'];
          country = data['Country'];

          sub_image = data['subproductImage'];

          print("sub_image:-$sub_image");

          if (sub_image != null) {
            for (var data in sub_image) {
              postdetail.SubproductImage record = postdetail.SubproductImage(
                productImageId: data['productImageId'],
                subImageUrl: data['sub_image_url'],
              );
              subProductImageList.add(record);
            }

            if (subProductImageList.length == 1) {
              main_product1 = subProductImageList[0].subImageUrl.toString();
              image1_id = subProductImageList[0].productImageId.toString();
            }
            if (subProductImageList.length >= 2) {
              main_product1 = subProductImageList[0].subImageUrl.toString();
              image1_id = subProductImageList[0].productImageId.toString();

              main_product2 = subProductImageList[1].subImageUrl.toString();
              image2_id = subProductImageList[1].productImageId.toString();
            }
          }
        }
        if (color_array != null) {
          for (var data in color_array) {
            constanst.color_id_list.add(
              data['colorId'],
            );
            constanst.color_name_list.add(
              data['colorName'],
            );
          }
          _prodcolor.text = constanst.color_name_list.join(", ");
        }
      }
      setState(() {
        if (_select_postType == "Sell Post" ||
            _select_postType == "SellPost" ||
            _select_postType == "SelePost") {
          sampleData1.last.isSelected = true;
        } else if (_select_postType == "Buy Post" ||
            _select_postType == "BuyPost") {
          sampleData1.first.isSelected = true;
        }
        _isloading = true;
      });
    } else {
      _isloading = true;
      print(
        res['message'],
      );
    }

    return jsonArray;
  }

  void get_data() async {
    GetCategoryController bt = GetCategoryController();
    constanst.cat_data = bt.setlogin();
    _isloading = true;
    constanst.cat_data!.then((value) {
      for (var item in value) {
        constanst.catdata.add(item);
      }
      for (int i = 0; i < constanst.catdata.length; i++) {
        constanst.category_itemsCheck.add(Icons.circle_outlined);
      }
      _isloading = true;
    });
  }

  void get_data3() async {
    GetColorsController bt = GetColorsController();
    constanst.color_data = bt.setlogin();
    _isloading = true;
    constanst.color_data!.then((value) {
      for (var item in value) {
        constanst.colordata.add(item);
      }
      _isloading = true;
      setState(() {});
    });
  }

  findcategory(cat_name) {
    final index = constanst.catdata
        .indexWhere((element) => element.categoryName == cat_name);

    return index;
  }

  findtype(cat_name) {
    final index = constanst.cat_type_data
        .indexWhere((element) => element.productType == cat_name);

    return index;
  }

  findgrade(cat_name) {
    final index = constanst.cat_grade_data
        .indexWhere((element) => element.productGrade == cat_name);

    return index;
  }

  Future delete_mainProductImage({required int subImageId}) async {
    var res = await deleteMainProductImage(
      productId: widget.prod_id,
      subImageId: subImageId.toString(),
    );
    print("delete_mainProductImage:-${res}");
    if (res['status'] == 1) {
      showCustomToast(
        res['message'],
      );
    } else {
      showCustomToast(
        res['message'],
      );
    }
    return res;
  }

  delete_subimage(String prod_id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await deletePostSubImage(
      prod_id,
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );
    if (res['status'] == 1) {
      return true;
    } else {
      showCustomToast(
        res['message'],
      );
    }
    setState(() {});
    return false;
  }

  add_buysubimage({required String prod_id}) async {
    int image_counter = constanst.imagesList.length;

    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await addBuyeSubImage(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        prod_id,
        image_counter.toString(),
        device);

    if (res['status'] == 1) {
      showCustomToast(
        res['message'],
      );
    } else {
      showCustomToast(
        res['message'],
      );
    }
    setState(() {});
    return res;
  }
}

class selectcolor extends StatefulWidget {
  const selectcolor({Key? key}) : super(key: key);

  @override
  State<selectcolor> createState() => _selectcolorState();
}

class _selectcolorState extends State<selectcolor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.0), // Set the bottom border radius
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.1), // Optional shadow for elevation effect
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor:
                Colors.transparent, // Make AppBar's background transparent
            elevation: 0, // Remove the default AppBar shadow
            title: const Text(
              'Select Color of Product',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                fontFamily: 'assets/fonts/Metropolis-Black.otf',
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false, // Removes the default back icon
            actions: [
              IconButton(
                icon: Icon(Icons.clear,
                    color: Colors.black), // Cancel icon on the right side
                onPressed: () {
                  Navigator.of(context).pop(); // Close the current screen
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            10.sbh,
            FutureBuilder<List<color.Result>?>(
                future: constanst.color_data,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
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
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        shrinkWrap: true,
                        itemCount: constanst.colordata.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          color.Result record = constanst.colordata[index];
                          return CommanBottomSheet(
                            onTap: () {
                              setState(() {
                                if (constanst.color_id_list
                                    .contains(record.colorId.toString())) {
                                  constanst.color_name_list
                                      .remove(record.colorName.toString());
                                  constanst.color_id_list
                                      .remove(record.colorId.toString());
                                } else {
                                  constanst.color_name_list
                                      .add(record.colorName.toString());
                                  constanst.color_id_list
                                      .add(record.colorId.toString());
                                }
                              });
                            },
                            checked: constanst.color_id_list
                                .contains(record.colorId.toString()),
                            title: record.colorName,
                          );
                        });
                  }
                }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(50.0),
                  color: AppColors.primaryColor,
                ),
                child: TextButton(
                  onPressed: () {
                    if (constanst.color_name_list.isNotEmpty) {
                      Navigator.pop(context);
                    } else {
                      showCustomToast('Select Minimum 1 Colour');
                    }
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
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class SelectCategory extends StatefulWidget {
  const SelectCategory({Key? key}) : super(key: key);

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final TextEditingController _addcategory = TextEditingController();
  Color _color1 = Colors.black26; //name
  bool _isloading1 = false;

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
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.0), // Set the bottom border radius
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.1), // Optional shadow for elevation effect
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor:
                Colors.transparent, // Make AppBar's background transparent
            elevation: 0, // Remove the default AppBar shadow
            title: Column(
              children: [
                Container(
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey,
                  ),
                ),
                5.sbh,
                const Text(
                  'Select Product Category',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'assets/fonts/Metropolis-Black.otf',
                  ),
                ),
              ],
            ),
            centerTitle: true,
            automaticallyImplyLeading: false, // Removes the default back icon
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss keyboard when tapping outside
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              10.sbh,
              FutureBuilder<List<cat.Result>?>(
                future: constanst.cat_data,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
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
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      shrinkWrap: true,
                      itemCount: constanst.catdata.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        cat.Result record = constanst.catdata[index];
                        return CommanBottomSheet(
                          onTap: () {
                            setState(() {
                              constanst.select_categotyId.clear();
                              constanst.select_categotyType.clear();
                              if (constanst.select_categotyId.contains(
                                record.categoryId.toString(),
                              )) {
                                constanst.select_categotyId.remove(
                                  record.categoryId.toString(),
                                );
                                constanst.select_categotyType
                                    .remove(record.categoryName.toString());
                              } else {
                                if (constanst.select_categotyId.length < 2) {
                                  constanst.select_categotyId
                                      .add(record.categoryId.toString());
                                  constanst.select_categotyType
                                      .add(record.categoryName.toString());
                                } else {
                                  showCustomToast('Select Minimum 1 Category');
                                }
                              }
                            });
                          },
                          checked: constanst.select_categotyId.contains(
                            record.categoryId.toString(),
                          ),
                          title: record.categoryName,
                        );
                      },
                    );
                  }
                },
              ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          buttonText: 'Update',
          onPressed: () async {
            if (constanst.select_categotyType.isNotEmpty) {
              if (_addcategory.text.isNotEmpty) {
                await _updateCategory();
              } else {
                Navigator.pop(context);
              }
              setState(() {});
            } else {
              showCustomToast('Select Minimum 1 Category');
            }
          },
          isLoading: _isloading1,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class selectType extends StatefulWidget {
  const selectType({Key? key}) : super(key: key);

  @override
  State<selectType> createState() => _selectTypeState();
}

class _selectTypeState extends State<selectType> {
  final TextEditingController _addtype = TextEditingController();
  Color _color1 = Colors.black26; //name
  bool _isloading1 = false;

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
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.0), // Set the bottom border radius
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.1), // Optional shadow for elevation effect
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor:
                Colors.transparent, // Make AppBar's background transparent
            elevation: 0, // Remove the default AppBar shadow
            title: Column(
              children: [
                Container(
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey,
                  ),
                ),
                5.sbh,
                Text(
                  'Select Product Type',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'assets/fonts/Metropolis-Black.otf',
                  ),
                ),
              ],
            ),
            centerTitle: true,
            automaticallyImplyLeading: false, // Removes the default back icon
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss keyboard when tapping outside
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              10.sbh,
              FutureBuilder<List<type.Result>?>(
                  future: constanst.cat_typedata,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
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
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          shrinkWrap: true,
                          itemCount: constanst.cat_type_data.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            type.Result record = constanst.cat_type_data[index];
                            return CommanBottomSheet(
                              onTap: () {
                                setState(() {
                                  if (constanst.select_typeId.contains(
                                      record.producttypeId.toString())) {
                                    constanst.select_typeId.remove(
                                        record.producttypeId.toString());
                                    constanst.select_typename
                                        .remove(record.productType.toString());
                                  } else {
                                    if (constanst.select_typename.length < 3) {
                                      constanst.select_typeId
                                          .add(record.producttypeId.toString());
                                      constanst.select_typename
                                          .add(record.productType.toString());
                                    } else {
                                      showCustomToast(
                                        'You Can Select Maximum 3 Type',
                                      );
                                    }
                                  }
                                });
                              },
                              checked: constanst.select_typeId
                                  .contains(record.producttypeId.toString()),
                              title: record.productType,
                            );
                          });
                    }
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          buttonText: 'Update',
          onPressed: () async {
            if (constanst.select_typeId.isNotEmpty) {
              if (_addtype.text.isNotEmpty) {
                await _updateType();
              } else {
                Navigator.pop(context);
              }
              setState(() {});
            } else {
              showCustomToast('Select Minimum 1 Type');
            }
          },
          isLoading: _isloading1,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class selectGrade extends StatefulWidget {
  const selectGrade({Key? key}) : super(key: key);

  @override
  State<selectGrade> createState() => _selectGradeState();
}

class _selectGradeState extends State<selectGrade> {
  final TextEditingController _addgrade = TextEditingController();
  Color _color1 = Colors.black26; //name
  bool _isloading1 = false;

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
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.0),
            ),
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
            title: Column(
              children: [
                Container(
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey,
                  ),
                ),
                5.sbh,
                Text(
                  'Select Product Grade',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'assets/fonts/Metropolis-Black.otf',
                  ),
                ),
              ],
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              10.sbh,
              FutureBuilder<List<grade.Result>?>(
                  future: constanst.cat_gradedata,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
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
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          shrinkWrap: true,
                          itemCount: constanst.cat_grade_data.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            grade.Result record =
                                constanst.cat_grade_data[index];
                            return CommanBottomSheet(
                              onTap: () {
                                setState(() {
                                  if (constanst.select_gradeId.contains(
                                      record.productgradeId.toString())) {
                                    constanst.select_gradeId.remove(
                                        record.productgradeId.toString());
                                    constanst.select_gradname
                                        .remove(record.productGrade.toString());
                                  } else {
                                    if (constanst.select_gradeId.length < 3) {
                                      constanst.select_gradeId.add(
                                          record.productgradeId.toString());
                                      constanst.select_gradname
                                          .add(record.productGrade.toString());
                                    } else {
                                      showCustomToast(
                                        'You Can Select Maximum 3 Grade',
                                      );
                                    }
                                  }
                                });
                              },
                              checked: constanst.select_gradeId
                                  .contains(record.productgradeId.toString()),
                              title: record.productGrade,
                            );
                          });
                    }
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          buttonText: 'Update',
          onPressed: () async {
            if (constanst.select_gradeId.isNotEmpty) {
              if (_addgrade.text.isNotEmpty) {
                await _updateGrade();
              } else {
                Navigator.pop(context);
              }
              setState(() {});
            } else {
              showCustomToast('Select Minimum 1 Grade');
            }
          },
          isLoading: _isloading1,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
