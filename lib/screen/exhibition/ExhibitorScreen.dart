// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names, prefer_typing_uninitialized_variables, unnecessary_null_comparison

import 'dart:core';
import 'dart:io';

import 'package:Plastic4trade/model/GetCategory.dart' as cat;
import 'package:Plastic4trade/model/getExhibitor.dart' as exhibitor;
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_api_google_plac_api.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/custom_location.dart';
import 'package:Plastic4trade/widget/custom_search_input.dart';
import 'package:Plastic4trade/widget/customshimmer/news_custom_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';

import 'package:getwidget/getwidget.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../api/api_interface.dart';
import '../../constroller/GetCategoryController.dart';
import '../../utill/constant.dart';
import '../../widget/FilterScreen.dart';
import '../../widget/HomeAppbar.dart';

class Exhibitor extends StatefulWidget {
  const Exhibitor({Key? key}) : super(key: key);

  @override
  State<Exhibitor> createState() => _DirectoryState();
}

class _DirectoryState extends State<Exhibitor> {
  String category_id = '',
      grade_id = '',
      type_id = '',
      bussinesstype = '',
      post_type = '',
      coretype = '',
      lat = '',
      log = '';
  final PageController controller = PageController(initialPage: 0);
  List<dynamic>? exhibitorList;
  bool? isload;
  int selectedIndex = 0, _defaultChoiceIndex = -1;
  int offset = 0;
  int getSliderIndex = 0;
  List<exhibitor.Result> exhibitor_data = [];
  List<dynamic> resultList = [];
  List<dynamic> resultList1 = [];
  List<dynamic> resultList2 = [];
  var business_type;
  List<String>? ints;
  String? location, search;
  String? packageName;
  PackageInfo? packageInfo;

  bool isLoading = true;
  String crown_color = '';
  String plan_name = '';
  String? verify_status;
  int? trusted_status;
  final TextEditingController _loc = TextEditingController();
  final TextEditingController _search = TextEditingController();
  String appUserId = "";

