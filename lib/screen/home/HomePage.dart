// ignore_for_file: unnecessary_null_comparison, empty_catches, non_constant_identifier_names, prefer_typing_uninitialized_variables, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/main.dart';
import 'package:Plastic4trade/model/GetCategory.dart' as cat;
import 'package:Plastic4trade/model/GetProductName.dart';
import 'package:Plastic4trade/model/getBannerImage.dart' as img;
import 'package:Plastic4trade/model/getHomePost.dart' as homepost;
import 'package:Plastic4trade/model/getHomePostSearch.dart' as homesearch;
import 'package:Plastic4trade/model/get_popup_banner_model.dart' as popup;
import 'package:Plastic4trade/screen/buyer_seller/Buyer_sell_detail.dart';
import 'package:Plastic4trade/screen/home/home_page_list.dart';
import 'package:Plastic4trade/screen/productmatch/product_match_home_screen.dart';
import 'package:Plastic4trade/screen/splash/splash_screen.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_api_google_plac_api.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/FilterScreen.dart';
import 'package:Plastic4trade/widget/custom_addFilter.dart';
import 'package:Plastic4trade/widget/custom_firebase_homepage.dart';
import 'package:Plastic4trade/widget/custom_location.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/widget/custom_search_input.dart';
import 'package:Plastic4trade/widget/customshimmer/custome_shimmer_loader.dart';
import 'package:android_id/android_id.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:Plastic4trade/model/GetProductName.dart' as pnm;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';
import '../../api/api_interface.dart';
import '../../constroller/GetCategoryController.dart';
import '../../utill/constant.dart';
import '../../widget/HomeAppbar.dart';
import '../../widget/MainScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0, _defaultChoiceIndex = -1;
  DateTime? currentBackPressTime;
  bool loadmore = false;
  String token = "";
  // Update
  String? version;
  AppUpdateInfo? _updateInfo;
  String? packageName;
  PackageInfo? packageInfo;
  final scrollercontroller = ScrollController();
  List<img.Result> banner_img = [];
  List<popup.Banner> popup_img = [];

  List<homepost.Result> homepost_data = [];
  List<homesearch.Result> homepostsearch_data = [];
  WebViewController? web_controller;
  int offset = 0;
  int count = 0;
  int getSliderIndex = 0;
  int getpopupSliderIndex = 0;

  late String lat = "";
  int appopencount = 0;
  String? location, search;
  late String log = "";
  String quicknews = "data";
  bool isload = false;
  bool _isLoaded = false;
  String? buttonLink;

  String category_filter_id = '',
      category_id = '""',
      grade_id = '',
      type_id = '',
      bussinesstype = '',
      coretype = '',
      post_type = '';
  final TextEditingController _loc = TextEditingController();
  final TextEditingController _search = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final PageController controller = PageController(initialPage: 0);
  int itemsToLoad = 15;
  bool apiCalled = false;
  late Timer _timer;
  Timer? _dialogTimer;
  bool isLoading = true;
  bool isDataNotFound = false;
  int step = 0;
  Future? getRalProductMatchFuture;

  String? deviceId;
  late SharedPreferences _pref;
  List<String> _suggestions = [];

  Future<void> _initializePreferences() async {
    _pref = await SharedPreferences.getInstance();
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    if (Platform.isAndroid) {
      try {
        final androidId = AndroidId();
        deviceId = await androidId.getId();
        print('Android Device ID: $deviceId');
      } on PlatformException {
        print('Failed to get Android Device ID.');
      }
    } else if (Platform.isIOS) {
      try {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor;
        print('iOS Device ID: $deviceId');
      } on PlatformException {
        print('Failed to get iOS Device ID.');
      }
    }

    if (deviceId != null) {
      await _pref.setString('device_id', deviceId.toString());
      print('Device ID saved: $deviceId');
    } else {
      print('Device ID is null.');
    }
  }

  void _clearSearch() {
    _search.clear();
    setState(() {});
    count = 0;
    offset = 0;
    homepost_data.clear();
    get_HomePost();
  }

  @override
  void initState() {
    super.initState();
    _initializeGoogleApiKey();
    _initializePreferences();

    GtmUtil.logScreenView('Home', 'Home');
    scrollercontroller.addListener(_scrollercontroller);
    if (!_isLoaded) {
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (getSliderIndex < banner_img.length - 1) {
          getSliderIndex++;
        } else {
          getSliderIndex = 0;
        }
        controller.animateToPage(
          getSliderIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      });
      _isLoaded = true;
    }

    constanst.catdata.clear();
    getPackage();
    get_HomePost();

    checkNetwork(context);

    get_PopUp_Slider();
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

  @override
  void dispose() {
    super.dispose();
    _dialogTimer?.cancel();
    scrollercontroller.removeListener(_scrollercontroller);
    controller.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _onbackpress(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.greyBackground,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
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
                                          location =
                                              place.description.toString();
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
                                        final geometry =
                                            detail.result.geometry!;
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
                            6.sbw,
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40.0)),
                                color: Colors.white,
                              ),
                              height: 40,
                              width: MediaQuery.of(context).size.width / 2.8,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    CustomSearchInput(
                                      onClear: _clearSearch,
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
                                        setState(() {});
                                        if (value.isEmpty) {
                                          WidgetsBinding.instance.focusManager
                                              .primaryFocus
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                          _search.text =
                                              suggestion.toUpperCase();
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
                                          ProductMatchHomeScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    slider_home(),
                    10.sbh,
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainScreen(3)),
                        );
                      },
                      child: isload
                          ? Shimmer.fromColors(
                              baseColor: AppColors.grayHighforshimmer,
                              highlightColor: Colors.grey[50]!,
                              child: Container(color: Colors.white),
                            )
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                height: 22,
                                child: Marquee(
                                  text: quicknews == null
                                      ? "No data available"
                                      : quicknews,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13.0,
                                    color: Colors.black,
                                  ),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 50.0,
                                  pauseAfterRound: const Duration(seconds: 1),
                                  startPadding: 10.0,
                                  accelerationDuration:
                                      const Duration(milliseconds: 300),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration:
                                      const Duration(milliseconds: 500),
                                  decelerationCurve: Curves.easeOut,
                                ),
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
                      isLoading ? postShimmerLoader(context) : category(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 20,
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
            Positioned(
              right: 0,
              bottom: 80,
              child: Container(
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
                    GtmUtil.logScreenView(
                        'List_Button_Home_Screen', 'homepagelist');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePageList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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

  Widget postShimmerLoader(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 8,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).size.width / 620,
      ),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return CustomShimmerLoader(width: 175, height: 200);
      },
    );
  }

  Widget category() {
    return FutureBuilder(
      future: getRalProductMatchFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('No Data Found'));
        }
        if (snapshot.connectionState == ConnectionState.none &&
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
                    print('Empty else branch triggered');
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

  bool categoryMatchtoLoad() {
    int itemsPerPage = 20;
    return homepost_data.length % itemsPerPage == 0 && homepost_data.isNotEmpty;
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo?.packageName;
    version = packageInfo?.version;

    if (Platform.isAndroid) {
      _checkForUpdate();
    } else if (Platform.isIOS) {
      _checkVersionAndNavigate();
    }
  }

// Android specific update check
  Future<void> _checkForUpdate() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();
      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        _performInAppUpdate();
      } else {
        checkNetwork(context);
      }
    } catch (e) {
      print("Error checking for update: $e");
      checkNetwork(context);
    }
  }

