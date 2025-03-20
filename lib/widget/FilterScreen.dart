import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_api_google_plac_api.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:Plastic4trade/model/Getfilterdata.dart' as filter;
import '../api/api_interface.dart';
import '../model/Getfilterdata.dart';
import '../screen/CategoryScreen.dart';
import '../utill/constant.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? assignedName;
  bool gender = false;
  bool? iscategory,
      istype,
      isgrade,
      isbussiness_type,
      ispost_type,
      is_core_type,
      islocation,
      isload;
  String category_id = '',
      grade_id = '',
      type_id = '',
      bussinesstype = '',
      coretype = '',
      post_type = '';
  List<filter.Category> category_data = [];
  List<filter.Businesstype> bussines_data = [];
  List<filter.Producttype> product_type = [];
  List<filter.Productgrade> product_grade = [];
  List<filter.CoreType> core_type = [];
  List<filter.CoreType> filteredCoreType = [];
  List<filter.Productgrade> filteredproductgrade = [];
  List<filter.Producttype> filteredproducttype = [];
  List<filter.Category> filteredproductcategory = [];
  List<filter.Businesstype> filteredproductbusiness = [];

  TextEditingController searchController = TextEditingController();
  TextEditingController searchControllergrade = TextEditingController();
  TextEditingController searchControllertype = TextEditingController();
  TextEditingController searchControllercategory = TextEditingController();
  TextEditingController searchControllerbusiness = TextEditingController();
  final TextEditingController _loc = TextEditingController();

  List<RadioModel> sampleData1 = <RadioModel>[];

  String? location, search;
  Timer? _debounce;
  List<String> _locationSuggestions = [];

  Color _color1 = AppColors.blackColor;
  Color _color2 = AppColors.blackColor;
  Color _color3 = AppColors.blackColor;
  Color _color4 = AppColors.blackColor;
  Color _color5 = AppColors.blackColor;
  Color _color6 = AppColors.blackColor;
  Color _color7 = AppColors.blackColor;

  @override
  void initState() {
    super.initState();
    filteredCoreType = core_type;
    filteredproductgrade = product_grade;
    filteredproducttype = product_type;
    filteredproductcategory = category_data;
    filteredproductbusiness = bussines_data;
    searchController.addListener(_filterCoreTypes);
    searchControllergrade.addListener(_filterProductGrade);
    searchControllertype.addListener(_filterProductType);
    searchControllercategory.addListener(_filterCategory);
    searchControllerbusiness.addListener(_filterBusiness);

    _initializeGoogleApiKey();

    sampleData1.add(RadioModel(false, 'Buy Post'));
    sampleData1.add(RadioModel(false, 'Sell Post'));
    checknetowork();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchControllergrade.dispose();
    searchControllertype.dispose();
    searchControllercategory.dispose();
    searchControllerbusiness.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _filterCoreTypes() {
    setState(() {
      final query = searchController.text.toLowerCase();

      if (query.isEmpty) {
        filteredCoreType = core_type;
      } else {
        filteredCoreType = core_type
            .where((core) =>
                core.coreType.toString().toLowerCase().contains(query))
            .toList();

        filteredCoreType.sort((a, b) {
          if (a.coreType.toString().toLowerCase().startsWith(query)) {
            return -1;
          } else if (b.coreType.toString().toLowerCase().startsWith(query)) {
            return 1;
          }
          return a.coreType.toString().compareTo(b.coreType.toString());
        });
      }
    });
  }

  void _filterProductGrade() {
    setState(() {
      final query = searchControllergrade.text.toLowerCase();

      if (query.isEmpty) {
        filteredproductgrade = product_grade;
      } else {
        filteredproductgrade = product_grade
            .where((grade) =>
                grade.productGrade.toString().toLowerCase().contains(query))
            .toList();

        filteredproductgrade.sort((a, b) {
          if (a.productGrade.toString().toLowerCase().startsWith(query)) {
            return -1;
          } else if (b.productGrade
              .toString()
              .toLowerCase()
              .startsWith(query)) {
            return 1;
          }
          return a.productGrade.toString().compareTo(b.productGrade.toString());
        });
      }
    });
  }

  void _filterProductType() {
    setState(() {
      final query = searchControllertype.text.toLowerCase();

      if (query.isEmpty) {
        filteredproducttype = product_type;
      } else {
        filteredproducttype = product_type
            .where((type) =>
                type.productType.toString().toLowerCase().contains(query))
            .toList();

        filteredproducttype.sort((a, b) {
          if (a.productType.toString().toLowerCase().startsWith(query)) {
            return -1;
          } else if (b.productType.toString().toLowerCase().startsWith(query)) {
            return 1;
          }
          return a.productType.toString().compareTo(b.productType.toString());
        });
      }
    });
  }

  void _filterCategory() {
    setState(() {
      final query = searchControllercategory.text.toLowerCase();

      if (query.isEmpty) {
        filteredproductcategory = category_data;
      } else {
        filteredproductcategory = category_data
            .where((category) =>
                category.categoryName.toString().toLowerCase().contains(query))
            .toList();

        filteredproductcategory.sort((a, b) {
          if (a.categoryName.toString().toLowerCase().startsWith(query)) {
            return -1;
          } else if (b.categoryName
              .toString()
              .toLowerCase()
              .startsWith(query)) {
            return 1;
          }
          return a.categoryName.toString().compareTo(b.categoryName.toString());
        });
      }
    });
  }

  void _filterBusiness() {
    setState(() {
      final query = searchControllerbusiness.text.toLowerCase();

      if (query.isEmpty) {
        filteredproductbusiness = bussines_data;
      } else {
        filteredproductbusiness = bussines_data
            .where((business) =>
                business.businessType.toString().toLowerCase().contains(query))
            .toList();

        filteredproductbusiness.sort((a, b) {
          if (a.businessType.toString().toLowerCase().startsWith(query)) {
            return -1;
          } else if (b.businessType
              .toString()
              .toLowerCase()
              .startsWith(query)) {
            return 1;
          }
          return a.businessType.toString().compareTo(b.businessType.toString());
        });
      }
    });
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

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      clear();
      get_Filterdata();
    }
  }

  clear() {
    category_data.clear();
    product_type.clear();
    product_grade.clear();
    bussines_data.clear();
    constanst.category_itemsCheck.clear();
    constanst.Type_itemsCheck.clear();
    constanst.Grade_itemsCheck.clear();
    constanst.bussiness_type_itemsCheck.clear();
  }

  get_Filterdata() async {
    var res = await getfilterdata();
    print(res);
    if (res['status'] == 1) {
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      for (var item in res['category']) {
        category_data.add(Category.fromJson(item));
      }

      for (var item in res['producttype']) {
        product_type.add(Producttype.fromJson(item));
      }

      for (var item in res['productgrade']) {
        product_grade.add(Productgrade.fromJson(item));
      }

      for (var item in res['businesstype']) {
        bussines_data.add(Businesstype.fromJson(item));
      }

      for (var item in res['corebusiness']) {
        core_type.add(CoreType.fromJson(item));
      }

      for (int i = 0; i < category_data.length; i++) {
        constanst.category_itemsCheck.add(Icons.circle_outlined);
      }

      for (int i = 0; i < product_type.length; i++) {
        constanst.Type_itemsCheck.add(Icons.circle_outlined);
      }

      for (int i = 0; i < product_grade.length; i++) {
        constanst.Grade_itemsCheck.add(Icons.circle_outlined);
      }

      for (int i = 0; i < bussines_data.length; i++) {
        constanst.bussiness_type_itemsCheck.add(Icons.circle_outlined);
      }

      for (int i = 0; i < core_type.length; i++) {
        constanst.core_type_itemsCheck.add(Icons.circle_outlined);
      }
      isload = true;

      setState(() {});
    } else {
      showCustomToast(res['message']);
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              5.sbh,
              Container(
                height: 5,
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.gray,
                ),
              ),
              5.sbh,
              Center(
                child: Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                    fontFamily: 'assets/fonts/Metropolis-Black.otf',
                  ),
                ),
              ),
              const SizedBox(height: 5),
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
                        color: AppColors.blackColor,
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.60,
                        height: MediaQuery.of(context).size.height / 1.25,
                        child: isload == true ? ScreenB() : const SizedBox()),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2.3,
              height: 60,
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                  constanst.lat = "";
                  constanst.log = "";
                  constanst.location = "";
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                    style: TextStyle(
                        fontSize: 19.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                        fontFamily: 'assets\fonst\Metropolis-Black.otf')),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2.3,
              height: 60,
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(50.0),
                  color: AppColors.primaryColor),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Apply',
                    style: TextStyle(
                        fontSize: 19.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.backgroundColor,
                        fontFamily: 'assets\fonst\Metropolis-Black.otf')),
              ),
            ),
          ],
        ));
  }

  Widget ScreenA() {
    return Column(children: [
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = true;
                  istype = false;
                  isgrade = false;
                  isbussiness_type = false;
                  ispost_type = false;
                  is_core_type = false;

                  islocation = false;
                  _color1 = AppColors.primaryColor;
                  _color2 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;
                  _color5 = AppColors.blackColor;
                  _color6 = AppColors.blackColor;
                  _color7 = AppColors.blackColor;

                  setState(() {});
                },
                child: Text(
                  'Category',
                  style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets\fonst\Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color1),
                ))),
      ),
      Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  istype = true;
                  isgrade = false;
                  isbussiness_type = false;
                  ispost_type = false;
                  is_core_type = false;

                  islocation = false;
                  _color2 = AppColors.primaryColor;
                  _color1 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;
                  _color5 = AppColors.blackColor;
                  _color6 = AppColors.blackColor;
                  _color7 = AppColors.blackColor;

                  setState(() {});
                },
                child: Text(
                  'Type',
                  style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets\fonst\Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color2),
                ))),
      ),
      Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  istype = false;
                  isgrade = true;
                  isbussiness_type = false;
                  ispost_type = false;
                  is_core_type = false;

                  islocation = false;
                  _color3 = AppColors.primaryColor;
                  _color1 = AppColors.blackColor;
                  _color2 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;
                  _color5 = AppColors.blackColor;
                  _color6 = AppColors.blackColor;
                  _color7 = AppColors.blackColor;

                  setState(() {});
                },
                child: Text(
                  'Grade',
                  style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets\fonst\Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color3),
                ))),
      ),
      Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  istype = false;
                  isgrade = false;
                  isbussiness_type = true;
                  ispost_type = false;
                  is_core_type = false;
                  islocation = false;

                  _color4 = AppColors.primaryColor;
                  _color1 = AppColors.blackColor;
                  _color2 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;
                  _color5 = AppColors.blackColor;
                  _color6 = AppColors.blackColor;
                  _color7 = AppColors.blackColor;

                  setState(() {});
                },
                child: Text(
                  'Business Type',
                  style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'assets\fonst\Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color4),
                ))),
      ),
      Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  istype = false;
                  isgrade = false;
                  isbussiness_type = false;
                  ispost_type = true;
                  is_core_type = false;
                  islocation = false;

                  _color5 = AppColors.primaryColor;
                  _color1 = AppColors.blackColor;
                  _color2 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;
                  _color6 = AppColors.blackColor;
                  _color7 = AppColors.blackColor;
                  setState(() {});
                },
                child: Text(
                  'Post Type',
                  style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets\fonst\Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color5),
                ))),
      ),
      Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  istype = false;
                  isgrade = false;
                  isbussiness_type = false;
                  ispost_type = false;
                  is_core_type = true;
                  islocation = false;
                  _color6 = AppColors.primaryColor;
                  _color5 = AppColors.blackColor;
                  _color1 = AppColors.blackColor;
                  _color2 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;
                  _color7 = AppColors.blackColor;
                  setState(() {});
                },
                child: Text(
                  'Core Business',
                  style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets\fonst\Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color6),
                ))),
      ),
      Divider(color: AppColors.gray),
      SizedBox(
        height: 50,
        child: Align(
            child: TextButton(
                onPressed: () {
                  iscategory = false;
                  istype = false;
                  isgrade = false;
                  isbussiness_type = false;
                  ispost_type = false;
                  is_core_type = false;
                  islocation = true;
                  _color7 = AppColors.primaryColor;

                  _color6 = AppColors.blackColor;
                  _color1 = AppColors.blackColor;
                  _color2 = AppColors.blackColor;
                  _color4 = AppColors.blackColor;
                  _color5 = AppColors.blackColor;
                  _color3 = AppColors.blackColor;

                  setState(() {});
                },
                child: Text(
                  'Location',
                  style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets\fonst\Metropolis-Black.otf')
                      .copyWith(fontWeight: FontWeight.w500, color: _color7),
                ))),
      ),
      Divider(color: AppColors.gray),
      SizedBox(
        height: MediaQuery.of(context).size.height / 6.5,
      )
    ]);
  }

  Widget ScreenB() {
    return SizedBox(
        child: iscategory == true
            ? category()
            : istype == true
                ? type()
                : isgrade == true
                    ? grade()
                    : isbussiness_type == true
                        ? bussiness_type()
                        : ispost_type == true
                            ? posttype()
                            : is_core_type == true
                                ? core_business()
                                : islocation == true
                                    ? locationScreen()
                                    : Container());
  }

  Widget category() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: AppColors.backgroundColor,
          ),
          height: 40,
          child: TextField(
            controller: searchControllercategory,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search Category',
              contentPadding: EdgeInsets.only(top: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              hintStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 5.0, left: 5.0),
                child: Icon(
                  Icons.search,
                  color: AppColors.blackColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        5.sbh,
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredproductcategory.length,
            // physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              filter.Category category = filteredproductcategory[index];
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
                      setState(() {});
                      print(constanst.select_categotyId);
                    } else {
                      showCustomToast('You Can Select Maximum 3 Category');
                    }
                  } else {
                    constanst.category_itemsCheck[index] =
                        Icons.circle_outlined;
                    category_id = category.id.toString();
                    constanst.select_categotyId.remove(category_id);
                    print('remove $category_id');
                    print(constanst.select_categotyId);
                    setState(() {});
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 4.0,
                  decoration: BoxDecoration(color: AppColors.transperent),
                  child: Row(
                    children: [
                      IconButton(
                          icon: constanst.category_itemsCheck[index] ==
                                  Icons.circle_outlined
                              ? Icon(Icons.circle_outlined,
                                  color: AppColors.black45Color)
                              : Icon(Icons.check_circle,
                                  color: AppColors.greenWithShade),
                          onPressed: () {
                            gender = true;
                            if (constanst.category_itemsCheck[index] ==
                                Icons.circle_outlined) {
                              if (constanst.select_categotyId.length <= 2) {
                                constanst.category_itemsCheck[index] =
                                    Icons.check_circle_outline;

                                category_id = category.id.toString();
                                constanst.select_categotyId.add(category_id);
                                setState(() {});

                                print(constanst.select_categotyId);
                              } else {
                                showCustomToast(
                                    'You Can Select Maximum 3 Category');
                              }
                            } else {
                              constanst.category_itemsCheck[index] =
                                  Icons.circle_outlined;
                              category_id = category.id.toString();
                              constanst.select_categotyId.remove(category_id);
                              print('remove $category_id');
                              print(constanst.select_categotyId);
                              setState(() {});
                            }
                          }),
                      Text(category.categoryName.toString(),
                          style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackColor,
                              fontFamily: 'assets\fonst\Metropolis-Black.otf'),
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        60.sbh,
      ],
    );
  }

  Widget type() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: AppColors.backgroundColor,
          ),
          height: 40,
          child: TextField(
            controller: searchControllertype,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search Type',
              contentPadding: EdgeInsets.only(top: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              hintStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 5.0, left: 5.0),
                child: Icon(
                  Icons.search,
                  color: AppColors.blackColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        5.sbh,
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredproducttype.length,
              itemBuilder: (BuildContext context, int index) {
                filter.Producttype category = filteredproducttype[index];
                return GestureDetector(
                  onTap: () {
                    gender = true;
                    if (constanst.Type_itemsCheck[index] ==
                        Icons.circle_outlined) {
                      if (constanst.select_typeId.length <= 2) {
                        constanst.Type_itemsCheck[index] =
                            Icons.check_circle_outline;
                        type_id = category.id.toString();
                        constanst.select_typeId.add(type_id);
                        setState(() {});
                      } else {
                        showCustomToast('You Can Select Maximum 3 Type');
                      }
                    } else {
                      constanst.Type_itemsCheck[index] = Icons.circle_outlined;
                      type_id = category.id.toString();
                      constanst.select_typeId.remove(type_id);
                      setState(() {});
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 4.0,
                    decoration: BoxDecoration(color: AppColors.transperent),
                    child: Row(
                      children: [
                        IconButton(
                            icon: constanst.Type_itemsCheck[index] ==
                                    Icons.circle_outlined
                                ? Icon(Icons.circle_outlined,
                                    color: AppColors.black45Color)
                                : Icon(Icons.check_circle,
                                    color: AppColors.greenWithShade),
                            onPressed: () {
                              gender = true;
                              if (constanst.Type_itemsCheck[index] ==
                                  Icons.circle_outlined) {
                                if (constanst.select_typeId.length <= 2) {
                                  constanst.Type_itemsCheck[index] =
                                      Icons.check_circle_outline;
                                  type_id = category.id.toString();
                                  constanst.select_typeId.add(type_id);
                                  setState(() {});
                                } else {
                                  showCustomToast(
                                      'You Can Select Maximum 3 Type');
                                }
                              } else {
                                constanst.Type_itemsCheck[index] =
                                    Icons.circle_outlined;
                                type_id = category.id.toString();
                                constanst.select_typeId.remove(type_id);
                                setState(() {});
                              }
                            }),
                        Text(category.productType.toString(),
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackColor,
                                fontFamily:
                                    'assets\fonst\Metropolis-Black.otf'),
                            softWrap: false,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              }),
        ),
        60.sbh,
      ],
    );
  }

  Widget grade() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: AppColors.backgroundColor,
          ),
          height: 40,
          child: TextField(
            controller: searchControllergrade,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search Grade',
              contentPadding: EdgeInsets.only(top: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              hintStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 5.0, left: 5.0),
                child: Icon(
                  Icons.search,
                  color: AppColors.blackColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        5.sbh,
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredproductgrade.length,
              itemBuilder: (BuildContext context, int index) {
                filter.Productgrade category = filteredproductgrade[index];
                return GestureDetector(
                  onTap: () {
                    gender = true;
                    if (constanst.Grade_itemsCheck[index] ==
                        Icons.circle_outlined) {
                      if (constanst.select_gradeId.length <= 2) {
                        constanst.Grade_itemsCheck[index] =
                            Icons.check_circle_outline;
                        grade_id = category.id.toString();
                        constanst.select_gradeId.add(grade_id);
                        setState(() {});
                      } else {
                        showCustomToast('You Can Select Maximum 3 Grade');
                      }
                    } else {
                      constanst.Grade_itemsCheck[index] = Icons.circle_outlined;
                      grade_id = category.id.toString();
                      constanst.select_gradeId.remove(grade_id);
                      setState(() {});
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 4.0,
                    decoration: BoxDecoration(color: AppColors.transperent),
                    child: Row(
                      children: [
                        IconButton(
                            icon: constanst.Grade_itemsCheck[index] ==
                                    Icons.circle_outlined
                                ? Icon(Icons.circle_outlined,
                                    color: AppColors.black45Color)
                                : Icon(Icons.check_circle,
                                    color: AppColors.greenWithShade),
                            onPressed: () {
                              if (constanst.Grade_itemsCheck[index] ==
                                  Icons.circle_outlined) {
                                // Check if maximum selection limit is reached
                                if (constanst.select_gradeId.length < 3) {
                                  constanst.Grade_itemsCheck[index] =
                                      Icons.check_circle_outline;
                                  grade_id = category.id.toString();
                                  constanst.select_gradeId.add(grade_id);
                                } else {
                                  showCustomToast(
                                    'You Can Select Maximum 3 Grade',
                                  );
                                }
                              } else {
                                // Deselect the item
                                constanst.Grade_itemsCheck[index] =
                                    Icons.circle_outlined;
                                grade_id = category.id.toString();
                                constanst.select_gradeId.remove(grade_id);
                              }
                              setState(() {});
                            }),
                        Text(category.productGrade.toString(),
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackColor,
                                fontFamily:
                                    'assets\fonst\Metropolis-Black.otf'),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              }),
        ),
        60.sbh,
      ],
    );
  }

  Widget bussiness_type() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: AppColors.backgroundColor,
          ),
          height: 40,
          child: TextField(
            controller: searchControllerbusiness,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search Business Type',
              contentPadding: EdgeInsets.only(top: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              hintStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 5.0, left: 5.0),
                child: Icon(
                  Icons.search,
                  color: AppColors.blackColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        5.sbh,
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredproductbusiness.length,
              itemBuilder: (BuildContext context, int index) {
                filter.Businesstype category = filteredproductbusiness[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      gender = true;
                      if (constanst.bussiness_type_itemsCheck[index] ==
                          Icons.circle_outlined) {
                        if (constanst.selectbusstype_id.length <= 2) {
                          constanst.bussiness_type_itemsCheck[index] =
                              Icons.check_circle_outline;
                          bussinesstype = category.id.toString();
                          constanst.selectbusstype_id.add(bussinesstype);
                          setState(() {});
                        } else {
                          showCustomToast(
                              'You Can Select Maximum 3 Bussiness Type');
                        }
                      } else {
                        constanst.bussiness_type_itemsCheck[index] =
                            Icons.circle_outlined;
                        bussinesstype = category.id.toString();
                        constanst.selectbusstype_id.remove(bussinesstype);
                        setState(() {});
                      }
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 4.0,
                    decoration: BoxDecoration(color: AppColors.transperent),
                    child: Row(
                      children: [
                        IconButton(
                            icon: constanst.bussiness_type_itemsCheck[index] ==
                                    Icons.circle_outlined
                                ? Icon(Icons.circle_outlined,
                                    color: AppColors.black45Color)
                                : Icon(Icons.check_circle,
                                    color: AppColors.greenWithShade),
                            onPressed: () {
                              setState(() {
                                gender = true;
                                if (constanst
                                        .bussiness_type_itemsCheck[index] ==
                                    Icons.circle_outlined) {
                                  if (constanst.selectbusstype_id.length <= 2) {
                                    constanst.bussiness_type_itemsCheck[index] =
                                        Icons.check_circle_outline;
                                    bussinesstype = category.id.toString();
                                    constanst.selectbusstype_id
                                        .add(bussinesstype);
                                    setState(() {});
                                  } else {
                                    showCustomToast(
                                        'You Can Select Maximum 3 Bussiness Type');
                                  }
                                } else {
                                  constanst.bussiness_type_itemsCheck[index] =
                                      Icons.circle_outlined;
                                  bussinesstype = category.id.toString();
                                  constanst.selectbusstype_id
                                      .remove(bussinesstype);
                                  setState(() {});
                                }
                              });
                            }),
                        Text(category.businessType.toString(),
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackColor,
                                fontFamily:
                                    'assets\fonst\Metropolis-Black.otf'),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              }),
        ),
        60.sbh,
      ],
    );
  }

  Widget posttype() {
    return Padding(
        padding: EdgeInsets.only(left: 0.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (sampleData1.first.isSelected == false) {
                    sampleData1.first.isSelected = true;

                    post_type = 'BuyPost';
                    constanst.select_categotyType.add(post_type.toString());
                    print(constanst.select_categotyType);
                  } else {
                    sampleData1.first.isSelected = false;
                    constanst.select_categotyType.remove('BuyPost');
                    print(constanst.select_categotyType);
                  }
                });
              },
              child: Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 4.0,
                padding: EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(color: AppColors.transperent),
                child: Row(
                  children: [
                    GestureDetector(
                      child: Row(children: [
                        sampleData1.first.isSelected == true
                            ? Icon(Icons.check_circle,
                                color: AppColors.greenWithShade)
                            : Icon(Icons.circle_outlined,
                                color: AppColors.black45Color),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Buyer/Buy Post',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontSize: 17))
                      ]),
                      onTap: () {
                        setState(() {
                          if (sampleData1.first.isSelected == false) {
                            sampleData1.first.isSelected = true;

                            post_type = 'BuyPost';
                            constanst.select_categotyType
                                .add(post_type.toString());
                            print(constanst.select_categotyType);
                          } else {
                            sampleData1.first.isSelected = false;
                            constanst.select_categotyType.remove('BuyPost');
                            print(constanst.select_categotyType);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  print(sampleData1.last.isSelected);
                  if (sampleData1.last.isSelected == false) {
                    sampleData1.last.isSelected = true;
                    setState(() {});

                    post_type = 'SalePost';
                    constanst.select_categotyType.add(post_type.toString());
                    print(constanst.select_categotyType);
                  } else {
                    sampleData1.last.isSelected = false;
                    constanst.select_categotyType.remove('SalePost');
                    print(constanst.select_categotyType);
                  }
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 4.0,
                padding: EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(color: AppColors.transperent),
                height: 30,
                child: GestureDetector(
                  child: Row(children: [
                    sampleData1.last.isSelected == true
                        ? Icon(Icons.check_circle,
                            color: AppColors.greenWithShade)
                        : Icon(Icons.circle_outlined,
                            color: AppColors.black45Color),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Seller/Sell Post',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 17))
                  ]),
                  onTap: () {
                    setState(() {
                      print(sampleData1.last.isSelected);
                      if (sampleData1.last.isSelected == false) {
                        sampleData1.last.isSelected = true;
                        setState(() {});

                        post_type = 'SalePost';
                        constanst.select_categotyType.add(post_type.toString());
                        print(constanst.select_categotyType);
                      } else {
                        sampleData1.last.isSelected = false;
                        constanst.select_categotyType.remove('SalePost');
                        print(constanst.select_categotyType);
                      }
                    });
                  },
                ),
              ),
            )
          ],
        ));
  }

  Widget core_business() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: AppColors.backgroundColor,
          ),
          height: 40,
          child: TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search Core Business',
              contentPadding: EdgeInsets.only(top: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              hintStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 5.0, left: 5.0),
                child: Icon(
                  Icons.search,
                  color: AppColors.blackColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        5.sbh,
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredCoreType.length,
            itemBuilder: (BuildContext context, int index) {
              filter.CoreType core = filteredCoreType[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    gender = true;
                    if (constanst.core_type_itemsCheck[index] ==
                        Icons.circle_outlined) {
                      if (constanst.selectcore_id.length <= 2) {
                        constanst.core_type_itemsCheck[index] =
                            Icons.check_circle_outline;
                        coretype = core.id.toString();
                        constanst.selectcore_id.add(coretype);
                      } else {
                        showCustomToast(
                            'You Can Select Maximum 3 Core Business');
                      }
                    } else {
                      constanst.core_type_itemsCheck[index] =
                          Icons.circle_outlined;
                      coretype = core.id.toString();
                      constanst.selectcore_id.remove(coretype);
                    }
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 4.0,
                  decoration: BoxDecoration(color: AppColors.transperent),
                  child: Row(
                    children: [
                      IconButton(
                        icon: constanst.core_type_itemsCheck[index] ==
                                Icons.circle_outlined
                            ? Icon(Icons.circle_outlined,
                                color: AppColors.black45Color)
                            : Icon(Icons.check_circle,
                                color: AppColors.greenWithShade),
                        onPressed: () {
                          setState(() {
                            gender = true;
                            if (constanst.core_type_itemsCheck[index] ==
                                Icons.circle_outlined) {
                              if (constanst.selectcore_id.length <= 2) {
                                constanst.core_type_itemsCheck[index] =
                                    Icons.check_circle_outline;
                                coretype = core.id.toString();
                                constanst.selectcore_id.add(coretype);
                              } else {
                                showCustomToast(
                                    'You Can Select Maximum 3 Bussiness Type');
                              }
                            } else {
                              constanst.core_type_itemsCheck[index] =
                                  Icons.circle_outlined;
                              coretype = core.id.toString();
                              constanst.selectcore_id.remove(coretype);
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          core.coreType.toString(),
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blackColor,
                            fontFamily: 'assets\\fonts\\Metropolis-Black.otf',
                          ),
                          softWrap: false,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        60.sbh,
      ],
    );
  }

  Widget locationScreen() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: AppColors.backgroundColor,
          ),
          height: 40,
          child: TextField(
            controller: _loc,
            onChanged: (query) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () async {
                if (query.isNotEmpty) {
                  var suggestions = await fetchLocationSuggestions(query);

                  setState(() {
                    _locationSuggestions = suggestions;
                  });
                }
              });
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search Location',
              contentPadding: EdgeInsets.only(top: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              hintStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: AppColors.blackColor,
              ),
              suffixIcon: InkWell(
                onTap: () {
                  _loc.clear();
                  setState(() {
                    _locationSuggestions.clear();
                  });
                },
                child: Icon(
                  Icons.clear,
                  color: AppColors.blackColor,
                ),
              ),
            ),
          ),
        ),
        _locationSuggestions.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                  itemCount: _locationSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_locationSuggestions[index]),
                      onTap: () async {
                        var selectedLocation = _locationSuggestions[index];
                        setState(
                          () {
                            location = selectedLocation;
                            _loc.text = location!;
                          },
                        );

                        await fetchLocationDetails(selectedLocation);
                      },
                    );
                  },
                ),
              )
            : Container(),
      ],
    );
  }
}

Future<List<String>> fetchLocationSuggestions(String query) async {
  final places = GoogleMapsPlaces(apiKey: constanst.googleApikey);

  // Fetch autocomplete predictions
  final result = await places.autocomplete(
    query,
    components: [], // Adjust as per requirement
  );

  // Extract descriptions (city, state, country)
  return result.predictions.map((e) => e.description ?? '').toList();
}

Future<void> fetchLocationDetails(String placeName) async {
  final places = GoogleMapsPlaces(apiKey: constanst.googleApikey);
  final response = await places.searchByText(placeName);
  if (response.status == 'OK') {
    final location = response.results.first.geometry?.location;
    if (location != null) {
      constanst.lat = location.lat.toString();
      constanst.log = location.lng.toString();
    }
  }
}