  @override
  void initState() {
    super.initState();
    _initializeGoogleApiKey();
    checknetowork();
    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
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

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  void getPackage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    appUserId = pref.getString('user_id').toString();
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      getPackage();
      get_categorylist();
      get_Exhibitorlist();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      exhibitor_data.clear();
      offset = 0;
    });

    await get_Exhibitorlist();

    showCustomToast('Data Refreshed');

    return null;
  }

  get_Exhibitorlist() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await get_exhibitor(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      category_id,
      grade_id,
      type_id,
      bussinesstype,
      post_type,
      coretype,
      constanst.lat,
      constanst.log,
      _search.text.toString(),
      device,
    );

    print("RESPONSE == $res");

    var jsonArray;

    if (res['status'] == 1 && res['result'] != null) {
      jsonArray = res['result'];
      exhibitorList = res['result'];

      // Clear existing data before adding new data
      resultList.clear();
      resultList1.clear();
      resultList2.clear();
      exhibitor_data.clear();

      for (var data in jsonArray) {
        exhibitor.Result record = exhibitor.Result(
          username: data['username'],
          id: data['id'],
          address: data['address'],
          businessName: data['business_name'],
          userImageUrl: data['user_image_url'],
          crownColor: data['crown_color'],
          planName: data['plan_name'],
          isBusinessProfileView: data['can_business_profile_view'],
          isBusinessOldView: data['check_old_view'],
          verify_status: data['verification_status'],
          trusted_status: data['trusted_status'],
        );

        print(
            'verify_status from get_Exhibitorlist: ${data['verification_status']}');
        print(
            'trusted_status from get_Exhibitorlist: ${data['trusted_status']}');

        List<dynamic>? businessTypes =
            (data["business_type"] as List).map((e) => e.toString()).toList();
        resultList.add(businessTypes.join(" | "));

        List<dynamic>? productNames =
            (data["product_name"] as List).map((e) => e.toString()).toList();
        resultList1.add(productNames.join(", "));

        List<dynamic>? images =
            (data["images"] as List).map((e) => e.toString()).toList();
        resultList2.add(images.join(", "));

        exhibitor_data.add(record);
      }

      // Only call setState once after all data is processed
      setState(() {
        isload = true;
      });
    } else {
      isload = true;
      print(res['message']);
      setState(() {});
    }
  }

  void get_categorylist() async {
    GetCategoryController bt = GetCategoryController();
    constanst.cat_data = bt.setlogin();

    constanst.cat_data!.then((value) {
      for (var item in value) {
        constanst.catdata.add(item);
      }
      isload = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: CustomeApp('Exhibitor'),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
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
                        color: Colors.white,
                      ),
                      height: 40,
                      width: MediaQuery.of(context).size.width / 2.6,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: CustomLocationInput(
                          controller: _loc,
                          prefixIcon: Icons.location_on_outlined,
                          suffixIcon: Icons.clear,
                          onClear: () {
                            _loc.clear();
                            exhibitor_data.clear();
                            constanst.lat = "";
                            constanst.log = "";
                            get_Exhibitorlist();
                            setState(() {});
                          },
                          onTap: () async {
                            var place = await PlacesAutocomplete.show(
                              context: context,
                              apiKey: constanst.googleApikey,
                              mode: Mode.overlay,
                              types: ['(cities)'],
                              strictbounds: false,
                              onError: (err) {},
                            );

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
                              exhibitor_data.clear();
                              offset = 0;

                              setState(() {});
                            }

                            if (place != null) {
                              setState(() {
                                location = place.description.toString();
                                _loc.text = location!;
                                exhibitor_data.clear();
                                get_Exhibitorlist();
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
                      color: Colors.white,
                    ),
                    height: 40,
                    margin: const EdgeInsets.only(left: 8.0),
                    width: MediaQuery.of(context).size.width / 2.2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: CustomSearchInput(
                        controller: _search,
                        onSubmitted: (value) {
                          WidgetsBinding.instance.focusManager.primaryFocus
                              ?.unfocus();
                          exhibitor_data.clear();
                          get_Exhibitorlist();
                          setState(() {});
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            WidgetsBinding.instance.focusManager.primaryFocus
                                ?.unfocus();
                            exhibitor_data.clear();
                            _search.clear();
                            offset = 0;

                            get_Exhibitorlist();
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
                      width: MediaQuery.of(context).size.width / 11.2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        Icons.filter_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isLoading ? DirectoryWithShimmerLoader(context) : directory()
        ]));
  }

  Widget DirectoryWithShimmerLoader(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: NewsShimmerLoader(width: 175, height: 350),
        );
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: exhibitor_data.isEmpty ? 1 : exhibitor_data.length + 1,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (exhibitor_data.isEmpty) {
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
          if (index == exhibitor_data.length) {
            if (hasMoreQuickNewsToLoad() && !exhibitor_data.isEmpty) {
              return NewsShimmerLoader(
                width: 175,
                height: 350,
              );
            } else {
              return SizedBox();
            }
          } else {
            exhibitor.Result record = exhibitor_data[index];
            List<dynamic> firstExhibitorImages =
                exhibitorList![index]['images'];
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
                    if (appUserId == record.id.toString()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => bussinessprofile(
                            int.parse(record.id.toString()),
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
                            int.parse(record.id.toString()),
                          ),
                        ),
                      ).then((_) {
                        _refreshData();
                      });
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x3FA6A6A6),
                          blurRadius: 16.32,
                          offset: Offset(0, 3.26),
                          spreadRadius: 0,
                        )
                      ]),
                  child: Column(children: [
                    Container(
                        padding:
                            const EdgeInsets.only(top: 15, right: 15, left: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                        ),
                        child: Row(children: [
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
                          Flexible(
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 0.0, 0.0, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        record.isBusinessProfileView == 1 &&
                                                record.isBusinessOldView == 1
                                            ? record.username.toString()
                                            : 'XXXXX ' +
                                                record.username!
                                                    .split(' ')
                                                    .last,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.24,
                                            fontFamily:
                                                'assets/fonst/Metropolis-Black.otf'),
                                      ),
                                      Text(resultList[index].toString(),
                                          softWrap: false,
                                          style: const TextStyle(
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-Black.otf')
                                              .copyWith(fontSize: 11),
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      SizedBox(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const ImageIcon(
                                                AssetImage(
                                                    'assets/location.png'),
                                                size: 10),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Expanded(
                                                child: Text(
                                                    record.address.toString(),
                                                    softWrap: false,
                                                    style: const TextStyle(
                                                            fontSize: 11.0,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf')
                                                        .copyWith(fontSize: 11),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis))
                                          ],
                                        ),
                                      )
                                    ],
                                  ))),
                          GestureDetector(
                            onTap: () async {
                              final call = Uri.parse(
                                  'tel:${exhibitorList![index]['countryCode']} ${exhibitorList![index]['phoneno']}');
                              if (await canLaunchUrl(call)) {
                                launchUrl(call);
                              } else {
                                throw 'Could not launch $call';
                              }
                            },
                            child: Image.asset(
                              "assets/Call2.png",
                              width: 30,
                              height: 30,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () async {
                              final web =
                                  Uri.parse('https://www.plastic4trade.com');
                              if (await canLaunchUrl(web)) {
                                launchUrl(web);
                              } else {
                                throw 'Could not launch $web';
                              }
                            },
                            child: Image.asset(
                              "assets/web.png",
                              width: 30,
                              height: 30,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () async {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              String appUsername =
                                  pref.getString('name').toString();
                              launchUrl(
                                Uri.parse('https://wa.me/${exhibitorList![index]['countryCode']}${exhibitorList![index]['phoneno']}' +
                                    '?text=Hello ${record.username} \nI am $appUsername \nI Saw Your Exhibitor Profile On Plastic4Trade App. \nI Want to Know About Your Business. \n\n' +
                                    'Open App' +
                                    '\n' +
                                    'Android:' +
                                    '\n' +
                                    'https://play.google.com/store/apps/details?id=com.p4t.plastic4trade' +
                                    '\n' +
                                    '\n'
                                        'IOS:' +
                                    '\n' +
                                    'https://apps.apple.com/app/plastic4trade/id6450507332'),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Image.asset(
                              'assets/whatsapp.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ])),
                    const Divider(
                      color: Colors.black38,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10.0, 2.0, 0.0, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(record.businessName.toString(),
                            softWrap: false,
                            style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontFamily:
                                    'assets/fonst/Metropolis-SemiBold.otf'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    if (record.verify_status != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                              image: record.verify_status == "0"
                                  ? AssetImage('assets/Unverified.png')
                                  : AssetImage('assets/verify.png'),
                              height: 26,
                              width: 26,
                            ),
                            3.sbw,
                            Text(
                              record.verify_status == "0"
                                  ? 'Not verified'
                                  : 'Verified',
                              style: TextStyle(
                                color: record.verify_status == "0"
                                    ? AppColors.blackColor
                                    : AppColors.verfirdColor,
                                fontSize: 13,
                                fontFamily: 'Metropolis',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            8.sbw,
                            if (record.trusted_status != null)
                              Row(
                                children: [
                                  Image(
                                    image: record.trusted_status == 0
                                        ? AssetImage('assets/Untrusted.png')
                                        : AssetImage('assets/trust.png'),
                                    height: 18,
                                    width: 20,
                                  ),
                                  3.sbw,
                                  Text(
                                    record.trusted_status == 0
                                        ? 'Untrusted'
                                        : 'Trusted',
                                    style: TextStyle(
                                      color: verify_status == "0"
                                          ? AppColors.blackColor
                                          : AppColors.verfirdColor,
                                      fontSize: 13,
                                      fontFamily: 'Metropolis',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Align(
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
                    ),
                    firstExhibitorImages.isNotEmpty
                        ? slider(firstExhibitorImages)
                        : SizedBox.shrink(),
                  ]),
                ));
          }
        },
      ),
    ));
  }

  bool hasMoreQuickNewsToLoad() {
    int itemsPerPage = 20;
    return exhibitor_data.length % itemsPerPage == 0;
  }

  Widget horiztallist() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
          shrinkWrap: false,
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: constanst.catdata.length,
          itemBuilder: (context, index) {
            cat.Result result = constanst.catdata[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Wrap(spacing: 6.0, runSpacing: 6.0, children: <Widget>[
                ChoiceChip(
                  label: Text(constanst.catdata[index].categoryName.toString()),
                  selected: _defaultChoiceIndex == index,
                  selectedColor: AppColors.blackColor,
                  onSelected: (bool selected) {
                    setState(() {
                      _defaultChoiceIndex = selected ? index : -1;
                      if (_defaultChoiceIndex == -1) {
                        category_id = result.categoryId.toString();
                        exhibitor_data.clear();
                        get_Exhibitorlist();
                      } else {
                        category_id = result.categoryId.toString();
                        exhibitor_data.clear();
                        get_Exhibitorlist();
                      }
                    });
                  },
                  backgroundColor: AppColors.greyBackground,
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf')
                      .copyWith(
                          color: _defaultChoiceIndex == index
                              ? Colors.white
                              : Colors.black),
                  showCheckmark: false,
                ),
              ]),
            );
          }),
    );
  }

  Widget slider(List firstExhibitorImages) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        GFCarousel(
          height: 210,
          autoPlay: true,
          pagerSize: 2.0,
          viewportFraction: 1.0,
          aspectRatio: 2,
          items: firstExhibitorImages.map(
            (url) {
              return Container(
                margin: const EdgeInsets.all(15.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                  child: CachedNetworkImage(
                    imageUrl: url.toString(),
                    fit: BoxFit.cover,
                    width: 2500.0,
                  ),
                ),
              );
            },
          ).toList(),
          onPageChanged: (index) {
            setState(() {
              getSliderIndex = index;
            });
          },
        ),
        Positioned(
          bottom: 20,
          child: SizedBox(
            height: 8,
            child: ListView.builder(
              itemCount: firstExhibitorImages.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: getSliderIndex == index
                        ? AppColors.primaryColor
                        : Colors.white,
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
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
        )),
        builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize:
                0.85, // Initial height as a fraction of screen height
            builder: (BuildContext context, ScrollController scrollController) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return const FilterScreen();
                },
              );
            })).then(
      (value) {
        category_id = constanst.select_categotyId.join(",");
        type_id = constanst.select_typeId.join(",");
        grade_id = constanst.select_gradeId.join(",");
        bussinesstype = constanst.selectbusstype_id.join(",");

        post_type = constanst.select_categotyType.join(",");
        coretype = constanst.selectcore_id.join(",");

        exhibitor_data.clear();

        get_Exhibitorlist();
        constanst.select_categotyId.clear();
        constanst.select_typeId.clear();
        constanst.select_gradeId.clear();
        constanst.selectbusstype_id.clear();
        constanst.select_categotyType.clear();
        coretype = constanst.selectcore_id.join(",");

        setState(() {});
      },
    );
  }
}
