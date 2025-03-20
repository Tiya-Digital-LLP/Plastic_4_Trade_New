// ignore_for_file: non_constant_identifier_names, camel_case_types, must_be_immutable, unnecessary_null_comparison, depend_on_referenced_packages, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, invalid_return_type_for_catch_error, deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/model/GetSalePostList.dart' as homepost;
import 'package:Plastic4trade/model/Get_likeUser.dart' as like;
import 'package:Plastic4trade/model/Get_shareUser.dart' as share_pro;
import 'package:Plastic4trade/model/Get_viewUser.dart' as view_pro;
import 'package:Plastic4trade/model/other_user_follower.dart' as getfllow;
import 'package:Plastic4trade/model/other_user_following.dart' as getfllowing;
import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_chat_shimmer_loader.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/widget/customshimmer/custome_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_interface.dart';
import '../../model/GetSalePostList.dart';
import '../../model/Get_likeUser.dart';
import '../../model/Get_shareUser.dart';
import '../../model/Get_viewUser.dart';
import '../buyer_seller/Buyer_sell_detail.dart';
import '../chat/ChartDetail.dart';
import '../Review.dart';

int? following_count, followers_count;

class other_user_profile extends StatefulWidget {
  int user_id;

  other_user_profile(this.user_id, {Key? key}) : super(key: key);

  @override
  State<other_user_profile> createState() => _bussinessprofileState();
}

