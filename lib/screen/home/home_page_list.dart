import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/model/GetProductName.dart';
import 'package:Plastic4trade/screen/productmatch/product_match_home_list.dart';
import 'package:Plastic4trade/utill/custom_api_google_plac_api.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/model/GetCategory.dart' as cat;
import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/main.dart';
import 'package:Plastic4trade/screen/buyer_seller/Buyer_sell_detail.dart';
import 'package:Plastic4trade/model/GetProductName.dart' as pnm;

import 'package:Plastic4trade/screen/splash/splash_screen.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/FilterScreen.dart';
import 'package:Plastic4trade/widget/HomeAppbar.dart';
import 'package:Plastic4trade/widget/custom_addFilter.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_chat_shimmer_loader.dart';
import 'package:Plastic4trade/widget/custom_firebase_homepage.dart';
import 'package:Plastic4trade/widget/custom_location.dart';
import 'package:Plastic4trade/widget/custom_search_input.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter/material.dart';
import 'package:Plastic4trade/model/getBannerImage.dart' as img;
import 'package:Plastic4trade/model/getHomePost.dart' as homepost;
import 'package:Plastic4trade/model/getHomePostSearch.dart' as homesearch;
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageList extends StatefulWidget {
  const HomePageList({super.key});

  @override
  State<HomePageList> createState() => _HomePageListState();
}

class _HomePageListState extends State<HomePageList> {
  int selectedIndex = 0, _defaultChoiceIndex = -1;

  bool loadmore = false;

  final scrollercontroller = ScrollController();
  List<img.Result> banner_img = [];
  List<homepost.Result> homepost_data = [];
  List<homesearch.Result> homepostsearch_data = [];
  int offset = 0;
  int count = 0;
  int getSliderIndex = 0;
  late String lat = "";
  int appopencount = 0;
  String? location, search;
  late String log = "";
  String quicknews = "data";
  bool isload = false;
  List<String> _suggestions = [];

  String category_filter_id = '',
      category_id = '""',
      grade_id = '',
      type_id = '',
      bussinesstype = '',
      coretype = '',
      post_type = '';
  bool isLoading = true;

  final TextEditingController _loc = TextEditingController();
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeGoogleApiKey();
    scrollercontroller.addListener(_scrollercontroller);
    constanst.catdata;
    checkNetwork(context);
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

  @override
  void dispose() {
    super.dispose();
    scrollercontroller.removeListener(_scrollercontroller);
  }

