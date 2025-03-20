import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/model/GetCategory.dart' as cat;

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/constroller/GetCategoryController.dart';
import 'package:Plastic4trade/constroller/Getmybusinessprofile.dart';
import 'package:Plastic4trade/model/GetProductName.dart';
import 'package:Plastic4trade/screen/buyer_seller/Buyer_sell_detail.dart';
import 'package:Plastic4trade/screen/productmatch/product_match_seller_list.dart';

import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_api_google_plac_api.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/FilterScreen.dart';
import 'package:Plastic4trade/widget/HomeAppbar.dart';
import 'package:Plastic4trade/widget/custom_addFilter.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_chat_shimmer_loader.dart';
import 'package:Plastic4trade/widget/custom_location.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/widget/custom_search_input.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:Plastic4trade/model/getSalePost.dart' as salepost;
import 'package:Plastic4trade/model/getHomePostSearch.dart' as homesearch;
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:Plastic4trade/model/GetProductName.dart' as pnm;

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalePostList extends StatefulWidget {
  const SalePostList({super.key});

  @override
  State<SalePostList> createState() => _SalePostListState();
}

class _SalePostListState extends State<SalePostList> {
  int selectedIndex = 0, _defaultChoiceIndex = -1;
  List<salepost.Result> salepost_data = [];
  bool loadmore = false;
  final scrollercontroller = ScrollController();
  late String lat = "";
  String? location, search;
  late String log = "",
      category_filter_id = '',
      category_id = '""',
      grade_id = '',
      type_id = '',
      bussinesstype = '',
      coretype = '',
      post_type = '';
  List<homesearch.Result> homepostsearch_data = [];

  final TextEditingController _loc = TextEditingController();
  final TextEditingController _search = TextEditingController();
  int offset = 0;
  int count = 0;
  bool isload = false;
  FocusNode nodeOne = FocusNode();
  bool isLoading = true;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _initializeGoogleApiKey();

    scrollercontroller.addListener(_scrollercontroller);
    Clear_date();
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

  @override
  void dispose() {
    super.dispose();
    scrollercontroller.removeListener(_scrollercontroller);
    dispose();
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
      salepost_data.clear();
      offset = 0;
    });
    await get_salePost();
    setState(() {
      loadmore = true;
    });
    showCustomToast('Data refreshed');
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
      appBar: CustomeApp('LiveSeller'),
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40.0)),
                                color: Colors.white,
                              ),
                              height: 40,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                                    salepost_data.clear();
                                    get_salePost();
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
                                      salepost_data.clear();
                                      count = 0;
                                      offset = 0;
                                      WidgetsBinding
                                          .instance.focusManager.primaryFocus
                                          ?.unfocus();
                                      get_salePost();
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
                                      count = 0;
                                      offset = 0;
                                      salepost_data.clear();
                                      get_salePost();
                                      setState(() {});
                                    },
                                    controller: _search,
                                    onSubmitted: (value) {
                                      WidgetsBinding
                                          .instance.focusManager.primaryFocus
                                          ?.unfocus();
                                      salepost_data.clear();
                                      count = 0;
                                      offset = 0;
                                      get_salePost();
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
                                        salepost_data.clear();
                                        get_salePost();
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
                                      salepost_data.clear();
                                      count = 0;
                                      offset = 0;
                                      await get_salePost();
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
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: IconButton(
                              icon: Image.asset(
                                'assets/match.png',
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductMatchSellerList(),
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
                  if (index < salepost_data.length) {
                    salepost.Result result = salepost_data[index];
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
                        color: const Color(0xFFFFFFFF),
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
                childCount: salepost_data.length + 1,
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
        future: constanst.cat_data,
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
                    children: [
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
                              salepost_data.clear();
                              get_salePost();
                            } else {
                              category_filter_id = result.categoryId.toString();
                              salepost_data.clear();
                              get_salePost();
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
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  ViewItem(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          // <-- SEE HERE
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
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

        salepost_data.clear();

        get_salePost();
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

  get_salePost() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getSale_Post(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      '20',
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
    var jsonarray;

    if (res['status'] == 1) {
      jsonarray = res['result'];

      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonarray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      for (var data in jsonarray) {
        salepost.Result record = salepost.Result(
          postName: data['PostName'],
          categoryName: data['CategoryName'],
          productGrade: data['ProductGrade'],
          currency: data['Currency'],
          productPrice: data['ProductPrice'],
          postQuntity: data['PostQuntity'],
          state: data['State'],
          country: data['Country'],
          postType: data['PostType'],
          productId: data['productId'],
          isPaidPost: data['is_paid_post'],
          productType: data['ProductType'],
          mainproductImage: data['mainproductImage'],
        );
        salepost_data.add(record);
        loadmore = true;
      }
      isload = true;
      setState(() {});
    } else {
      showCustomToast(res['message']);
    }
    return jsonarray;
  }

  Clear_date() {
    constanst.catdata.clear();
  }

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 50) ==
        (scrollercontroller.position.maxScrollExtent - 50)) {
      loadmore = false;
      if (salepost_data.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        get_salePost();
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

  get_HomePostSearch() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getsaleSearch_Post(
      lat.toString(),
      log.toString(),
      _search.text.toString(),
      '20',
      offset.toString(),
      device,
    );
    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        jsonArray = res['result'];

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

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      if (pref.getBool('isWithoutLogin') == true) {
        get_categorylist();
        getSalePostWithoutLogin();
        get_product_name();
      } else {
        get_categorylist();
        getBussinessProfile();
        get_salePost();
        get_product_name();
      }
    }
  }

  void get_categorylist() async {
    GetCategoryController bt = GetCategoryController();
    constanst.cat_data = bt.setlogin();

    constanst.cat_data!.then((value) {
      for (var item in value) {
        constanst.catdata.add(item);
      }

      setState(() {});
    });
  }

  getBussinessProfile() async {
    GetmybusinessprofileController bt = GetmybusinessprofileController();
    SharedPreferences pref = await SharedPreferences.getInstance();
    constanst.getmyprofile = bt.Getmybusiness_profile(
      userId: pref.getString('user_id').toString(),
      apiToken: pref.getString('userToken').toString(),
      context: context,
      profileId: pref.getString('user_id').toString(),
    );
  }

  getSalePostWithoutLogin() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await sellPostWithoutLogin(
      device,
    );

    var jsonarray;

    if (res['status'] == 1) {
      jsonarray = res['result'];

      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonarray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      for (var data in jsonarray) {
        salepost.Result record = salepost.Result(
            postName: data['PostName'],
            categoryName: data['CategoryName'],
            productGrade: data['ProductGrade'],
            currency: data['Currency'],
            productPrice: data['ProductPrice'],
            state: data['State'],
            country: data['Country'],
            postType: data['PostType'],
            productId: data['productId'],
            isPaidPost: data['is_paid_post'],
            productType: data['ProductType'],
            mainproductImage: data['mainproductImage']);
        salepost_data.add(record);
        loadmore = true;
      }
      isload = true;
      setState(() {});
    } else {
      showCustomToast(res['message']);
    }
    return jsonarray;
  }
}
