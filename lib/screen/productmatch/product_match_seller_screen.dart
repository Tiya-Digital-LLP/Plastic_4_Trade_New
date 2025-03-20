import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/model/GetProductName.dart';
import 'package:Plastic4trade/model/getHomePost.dart' as homepost;
import 'package:Plastic4trade/model/GetCategory.dart' as cat;
import 'package:Plastic4trade/model/GetProductName.dart' as pnm;

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/screen/buyer_seller/Buyer_sell_detail.dart';
import 'package:Plastic4trade/screen/productmatch/product_match_seller_list.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/FilterScreen.dart';
import 'package:Plastic4trade/widget/HomeAppbar.dart';
import 'package:Plastic4trade/widget/custom_location.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/widget/custom_search_input.dart';
import 'package:Plastic4trade/widget/customshimmer/custome_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_api_headers/google_api_headers.dart';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductMatchSellerScreen extends StatefulWidget {
  const ProductMatchSellerScreen({super.key});

  @override
  State<ProductMatchSellerScreen> createState() =>
      _ProductMatchSellerScreenState();
}

class _ProductMatchSellerScreenState extends State<ProductMatchSellerScreen> {
  int count = 0;
  int offset = 0;
  bool isload = false;
  bool isLoading = true;
  bool loadmore = false;
  List<homepost.Result> homepost_data = [];
  final scrollercontroller = ScrollController();
  int selectedIndex = 0, _defaultChoiceIndex = -1;
  String category_filter_id = '',
      category_id = '""',
      grade_id = '',
      type_id = '',
      bussinesstype = '',
      coretype = '',
      post_type = '';
  final TextEditingController _loc = TextEditingController();
  final TextEditingController _search = TextEditingController();
  String? location, search;
  Future? getRalProductMatchFuture;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    scrollercontroller.addListener(_scrollercontroller);
    get_product_name();

    getProduct_Match();
    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  Widget productMatchShimmerLoader(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
        childAspectRatio: MediaQuery.of(context).size.width / 610,
      ),
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 2,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return CustomShimmerLoader(
          width: 175,
          height: 200,
        );
      },
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      homepost_data.clear();
      offset = 0;
    });

    await getProduct_Match();

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

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 50) ==
        (scrollercontroller.position.maxScrollExtent - 50)) {
      if (homepost_data.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        getRalProductMatchFuture = getProduct_Match();
      } else {
        showCustomToast('No more data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: CustomeApp(
        'Product Match',
      ),
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
                                    getProduct_Match();
                                    setState(() {});
                                  },
                                  onTap: () async {
                                    GtmUtil.logScreenView(
                                        'Location_by_home', 'Locationbyhome');
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
                                      getProduct_Match();
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
                            width: MediaQuery.of(context).size.width / 2.2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: CustomSearchInput(
                                onClear: () {
                                  _search.clear();
                                  count = 0;
                                  offset = 0;
                                  homepost_data.clear();
                                  getProduct_Match();
                                  setState(() {});
                                },
                                controller: _search,
                                onSubmitted: (value) {
                                  WidgetsBinding
                                      .instance.focusManager.primaryFocus
                                      ?.unfocus();
                                  homepost_data.clear();
                                  count = 0;
                                  offset = 0;
                                  getProduct_Match();
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
                                    getProduct_Match();
                                    setState(() {});
                                  }
                                },
                                suggestionsCallback: (pattern) {
                                  return _getSuggestions(pattern);
                                },
                                itemBuilder: (context, suggestion) {
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.5,
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
                                  await getProduct_Match();
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          6.sbw,
                          GestureDetector(
                            onTap: () {
                              GtmUtil.logScreenView(
                                  'Filter_Home', 'filterhome');
                              ViewItem(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 10.2,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    isLoading
                        ? productMatchShimmerLoader(context)
                        : categoryProductMatch(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(100)),
        child: IconButton(
          icon: Icon(
            Icons.list,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            GtmUtil.logScreenView('List_Button_Home_Screen', 'homepagelist');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductMatchSellerList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget categoryProductMatch() {
    return FutureBuilder(
      future: getRalProductMatchFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('No Product Match Found'));
        }
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
        } else {
          return SizedBox(
            // Replace Expanded with SizedBox
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 0.0,
                childAspectRatio: MediaQuery.of(context).size.width / 610,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: homepost_data.isEmpty ? 1 : homepost_data.length + 2,
              itemBuilder: (context, index) {
                if (index < homepost_data.length) {
                  homepost.Result result = homepost_data[index];
                  return GestureDetector(
                    onTap: (() async {
                      GtmUtil.logScreenView(
                        'Similar_Post_Open_Buyer_seller',
                        'similarpost',
                      );
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: 170,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: result.isPaidPost == 'Paid'
                                          ? Colors.red
                                          : Colors.transparent,
                                      width:
                                          result.isPaidPost == 'Paid' ? 2.5 : 0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          result.mainproductImage.toString(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Container(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 5.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.greenWithShade,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.0)),
                                    ),
                                    child: Text(
                                      '${result.currency}${result.productPrice}',
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w800,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                if (result.isPaidPost == 'Paid')
                                  Positioned(
                                    top: -20,
                                    left: -25,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Image.asset(
                                        'assets/PaidPost.png',
                                        height: 90,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.postName.toString(),
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontFamily:
                                        'assets/fonst/Metropolis-SemiBold.otf',
                                  ),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  '${result.categoryName} | ${result.productGrade}',
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.grey,
                                    fontFamily: 'Metropolis',
                                  ),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  '${result.state}, ${result.country}',
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.grey,
                                    fontFamily: 'Metropolis',
                                  ),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5.0),
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
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (index == homepost_data.length ||
                    index == homepost_data.length + 1) {
                  if (categoryMatchtoLoad()) {
                    return CustomShimmerLoader(
                      width: 175,
                      height: 200,
                    );
                  } else {
                    return SizedBox();
                  }
                } else {
                  return CustomShimmerLoader(
                    width: 175,
                    height: 200,
                  );
                }
              },
            ),
          );
        }
      },
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
        )),
        builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.90,
            minChildSize: 0.25,
            maxChildSize: 0.90,
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

        getProduct_Match();
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
                                      GtmUtil.logScreenView(
                                        'Search_by_category_home',
                                        'CategoryHome',
                                      );

                                      _defaultChoiceIndex =
                                          selected ? index : -1;
                                      if (_defaultChoiceIndex == -1) {
                                        category_filter_id = "";
                                        homepost_data.clear();
                                        getProduct_Match();
                                      } else {
                                        category_filter_id =
                                            result.categoryId.toString();
                                        homepost_data.clear();
                                        getProduct_Match();
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

  bool categoryMatchtoLoad() {
    int itemsPerPage = 20;
    return homepost_data.length % itemsPerPage == 0 && homepost_data.isNotEmpty;
  }

  getProduct_Match() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await get_Product_Match_seller(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      category_id,
      category_filter_id,
      type_id,
      grade_id,
      'SalePost',
      bussinesstype,
      coretype,
      constanst.lat,
      constanst.log,
      _search.text.toString(),
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
        homepost.Result record = homepost.Result(
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
          mainproductImage: data['mainproductImage'],
        );
        homepost_data.add(record);
        loadmore = true;
      }
      isload = true;
      setState(() {});
    } else {
      showCustomToast(res['message']);
    }
    return jsonarray;
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
}