class _bussinessprofileState extends State<other_user_profile>
    with TickerProviderStateMixin {
  late TabController _parentController;
  late TabController _childController;

  final scrollercontroller = ScrollController();
  String? username,
      chatId,
      email,
      countryCode,
      b_countryCode,
      business_name,
      image_url,
      website,
      address,
      bussmbl,
      usermbl,
      b_email,
      product_name,
      verify_status,
      instagram_url,
      youtube_url,
      facebook_url,
      linkedin_url,
      twitter_url,
      telegram_url,
      other_email_url,
      business_phone_url;
  String? ex_import_number,
      production_capacity,
      gst_number,
      Annual_Turnover,
      Premises_Type,
      business_type,
      core_business,
      is_follow,
      abot_buss,
      pan_number;

  String? firstyear_amount,
      secondyear_amount,
      thirdyear_amount,
      firstyear,
      secondYear,
      thirdYear;
  String? First_currency_sign = "",
      Second_currency_sign = "",
      Third_currency_sign = "";
  int? view_count,
      like,
      like_count,
      reviews_count,
      following_count,
      followers_count,
      chat_Id2,
      trusted_status,
      gst_verification_status,
      is_prime;
  bool isload = false;
  bool isLoading = true;
  GetSalePostList salePostList = GetSalePostList();
  GetSalePostList buyPostList = GetSalePostList();
  int offset = 0;
  int count = 0;
  String profileid = "", post_count = "0";
  String? packageName;
  PackageInfo? packageInfo;
  List<homepost.PostColor> colors = [];
  List<homepost.Result> salepostlist_data = [];
  List<homepost.Result> buypostlist_data = [];
  List<homepost.Result>? resultList;
  String crown_color = '';
  String plan_name = '';
  int? isFavorite;
  String? last_seen = DateTime.now().toString();
  String? signup_date = "";

  @override
  void initState() {
    _parentController = TabController(length: 2, vsync: this);
    int initialTabIndex =
        buypostlist_data.length >= salepostlist_data.length ? 0 : 1;
    _childController = TabController(length: 2, vsync: this);

    scrollercontroller.addListener(_scrollercontroller);
    checknetowork();
    super.initState();
    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
      print(
          "Data loaded. Buy Posts count: ${buypostlist_data.length}, Sell Posts count: ${salepostlist_data.length}");
      print("Initial tab index: $initialTabIndex");
      setState(() {
        _updateInitialTabIndex();
      });
    });
  }

  void _updateInitialTabIndex() {
    int initialTabIndex =
        buypostlist_data.length >= salepostlist_data.length ? 0 : 1;
    if (_childController.index != initialTabIndex) {
      _childController.index = initialTabIndex;
      print("Initial tab index updated to: $initialTabIndex");
    }
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void dispose() {
    _parentController.dispose();
    _childController.dispose();
    super.dispose();
  }

  void _showFullScreenDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: image_url.toString(),
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ))
              ],
            ),
          );
        });
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      print("USER ID === ${widget.user_id}");
      getPackage();
      getProfiless();
      get_buypostlist();
      get_salepostlist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return init();
  }

  Widget init() {
    DateTime? signupdateDate = DateTime.tryParse(signup_date!);

    // Get the formatted relative date
    String formattedSignUpDate = signupdateDate != null
        ? _formatRelativeDate(signupdateDate)
        : "Invalid date";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Business Profile',
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
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: _profileInfo2(),
                ),
                if (is_follow != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: is_follow == "0"
                              ? () {
                                  setState(() {
                                    followUnfollowUser("1");
                                    is_follow = "1";
                                    followers_count = (followers_count! + 1);
                                  });
                                }
                              : () {
                                  setState(() {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return CommanDialog(
                                            title: "Following",
                                            content: "Do you want to Unfollow",
                                            onPressed: () {
                                              setState(() {
                                                followUnfollowUser("0");
                                                is_follow = "0";
                                                followers_count =
                                                    followers_count! - 1;
                                              });
                                              Navigator.pop(context);
                                            },
                                          );
                                        });
                                  });
                                },
                          child: Container(
                            width: 104,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.primaryColor,
                            ),
                            child: Center(
                              child: Text(
                                is_follow == "0" ? 'Follow' : 'Followed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w500,
                                  height: 0.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 30),
                        if (followers_count != null)
                          GestureDetector(
                            onTap: () {
                              viewFollowerFollowing(
                                  context: context, tabIndex: 0);
                            },
                            child: Container(
                              width: 100,
                              child: Row(
                                children: [
                                  Text(
                                    followers_count.toString(),
                                    style: const TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontFamily:
                                            'assets/fonst/Metropolis-SemiBold.otf'),
                                  ),
                                  5.sbw,
                                  const Text(
                                    'Followers',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontFamily:
                                          'assets/fonst/Metropolis-SemiBold.otf',
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (following_count != null) 10.sbw,
                        GestureDetector(
                          onTap: () {
                            viewFollowerFollowing(
                                context: context, tabIndex: 1);
                          },
                          child: Container(
                            width: 120,
                            child: Row(
                              children: [
                                Text(
                                  following_count.toString(),
                                  style: const TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontFamily:
                                          'assets/fonst/Metropolis-SemiBold.otf'),
                                ),
                                5.sbw,
                                const Text(
                                  'Following',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily:
                                        'assets/fonst/Metropolis-SemiBold.otf',
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                10.sbh,
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last Active at ${_formatTime(last_seen)}',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.8),
                            fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                          ),
                        ),
                        Text(
                          'Member Since $formattedSignUpDate',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.8),
                            fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _icon(),
                const Divider(
                  color: Colors.black26,
                  height: 2.0,
                ),
                _section(),
                const Divider(
                  color: Colors.black26,
                  height: 2.0,
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: Column(
              children: [
                TabBar(
                  dividerColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _parentController,
                  tabs: [
                    Tab(text: 'Product Catalogue ($post_count)'),
                    const Tab(text: 'Business Info'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _parentController,
                    children: [
                      _subtabSection(context),
                      _businessInfo(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section() {
    return SizedBox(
      height: 47,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              like == 0
                  ? GestureDetector(
                      child: Image.asset(
                        'assets/like.png',
                        height: 20,
                        width: 20,
                      ),
                      onTap: () {
                        Profilelike();
                        like = 1;
                        int add = int.parse(like_count.toString());
                        add++;
                        like_count = add;

                        setState(() {});
                      },
                    )
                  : GestureDetector(
                      child: Image.asset(
                        'assets/like1.png',
                        height: 20,
                        width: 20,
                      ),
                      onTap: () {
                        Profilelike();

                        like = 0;
                        int add = int.parse(like_count.toString());
                        add--;
                        like_count = add;

                        setState(() {});
                      },
                    ),
              const SizedBox(
                width: 2,
              ),
              if (like_count != null)
                GestureDetector(
                  onTap: () {
                    ViewItem(context: context, tabIndex: 0);
                  },
                  child: Text('Like ($like_count)',
                      style: const TextStyle(
                        fontSize: 11.0,
                        fontFamily: 'Metropolis',
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      )),
                )
            ],
          ),
          GestureDetector(
            onTap: () async {
              var rev_count = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Review(profileid)));
              if (rev_count != null) {
                reviews_count = int.parse(rev_count.toString());
              }
              print("reviews_count:-$reviews_count");
              setState(() {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  (reviews_count ?? 0) > 0 ? Icons.star : Icons.star_border,
                  color:
                      (reviews_count ?? 0) > 0 ? Colors.amber : Colors.black54,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  'Reviews ($reviews_count)',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'assets/fonst/Metropolis-Black.otf',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.24,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ViewItem(context: context, tabIndex: 1);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.black54,
                  size: 17,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  'Views ($view_count)',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'assets/fonst/Metropolis-Black.otf',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.24,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              String mobile = bussmbl.toString();
              sharecount();
              shareImage(
                url: image_url.toString(),
                userId: profileid.toString(),
                UserName: username.toString(),
                companyName: business_name.toString(),
                number: mobile,
                location: address.toString(),
                gst: gst_number.toString(),
                email: b_email.toString(),
                natureOfBusiness: business_type!.replaceAll(",", ", "),
                coreOfBusiness: core_business.toString(),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/Send.png',
                  height: 14,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  'Share',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'assets/fonst/Metropolis-Black.otf',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.24,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _businessInfo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  //height: 300,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.05),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3FA6A6A6),
                        blurRadius: 16.32,
                        offset: Offset(0, 3.26),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Nature Of Business',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          business_type != null
                              ? business_type!.replaceAll(",", ", ")
                              : "",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 13,
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text('Core Business',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                fontSize: 12,
                                color: Colors.black38)),
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              core_business != null
                                  ? core_business
                                      .toString()
                                      .replaceAll(",", ", ")
                                  : "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf',
                                  fontSize: 13,
                                  color: Colors.black))),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Our Products',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'assets/fonts/Metropolis-Black.otf',
                            fontSize: 12,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          product_name != null
                              ? product_name!.replaceAll(",", ", ")
                              : "",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'assets/fonts/Metropolis-Black.otf',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Business Phone',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf',
                                      fontSize: 12,
                                      color: Colors.black38),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  onTap: () => launchUrl(
                                    Uri.parse('tel:$b_countryCode + $bussmbl'),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  child: Text(
                                    bussmbl != null && bussmbl!.isNotEmpty
                                        ? b_countryCode.toString() +
                                            bussmbl.toString()
                                        : '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf',
                                        fontSize: 13,
                                        color: Colors.black),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Business Email',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf',
                                      fontSize: 12,
                                      color: Colors.black38),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  onTap: () => launchUrl(
                                    Uri.parse('mailto:${b_email.toString()}'),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  child: Text(
                                    b_email.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf',
                                        fontSize: 13,
                                        color: Colors.black),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Website',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () {
                            final urlString = website.toString();
                            final formattedUrl =
                                !urlString.startsWith('http://') &&
                                        !urlString.startsWith('https://')
                                    ? 'https://$urlString'
                                    : urlString;
                            launch(formattedUrl,
                                    forceSafariVC: false,
                                    forceWebView: false,
                                    enableJavaScript: true)
                                .catchError(
                              (e) => print('Error launching URL: $e'),
                            );
                          },
                          child: Text(
                            website.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                fontSize: 13,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'About Your Business',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...buildWidgets(abot_buss ?? ""),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.05),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3FA6A6A6),
                        blurRadius: 16.32,
                        offset: Offset(0, 3.26),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'GST/VAT/TAX',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf',
                            fontSize: 12,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Text(
                                  gst_number.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf',
                                      fontSize: 13,
                                      color: Colors.black),
                                ),
                                5.sbw,
                                if (gst_number != "")
                                  gst_verification_status == 0
                                      ? Icon(
                                          Icons.clear,
                                          color: Colors.red.shade600,
                                        )
                                      : gst_verification_status == 1
                                          ? Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.green.shade600,
                                            )
                                          : gst_verification_status == 2
                                              ? Icon(
                                                  Icons.warning,
                                                  color: Colors.orange.shade600,
                                                )
                                              : Container(),
                              ],
                            ),
                            5.sbw,
                            if (gst_number != "")
                              Text(
                                gst_verification_status == 0
                                    ? 'Not verified'
                                    : gst_verification_status == 1
                                        ? 'Verified'
                                        : 'Irrelevant',
                                style: TextStyle(
                                  color: gst_verification_status == 0
                                      ? AppColors.red
                                      : gst_verification_status == 1
                                          ? Colors.green
                                          : Colors.orange,
                                  fontSize: 13,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Pan Number: ',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38),
                        ),
                      ),
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              pan_number.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf',
                                  fontSize: 13,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'IEC Number: ',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          ex_import_number.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 13,
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Production Capacity',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          production_capacity.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 13,
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Annual Turnover',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              firstyear_amount != null &&
                                      firstyear_amount!.isNotEmpty
                                  ? Text(
                                      '$firstyear : $firstyear_amount',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf',
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                          Row(
                            children: [
                              secondyear_amount !=
                                          null &&
                                      secondyear_amount!.isNotEmpty
                                  ? Text('$secondYear : $secondyear_amount',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf',
                                          fontSize: 14,
                                          color: Colors.black))
                                  : SizedBox.shrink(),
                            ],
                          ),
                          Row(
                            children: [
                              thirdyear_amount != null &&
                                      thirdyear_amount!.isNotEmpty
                                  ? Text(
                                      '$thirdYear : $thirdyear_amount',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf',
                                          fontSize: 14,
                                          color: Colors.black),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                      const Divider(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Premises Type',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          Premises_Type.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 13,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return ''; // Return empty string if dateTimeString is not available.
    }

    DateTime dateTime = DateTime.parse(dateTimeString);
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return "Today"; // Last seen is today
    } else if (difference.inDays == 1) {
      return "1 Day ago"; // Last seen was yesterday
    } else if (difference.inDays < 30) {
      return "${difference.inDays} Days ago"; // Last seen was within the last month
    } else if (difference.inDays < 365) {
      final int months = (difference.inDays / 30).floor();
      return months == 1
          ? "1 Month ago"
          : "$months Months ago"; // Last seen was within the last year
    } else {
      final int years = (difference.inDays / 365).floor();
      return years == 1
          ? "1 Year ago"
          : "$years Years ago"; // Last seen was over a year ago
    }
  }

  String _formatRelativeDate(DateTime lastSeenDate) {
    final DateTime now = DateTime.now();

    // Create a new DateTime object with the same year, month, and day as 'now'
    final DateTime today = DateTime(now.year, now.month, now.day);

    final Duration difference = today.difference(lastSeenDate);

    if (difference.inDays == 0) {
      return "Today"; // Last seen is today
    } else if (difference.inDays == 1) {
      return "1 Day ago"; // Last seen was yesterday
    } else if (difference.inDays < 30) {
      return "${difference.inDays} Days ago"; // Last seen was within the last month
    } else if (difference.inDays < 365) {
      final int months = (difference.inDays / 30).floor();
      return months == 1
          ? "1 Month ago"
          : "$months Months ago"; // Last seen was within the last year
    } else {
      final int years = (difference.inDays / 365).floor();
      return years == 1
          ? "1 Year ago"
          : "$years Years ago"; // Last seen was over a year ago
    }
  }

  Widget _icon() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: SizedBox(
        height: 60,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChartDetail(
                      user_id: profileid,
                      user_image: image_url,
                      user_name: username,
                      chatId: chat_Id2.toString(),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(5.0),
                margin: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26, width: 1),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 4.2,
                  height: 25,
                  child: const Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/sms.png'),
                      ),
                      Text(
                        'Chat',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf',
                            fontSize: 14,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                String appUsername = pref.getString('name').toString();
                print('Mobile_no: ${countryCode}${usermbl}');
                launchUrl(
                  Uri.parse('https://wa.me/$countryCode$usermbl' +
                      '?text=Hello $username \nI am $appUsername \nI Saw Your Profile On Plastic4Trade App. \nI Want to Know About Your Business. \n\n' +
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
              child: Container(
                padding: const EdgeInsets.all(5.0),
                margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26, width: 1),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 3.8,
                  height: 25,
                  child: Row(
                    children: [
                      Image.asset(
                        ('assets/whatsapp.png'),
                      ),
                      const Text(
                        'WhatsApp',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf',
                            fontSize: 14,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 26,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    if (facebook_url == null || facebook_url!.isEmpty) {
                      showCustomToast(
                        "No Facebook URL found!",
                      );
                    } else {
                      launchUrl(
                        Uri.parse(facebook_url!),
                        mode: LaunchMode.externalApplication,
                      );
                      GtmUtil.logScreenView(
                        'Facebook_User_click',
                        'facebookuserclick',
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/facebook.png',
                    width: 26,
                    height: 26,
                  ),
                ),
                IconButton(
                  iconSize: 26,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    if (instagram_url == null || instagram_url!.isEmpty) {
                      showCustomToast(
                        "No Instagram URL found!",
                      );
                    } else {
                      launchUrl(
                        Uri.parse(instagram_url!),
                        mode: LaunchMode.externalApplication,
                      );
                      GtmUtil.logScreenView(
                        'Instagram_User_click',
                        'instagramuserclick',
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/instagram.png',
                    width: 26,
                    height: 26,
                  ),
                ),
                IconButton(
                  iconSize: 26,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    if (linkedin_url == null || linkedin_url!.isEmpty) {
                      showCustomToast(
                        "No LinkedIn URL found!",
                      );
                    } else {
                      launchUrl(
                        Uri.parse(linkedin_url!),
                        mode: LaunchMode.externalApplication,
                      );
                      GtmUtil.logScreenView(
                        'Linkdien_User_click',
                        'linkdienuserclick',
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/linkdin.png',
                    width: 26,
                    height: 26,
                  ),
                ),
                IconButton(
                  iconSize: 26,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    if (youtube_url == null || youtube_url!.isEmpty) {
                      showCustomToast(
                        "No YouTube URL found!",
                      );
                    } else {
                      launchUrl(
                        Uri.parse(youtube_url!),
                        mode: LaunchMode.externalApplication,
                      );
                      GtmUtil.logScreenView(
                        'Youtube_User_click',
                        'youtubeuserclick',
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/youtube.png',
                    width: 26,
                    height: 26,
                  ),
                ),
                IconButton(
                  iconSize: 26,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    if (twitter_url == null || twitter_url!.isEmpty) {
                      showCustomToast(
                        "No Twitter URL found!",
                      );
                    } else {
                      launchUrl(
                        Uri.parse(twitter_url!),
                        mode: LaunchMode.externalApplication,
                      );
                      GtmUtil.logScreenView(
                        'Twitter_User_click',
                        'twitteruserclick',
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/xIcon.jpg',
                    width: 26,
                    height: 26,
                  ),
                ),
                IconButton(
                  iconSize: 26,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    if (telegram_url == null || telegram_url!.isEmpty) {
                      showCustomToast(
                        "No Telegram URL found!",
                      );
                    } else {
                      print('telegram_url: $telegram_url');

                      launchUrl(
                        Uri.parse(telegram_url!),
                        mode: LaunchMode.externalApplication,
                      );
                      GtmUtil.logScreenView(
                        'Telegram_User_click',
                        'telegramuserclick',
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/Telegram.png',
                    width: 26,
                    height: 26,
                  ),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }

  // Widget _profileInfo() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       GestureDetector(
  //         onTap: () {
  //           _showFullScreenDialog(context);
  //         },
  //         child: Column(
  //           children: [
  //             if (isload == false)
  //               Shimmer.fromColors(
  //                 baseColor: AppColors.grayHighforshimmer,
  //                 highlightColor: AppColors.grayLightforshimmer,
  //                 child: Container(
  //                   width: 110.0,
  //                   height: 110.0,
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     shape: BoxShape.circle,
  //                   ),
  //                 ),
  //               )
  //             else if (crown_color != null &&
  //                 crown_color.length > 1 &&
  //                 image_url != null)
  //               Container(
  //                 width: 110.0,
  //                 height: 110.0,
  //                 decoration: BoxDecoration(
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Color(
  //                               int.parse(crown_color.substring(1), radix: 16) |
  //                                   0xFF000000)
  //                           .withOpacity(0.5),
  //                       spreadRadius: 3,
  //                       blurRadius: 7,
  //                       offset: Offset(0, 3),
  //                     ),
  //                   ],
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: Container(
  //                   width: 100.0,
  //                   height: 100.0,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     border: Border.all(
  //                       width: 4,
  //                       color: Color(
  //                           int.parse(crown_color.substring(1), radix: 16) |
  //                               0xFF000000),
  //                     ),
  //                   ),
  //                   child: Container(
  //                     width: 100.0,
  //                     height: 100.0,
  //                     decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       image: DecorationImage(
  //                         image: NetworkImage(
  //                           '${image_url.toString()}?${DateTime.now().millisecondsSinceEpoch}',
  //                         ),
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             if (crown_color != null &&
  //                 crown_color.length > 1 &&
  //                 plan_name != null)
  //               Container(
  //                 width: 60,
  //                 height: 20,
  //                 alignment: Alignment.center,
  //                 transform: Matrix4.translationValues(0.0, -10.0, 0.0),
  //                 decoration: BoxDecoration(
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Color(
  //                               int.parse(crown_color.substring(1), radix: 16) |
  //                                   0xFF000000)
  //                           .withOpacity(0.5),
  //                       spreadRadius: 1,
  //                       blurRadius: 7,
  //                       offset: Offset(0, 3),
  //                     ),
  //                   ],
  //                   borderRadius: BorderRadius.circular(40),
  //                   color: Color(
  //                       int.parse(crown_color.substring(1), radix: 16) |
  //                           0xFF000000),
  //                 ),
  //                 child: Align(
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     plan_name == "Premium Plan"
  //                         ? "Premium"
  //                         : plan_name == "Standard Plan"
  //                             ? "Standard"
  //                             : plan_name,
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 11,
  //                       fontFamily: 'Metropolis-SemiBold',
  //                       fontWeight: FontWeight.w600,
  //                       letterSpacing: -0.24,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           isload == false
  //               ? Shimmer.fromColors(
  //                   baseColor: AppColors.grayHighforshimmer,
  //                   highlightColor: AppColors.grayLightforshimmer,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Container(
  //                         width: 150,
  //                         height: 15,
  //                         color: Colors.white,
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Container(
  //                         width: 50,
  //                         height: 13,
  //                         color: Colors.white,
  //                       ),
  //                       const SizedBox(height: 5),
  //                       Container(
  //                         width: 100,
  //                         height: 13,
  //                         color: Colors.white,
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Container(
  //                         width: 120,
  //                         height: 13,
  //                         color: Colors.white,
  //                       ),
  //                     ],
  //                   ),
  //                 )
  //               : SizedBox(
  //                   width: MediaQuery.of(context).size.width / 1.8,
  //                   child: business_name != null
  //                       ? Text(
  //                           capitalizeEachWord(business_name.toString()),
  //                           softWrap: true,
  //                           maxLines: 3,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: const TextStyle(
  //                             fontSize: 19.0,
  //                             fontWeight: FontWeight.w700,
  //                             color: Colors.black,
  //                             fontFamily:
  //                                 'assets/fonst/Metropolis-SemiBold.otf',
  //                           ),
  //                         )
  //                       : SizedBox.shrink()),
  //           if (username != null)
  //             Row(
  //               children: [
  //                 const ImageIcon(
  //                   AssetImage('assets/user.png'),
  //                 ),
  //                 const SizedBox(width: 5),
  //                 Text(
  //                   capitalizeEachWord(username.toString()),
  //                   style: const TextStyle(
  //                     fontSize: 16.0,
  //                     fontWeight: FontWeight.w400,
  //                     color: Colors.black,
  //                     fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
  //                   ),
  //                   softWrap: false,
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           if (countryCode != null && usermbl != null)
  //             Row(
  //               children: [
  //                 const ImageIcon(AssetImage('assets/call.png'), size: 16),
  //                 const SizedBox(width: 5),
  //                 SizedBox(
  //                   width: MediaQuery.of(context).size.width / 1.8,
  //                   child: GestureDetector(
  //                     onTap: () => launchUrl(
  //                       Uri.parse('tel:$countryCode$usermbl'),
  //                       mode: LaunchMode.externalApplication,
  //                     ),
  //                     child: Text(
  //                       '$countryCode $usermbl',
  //                       style: const TextStyle(
  //                         fontSize: 16.0,
  //                         fontWeight: FontWeight.w400,
  //                         color: Colors.black,
  //                         fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           if (address != null)
  //             Row(
  //               children: [
  //                 const ImageIcon(
  //                   AssetImage('assets/location.png'),
  //                   size: 16,
  //                 ),
  //                 const SizedBox(width: 5),
  //                 SizedBox(
  //                   width: MediaQuery.of(context).size.width / 1.8,
  //                   child: Text(
  //                     address.toString(),
  //                     softWrap: false,
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: const TextStyle(
  //                       fontSize: 16.0,
  //                       fontWeight: FontWeight.w400,
  //                       color: Colors.black,
  //                       fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           if (verify_status != null)
  //             Container(
  //                 child: Row(children: [
  //               Column(
  //                 children: [
  //                   verify_status == "1"
  //                       ? Row(
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           children: [
  //                             Image(
  //                               image: AssetImage('assets/Unverified.png'),
  //                               height: 30,
  //                               width: 30,
  //                             ),
  //                             3.sbw,
  //                             Text(
  //                               'Unverified',
  //                               style: TextStyle(
  //                                 color: AppColors.verfirdColor,
  //                                 fontSize: 13,
  //                                 fontFamily: 'Metropolis',
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                             ),
  //                             8.sbw,
  //                             Row(
  //                               children: [
  //                                 Image(
  //                                   image: AssetImage('assets/Untrusted.png'),
  //                                   height: 22,
  //                                   width: 30,
  //                                 ),
  //                                 3.sbw,
  //                                 Text(
  //                                   'Untrusted',
  //                                   style: TextStyle(
  //                                     color: AppColors.verfirdColor,
  //                                     fontSize: 13,
  //                                     fontFamily: 'Metropolis',
  //                                     fontWeight: FontWeight.w600,
  //                                   ),
  //                                 ),
  //                               ],
  //                             )
  //                           ],
  //                         )
  //                       : verify_status == "2"
  //                           ? Row(
  //                               children: const [
  //                                 Image(image: AssetImage('assets/verify.png')),
  //                                 Text('Verified'),
  //                               ],
  //                             )
  //                           : verify_status == "3"
  //                               ? Row(
  //                                   children: [
  //                                     const Image(
  //                                         image:
  //                                             AssetImage('assets/verify.png')),
  //                                     const Text('Verified'),
  //                                     const SizedBox(width: 5),
  //                                     Row(
  //                                       children: const [
  //                                         Image(
  //                                           image:
  //                                               AssetImage('assets/trust.png'),
  //                                           height: 20,
  //                                           width: 30,
  //                                         ),
  //                                         Text('Trusted'),
  //                                       ],
  //                                     )
  //                                   ],
  //                                 )
  //                               : Container()
  //                 ],
  //               ),
  //             ])),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _profileInfo2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (() {
            _showFullScreenDialog(context);
          }),
          child: Column(
            children: [
              if (isload == false)
                Shimmer.fromColors(
                  baseColor: AppColors.grayHighforshimmer,
                  highlightColor: AppColors.grayLightforshimmer,
                  child: Container(
                    width: 110.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else if (crown_color != null &&
                  crown_color.length > 1 &&
                  image_url != null)
                Container(
                  width: 110.0,
                  height: 110.0,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                                int.parse(crown_color.substring(1), radix: 16) |
                                    0xFF000000)
                            .withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 4,
                        color: Color(
                            int.parse(crown_color.substring(1), radix: 16) |
                                0xFF000000),
                      ),
                    ),
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            '${image_url.toString()}?${DateTime.now().millisecondsSinceEpoch}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              if (crown_color != null &&
                  crown_color.length > 1 &&
                  plan_name != null)
                Container(
                  width: 60,
                  height: 20,
                  alignment: Alignment.center,
                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                                int.parse(crown_color.substring(1), radix: 16) |
                                    0xFF000000)
                            .withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(40),
                    color: Color(
                        int.parse(crown_color.substring(1), radix: 16) |
                            0xFF000000),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      plan_name == "Premium Plan"
                          ? "Premium"
                          : plan_name == "Standard Plan"
                              ? "Standard"
                              : plan_name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'Metropolis-SemiBold',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isload == false
                ? Shimmer.fromColors(
                    baseColor: AppColors.grayHighforshimmer,
                    highlightColor: AppColors.grayLightforshimmer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 50,
                          height: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 100,
                          height: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: business_name != null
                        ? Text(
                            capitalizeEachWord(business_name.toString()),
                            softWrap: true,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily:
                                  'assets/fonst/Metropolis-SemiBold.otf',
                            ),
                          )
                        : SizedBox.shrink()),
            if (username != null)
              Row(
                children: [
                  const ImageIcon(
                    AssetImage('assets/user.png'),
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: Text(
                      capitalizeEachWord(username.toString()),
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                      ),
                    ),
                  ),
                ],
              ),
            if (countryCode != null && usermbl != null)
              Row(
                children: [
                  const ImageIcon(AssetImage('assets/call.png'), size: 16),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: GestureDetector(
                      onTap: () => launchUrl(
                        Uri.parse('tel:$countryCode$usermbl'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(
                        '$countryCode $usermbl',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (address != null)
              Row(
                children: [
                  const ImageIcon(
                    AssetImage('assets/location.png'),
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: Text(
                      address.toString(),
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            if (verify_status != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: verify_status == "0"
                        ? AssetImage('assets/Unverified.png')
                        : AssetImage('assets/verify.png'),
                    height: 30,
                    width: 30,
                  ),
                  3.sbw,
                  Text(
                    verify_status == "0" ? 'Not verified' : 'Verified',
                    style: TextStyle(
                      color: verify_status == "0"
                          ? AppColors.blackColor
                          : AppColors.verfirdColor,
                      fontSize: 13,
                      fontFamily: 'Metropolis',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  8.sbw,
                  if (trusted_status != null)
                    Row(
                      children: [
                        Image(
                          image: trusted_status == 0
                              ? AssetImage('assets/Untrusted.png')
                              : AssetImage('assets/trust.png'),
                          height: 22,
                          width: 30,
                        ),
                        3.sbw,
                        Text(
                          trusted_status == 0 ? 'Untrusted' : 'Trusted',
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
              )
          ],
        )
      ],
    );
  }

  String capitalizeEachWord(String text) {
    if (text.isEmpty) return '';
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  Future<void> sharecount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await share_count(
      profileid.toString(),
      pref.getString('user_id').toString(),
      device,
    );

    if (res['status'] == 1) {
      if (mounted) {
        setState(() {});
      }
    } else {
      showCustomToast(res['message']);
    }
  }

  Widget _subtabSection(BuildContext context) {
    return Column(children: [
      Container(
        margin: const EdgeInsets.all(10.0),
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            25.0,
          ),
        ),
        child: TabBar(
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          controller: _childController,
          physics: const AlwaysScrollableScrollPhysics(),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25.0,
            ),
            color: AppColors.primaryColor,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(
              child: Text(
                'Buy Posts',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Metropolis',
                ),
              ),
            ),
            Tab(
              child: Text(
                'Sell Posts',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Metropolis',
                ),
              ),
            ),
          ],
        ),
      ),
      Expanded(
          child: Container(
        child: TabBarView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _childController,
            children: [
              isLoading ? PostWithShimmerLoader(context) : Buyer_post(),
              isLoading ? PostWithShimmerLoader(context) : Sale_post(),
            ]),
      )),
    ]);
  }

  Widget PostWithShimmerLoader(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: MediaQuery.of(context).size.width / 620,
        crossAxisCount: 2,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 4,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return CustomShimmerLoader(width: 175, height: 200);
      },
    );
  }

  Widget Buyer_post() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: MediaQuery.of(context).size.width /
            620, //MediaQuery.of(context).size.aspectRatio * 1.3,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
        crossAxisCount: 2,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      controller: scrollercontroller,
      itemCount: buypostlist_data.isEmpty ? 1 : buypostlist_data.length + 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == buypostlist_data.length) {
          if (buyPostToLoad() && !buypostlist_data.isEmpty) {
            if (buypostlist_data.isNotEmpty) {
              return SizedBox();
            }
            return CustomShimmerLoader(
              width: 175,
              height: 200,
            );
          } else {
            return SizedBox();
          }
        } else {
          homepost.Result result = buypostlist_data[index];
          return GestureDetector(
            onTap: (() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Buyer_sell_detail(
                    prod_id: result.productId.toString(),
                    post_type: result.postType.toString(),
                  ),
                ),
              );
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
                              width: result.isPaidPost == 'Paid' ? 2.5 : 0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: result.mainproductImage.toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Text(
                              '${result.currency}${result.productPrice}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
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
                  const SizedBox(
                      height: 10.0), // Added spacing between elements
                  Expanded(
                    child: Padding(
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
                          const SizedBox(
                              height: 5.0), // Added spacing between elements
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
                          const SizedBox(
                              height: 5.0), // Added spacing between elements
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
                          const SizedBox(
                              height: 5.0), // Added spacing between elements
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
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  bool buyPostToLoad() {
    int itemsPerPage = 20;
    return buypostlist_data.length % itemsPerPage == 0;
  }

  void _scrollercontroller() {
    if (scrollercontroller.position.pixels ==
        scrollercontroller.position.maxScrollExtent) {
      if (_childController.index == 0) {
        if (salepostlist_data.isNotEmpty) {
          count++;
          if (count == 1) {
            offset = offset + 31;
          } else {
            offset = offset + 20;
          }
          get_salepostlist();
        }
      } else if (_childController.index == 1) {
        if (buypostlist_data.isNotEmpty) {
          count++;
          if (count == 1) {
            offset = offset + 31;
          } else {
            offset = offset + 20;
          }
          get_buypostlist();
        }
      }
    }
  }

  Widget Sale_post() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: MediaQuery.of(context).size.width / 620,
        crossAxisCount: 2,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      controller: scrollercontroller,
      itemCount: salepostlist_data.isEmpty ? 1 : salepostlist_data.length + 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == salepostlist_data.length) {
          if (salePostToLoad() && !salepostlist_data.isEmpty) {
            if (salepostlist_data.isNotEmpty) {
              return SizedBox();
            }
            return CustomShimmerLoader(
              width: 175,
              height: 200,
            );
          } else {
            return SizedBox();
          }
        } else {
          homepost.Result result = salepostlist_data[index];
          return GestureDetector(
            onTap: (() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Buyer_sell_detail(
                    prod_id: result.productId.toString(),
                    post_type: result.postType.toString(),
                  ),
                ),
              );
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
                              width: result.isPaidPost == 'Paid' ? 2.5 : 0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: result.mainproductImage.toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Text(
                              '${result.currency}${result.productPrice}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
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
                  const SizedBox(
                      height: 10.0), // Added spacing between elements
                  Expanded(
                    child: Padding(
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
                          const SizedBox(
                              height: 5.0), // Added spacing between elements
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
                          const SizedBox(
                              height: 5.0), // Added spacing between elements
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
                          const SizedBox(
                              height: 5.0), // Added spacing between elements
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
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  bool salePostToLoad() {
    int itemsPerPage = 20;
    return salepostlist_data.length % itemsPerPage == 0;
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

    var res = await getbusinessprofileDetail(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.user_id.toString(),
      device,
    );

    log("RESPONSE === $res");

    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      // Assigning data from response
      chat_Id2 = res['chat_id2'] ?? 0;

      profileid = res['profile']['user_id'] ?? "";
      username = res['user']['username'] ?? "";
      instagram_url = res['profile']['instagram_link'] ?? "";
      youtube_url = res['profile']['youtube_link'] ?? "";
      facebook_url = res['profile']['facebook_link'] ?? "";
      linkedin_url = res['profile']['linkedin_link'] ?? "";
      twitter_url = res['profile']['twitter_link'] ?? "";
      telegram_url = res['profile']['telegram_link'] ?? "";
      business_phone_url = res['user']['business_phone'] ?? "";
      other_email_url = res['user']['other_email'] ?? "";
      business_name = res['profile']['business_name'] ?? "";
      email = res['user']['email'] ?? "";
      b_email = res['profile']['other_email'] ?? "";
      website = res['profile']['website'] ?? "";
      bussmbl = res['profile']['business_phone'] ?? "";
      usermbl = res['user']['phoneno'] ?? "";
      address = res['profile']['address'] ?? "";
      post_count = res['profile']['post_count'] ?? "";
      b_countryCode = res['profile']['countryCode'] ?? "";
      last_seen = res['user']['last_seen'] ?? "";
      print('last_seen: $last_seen');

      signup_date = res['user']['signup_date'] ?? "";

      isFavorite = res['user']['is_favorite'] ?? 0;

      countryCode = res['user']['countryCode'] ?? "";

      view_count = res['profile']['view_count'] ?? "";
      like = res['profile']['like_count'] ?? "";
      reviews_count = res['profile']['reviews_count'] ?? "";
      following_count = res['profile']['following_count'] ?? "";
      followers_count = res['profile']['followers_count'] ?? "";
      verify_status = res['profile']['verification_status'] ?? "";
      trusted_status = res['profile']['trusted_status'];
      gst_verification_status = res['profile']['gst_verification_status'];
      print('trusted_status: $trusted_status');
      like_count = res['profile']['like_count'] ?? "";
      is_follow = res['profile']['is_follow'] ?? "";
      print("is_follow:-${is_follow}");
      abot_buss = res['profile']['about_business'] ?? "";
      image_url = res['user']['image_url'] ?? "";
      is_prime = res['user']['is_prime'] ?? "";
      crown_color = res['user']['crown_color'] ?? "";
      print('api responce: $plan_name');
      plan_name = res['user']['plan_name'] ?? "";
      print('app responce: $plan_name');

      gst_number = res['profile']['gst_tax_vat'] ?? "";
      Premises_Type = res['profile']['premises'] ?? '';
      Annual_Turnover = res['profile']['annual_turnover'] ?? '';

      pan_number = res['profile']['pan_number'] ?? '';
      production_capacity = res['profile']['annualcapacity'] == null
          ? ""
          : res['profile']['annualcapacity']['name'] ?? '';
      ex_import_number = res['profile']['export_import_number'] ?? '';

      business_type = res['profile']['business_type_name'] ?? '';
      core_business = res['profile']['core_businesses_name'] ?? '';

      product_name = res['profile']['product_name'] ?? '';

      print(
          'product_name_business_profile ${res['profile']['directory_post']}');

      // Assuming `res` is your JSON response
      List<dynamic> annualTurnovers = res['profile']['annualTurnovers'] ?? [];

      if (annualTurnovers.isNotEmpty) {
        firstyear = annualTurnovers[0]['year'] ?? '';
        secondYear =
            annualTurnovers.length > 1 ? annualTurnovers[1]['year'] ?? '' : '';
        thirdYear =
            annualTurnovers.length > 2 ? annualTurnovers[2]['year'] ?? '' : '';
      }
      if (annualTurnovers.isNotEmpty) {
        First_currency_sign = annualTurnovers[0]['currency'] ?? '';
        Second_currency_sign = annualTurnovers.length > 1
            ? annualTurnovers[1]['currency'] ?? ''
            : '';
        Third_currency_sign = annualTurnovers.length > 2
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

      isload = true;
    } else if (res['status'] == 3) {
      showCustomToast("Upgrade Your Plan To View Contact Details");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Premiun(),
        ),
      );
    } else {
      isload = true;
      showCustomToast(res['message']);
    }

    setState(() {});
  }

  get_buypostlist() async {
    buyPostList = GetSalePostList();
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await get_postUser(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      '20',
      offset.toString(),
      widget.user_id.toString(),
      device,
    );
    var jsonArray;
    if (res['status'] == 1) {
      buyPostList = GetSalePostList.fromJson(res);

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
              unit: data['Unit'],
              postQuntity: data['PostQuntity'],
              productStatus: data['product_status'],
              mainproductImage: data['mainproductImage']);

          buypostlist_data.add(record);
        }
        _childController.dispose();
        _childController = TabController(
            length: 2,
            vsync: this,
            initialIndex: buypostlist_data.isEmpty ? 1 : 0);
        isload = true;

        if (mounted) {
          setState(() {});
        }
      }
    } else {
      isload = true;
      // showCustomToast(res['message']);
    }
    return jsonArray;
  }

  Future<void> Profilelike() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await profile_like(
      profileid.toString(),
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    var jsonArray;

    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));
      showCustomToast(res['message']);

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
    } else {
      showCustomToast(res['message']);
    }
    setState(() {});
    return jsonArray;
  }

  Future<void> followUnfollowUser(isFollow) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var response = await followUnfollow(
      isFollow.toString(),
      widget.user_id.toString(),
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );
    print("FOLLOW RESPONSE == $response");

    var jsonArray;

    if (response['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      showCustomToast(response['message']);
    } else {
      showCustomToast(response['message']);
    }
    setState(() {});
    return jsonArray;
  }

  get_salepostlist() async {
    salePostList = GetSalePostList();
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getsale_PostList(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      widget.user_id.toString(),
      device,
    );
    var jsonArray;
    if (res['status'] == 1) {
      salePostList = GetSalePostList.fromJson(res);

      if (res['result'] != null) {
        jsonArray = res['result'];
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
              unit: data['Unit'],
              postQuntity: data['PostQuntity'],
              productStatus: data['product_status'],
              mainproductImage: data['mainproductImage']);

          salepostlist_data.add(record);
        }
        isload = true;
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      isload = true;
      // showCustomToast(res['message']);
    }
    setState(() {});
    return jsonArray;
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
  }

  void shareImage({
    required String url,
    required String userId,
    required String UserName,
    required String companyName,
    required String number,
    required String location,
    required String natureOfBusiness,
    required String coreOfBusiness,
    required String email,
    String? gst,
  }) async {
    try {
      final dynamicLink = await createDynamicLink(
        'https://www.plastic4trade.com',
        'UserProfile',
        userId,
      );

      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load image from the server');
      }

      final bytes = response.bodyBytes;
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/image.jpg';
      File(path).writeAsBytesSync(bytes);

      final shareText = "Nature of Business: $natureOfBusiness\n" +
          "\n" +
          "Core Business: $coreOfBusiness\n" +
          "\t" +
          "\n\n" +
          'Plastic4trade is a B2B Plastic Business App, Buy & Sale your Products, Raw Material, Recycle Plastic Scrap, Plastic Machinery, Polymer Price, News, Update for Manufacturers, Traders, Exporters, Importers....' +
          "\n\n" +
          'More Info: $dynamicLink';

      await Share.shareFiles([path], text: shareText);
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error sharing image: $e');
    }
  }

  List<Widget> buildWidgets(String text) {
    List<Widget> widgets = [];
    final lines = text.split('\n');

    for (var line in lines) {
      widgets.add(
        buildLineWidget(line),
      );
    }

    return widgets;
  }

  Widget buildLineWidget(String line) {
    final words = line.split(' ');

    List<Widget> lineWidgets = [];
    for (var word in words) {
      if (RegExp(r'https?://[^\s/$.?#].[^\s]*').hasMatch(word)) {
        lineWidgets.add(
          GestureDetector(
            onTap: () async {
              if (await canLaunch(word)) {
                await launch(word);
              } else {
                throw 'Could not launch $word';
              }
            },
            child: Text(
              word,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      } else if (RegExp(r'\b\d{10}\b').hasMatch(word)) {
        String phoneNumber = RegExp(r'\b\d{10}\b').stringMatch(word)!;
        lineWidgets.add(
          GestureDetector(
            onTap: () async {
              final url = 'tel:$phoneNumber';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: Text(
              phoneNumber,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      } else if (word.endsWith('.com') || word.endsWith('.in')) {
        String url = word;
        if (!url.startsWith('http')) {
          url = 'http://$url';
        }
        lineWidgets.add(
          GestureDetector(
            onTap: () async {
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: Text(
              word,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      } else {
        // Handle regular text
        lineWidgets.add(
          Text(
            word,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }
      lineWidgets.add(
        const SizedBox(width: 4),
      ); // Add some spacing between words
    }
    return Wrap(
      direction: Axis.horizontal,
      // This ensures the children are laid out horizontally
      children: lineWidgets,
    );
  }

  ViewItem({required BuildContext context, int tabIndex = 0}) {
    return showModalBottomSheet(
      backgroundColor: AppColors.backgroundColor,
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
          initialChildSize: 0.60,
          builder: (BuildContext context, ScrollController scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return ViewWidget(
                  profileid: profileid.toString(),
                  tabIndex: tabIndex,
                );
              },
            );
          }),
    );
  }

  viewFollowerFollowing(
      {required BuildContext context, required int tabIndex}) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
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
        initialChildSize: 0.60,
        builder: (BuildContext context, ScrollController scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              return ViewFollowerFollowingList(
                userId: widget.user_id.toString(),
                tabIndex: tabIndex,
              );
            },
          );
        },
      ),
    ).then(
      (value) {},
    );
  }
}

class ViewWidget extends StatefulWidget {
  String profileid;
  int tabIndex = 0;

  ViewWidget({
    Key? key,
    required this.profileid,
    required this.tabIndex,
  }) : super(key: key);

  @override
  State<ViewWidget> createState() => _ViewState();
}

class _ViewState extends State<ViewWidget> with SingleTickerProviderStateMixin {
  bool? isload;
  late TabController _tabController;
  List<like.Data> dataList = [];
  List<view_pro.Data> dataList1 = [];
  List<share_pro.Data> dataList2 = [];
  int currentPage = 1;
  final int pageSize = 20;

  final scrollercontroller = ScrollController();
  int offset = 0;
  int count = 0;
  bool loadmore = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollercontroller.addListener(_scrollercontroller);

    _tabController =
        TabController(length: 3, vsync: this, initialIndex: widget.tabIndex);
    get_like();
    get_share();
    get_view();
  }

  Future<void> _refreshData() async {
    setState(() {
      offset = 0;
      dataList1.clear();
    });

    await get_view();

    showCustomToast('Data Refreshed');
    scrollercontroller.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    return null;
  }

  @override
  void dispose() {
    scrollercontroller.removeListener(_scrollercontroller);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> get_like({bool loadMore = false}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var res = await get_profileliked_user(
      widget.profileid,
      pref.getString('user_id').toString(),
      currentPage,
      pageSize,
    );

    if (res['status'] == 1) {
      List<like.Data> newDataList = Get_likeUser.fromJson(res).data ?? [];
      setState(() {
        dataList.addAll(newDataList);
        currentPage++;
      });
    } else {
      showCustomToast(res['message']);
    }
  }

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 50) ==
        (scrollercontroller.position.maxScrollExtent - 50)) {
      loadmore = false;
      if (dataList1.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 20;
        } else {
          offset = offset + 20;
        }
        get_view();
      }
    }
  }

  Future<void> get_view() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (isLoading) return;

    isLoading = true;

    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    try {
      var res = await get_profileviewd_user(
        widget.profileid,
        device,
        offset.toString(),
        pref.getString('user_id').toString(),
      );

      if (res['status'] == 1) {
        GetViewUser common = GetViewUser.fromJson(res);
        List newData = common.data ?? [];

        setState(() {
          dataList1.addAll(newData as Iterable<view_pro.Data>);
        });

        if (newData.isNotEmpty) {
          setState(() {
            loadmore = true;
          });
        } else {
          setState(() {
            loadmore = false;
          });
        }
      } else {
        showCustomToast(res['message']);
      }
    } catch (e) {
      showCustomToast('Error fetching data');
      print(e);
    } finally {
      isLoading = false;
    }
  }

  get_share() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    GetShareUser common = GetShareUser();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await get_profiles_share(
      widget.profileid,
      device,
      pref.getString('user_id').toString(),
    );

    if (res['status'] == 1) {
      common = GetShareUser.fromJson(res);
      dataList2 = common.data ?? [];
      isload = true;
    } else {
      showCustomToast(res['message']);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isload == true
        ? Column(
            children: [
              const SizedBox(height: 5),
              Image.asset(
                'assets/hori_line.png',
                width: 150,
                height: 5,
              ),
              TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                indicatorColor: AppColors.primaryColor,
                tabs: const [
                  Tab(text: 'Like'),
                  Tab(text: 'View'),
                  Tab(text: 'Share'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      itemCount: dataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            print('outsideTap');

                            final int? isBusinessProfileView =
                                dataList[index].isBusinessProfileView;

                            if (isBusinessProfileView != null) {
                              print(
                                  'isBusinessProfileView value: $isBusinessProfileView');

                              if (isBusinessProfileView == 1) {
                                print('Redirecting to other_user_profile');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => other_user_profile(
                                        int.parse(
                                            dataList[index].userId.toString())),
                                  ),
                                ).then((_) {
                                  get_like();
                                });
                              } else if (isBusinessProfileView == 0) {
                                print('Redirecting to Premium');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Premiun(),
                                  ),
                                ).then((_) {
                                  get_like();
                                });
                                showCustomToast('Upgrade Plan to View Profile');
                              }
                            } else {
                              print('isBusinessProfileView is null');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Card(
                              color: AppColors.backgroundColor,
                              elevation: 9,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        dataList[index].isBusinessProfileView ==
                                                    1 &&
                                                dataList[index]
                                                        .isBusinessOldView ==
                                                    0
                                            ? Icon(
                                                Icons
                                                    .supervised_user_circle_outlined,
                                                color: AppColors.primaryColor,
                                                size: 51,
                                              )
                                            : dataList[index]
                                                            .isBusinessProfileView ==
                                                        0 &&
                                                    dataList[index]
                                                            .isBusinessOldView ==
                                                        0
                                                ? Icon(
                                                    Icons
                                                        .supervised_user_circle_outlined,
                                                    color:
                                                        AppColors.primaryColor,
                                                    size: 51,
                                                  )
                                                : dataList[index]
                                                                .isBusinessProfileView ==
                                                            1 &&
                                                        dataList[index]
                                                                .isBusinessOldView ==
                                                            1
                                                    ? CircleAvatar(
                                                        backgroundColor:
                                                            AppColors
                                                                .backgroundColor,
                                                        radius: 25,
                                                        backgroundImage: dataList[
                                                                        index]
                                                                    .imageUrl
                                                                    .toString() !=
                                                                ''
                                                            ? NetworkImage(dataList[
                                                                        index]
                                                                    .imageUrl
                                                                    .toString())
                                                                as ImageProvider
                                                            : const AssetImage(
                                                                'assets/plastic4trade logo final 1 (2).png'),
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .supervised_user_circle_outlined,
                                                        color: AppColors
                                                            .primaryColor,
                                                        size: 51,
                                                      ),
                                        8.sbw,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dataList[0].isBusinessProfileView ==
                                                          1 &&
                                                      dataList[0]
                                                              .isBusinessOldView ==
                                                          0
                                                  ? 'XXXXX ' +
                                                      dataList[index]
                                                          .username!
                                                          .split(' ')
                                                          .last
                                                  : dataList[0].isBusinessProfileView ==
                                                              0 &&
                                                          dataList[0]
                                                                  .isBusinessOldView ==
                                                              0
                                                      ? 'XXXXX ' +
                                                          dataList[index]
                                                              .username!
                                                              .split(' ')
                                                              .last
                                                      : dataList[index]
                                                                      .isBusinessProfileView ==
                                                                  1 &&
                                                              dataList[index]
                                                                      .isBusinessOldView ==
                                                                  1
                                                          ? dataList[index]
                                                              .username
                                                              .toString()
                                                          : 'XXXXX ' +
                                                              dataList[index]
                                                                  .username!
                                                                  .split(' ')
                                                                  .last,
                                              style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.blackColor,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-Black.otf'),
                                            ),
                                            Text(
                                              dataList[index]
                                                      .businessTypeName ??
                                                  "Unknown",
                                              style: TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 12.0,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_right,
                                      size: 30,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Adjust the ListView.builder to show shimmer loader at the end
                    RefreshIndicator(
                      backgroundColor: AppColors.primaryColor,
                      color: AppColors.backgroundColor,
                      onRefresh: _refreshData,
                      child: dataList1.isEmpty
                          ? SizedBox()
                          : ListView.builder(
                              padding: const EdgeInsets.all(15),
                              controller: scrollercontroller,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: dataList1.length + (loadmore ? 1 : 0),
                              itemBuilder: (BuildContext context, int index) {
                                if (index < dataList1.length) {
                                  return GestureDetector(
                                    onTap: () {
                                      print('outsideTap');

                                      final int? isBusinessProfileView =
                                          dataList1[index]
                                              .isBusinessProfileView;

                                      if (isBusinessProfileView != null) {
                                        print(
                                            'isBusinessProfileView value: $isBusinessProfileView');

                                        if (isBusinessProfileView == 1) {
                                          print(
                                              'Redirecting to other_user_profile');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  other_user_profile(int.parse(
                                                      dataList1[index]
                                                          .userId
                                                          .toString())),
                                            ),
                                          ).then((_) {
                                            get_view();
                                          });
                                        } else if (isBusinessProfileView == 0) {
                                          print('Redirecting to Premium');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  Premiun(),
                                            ),
                                          ).then((_) {
                                            get_view();
                                          });
                                          showCustomToast(
                                              'Upgrade Plan to View Profile');
                                        }
                                      } else {
                                        print('isBusinessProfileView is null');
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0),
                                      child: Card(
                                        color: AppColors.backgroundColor,
                                        elevation: 9,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  dataList1[index].isBusinessProfileView ==
                                                              1 &&
                                                          dataList1[index]
                                                                  .isBusinessOldView ==
                                                              0
                                                      ? Icon(
                                                          Icons
                                                              .supervised_user_circle_outlined,
                                                          color: AppColors
                                                              .primaryColor,
                                                          size: 51,
                                                        )
                                                      : dataList1[index]
                                                                      .isBusinessProfileView ==
                                                                  0 &&
                                                              dataList1[index]
                                                                      .isBusinessOldView ==
                                                                  0
                                                          ? Icon(
                                                              Icons
                                                                  .supervised_user_circle_outlined,
                                                              color: AppColors
                                                                  .primaryColor,
                                                              size: 51,
                                                            )
                                                          : dataList1[index]
                                                                          .isBusinessProfileView ==
                                                                      1 &&
                                                                  dataList1[index]
                                                                          .isBusinessOldView ==
                                                                      1
                                                              ? CircleAvatar(
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .backgroundColor,
                                                                  radius: 25,
                                                                  backgroundImage: dataList1[index]
                                                                              .imageUrl
                                                                              .toString() !=
                                                                          ''
                                                                      ? NetworkImage(dataList1[index]
                                                                              .imageUrl
                                                                              .toString())
                                                                          as ImageProvider
                                                                      : const AssetImage(
                                                                          'assets/plastic4trade logo final 1 (2).png'),
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .supervised_user_circle_outlined,
                                                                  color: AppColors
                                                                      .primaryColor,
                                                                  size: 51,
                                                                ),
                                                  8.sbw,
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        dataList1[index].isBusinessProfileView ==
                                                                    1 &&
                                                                dataList1[index]
                                                                        .isBusinessOldView ==
                                                                    0
                                                            ? 'XXXXX ' +
                                                                dataList1[index]
                                                                    .username!
                                                                    .split(' ')
                                                                    .last
                                                            : dataList1[index].isBusinessProfileView ==
                                                                        0 &&
                                                                    dataList1[index]
                                                                            .isBusinessOldView ==
                                                                        0
                                                                ? 'XXXXX ' +
                                                                    dataList1[
                                                                            index]
                                                                        .username!
                                                                        .split(
                                                                            ' ')
                                                                        .last
                                                                : dataList1[index].isBusinessProfileView ==
                                                                            1 &&
                                                                        dataList1[index].isBusinessOldView ==
                                                                            1
                                                                    ? dataList1[
                                                                            index]
                                                                        .username
                                                                        .toString()
                                                                    : 'XXXXX ' +
                                                                        dataList1[index]
                                                                            .username!
                                                                            .split(' ')
                                                                            .last,
                                                        style: const TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .blackColor,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf'),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child: Text(
                                                          dataList1[index]
                                                                  .businessTypeName ??
                                                              'N/A',
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .blackColor,
                                                            fontSize: 12.0,
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Icon(
                                                Icons.arrow_right,
                                                size: 30,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
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
                              },
                            ),
                    ),
                    ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(15),
                        shrinkWrap: true,
                        itemCount: dataList2.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              print('outsideTap');

                              final int? isBusinessProfileView =
                                  dataList2[index].isBusinessProfileView;

                              if (isBusinessProfileView != null) {
                                print(
                                    'isBusinessProfileView value: $isBusinessProfileView');

                                if (isBusinessProfileView == 1) {
                                  print('Redirecting to other_user_profile');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => other_user_profile(
                                          int.parse(dataList2[index]
                                              .userId
                                              .toString())),
                                    ),
                                  ).then((_) {
                                    get_share();
                                  });
                                } else if (isBusinessProfileView == 0) {
                                  print('Redirecting to Premium');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Premiun(),
                                    ),
                                  ).then((_) {
                                    get_share();
                                  });
                                  showCustomToast(
                                      'Upgrade Plan to View Profile');
                                }
                              } else {
                                print('isBusinessProfileView is null');
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Card(
                                color: AppColors.backgroundColor,
                                elevation: 9,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          dataList2[index].isBusinessProfileView ==
                                                      1 &&
                                                  dataList2[index]
                                                          .isBusinessOldView ==
                                                      0
                                              ? Icon(
                                                  Icons
                                                      .supervised_user_circle_outlined,
                                                  color: AppColors.primaryColor,
                                                  size: 51,
                                                )
                                              : dataList2[index]
                                                              .isBusinessProfileView ==
                                                          0 &&
                                                      dataList2[index]
                                                              .isBusinessOldView ==
                                                          0
                                                  ? Icon(
                                                      Icons
                                                          .supervised_user_circle_outlined,
                                                      color: AppColors
                                                          .primaryColor,
                                                      size: 51,
                                                    )
                                                  : dataList2[index]
                                                                  .isBusinessProfileView ==
                                                              1 &&
                                                          dataList2[index]
                                                                  .isBusinessOldView ==
                                                              1
                                                      ? CircleAvatar(
                                                          backgroundColor:
                                                              AppColors
                                                                  .backgroundColor,
                                                          radius: 25,
                                                          backgroundImage: dataList2[
                                                                          index]
                                                                      .imageUrl
                                                                      .toString() !=
                                                                  ''
                                                              ? NetworkImage(dataList2[
                                                                          index]
                                                                      .imageUrl
                                                                      .toString())
                                                                  as ImageProvider
                                                              : const AssetImage(
                                                                  'assets/plastic4trade logo final 1 (2).png'),
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .supervised_user_circle_outlined,
                                                          color: AppColors
                                                              .primaryColor,
                                                          size: 51,
                                                        ),
                                          8.sbw,
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dataList2[index].isBusinessProfileView ==
                                                            1 &&
                                                        dataList2[index]
                                                                .isBusinessOldView ==
                                                            0
                                                    ? 'XXXXX ' +
                                                        dataList2[index]
                                                            .username!
                                                            .split(' ')
                                                            .last
                                                    : dataList2[index]
                                                                    .isBusinessProfileView ==
                                                                0 &&
                                                            dataList2[index]
                                                                    .isBusinessOldView ==
                                                                0
                                                        ? 'XXXXX ' +
                                                            dataList2[index]
                                                                .username!
                                                                .split(' ')
                                                                .last
                                                        : dataList2[index]
                                                                        .isBusinessProfileView ==
                                                                    1 &&
                                                                dataList2[index]
                                                                        .isBusinessOldView ==
                                                                    1
                                                            ? dataList2[index]
                                                                .username
                                                                .toString()
                                                            : 'XXXXX ' +
                                                                dataList2[index]
                                                                    .username!
                                                                    .split(' ')
                                                                    .last,
                                                style: const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.blackColor,
                                                    fontFamily:
                                                        'assets/fonst/Metropolis-Black.otf'),
                                              ),
                                              Text(
                                                dataList2[index]
                                                        .businessTypeName ??
                                                    "Unknown",
                                                style: TextStyle(
                                                  color: AppColors.blackColor,
                                                  fontSize: 12.0,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_right,
                                        size: 30,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ],
          )
        : Center(
            child: Center(
              child: CustomLottieContainer(
                child: Lottie.asset(
                  'assets/loading_animation.json',
                ),
              ),
            ),
          );
  }
}

class ViewFollowerFollowingList extends StatefulWidget {
  String userId;
  late int tabIndex;

  ViewFollowerFollowingList(
      {Key? key, required this.userId, required this.tabIndex})
      : super(key: key);

  @override
  State<ViewFollowerFollowingList> createState() =>
      _ViewFollowerFollowingListState();
}

class _ViewFollowerFollowingListState extends State<ViewFollowerFollowingList>
    with SingleTickerProviderStateMixin {
  bool? isload;
  late TabController _tabController;
  List<getfllow.Result> getfollowdata = [];
  List<getfllowing.Result> getfllowingdata = [];
  int offset = 0;
  int count = 0;
  bool loadmore = false;
  bool isLoading = false;
  final scrollercontroller = ScrollController();
  final scrollercontrollerfollowing = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollercontroller.addListener(_scrollercontroller);
    scrollercontrollerfollowing.addListener(_scrollercontrollerfollowing);
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.tabIndex);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _refreshData();
      } else if (_tabController.index == 1) {
        _refreshDatafollowing();
      }
    });
    _refreshData();
    _refreshDatafollowing();
  }

  @override
  void dispose() {
    scrollercontroller.removeListener(_scrollercontroller);
    scrollercontrollerfollowing.removeListener(_scrollercontrollerfollowing);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      getfollowdata.clear();
      offset = 0;
    });

    await getFollower();

    setState(() {
      loadmore = true;
    });
    setState(() {
      isload = true;
    });

    return null;
  }

  Future<void> _refreshDatafollowing() async {
    setState(() {
      getfllowingdata.clear();
      offset = 0;
    });

    getFollowing();

    setState(() {
      loadmore = true;
    });
    setState(() {
      isload = true;
    });

    return null;
  }

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 0) ==
        (scrollercontroller.position.maxScrollExtent - 0)) {
      loadmore = false;
      if (getfollowdata.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 11;
        } else {
          offset = offset + 10;
        }
        getFollower();
      }
    }
  }

  void _scrollercontrollerfollowing() {
    if ((scrollercontrollerfollowing.position.pixels - 0) ==
        (scrollercontrollerfollowing.position.maxScrollExtent - 0)) {
      loadmore = false;
      if (getfllowingdata.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 11;
        } else {
          offset = offset + 10;
        }
        getFollowing();
      }
    }
  }

  Future<void> getFollower() async {
    if (isLoading) return;

    isLoading = true;

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      String device = '';
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }
      print('Device Name: $device');

      var res = await getOtherUserFollowerLists(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        offset.toString(),
        widget.userId,
        device,
      );

      var jsonArray;
      if (res['status'] == 1 &&
          res['result'] != null &&
          res['result'].isNotEmpty) {
        jsonArray = res['result'];
        followers_count = res['totalFollowers'];

        for (var data in jsonArray) {
          getfllow.Result record = getfllow.Result(
            isFollowing: data['is_following'],
            name: data['name'],
            id: data['id'],
            image: data['image'],
            status: data['Status'],
            businessType: data['businessType'],
            isBusinessProfileView: data['can_business_profile_view'],
            isBusinessOldView: data['check_old_view'],
          );

          getfollowdata.add(record);

          if (getfollowdata.isNotEmpty) {
            setState(() {
              loadmore = true;
            });
            setState(() {
              loadmore = getfollowdata.isNotEmpty;
            });
          } else {
            setState(() {
              loadmore = false;
            });
          }
          isload = true;
          print((res['result']));
        }
      } else {
        setState(() {
          loadmore = false;
        });
        print('Error Message: ${res['message']}');
        showCustomToast(res['message']);
      }
    } catch (e) {
      print('Error in getFollower: $e');
      showCustomToast('An error occurred while fetching followers.');
    } finally {
      isLoading = false;
    }
  }

  Future<void> getFollowing() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      String device = '';
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }
      print('Device Name: $device');

      var res = await getOtherUserFollowingList(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        offset.toString(),
        widget.userId,
        device,
      );

      var jsonArray;
      if (res['status'] == 1 &&
          res['result'] != null &&
          res['result'].isNotEmpty) {
        jsonArray = res['result'];
        following_count = res['totalFollowing'];

        for (var data in jsonArray) {
          getfllowing.Result record = getfllowing.Result(
            name: data['name'],
            id: data['id'],
            image: data['image'],
            status: data['Status'],
            businessType: data['businessType'],
            isBusinessProfileView: data['can_business_profile_view'],
            isBusinessOldView: data['check_old_view'],
          );
          getfllowingdata.add(record);
        }

        if (getfllowingdata.isNotEmpty) {
          setState(() {
            loadmore = true;
          });
        } else {
          setState(() {
            loadmore = false;
          });
        }
      } else {
        print(res['message']);
        showCustomToast(res['message']);
      }

      print("getfllowingdata:- ${getfllowingdata.length}");
      return jsonArray;
    } catch (e) {
      print("Error occurred in getFollowing(): $e");
      showCustomToast("An error occurred. Please try again.");
    } finally {
      setState(() {});
    }
  }

  Future<void> setfollowUnfollow(String follow, String otherUserId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await followUnfollow(
      follow,
      otherUserId,
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        jsonArray = res['result'];

        getFollowing();

        if (mounted) {
          setState(() {});
        }
      }
      showCustomToast(res['message']);
    } else {
      showCustomToast(res['message']);
    }

    setState(() {});
    return jsonArray;
  }

  @override
  Widget build(BuildContext context) {
    return isload == true
        ? Column(
            children: [
              const SizedBox(height: 5),
              Image.asset(
                'assets/hori_line.png',
                width: 150,
                height: 5,
              ),
              TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Followers'),
                  Tab(text: 'Following'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    RefreshIndicator(
                      backgroundColor: AppColors.primaryColor,
                      color: AppColors.backgroundColor,
                      onRefresh: () async {
                        _refreshData();
                      },
                      child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: scrollercontroller,
                          itemCount: getfollowdata.length + (loadmore ? 1 : 0),
                          padding: const EdgeInsets.fromLTRB(3.0, 0, 3.0, 0),
                          itemBuilder: (context, index) {
                            if (index < getfollowdata.length) {
                              print("data:-${getfollowdata.length}");
                              getfllow.Result result = getfollowdata[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          other_user_profile(result.id!),
                                    ),
                                  ).then((_) {
                                    _refreshData();
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: SizedBox(
                                    height: 80,
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      elevation: 5,
                                      child: Container(
                                        decoration: ShapeDecoration(
                                          color: AppColors.backgroundColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13.05),
                                          ),
                                          shadows: [
                                            BoxShadow(
                                              color:
                                                  AppColors.boxShadowforshimmer,
                                              blurRadius: 16.32,
                                              offset: Offset(0, 3.26),
                                              spreadRadius: 0,
                                            )
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  result.isBusinessProfileView ==
                                                              1 &&
                                                          result.isBusinessOldView ==
                                                              0
                                                      ? Icon(
                                                          Icons
                                                              .supervised_user_circle_outlined,
                                                          color: AppColors
                                                              .primaryColor,
                                                          size: 51,
                                                        )
                                                      : result.isBusinessProfileView ==
                                                                  0 &&
                                                              result.isBusinessOldView ==
                                                                  0
                                                          ? Icon(
                                                              Icons
                                                                  .supervised_user_circle_outlined,
                                                              color: AppColors
                                                                  .primaryColor,
                                                              size: 51,
                                                            )
                                                          : result.isBusinessProfileView ==
                                                                      1 &&
                                                                  result.isBusinessOldView ==
                                                                      1
                                                              ? CircleAvatar(
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .backgroundColor,
                                                                  radius: 25,
                                                                  backgroundImage: result
                                                                              .image
                                                                              .toString() !=
                                                                          ''
                                                                      ? NetworkImage(result
                                                                              .image
                                                                              .toString())
                                                                          as ImageProvider
                                                                      : const AssetImage(
                                                                          'assets/plastic4trade logo final 1 (2).png'),
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .supervised_user_circle_outlined,
                                                                  color: AppColors
                                                                      .primaryColor,
                                                                  size: 51,
                                                                ),
                                                  10.sbw,
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        result.isBusinessProfileView ==
                                                                    1 &&
                                                                result.isBusinessOldView ==
                                                                    0
                                                            ? 'XXXXX ' +
                                                                result.name!
                                                                    .split(' ')
                                                                    .last
                                                            : result.isBusinessProfileView ==
                                                                        0 &&
                                                                    result.isBusinessOldView ==
                                                                        0
                                                                ? 'XXXXX ' +
                                                                    result.name!
                                                                        .split(
                                                                            ' ')
                                                                        .last
                                                                : result.isBusinessProfileView ==
                                                                            1 &&
                                                                        result.isBusinessOldView ==
                                                                            1
                                                                    ? result
                                                                        .name
                                                                        .toString()
                                                                    : 'XXXXX ' +
                                                                        result
                                                                            .name!
                                                                            .split(' ')
                                                                            .last,
                                                        style: const TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .blackColor,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf'),
                                                      ),
                                                      2.sbh,
                                                      Container(
                                                        width: 160,
                                                        child: Text(
                                                          result.businessType ??
                                                              'N/A',
                                                          style: const TextStyle(
                                                              fontSize: 10.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: AppColors
                                                                  .blackColor,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf'),
                                                          maxLines: 1,
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  if (result.isFollowing == 1) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return CommanDialog(
                                                          title: "Followers",
                                                          content:
                                                              "Do you want to Unfollow?",
                                                          onPressed: () {
                                                            setState(() {
                                                              result.isFollowing =
                                                                  0;
                                                            });
                                                            setfollowUnfollow(
                                                                "0",
                                                                result.id
                                                                    .toString());
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    setState(() {
                                                      result.isFollowing = 1;
                                                    });
                                                    setfollowUnfollow("1",
                                                        result.id.toString());
                                                  }
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        AppColors.primaryColor,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(50),
                                                    ),
                                                  ),
                                                  height: 35,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4,
                                                  child: Text(
                                                    result.isFollowing == 1
                                                        ? 'Followed'
                                                        : 'Follow',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                    RefreshIndicator(
                      backgroundColor: AppColors.primaryColor,
                      color: AppColors.backgroundColor,
                      onRefresh: () async {
                        _refreshDatafollowing();
                      },
                      child: ListView.builder(
                          controller: scrollercontrollerfollowing,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              getfllowingdata.length + (loadmore ? 1 : 0),
                          padding: const EdgeInsets.fromLTRB(3.0, 0, 3.0, 0),
                          itemBuilder: (context, index) {
                            if (index < getfllowingdata.length) {
                              getfllowing.Result result =
                                  getfllowingdata[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          other_user_profile(result.id!),
                                    ),
                                  ).then((_) {
                                    _refreshDatafollowing();
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: SizedBox(
                                    height: 80,
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      elevation: 5,
                                      child: Container(
                                        decoration: ShapeDecoration(
                                          color: AppColors.backgroundColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13.05),
                                          ),
                                          shadows: [
                                            BoxShadow(
                                              color:
                                                  AppColors.boxShadowforshimmer,
                                              blurRadius: 16.32,
                                              offset: Offset(0, 3.26),
                                              spreadRadius: 0,
                                            )
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  result.isBusinessProfileView ==
                                                              1 &&
                                                          result.isBusinessOldView ==
                                                              0
                                                      ? Icon(
                                                          Icons
                                                              .supervised_user_circle_outlined,
                                                          color: AppColors
                                                              .primaryColor,
                                                          size: 51,
                                                        )
                                                      : result.isBusinessProfileView ==
                                                                  0 &&
                                                              result.isBusinessOldView ==
                                                                  0
                                                          ? Icon(
                                                              Icons
                                                                  .supervised_user_circle_outlined,
                                                              color: AppColors
                                                                  .primaryColor,
                                                              size: 51,
                                                            )
                                                          : result.isBusinessProfileView ==
                                                                      1 &&
                                                                  result.isBusinessOldView ==
                                                                      1
                                                              ? CircleAvatar(
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .backgroundColor,
                                                                  radius: 25,
                                                                  backgroundImage: result
                                                                              .image
                                                                              .toString() !=
                                                                          ''
                                                                      ? NetworkImage(result
                                                                              .image
                                                                              .toString())
                                                                          as ImageProvider
                                                                      : const AssetImage(
                                                                          'assets/plastic4trade logo final 1 (2).png'),
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .supervised_user_circle_outlined,
                                                                  color: AppColors
                                                                      .primaryColor,
                                                                  size: 51,
                                                                ),
                                                  10.sbw,
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        result.isBusinessProfileView ==
                                                                    1 &&
                                                                result.isBusinessOldView ==
                                                                    0
                                                            ? 'XXXXX ' +
                                                                result.name!
                                                                    .split(' ')
                                                                    .last
                                                            : result.isBusinessProfileView ==
                                                                        0 &&
                                                                    result.isBusinessOldView ==
                                                                        0
                                                                ? 'XXXXX ' +
                                                                    result.name!
                                                                        .split(
                                                                            ' ')
                                                                        .last
                                                                : result.isBusinessProfileView ==
                                                                            1 &&
                                                                        result.isBusinessOldView ==
                                                                            1
                                                                    ? result
                                                                        .name
                                                                        .toString()
                                                                    : 'XXXXX ' +
                                                                        result
                                                                            .name!
                                                                            .split(' ')
                                                                            .last,
                                                        style: const TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .blackColor,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf'),
                                                      ),
                                                      2.sbh,
                                                      Container(
                                                        width: 160,
                                                        child: Text(
                                                          result.businessType ??
                                                              'N/A',
                                                          style: const TextStyle(
                                                              fontSize: 10.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: AppColors
                                                                  .blackColor,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf'),
                                                          maxLines: 1,
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  if (result.isFollowing == 1) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return CommanDialog(
                                                          title: "Followers",
                                                          content:
                                                              "Do you want to Unfollow?",
                                                          onPressed: () {
                                                            setState(() {
                                                              result.isFollowing =
                                                                  0;
                                                            });
                                                            setfollowUnfollow(
                                                                "0",
                                                                result.id
                                                                    .toString());
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    setState(() {
                                                      result.isFollowing = 1;
                                                    });
                                                    setfollowUnfollow("1",
                                                        result.id.toString());
                                                  }
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        AppColors.primaryColor,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(50),
                                                    ),
                                                  ),
                                                  height: 35,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4,
                                                  child: Text(
                                                    (result.isFollowing == 1)
                                                        ? 'Followed'
                                                        : 'Follow',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                  ],
                ),
              ),
            ],
          )
        : Center(
            child: CustomLottieContainer(
              child: Lottie.asset(
                'assets/loading_animation.json',
              ),
            ),
          );
  }
}