// Android specific update performance
  void _performInAppUpdate() async {
    try {
      final result = await InAppUpdate.performImmediateUpdate();
      if (result == AppUpdateResult.success) {
        // Update is complete, no further action needed
      } else if (result == AppUpdateResult.userDeniedUpdate) {
        final versionCheck = await checkVersion('android');
        if (versionCheck != null) {
          if (versionCheck.success == 1) {
            checkNetwork(context);
          } else if (versionCheck.success == 2) {
            Navigator.of(context).pop();
            _showUpdateDialogAndroid();
          }
        } else {
          // Handle null version check
        }
      } else if (result == AppUpdateResult.inAppUpdateFailed) {
        // Update failed, handle failure and proceed with checkNetwork
        checkNetwork(context);
      }
    } catch (e) {
      print("Failed to perform update: $e");
      checkNetwork(context); // In case of any error, call checkNetwork
    }
  }

  void _openGooglePlayStore() async {
    final String url =
        'https://play.google.com/store/apps/details?id=com.p4t.plastic4trade';

    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showUpdateDialogAndroid() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(22.0),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'assets/plastic4trade logo final.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Update Available!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 22),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'A new version of the app is available. Please update to continue.',
                          style: TextStyle(color: Colors.black45, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 140,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: AppColors.backgroundColor),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          exit(0);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      width: 140,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: AppColors.primaryColor),
                      child: TextButton(
                        onPressed: () {
                          if (Platform.isAndroid) {
                            _openGooglePlayStore();
                          }
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// iOS specific version check
  Future<void> _checkVersionAndNavigate() async {
    final versionCheck = await checkVersion('ios');
    if (versionCheck != null) {
      if (versionCheck.success == 1) {
        checkNetwork(context);
      } else if (versionCheck.success == 2) {
        _showUpdateDialog();
      }
    } else {
      // Handle null version check
    }
  }

// Show update dialog for iOS
  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(22.0),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'assets/plastic4trade logo final.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Update Available!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 22),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'A new version of the app is available. Please update to continue.',
                          style: TextStyle(color: Colors.black45, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 140,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: AppColors.backgroundColor),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          exit(0);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      width: 140,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: AppColors.primaryColor),
                      child: TextButton(
                        onPressed: () {
                          if (Platform.isIOS) {
                            _launchAppStore();
                          }
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Launch the App Store for iOS updates
  void _launchAppStore() async {
    const String appStoreUrl = 'https://itunes.apple.com/app/id6450507332';
    // ignore: deprecated_member_use
    if (await canLaunch(appStoreUrl)) {
      // ignore: deprecated_member_use
      await launch(appStoreUrl);
    } else {
      throw 'Could not launch $appStoreUrl';
    }
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

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 100) ==
        (scrollercontroller.position.maxScrollExtent - 100)) {
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

  Future<bool> _onbackpress(BuildContext context) async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      showDialog(
          context: context,
          builder: (context) {
            return CommanDialog(
              title: "App",
              content: "Do You Want Exit App?",
              onPressed: () {
                SystemNavigator.pop();
              },
            );
          });
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(true);
  }

  Widget exitConfirmationModal(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 125.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Plastic4trade - B2B Polymer",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Are You Sure You Want To Exit The App?",
              style: TextStyle(fontSize: 12.0),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(
                  "Okay",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget slider_home() {
    return Visibility(
      visible: banner_img.isNotEmpty ||
          isLoading, // Show only if there is data or still loading
      child: SizedBox(
        height: MediaQuery.of(context).size.width / 2,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: isLoading
                  ? Shimmer.fromColors(
                      baseColor: AppColors.grayHighforshimmer,
                      highlightColor: AppColors.grayLightforshimmer,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    )
                  : banner_img.isEmpty
                      ? SizedBox.shrink()
                      : PageView.builder(
                          controller: controller,
                          itemCount: banner_img.length,
                          itemBuilder: (context, index) {
                            img.Result record = banner_img[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: record.bannertype == 'image'
                                  ? GestureDetector(
                                      onTap: () {
                                        if (record.buttonLink == null ||
                                            record.buttonLink!.isEmpty) {
                                          showCustomToast("No URL found!");
                                        } else {
                                          launchUrl(
                                            Uri.parse(record.buttonLink!),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: record.bannerImage.toString(),
                                        fit: BoxFit.fill,
                                        width: 2500.0,
                                      ),
                                    )
                                  : web_view(record.bannerImage.toString()),
                            );
                          },
                          onPageChanged: (index) {
                            setState(() {
                              getSliderIndex = index;
                            });
                          },
                        ),
            ),
            if (banner_img.length > 1)
              Positioned(
                bottom: 10,
                right: 16,
                child: SizedBox(
                  height: 8,
                  child: ListView.builder(
                    itemCount: banner_img.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        width: getSliderIndex == index ? 14 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(3.5),
                          color: getSliderIndex == index
                              ? AppColors.primaryColor
                              : const Color(0xFFD9D9D9),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Show the slider dialog
  void showSliderDialog(BuildContext context) {
    int currentSliderIndex = 0;

    // Start the timer to auto-animate the slider
    _dialogTimer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      currentSliderIndex = (currentSliderIndex < popup_img.length - 1)
          ? currentSliderIndex + 1
          : 0;

      controller.animateToPage(
        currentSliderIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return TweenAnimationBuilder(
              tween: Tween<Offset>(
                begin: const Offset(1.0, 1.0),
                end: const Offset(0.3, 0.3),
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, Offset offset, child) {
                return Transform.translate(
                  offset: Offset(
                    offset.dx * MediaQuery.of(context).size.width * 0.5,
                    offset.dy * MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: child,
                );
              },
              child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      height: 480,
                      width: 80,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          PageView.builder(
                            controller: controller,
                            itemCount: popup_img.length,
                            itemBuilder: (context, index) {
                              final record = popup_img[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      record.bannerImage?.isNotEmpty == true
                                          ? record.bannerImage!
                                          : 'https://via.placeholder.com/150',
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                ),
                              );
                            },
                            onPageChanged: (index) {
                              setState(() {
                                currentSliderIndex = index;
                              });
                            },
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          if (popup_img.length > 1)
                            Positioned(
                              bottom: 10,
                              right: 16,
                              child: SizedBox(
                                height: 8,
                                child: ListView.builder(
                                  itemCount: popup_img.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width:
                                          currentSliderIndex == index ? 14 : 7,
                                      height: 7,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius:
                                            BorderRadius.circular(3.5),
                                        color: currentSliderIndex == index
                                            ? Colors.blue // Active dot color
                                            : const Color(
                                                0xFFD9D9D9), // Inactive dot color
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  })),
            );
          },
        );
      },
    ).then((_) {
      // Cancel the dialog timer when the dialog is closed
      _dialogTimer?.cancel();
    });
  }

  Widget? web_view(String imageurl) {
    web_controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(imageurl));
    return WebViewWidget(controller: web_controller as WebViewController);
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
        category_filter_id = constanst.select_categotyId.join(",");
        type_id = constanst.select_typeId.join(",");
        grade_id = constanst.select_gradeId.join(",");

        post_type = constanst.select_categotyType.join(",");
        bussinesstype = constanst.selectbusstype_id.join(",");
        coretype = constanst.selectcore_id.join(",");

        homepost_data.clear();

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

  void get_categorylist() async {
    GetCategoryController bt = GetCategoryController();
    constanst.cat_data = bt.setlogin();

    constanst.cat_data!.then((value) {
      setState(() {
        for (var item in value) {
          constanst.catdata.add(item);
        }
      });
    });
  }

  // Fetch and display the pop-up slider data
  Future<void> get_PopUp_Slider() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';

    try {
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }
      print('Device Name: $device');

      String? userId = pref.getString('user_id');
      String? apiToken = pref.getString('userToken');
      print('User ID: ${userId ?? "not found"}');
      print('API Token: ${apiToken ?? "not found"}');

      // Check for missing userId or apiToken
      if (userId == null || apiToken == null) {
        print('Error: User ID or API Token is null');
        // showCustomToast('User ID or API Token is missing');
        return;
      }

      var res = await getpopupSlider(userId, apiToken, device);
      print('Response from getpopupSlider: ${res.toString()}');

      if (res == null || res['status'] == 0) {
        print('Error: ${res['message'] ?? "Unknown error"}');
        showCustomToast(res['message'] ?? "Unknown error");
        return;
      }

      if (res['status'] == 1 && res['result'] != null) {
        setState(() {
          var jsonarray = res['result'];

          // Clear existing popup_img to prevent duplicates
          popup_img.clear();

          for (var data in jsonarray) {
            if (data['bannertype'] == null || data['BannerImage'] == null) {
              print('Error: Missing data fields in banner: ${data.toString()}');
              continue;
            }

            popup.Banner record = popup.Banner(
              bannertype: data['bannertype'],
              bannerImage: data['BannerImage'],
              buttonLink: data['ButtonLink'],
            );
            popup_img.add(record);
          }

          // Open dialog only once after all banners are added
          if (popup_img.isNotEmpty) {
            showSliderDialog(context);
          }
        });
      } else {
        print('Error: ${res['message'] ?? "Unknown error"}');
      }
    } catch (e, stacktrace) {
      print('Exception occurred: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  get_Slider() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';

    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }

    String userId = pref.getString('user_id').toString();
    String apiToken = pref.getString('userToken').toString();

    var res = await getSlider(
      userId,
      apiToken,
      device,
      context,
    );

    if (res['status'] == 1 && res['result'] != null) {
      var jsonarray = res['result'];

      setState(() {
        if (jsonarray.isEmpty) {
          banner_img.clear();
        } else {
          banner_img.clear();
          for (var data in jsonarray) {
            img.Result record = img.Result(
              bannertype: data['bannertype'],
              bannerImage: data['BannerImage'],
              buttonLink: data['ButtonLink'],
            );
            banner_img.add(record);
          }
        }
        isLoading = false;
      });
    } else {
      setState(() {
        banner_img.clear();
        isLoading = false;
      });
      // showCustomToast(res['message']);
    }
  }

  getquicknews() async {
    setState(() {
      isload = true;
    });

    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    var res = await gethomequicknew(device);

    setState(() {
      isload = false;
    });

    setState(() {
      if (res['status'] == 1) {
        quicknews = res['result'];
      } else {
        showCustomToast(res['message']);
      }
    });

    if (res['status'] == 1) {
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(quicknews)));
      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
    }
  }

  Future<void> get_HomePost() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String? userId = pref.getString('user_id');
    String? apiToken = pref.getString('userToken');

    String device =
        Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : '');
    print('Device Name: $device');

    setState(() {
      loadmore = false;
    });

    var res = await getHome_Post(
      userId.toString(),
      apiToken.toString(),
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
      constanst.email_verified = res['email_verified'] ?? false;
      print('Email Verified: ${constanst.email_verified}');
      constanst.step = res['users']?['step_counter'] ?? 0;
      print('Step Counter: ${constanst.step}');
      setState(() {
        for (var data in res['result']) {
          homepost_data.add(
            homepost.Result(
              postName: data['PostName'],
              categoryName: data['CategoryName'],
              productGrade: data['ProductGrade'],
              currency: data['Currency'],
              productPrice: data['ProductPrice'],
              state: data['State'],
              country: data['Country'],
              postType: data['PostType'],
              isPaidPost: data['is_paid_post'],
              productId: data['productId'],
              productType: data['ProductType'],
              mainproductImage: data['mainproductImage'],
            ),
          );
        }
        loadmore = true;
      });
    } else {
      setState(() {
        loadmore = true;
      });
      showCustomToast('No Data Found');
    }
  }

  getHomePostWithoutLogin() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await homePostWithoutLogin(
      device,
    );

    print("RESPONSE CODE === ${res['status']}");

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
          homepost.Result record = homepost.Result(
              postName: data['PostName'],
              categoryName: data['CategoryName'],
              productGrade: data['ProductGrade'],
              currency: data['Currency'],
              productPrice: data['ProductPrice'],
              state: data['State'],
              country: data['Country'],
              postType: data['PostType'],
              isPaidPost: data['is_paid_post'],
              productId: data['productId'],
              productType: data['ProductType'],
              mainproductImage: data['mainproductImage']);

          homepost_data.add(record);
          loadmore = true;
        }
        setState(() {});
      }
    } else {
      showCustomToast(res['message']);
    }
    return jsonArray;
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

  Future<void> checkNetwork(BuildContext context) async {
    print("Checking network connectivity...");

    final connectivityResult = await Connectivity().checkConnectivity();
    print("Connectivity Result: $connectivityResult");

    SharedPreferences pref = await SharedPreferences.getInstance();
    print("SharedPreferences instance obtained.");

    if (connectivityResult == ConnectivityResult.none) {
      print("No internet connection.");
      showCustomToast('Internet Connection not available');
    } else {
      bool? isWithoutLogin = pref.getBool('isWithoutLogin');
      print("isWithoutLogin: $isWithoutLogin");

      if (isWithoutLogin == true) {
        print("Fetching data without login...");
        getHomePostWithoutLogin();
        get_categorylist();
        getquicknews();
        get_Slider();
        get_product_name();
      } else {
        try {
          print("Fetching data for logged-in user...");
          get_categorylist();
          get_Slider();
          getquicknews();
          get_product_name();

          print("Initializing Firebase...");
          FirebaseInitializer firebaseInitializer =
              FirebaseInitializer(context);
          await firebaseInitializer.initializeFirebase();
          print("Firebase initialized successfully.");
        } catch (e) {
          print("Error encountered: $e");
          print("Redirecting to SplashScreen...");

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
