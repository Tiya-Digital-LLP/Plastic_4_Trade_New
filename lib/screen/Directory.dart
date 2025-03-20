// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, unnecessary_null_comparison, deprecated_member_use

import 'dart:io';
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_api_google_plac_api.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_chat_shimmer_loader.dart';
import 'package:Plastic4trade/widget/custom_location.dart';
import 'package:Plastic4trade/widget/custom_search_input.dart';
import 'package:Plastic4trade/widget/customshimmer/news_custom_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_interface.dart';
import '../utill/constant.dart';
import '../constroller/GetCategoryController.dart';
import '../widget/FilterScreen.dart';
import '../widget/HomeAppbar.dart';
import 'package:Plastic4trade/model/getDirectory.dart' as dir;
import 'package:Plastic4trade/model/GetCategory.dart' as cat;

class Directory1 extends StatefulWidget {
  const Directory1({Key? key}) : super(key: key);

  @override
  State<Directory1> createState() => _DirectoryState();
}

class _DirectoryState extends State<Directory1> {
  int selectedIndex = 0, _defaultChoiceIndex = -1;
  int offset = 0;
  int count = 0;
  bool? isLoad;
  List<dir.Result> dir_data = [];
  List<dynamic> resultList = [];
  List<dynamic> resultList1 = [];
  var business_type;
  List<String>? ints;

  String? location, search;
  bool isLoading = true;
  String category_filter_id = '',
      category_id = '""',
      grade_id = '',
      type_id = '',
      bussinesstype = '',
      coretype = '',
      post_type = '';
  final TextEditingController _loc = TextEditingController();
  final TextEditingController _search = TextEditingController();
  String crown_color = '';
  String plan_name = '';
  String appUserId = "";
  final scrollercontroller = ScrollController();
  bool loadmore = false;