  Future<void> _refreshData() async {
    setState(() {
      constanst.select_categotyId.clear();
      constanst.select_typeId.clear();
      constanst.select_gradeId.clear();
      constanst.select_categotyType.clear();
      constanst.selectbusstype_id.clear();
      constanst.selectcore_id.clear();
      constanst.lat = "";
      constanst.log = "";
      homepost_data.clear();
      offset = 0;
    });

    await get_HomePost();

    setState(() {
      loadmore = true;
    });

    showCustomToast('Data Refreshed');
    scrollercontroller.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: CustomeApp('LiveHome'),
      body: RefreshIndicator(
        backgroundColor: AppColors.primaryColor,
        color: AppColors.backgroundColor,
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: scrollercontroller,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  horiztallist(),
                  5.sbh,
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40.0)),
                                color: Colors.white,
                              ),
                              height: 40,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: CustomLocationInput(
                                  controller: _loc,
                                  prefixIcon: Icons.location_on_outlined,
                                  suffixIcon: Icons.clear,
                                  onClear: () {
                                    _loc.clear();
                                    count = 0;
                                    offset = 0;
                                    constanst.lat = "";
                                    constanst.log = "";
                                    homepost_data.clear();
                                    get_HomePost();
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
                                            await const GoogleApiHeaders()
                                                .getHeaders(),
                                      );
                                      String placeid = place.placeId ?? "0";
                                      final detail = await plist
                                          .getDetailsByPlaceId(placeid);
                                      final geometry = detail.result.geometry!;
                                      constanst.lat =
                                          geometry.location.lat.toString();
                                      constanst.log =
                                          geometry.location.lng.toString();
                                      homepost_data.clear();
                                      count = 0;
                                      offset = 0;
                                      WidgetsBinding
                                          .instance.focusManager.primaryFocus
                                          ?.unfocus();
                                      get_HomePost();
                                      setState(() {});
                                    }
                                  },
                                  onChanged: (value) {},
                                  hintText: 'Location',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0)),
                              color: Colors.white,
                            ),
                            height: 40,
                            width: MediaQuery.of(context).size.width / 2.8,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Stack(
                                children: [
                                  CustomSearchInput(
                                    onClear: () {
                                      _search.clear();
                                      setState(() {});
                                      count = 0;
                                      offset = 0;
                                      homepost_data.clear();
                                      get_HomePost();
                                    },
                                    controller: _search,
                                    onSubmitted: (value) {
                                      WidgetsBinding
                                          .instance.focusManager.primaryFocus
                                          ?.unfocus();
                                      homepost_data.clear();
                                      count = 0;
                                      offset = 0;
                                      get_HomePost();
                                      setState(() {});
                                    },
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        WidgetsBinding
                                            .instance.focusManager.primaryFocus
                                            ?.unfocus();
                                        _search.clear();
                                        count = 0;
                                        offset = 0;
                                        homepost_data.clear();
                                        get_HomePost();
                                        setState(() {});
                                      }
                                    },
                                    suggestionsCallback: (pattern) {
                                      return _getSuggestions(pattern);
                                    },
                                    itemBuilder: (context, suggestion) {
                                      return SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.5,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  suggestion,
                                                  style: const TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                    fontFamily:
                                                        'assets/fonst/Metropolis-Black.otf',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    onSuggestionSelected: (suggestion) async {
                                      if (suggestion.length > 40) {
                                        showCustomToast(
                                            'Product name cannot exceed 40 characters');
                                        _search.text = suggestion
                                            .substring(0, 40)
                                            .toUpperCase();
                                      } else {
                                        _search.text = suggestion.toUpperCase();
                                      }
                                      WidgetsBinding
                                          .instance.focusManager.primaryFocus
                                          ?.unfocus();
                                      homepost_data.clear();
                                      count = 0;
                                      offset = 0;
                                      await get_HomePost();
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              ViewItem(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 11.2,
                              height: 40,
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
                          3.sbw,
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width / 10.2,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(100)),
                            child: IconButton(
                              icon: Image.asset(
                                'assets/match.png',
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductMatchHomeList(),
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
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < homepost_data.length) {
                    homepost.Result result = homepost_data[index];
                    return GestureDetector(
                      onTap: (() async {
                        constanst.productId = result.productId.toString();
                        constanst.post_type = result.postType.toString();
                        constanst.redirectpage = "sale_buy";
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        if (pref.getBool('isWithoutLogin') == true) {
                          showLoginDialog(context);
                          return;
                        }
                        print("Current step before switch: ${constanst.step}");
                        switch (constanst.step) {
                          case 3:
                            showEmailDialog(context);
                            break;
                          case 5:
                            showInformationDialog(context);
                            break;
                          case 6:
                          case 7:
                          case 8:
                            categoryDialog(context);
                            break;
                          case 9:
                            addPostDialog(context);
                            break;
                          case 10:
                            addPostDialog(context);
                            break;
                          case 11:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Buyer_sell_detail(
                                  prod_id: result.productId.toString(),
                                  post_type: result.postType.toString(),
                                ),
                              ),
                            );
                            break;
                          default:
                            print("Unexpected value: ${constanst.step}");
                            break;
                        }
                      }),
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.05),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13.0),
                            border: Border.all(
                              color: result.isPaidPost == 'Paid'
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3, // 60%
                                      child: Text(
                                        '${result.postName}',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                          fontFamily:
                                              'assets/fonst/Metropolis-SemiBold.otf',
                                        ),
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1, // 20%
                                      child: Text(
                                        'Price: ${result.currency}${result.productPrice}',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                          fontFamily:
                                              'assets/fonst/Metropolis-SemiBold.otf',
                                        ),
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1, // 20%
                                      child: Text(
                                        'Qty: ${result.postQuntity}',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                          fontFamily:
                                              'assets/fonst/Metropolis-SemiBold.otf',
                                        ),
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${result.categoryName} | ${result.productType} | ${result.productGrade}',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                          fontFamily:
                                              'assets/fonst/Metropolis-SemiBold.otf',
                                        ),
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      result.postType.toString() == "BuyPost"
                                          ? "Buy Post"
                                          : "Sell Post",
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontFamily: 'Metropolis',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.greenWithShade,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return ChatShimmerLoader(
                      width: 175,
                      height: 100,
                    );
                  }
                },
                childCount: homepost_data.length + 1,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 16,
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(100)),
              child: CustomAddButton(
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _getSuggestions(String query) async {
    if (query.isEmpty) {
      return Future.value(_suggestions);
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

    return Future.value(matches);
  }

  Future get_product_name() async {
    GetProductName getdir = GetProductName();
    var res = await get_productname();
    getdir = GetProductName.fromJson(res);
    List<pnm.Result>? results = getdir.result;
    if (results != null) {
      _suggestions = [];
      _suggestions = results.map((result) => result.productName ?? "").toList();
      return _suggestions;
    } else {
      return [];
    }
  }

  Widget horiztallist() {
    return Container(
        height: 50,
        color: Colors.white,
        child: FutureBuilder(
            future: TickerFuture.complete(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.none &&
                  // ignore: unnecessary_null_comparison
                  snapshot.hasData == null) {
                return Center(
                  child: CustomLottieContainer(
                    child: Lottie.asset(
                      'assets/loading_animation.json',
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return ListView.builder(
                    shrinkWrap: false,
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: constanst.catdata.length,
                    itemBuilder: (context, index) {
                      cat.Result result = constanst.catdata[index];
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Wrap(
                              spacing: 6.0,
                              runSpacing: 6.0,
                              children: <Widget>[
                                ChoiceChip(
                                  label: Text(constanst
                                      .catdata[index].categoryName
                                      .toString()),
                                  selected: _defaultChoiceIndex == index,
                                  selectedColor: AppColors.blackColor,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _defaultChoiceIndex =
                                          selected ? index : -1;
                                      if (_defaultChoiceIndex == -1) {
                                        category_filter_id = "";
                                        homepost_data.clear();
                                        get_HomePost();
                                      } else {
                                        category_filter_id =
                                            result.categoryId.toString();
                                        homepost_data.clear();
                                        get_HomePost();
                                      }
                                    });
                                  },
                                  backgroundColor: AppColors.greyBackground,
                                  side: BorderSide.none,
                                  labelStyle: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf')
                                      .copyWith(
                                    color: _defaultChoiceIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  showCheckmark: false,
                                  // checkmarkColor: AppColors.backgroundColor,
                                ),
                              ]));
                    });
              }
            }));
  }

  ViewItem(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          // <-- SEE HERE
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        )),
        builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            builder: (BuildContext context, ScrollController scrollController) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return const FilterScreen();
                },
              );
            })).then(
      (value) {
        _loc.text = constanst.location.toString();
        category_filter_id = constanst.select_categotyId.join(",");
        type_id = constanst.select_typeId.join(",");
        grade_id = constanst.select_gradeId.join(",");

        post_type = constanst.select_categotyType.join(",");
        bussinesstype = constanst.selectbusstype_id.join(",");
        coretype = constanst.selectcore_id.join(",");

        homepost_data.clear();
        // _onLoading();

        get_HomePost();
        constanst.select_categotyId.clear();
        constanst.select_typeId.clear();
        constanst.select_gradeId.clear();
        constanst.select_categotyType.clear();
        constanst.selectbusstype_id.clear();
        constanst.selectcore_id.clear();

        setState(() {});
      },
    );
  }

  Future<void> get_HomePost() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device =
        Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : '');
    print('Device Name: $device');
    var res = await getHome_Post(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      category_filter_id,
      type_id,
      grade_id,
      post_type,
      bussinesstype,
      coretype,
      constanst.lat,
      constanst.log,
      _search.text.toString(),
      device,
      context,
    );

    if (res['status'] == 1) {
      var jsonArray = res['result'];
      print('filter data: $res');

      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      for (var data in jsonArray) {
        homepost.Result record = homepost.Result(
          postName: data['PostName'],
          categoryName: data['CategoryName'],
          productGrade: data['ProductGrade'],
          currency: data['Currency'],
          productPrice: data['ProductPrice'],
          postQuntity: data['PostQuntity'],
          state: data['State'],
          country: data['Country'],
          postType: data['PostType'],
          isPaidPost: data['is_paid_post'],
          productId: data['productId'],
          productType: data['ProductType'],
          mainproductImage: data['mainproductImage'],
        );
        homepost_data.add(record);
      }
      setState(() {
        loadmore = true;
      });
    } else {
      showCustomToast('No Data Found');
    }
  }

  get_HomePostSearch() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getHomeSearch_Post(
      lat.toString(),
      log.toString(),
      _search.text.toString(),
      '20',
      offset.toString(),
      device,
      context,
    );

    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        jsonArray = res['result'];

        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');

        for (var data in jsonArray) {
          homesearch.Result record = homesearch.Result(
              postName: data['PostName'],
              categoryName: data['CategoryName'],
              productGrade: data['ProductGrade'],
              currency: data['Currency'],
              productPrice: data['ProductPrice'],
              state: data['State'],
              country: data['Country'],
              postType: data['PostType'],
              isPaidPost: data['is_paid_post'],
              productType: data['ProductType'],
              productId: data['productId'],
              mainproductImage: data['mainproductImage']);
          homepostsearch_data.add(record);
          loadmore = true;
        }
        setState(() {});
      }
    } else {
      showCustomToast(res['message']);
    }
    return jsonArray;
  }

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 50) ==
        (scrollercontroller.position.maxScrollExtent - 50)) {
      loadmore = false;
      if (homepost_data.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        get_HomePost();
      } else if (homepostsearch_data.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        get_HomePostSearch();
      }
    }
  }

  Future<void> checkNetwork(BuildContext context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    SharedPreferences pref;

    try {
      pref = await SharedPreferences.getInstance();
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SplashScreen(
            analytics: MyApp.analytics,
            observer: MyApp.observer,
          ),
        ),
      );
      return;
    }

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      if (pref.getBool('isWithoutLogin') == true) {
      } else {
        try {
          _loc.text = constanst.location.toString();
          constanst.step = int.parse(pref.getString('step').toString());
          get_HomePost();
          get_product_name();

          FirebaseInitializer firebaseInitializer =
              FirebaseInitializer(context);
          await firebaseInitializer.initializeFirebase();
        } catch (e) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SplashScreen(
                analytics: MyApp.analytics,
                observer: MyApp.observer,
              ),
            ),
          );
          return;
        }
      }
    }
  }
}