  @override
  void initState() {
    scrollercontroller.addListener(_scrollercontroller);

    super.initState();
    _initializeGoogleApiKey();

    checknetowork();
    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollercontroller.removeListener(_scrollercontroller);
  }

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 50) ==
        (scrollercontroller.position.maxScrollExtent - 50)) {
      loadmore = false;
      if (dir_data.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 20;
        } else {
          offset = offset + 20;
        }
        get_direcorylist();
      }
    }
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

  Future<void> _refreshData() async {
    setState(() {
      dir_data.clear();
      offset = 0;
    });

    await get_direcorylist();

    showCustomToast('Data Refreshed');
    scrollercontroller.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    return null;
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  Widget ExhibitorWithShimmerLoader(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: NewsShimmerLoader(width: 175, height: 150),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: CustomeApp('Directory'),
        body: Column(children: [
          horiztallist(),
          5.sbh,
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40.0),
                            bottomRight: Radius.circular(40.0),
                            topLeft: Radius.circular(40.0),
                            bottomLeft: Radius.circular(40.0),
                          ),
                          color: AppColors.backgroundColor),
                      height: 40,
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: CustomLocationInput(
                          controller: _loc,
                          prefixIcon: Icons.location_on_outlined,
                          suffixIcon: Icons.clear,
                          onClear: () {
                            _loc.clear();
                            dir_data.clear();
                            constanst.lat = "";
                            constanst.log = "";
                            get_direcorylist();
                            setState(() {});
                          },
                          onTap: () async {
                            var place = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: constanst.googleApikey,
                                mode: Mode.overlay,
                                types: ['(cities)'],
                                strictbounds: false,
                                onError: (err) {});

                            if (place != null) {
                              setState(() {
                                location = place.description.toString();
                                constanst.location =
                                    place.description.toString();
                                _loc.text = location!;
                              });

                              final plist = GoogleMapsPlaces(
                                apiKey: constanst.googleApikey,
                                apiHeaders:
                                    await const GoogleApiHeaders().getHeaders(),
                              );
                              String placeid = place.placeId ?? "0";
                              final detail =
                                  await plist.getDetailsByPlaceId(placeid);

                              final geometry = detail.result.geometry!;
                              constanst.lat = geometry.location.lat.toString();
                              WidgetsBinding.instance.focusManager.primaryFocus
                                  ?.unfocus();
                              constanst.log = geometry.location.lng.toString();
                              dir_data.clear();
                              count = 0;
                              offset = 0;

                              setState(() {});
                            }

                            if (place != null) {
                              setState(() {
                                location = place.description.toString();
                                _loc.text = location!;
                                dir_data.clear();
                                get_direcorylist();
                              });

                              final plist = GoogleMapsPlaces(
                                apiKey: constanst.googleApikey,
                                apiHeaders:
                                    await const GoogleApiHeaders().getHeaders(),
                              );
                              String placeid = place.placeId ?? "0";
                              final detail =
                                  await plist.getDetailsByPlaceId(placeid);

                              final geometry = detail.result.geometry!;
                              constanst.lat = geometry.location.lat.toString();
                              constanst.log = geometry.location.lng.toString();
                              WidgetsBinding.instance.focusManager.primaryFocus
                                  ?.unfocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40.0),
                          bottomRight: Radius.circular(40.0),
                          topLeft: Radius.circular(40.0),
                          bottomLeft: Radius.circular(40.0),
                        ),
                        color: AppColors.backgroundColor),
                    height: 40,
                    margin: const EdgeInsets.only(left: 8.0),
                    width: MediaQuery.of(context).size.width / 2.2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: CustomSearchInput(
                        onClear: () {},
                        controller: _search,
                        onSubmitted: (value) {
                          dir_data.clear();
                          count = 0;
                          offset = 0;
                          get_direcorylist();
                          setState(() {});
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            WidgetsBinding.instance.focusManager.primaryFocus
                                ?.unfocus();
                            _search.clear();
                            count = 0;
                            offset = 0;
                            dir_data.clear();
                            get_direcorylist();
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ),
                  6.sbw,
                  GestureDetector(
                    onTap: () {
                      ViewItem(context);
                    },
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(
                          bottom: 3.0, left: 1.2, top: 3.0),
                      width: MediaQuery.of(context).size.width / 11.2,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor),
                      child: const Icon(
                        Icons.filter_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          isLoading ? ExhibitorWithShimmerLoader(context) : directory()
        ]));
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
          initialChildSize: 0.85,
          builder: (BuildContext context, ScrollController scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return const FilterScreen();
              },
            );
          }),
    ).then(
      (value) {
        _loc.text = constanst.location.toString();
        category_filter_id = constanst.select_categotyId.join(",");
        type_id = constanst.select_typeId.join(",");
        grade_id = constanst.select_gradeId.join(",");
        bussinesstype = constanst.selectbusstype_id.join(",");

        post_type = constanst.select_categotyType.join(",");
        coretype = constanst.selectcore_id.join(",");

        dir_data.clear();

        get_direcorylist();
        constanst.select_categotyId.clear();
        constanst.select_typeId.clear();
        constanst.select_gradeId.clear();
        constanst.selectbusstype_id.clear();
        constanst.select_categotyType.clear();
        constanst.selectcore_id.clear();

        setState(() {});
      },
    );
  }

  Widget directory() {
    return Expanded(
      child: RefreshIndicator(
        backgroundColor: AppColors.primaryColor,
        color: AppColors.backgroundColor,
        onRefresh: () async {
          _refreshData();
        },
        child: ListView.builder(
            controller: scrollercontroller,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: dir_data.length + (loadmore ? 1 : 0),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index < dir_data.length) {
                if (dir_data.isEmpty) {
                  return Center(
                    child: Text(
                      "No Data Found",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                dir.Result record = dir_data[index];
                return GestureDetector(
                  onTap: () async {
                    if (record.isBusinessProfileView == 0 &&
                        record.isBusinessOldView == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Premiun(),
                        ),
                      ).then((_) {
                        _refreshData();
                      });
                      showCustomToast('Upgrade Plan to View Profile');
                    } else {
                      if (appUserId == dir_data[index].id.toString()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => bussinessprofile(
                              int.parse(dir_data[index].id.toString()),
                            ),
                          ),
                        ).then((_) {
                          _refreshData();
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => bussinessprofile(
                              int.parse(dir_data[index].id.toString()),
                            ),
                          ),
                        ).then((_) {
                          _refreshData();
                        });
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
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
                    padding: const EdgeInsets.all(14),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.isBusinessProfileView == 1 &&
                                          record.isBusinessOldView == 1
                                      ? record.username.toString()
                                      : 'XXXXX ' +
                                          record.username!.split(' ').last,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.24,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf'),
                                ),
                                SizedBox(height: 1),
                                Text(resultList[index].toString(),
                                    style: TextStyle(
                                        color: AppColors.blackColor
                                            .withOpacity(0.50),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf')),
                                SizedBox(height: 4),
                                Text(
                                  record.address!.length > 35
                                      ? "${record.address!.substring(0, 35)}..."
                                      : record.address!,
                                  style: const TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.24,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ]),
                          Column(
                            children: [
                              record.isBusinessProfileView == 1 &&
                                      record.isBusinessOldView == 1
                                  ? Container(
                                      width: 51,
                                      height: 51,
                                      decoration: ShapeDecoration(
                                        shape: CircleBorder(
                                          side: BorderSide(
                                            width: 2,
                                            color: record.crownColor != null
                                                ? Color(int.parse(
                                                        record.crownColor!
                                                            .substring(1),
                                                        radix: 16) |
                                                    0xFF000000)
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              record.userImageUrl.toString(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: ShapeDecoration(
                                        shape: CircleBorder(
                                          side: BorderSide(
                                            width: 2,
                                            color: record.crownColor != null
                                                ? Color(int.parse(
                                                        record.crownColor!
                                                            .substring(1),
                                                        radix: 16) |
                                                    0xFF000000)
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.supervised_user_circle_outlined,
                                          color: AppColors.primaryColor,
                                          size: 45,
                                        ),
                                      ),
                                    ),
                              (record.isBusinessProfileView == 1 &&
                                      record.isBusinessOldView == 1)
                                  ? Container(
                                      width: 49,
                                      height: 13,
                                      alignment: Alignment.center,
                                      transform: Matrix4.translationValues(
                                          0.0, -10.0, 0.0),
                                      decoration: ShapeDecoration(
                                        color: record.crownColor != null
                                            ? Color(int.parse(
                                                    record.crownColor!
                                                        .substring(1),
                                                    radix: 16) |
                                                0xFF000000)
                                            : Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                      ),
                                      child: Text(
                                        record.planName ?? "",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontFamily: 'Metropolis-SemiBold',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.24,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 49,
                                      height: 13,
                                      alignment: Alignment.center,
                                      transform: Matrix4.translationValues(
                                          0.0, -10.0, 0.0),
                                      decoration: ShapeDecoration(
                                        color: record.crownColor != null
                                            ? Color(int.parse(
                                                    record.crownColor!
                                                        .substring(1),
                                                    radix: 16) |
                                                0xFF000000)
                                            : Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                      ),
                                      child: Text(
                                        record.planName ?? "",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontFamily: 'Metropolis-SemiBold',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.24,
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Align(
                        alignment: Alignment.topLeft,
                        child: resultList1[index].toString().isNotEmpty
                            ? Text(
                                resultList1[index].toString(),
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.24,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf',
                                ),
                                maxLines: 15,
                                overflow: TextOverflow.ellipsis,
                              )
                            : SizedBox.shrink(),
                      ),
                    ]),
                  ),
                );
              } else if (loadmore) {
                return ChatShimmerLoader(
                  width: 175,
                  height: 100,
                );
              } else {
                return SizedBox();
              }
            }),
      ),
    );
  }

  bool hasMoreQuickNewsToLoad() {
    int itemsPerPage = 20;
    return dir_data.length % itemsPerPage == 0;
  }

  Widget horiztallist() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
          shrinkWrap: false,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: constanst.catdata.length,
          itemBuilder: (context, index) {
            cat.Result result = constanst.catdata[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Wrap(spacing: 6.0, runSpacing: 6.0, children: <Widget>[
                ChoiceChip(
                  label: Text(
                    constanst.catdata[index].categoryName.toString(),
                  ),
                  selected: _defaultChoiceIndex == index,
                  selectedColor: AppColors.blackColor,
                  onSelected: (bool selected) {
                    setState(() {
                      _defaultChoiceIndex = selected ? index : -1;
                      if (_defaultChoiceIndex == -1) {
                        category_filter_id = "";
                        dir_data.clear();
                        get_direcorylist()();
                      } else {
                        category_filter_id = result.categoryId.toString();
                        dir_data.clear();
                        get_direcorylist();
                      }
                    });
                  },
                  backgroundColor: AppColors.greyBackground,
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf')
                      .copyWith(
                          color: _defaultChoiceIndex == index
                              ? Colors.white
                              : Colors.black),
                  showCheckmark: false,
                )
              ]),
            );
          }),
    );
  }

  void get_categorylist() async {
    GetCategoryController bt = GetCategoryController();
    constanst.cat_data = bt.setlogin();

    constanst.cat_data!.then((value) {
      for (var item in value) {
        constanst.catdata.add(item);
      }
      isLoad = true;
      setState(() {});
    });
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      getPackage();
      get_categorylist();
      get_direcorylist();
    }
  }

  void getPackage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    appUserId = pref.getString('user_id').toString();
  }

  get_direcorylist() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      String device = '';
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }
      print('Device Name: $device');

      // Call the get_directory API and print the full response
      var res = await get_directory(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        offset.toString(),
        category_filter_id,
        grade_id,
        type_id,
        bussinesstype,
        coretype,
        post_type,
        constanst.lat,
        constanst.log,
        _search.text.toString(),
        device,
      );

      print("Full Response: $res");

      // Check for success status
      if (res['status'] == 1 &&
          res['result'] != null &&
          res['result'].isNotEmpty) {
        var jsonArray = res['result'];

        for (var data in jsonArray) {
          dir.Result record = dir.Result(
            userImage: data['username'],
            username: data['username'],
            address: data['address'],
            userImageUrl: data['user_image_url'],
            id: data['id'],
            phoneno: data['phoneno'],
            crownColor: data['crown_color'],
            planName: data['plan_name'],
            isBusinessProfileView: data['can_business_profile_view'],
            isBusinessOldView: data['check_old_view'],
          );

          // Join business type list
          List<dynamic>? businessTypes =
              (data["business_type"] as List).map((e) => e.toString()).toList();
          String businessTypeStr = businessTypes.join(", ");
          resultList.add(businessTypeStr);

          // Join product name list
          List<dynamic>? productNames =
              (data["product_name"] as List).map((e) => e.toString()).toList();
          String productNameStr = productNames.join(", ");
          resultList1.add(productNameStr);

          dir_data.add(record);
        }

        // Call setState only once after processing the data
        setState(() {
          loadmore = true;
          isLoad = true;
        });
      } else {
        setState(() {
          loadmore = false;
          isLoad = true;
        });
        print(res['message']);
      }
    } catch (e) {
      print("Error occurred: $e");
      setState(() {
        isLoad = true;
      });
      return null;
    }
  }
}
