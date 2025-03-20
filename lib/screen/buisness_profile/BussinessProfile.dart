// ignore_for_file: avoid_print, camel_case_types, non_constant_identifier_names, invalid_return_type_for_catch_error, unnecessary_null_comparison, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, depend_on_referenced_packages, deprecated_member_use

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
import 'package:Plastic4trade/screen/buisness_profile/Bussinessinfo.dart';
import 'package:Plastic4trade/screen/buisness_profile/other_user_profile.dart';
import 'package:Plastic4trade/screen/chat/ChartDetail.dart';
import 'package:Plastic4trade/screen/chat/Chat.dart';
import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/save_user_id.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_chat_shimmer_loader.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/widget/customshimmer/custome_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_tab_view/scrollable_tab_view.dart';
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
import '../Follower_Following.dart';
import '../Review.dart';

// ignore: must_be_immutable
class bussinessprofile extends StatefulWidget {
  int user_id;

  bussinessprofile(this.user_id, {Key? key}) : super(key: key);

  @override
  State<bussinessprofile> createState() => _bussinessprofileState();
}

class _bussinessprofileState extends State<bussinessprofile>
    with TickerProviderStateMixin {
  late TabController _parentController;
  late TabController _childController;
  final scrollercontroller = ScrollController();
  String? username,
      appusername,
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
      pan_number,
      product_name,
      firstyear_amount,
      secondyear_amount,
      firstyear,
      secondYear,
      thirdYear,
      dynamicshortlink,
      thirdyear_amount;
  String? First_currency_sign = "",
      Second_currency_sign = "",
      Third_currency_sign = "";
  int? view_count,
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
  String crown_color = '';
  String plan_name = '';
  GetSalePostList salePostList = GetSalePostList();
  GetSalePostList buyPostList = GetSalePostList();
  int offset = 0;
  String post_count = "";
  int count = 0;
  String profileid = "";
  String? packageName;
  PackageInfo? packageInfo;
  List<homepost.PostColor> colors = [];
  List<homepost.Result> salepostlist_data = [];
  List<homepost.Result> buypostlist_data = [];
  List<homepost.Result>? resultList;
  String? last_seen = DateTime.now().toString();
  String? signup_date = "";
  bool? _isUserLoggedIn;

  int likeCount = 0;
  int like = 0;

  @override
  void initState() {
    _parentController = TabController(length: 2, vsync: this);
    int initialTabIndex =
        buypostlist_data.length >= salepostlist_data.length ? 0 : 1;
    _childController = TabController(length: 2, vsync: this);
    scrollercontroller.addListener(_scrollercontroller);
    checknetowork();
    _checkUserId();
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

  Future<void> _checkUserId() async {
    print("Starting _checkUserId method.");
    String? userId = await SharedPrefService.getUserId();
    print("Fetched userId from SharedPrefService: $userId");

    setState(() {
      // If userId is not null or empty, the user is logged in
      _isUserLoggedIn = userId != widget.user_id.toString();
      print("_isUserLoggedIn updated: $_isUserLoggedIn");
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
                  icon: Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      //isprofile=true;
    } else {
      getPackage();
      getBussinessProfile();
      getProfiless();
      get_userPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    return init(context);
  }

  Widget init(BuildContext context) {
    DateTime? signupdateDate = DateTime.tryParse(signup_date!);

    // Get the formatted relative date
    String formattedSignUpDate = signupdateDate != null
        ? _formatRelativeDate(signupdateDate)
        : "Invalid date";
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFFFFF),
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
        actions: [
          _isUserLoggedIn!
              ? SizedBox.shrink()
              : SizedBox(
                  width: 45,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Bussinessinfo(),
                        ),
                      );
                    },
                    icon: Image.asset('assets/edit.png'),
                  ),
                )
        ],
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            5.sbh,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _profileInfo2(),
            ),
            if (is_follow != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _isUserLoggedIn!
                          ? (is_follow == "0"
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
                                })
                          : null, // Disable onTap if _isUserLoggedIn is false
                      child: Opacity(
                        opacity: _isUserLoggedIn!
                            ? 1.0
                            : 0.5, // Reduce opacity when not logged in
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
                    ),
                    SizedBox(width: 30),
                    if (followers_count != null)
                      GestureDetector(
                        onTap: () {
                          if (_isUserLoggedIn!) {
                            viewFollowerFollowing(
                              context: context,
                              tabIndex: 0,
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const follower(
                                  initialIndex: 0,
                                ),
                              ),
                            );
                          }
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
                        if (_isUserLoggedIn!) {
                          viewFollowerFollowing(
                            context: context,
                            tabIndex: 1,
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const follower(
                                initialIndex: 1,
                              ),
                            ),
                          );
                        }
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Member Active at ${_formatTime(last_seen)}',
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
            _icon(),
            const Divider(
              color: Colors.black26,
              height: 2.0,
            ),
            _dividerSection(),
            const Divider(
              color: Colors.black26,
              height: 2.0,
            ),
            ScrollableTab(
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              dividerColor: Colors.grey,
              onTap: (value) {
                if (kDebugMode) {
                  print('index $value');
                }
              },
              tabs: [
                Tab(text: 'Product Catalogue ($post_count)'),
                const Tab(text: 'Business Info'),
              ],
              children: [
                isLoading ? PostWithShimmerLoader(context) : Buyer_post(),
                _businessInfo(),
              ],
            ),
          ],
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

  List<Widget> buildWidgets(String text) {
    List<Widget> widgets = [];
    final lines = text.split('\n');

    for (var line in lines) {
      widgets.add(buildLineWidget(line));
    }

    return widgets;
  }

  Widget _dividerSection() {
    return SizedBox(
      height: 47,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                child: Image.asset(
                  like == 0 ? 'assets/like.png' : 'assets/like1.png',
                  height: 20,
                  width: 20,
                ),
                onTap: () async {
                  try {
                    setState(() {
                      if (like == 0) {
                        like = 1;
                        likeCount = likeCount + 1;
                      } else {
                        like = 0;
                        likeCount = likeCount - 1;
                      }
                    });
                    await profileLikeHandler();
                  } catch (e) {
                    print('Error: $e');
                  }
                },
              ),
              const SizedBox(width: 2),
              if (likeCount != null)
                GestureDetector(
                  onTap: () {
                    ViewItem(context: context, tabIndex: 0);
                  },
                  child: Text(
                    'Like ($likeCount)',
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontFamily: 'Metropolis',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              print("profileid:-$profileid");
              var rev_count = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Review(profileid)));
              if (rev_count != null) {
                reviews_count = int.parse(rev_count.toString());
              }
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
                  width: 2,
                ),
                if (reviews_count != null)
                  Text('Reviews ($reviews_count)',
                      style: const TextStyle(
                        fontSize: 11.0,
                        fontFamily: 'Metropolis',
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ))
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
                ),
                if (view_count != null)
                  Text(
                    'Views ($view_count)',
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontFamily: 'Metropolis',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              String fullNumber = (b_countryCode ?? '') + '${bussmbl ?? ''}';

              sharecount();
              shareImage(
                dynamicshortlink: dynamicshortlink.toString(),
                url: image_url.toString(),
                userId: profileid.toString(),
                UserName: username.toString(),
                companyName: business_name.toString(),
                number: fullNumber,
                location: address.toString(),
                gst: gst_number.toString(),
                email: b_email.toString(),
                natureOfBusiness: business_type != null
                    ? business_type.toString().replaceAll(",", ", ")
                    : "",
                coreOfBusiness: core_business != null
                    ? core_business.toString().replaceAll(",", ", ")
                    : "",
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/Send.png',
                  height: 15,
                ),
                const SizedBox(
                  width: 2,
                ),
                const Text('Share',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontFamily: 'Metropolis',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_isUserLoggedIn!) {
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
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Chat(),
                      ),
                    );
                  }
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
              5.sbw,
              Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26, width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 3.8,
                      height: 25,
                      child: GestureDetector(
                        onTap: () async {
                          launchUrl(
                            Uri.parse('https://wa.me/$countryCode$usermbl' +
                                '?text=Hello $username \nI am $appusername \nI Saw Your Profile On Plastic4Trade App. \nI Want to Know About Your Business. \n\n' +
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
                        child: Row(
                          children: [
                            Image.asset(('assets/whatsapp.png')),
                            const Text('WhatsApp',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf',
                                    fontSize: 14,
                                    color: Colors.black)),
                          ],
                        ),
                      ))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        // Show a toast when no URL is found
                        showCustomToast(
                          "No Instagram URL found!",
                        );
                      } else {
                        // Proceed with launching the URL
                        launchUrl(
                          Uri.parse(instagram_url!),
                          mode: LaunchMode.externalApplication,
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
                        // Show a toast when no URL is found
                        showCustomToast(
                          "No LinkedIn URL found!",
                        );
                      } else {
                        // Proceed with launching the URL
                        launchUrl(
                          Uri.parse(linkedin_url!),
                          mode: LaunchMode.externalApplication,
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
                        // Show a toast when no URL is found
                        showCustomToast(
                          "No YouTube URL found!",
                        );
                      } else {
                        // Proceed with launching the URL
                        launchUrl(
                          Uri.parse(youtube_url!),
                          mode: LaunchMode.externalApplication,
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
                        // Show a toast when no URL is found
                        showCustomToast(
                          "No Twitter URL found!",
                        );
                      } else {
                        // Proceed with launching the URL
                        launchUrl(
                          Uri.parse(twitter_url!),
                          mode: LaunchMode.externalApplication,
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
                        // Show a toast when no URL is found
                        showCustomToast(
                          "No Telegram URL found!",
                        );
                      } else {
                        // Proceed with launching the URL
                        launchUrl(
                          Uri.parse(telegram_url!),
                          mode: LaunchMode.externalApplication,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileInfo2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (image_url != null && image_url!.isNotEmpty) {
                  // Redirect to full-screen dialog
                  _showFullScreenDialog(context);
                } else {
                  showCustomToast("No image available to view");
                }
              },
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
                  else if (crown_color != null && crown_color.length > 1)
                    Container(
                      width: 110.0,
                      height: 110.0,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(int.parse(crown_color.substring(1),
                                        radix: 16) |
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
                          ),
                          child: image_url != null && image_url!.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: image_url.toString(),
                                    fit: BoxFit.cover,
                                    width: 100.0,
                                    height: 100.0,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'No image found',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color(
                                        int.parse(crown_color.substring(1),
                                                radix: 16) |
                                            0xFF000000,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (crown_color != null &&
                crown_color.length > 1 &&
                plan_name != null)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 70,
                  height: 20,
                  alignment: Alignment.center,
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
                      plan_name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'Metropolis-SemiBold',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
                          width: 260,
                          height: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 180,
                          height: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 160,
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
              ),
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

  Widget _businessInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: Colors.white),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text('Nature Of Business',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38,
                            )),
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              business_type != null
                                  ? business_type
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
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text('Our Products',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                fontSize: 12,
                                color: Colors.black38)),
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              product_name.toString().replaceAll(",", ", "),
                              softWrap: true,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          )),
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
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text('Business Phone',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf',
                                          fontSize: 12,
                                          color: Colors.black38)),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: GestureDetector(
                                      onTap: () => launchUrl(
                                            Uri.parse(
                                                'tel:$b_countryCode + $bussmbl'),
                                            mode:
                                                LaunchMode.externalApplication,
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
                                      )),
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Text('Business Email',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf',
                                        fontSize: 12,
                                        color: Colors.black38)),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: GestureDetector(
                                      onTap: () => launchUrl(
                                        Uri.parse(
                                            'mailto:${b_email.toString()}'),
                                        mode: LaunchMode.externalApplication,
                                      ),
                                      child: Text(b_email.toString(),
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf',
                                              fontSize: 13,
                                              color: Colors.black)),
                                    )),
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
                        child: Text('Website',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                fontSize: 12,
                                color: Colors.black38)),
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
                                      (e) => print('Error launching URL: $e'));
                            },
                            child: Text(website.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf',
                                    fontSize: 13,
                                    color: Colors.black)),
                          )),
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
                        child: Text('About Your Business',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38,
                            )),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...buildWidgets(abot_buss ?? ""),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
            Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'GST/VAT/TAX',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontSize: 12,
                              color: Colors.black38),
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
                                                    color:
                                                        Colors.orange.shade600,
                                                  )
                                                : gst_verification_status == 3
                                                    ? Icon(
                                                        Icons.info,
                                                        color:
                                                            Colors.red.shade600,
                                                      )
                                                    : gst_verification_status ==
                                                            4
                                                        ? Icon(
                                                            Icons.block,
                                                            color: Colors
                                                                .red.shade600,
                                                          )
                                                        : gst_verification_status ==
                                                                5
                                                            ? Icon(
                                                                Icons
                                                                    .cancel_outlined,
                                                                color: Colors
                                                                    .red
                                                                    .shade600,
                                                              )
                                                            : gst_verification_status ==
                                                                    6
                                                                ? Icon(
                                                                    Icons.block,
                                                                    color: Colors
                                                                        .red
                                                                        .shade600,
                                                                  )
                                                                : Container(),
                                ],
                              ),
                              5.sbw,
                              if (gst_number != "")
                                Text(
                                  gst_verification_status == 0
                                      ? 'Not Verified'
                                      : gst_verification_status == 1
                                          ? 'Verified'
                                          : gst_verification_status == 2
                                              ? 'Irrelevant'
                                              : gst_verification_status == 3
                                                  ? 'Not Available'
                                                  : gst_verification_status == 4
                                                      ? 'Canceled'
                                                      : gst_verification_status ==
                                                              5
                                                          ? 'Suspended'
                                                          : gst_verification_status ==
                                                                  6
                                                              ? 'Suo Moto'
                                                              : 'Unknown Status',
                                  style: TextStyle(
                                    color: gst_verification_status == 0
                                        ? AppColors.red
                                        : gst_verification_status == 1
                                            ? Colors.green
                                            : gst_verification_status == 2
                                                ? Colors.orange
                                                : gst_verification_status == 3
                                                    ? Colors.red
                                                    : gst_verification_status ==
                                                            4
                                                        ? Colors.red
                                                        : gst_verification_status ==
                                                                5
                                                            ? Colors
                                                                .red // Example color for Suspended
                                                            : gst_verification_status ==
                                                                    6
                                                                ? Colors
                                                                    .red // Example color for Suo Moto
                                                                : Colors.black,
                                    fontSize: 13,
                                    fontFamily: 'Metropolis',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          )),
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
                            color: Colors.black38,
                          ),
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
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text('Production Capacity',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                fontSize: 12,
                                color: Colors.black38)),
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
                          )),
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
                        child: Text('Annual Turnover',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                fontSize: 12,
                                color: Colors.black38)),
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
                                  ? Text('$thirdYear : $thirdyear_amount',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf',
                                          fontSize: 14,
                                          color: Colors.black))
                                  : SizedBox.shrink(),
                            ],
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
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text('Premises Type',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                fontSize: 12,
                                color: Colors.black38)),
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
                          )),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildLineWidget(String line) {
    final words = line.split(' ');

    List<Widget> lineWidgets = [];
    for (var word in words) {
      if (RegExp(r'https?://[^\s/$.?#].[^\s]*').hasMatch(word)) {
        // Handle links
        lineWidgets.add(GestureDetector(
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
        ));
      } else if (RegExp(r'\b\d{10}\b').hasMatch(word)) {
        // Handle phone numbers
        String phoneNumber = RegExp(r'\b\d{10}\b').stringMatch(word)!;
        lineWidgets.add(GestureDetector(
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
        ));
      } else if (word.endsWith('.com') || word.endsWith('.in')) {
        // Handle website URLs with .com or .in extension
        String url = word;
        if (!url.startsWith('http')) {
          url = 'http://$url';
        }
        lineWidgets.add(GestureDetector(
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
        ));
      } else {
        // Handle regular text
        lineWidgets.add(Text(
          word,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ));
      }
      lineWidgets
          .add(const SizedBox(width: 4)); // Add some spacing between words
    }
    return Wrap(
      direction: Axis.horizontal,
      // This ensures the children are laid out horizontally
      children: lineWidgets,
    );
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
      pref.getString('user_id').toString(),
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

  Widget Buyer_post() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: MediaQuery.of(context).size.width / 620,
        crossAxisCount: 2,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
      ),
      physics: const NeverScrollableScrollPhysics(),
      controller: scrollercontroller,
      itemCount: buypostlist_data.isEmpty ? 1 : buypostlist_data.length + 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == buypostlist_data.length) {
          if (BuyerPostToLoad() && !buypostlist_data.isEmpty) {
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
                              color: result.isPaidPost == 'Paid' ||
                                      result.isSuspeded == '0'
                                  ? Colors.red
                                  : Colors.transparent,
                              width: result.isPaidPost == 'Paid' ||
                                      result.isSuspeded == '0'
                                  ? 2.5
                                  : 0,
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
                        if (result.isPaidPost == 'Paid' &&
                            result.isSuspeded == '1')
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
                          ),
                        if (result.isSuspeded == '0' &&
                            result.isPaidPost != 'Paid')
                          Positioned(
                            top: -20,
                            left: -25,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Image.asset(
                                'assets/suspended.png',
                                height: 80,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
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

  bool BuyerPostToLoad() {
    int itemsPerPage = 20;
    return buypostlist_data.length % itemsPerPage == 0;
  }

  void _scrollercontroller() {
    if (scrollercontroller.position.pixels ==
        scrollercontroller.position.maxScrollExtent) {
      if (buypostlist_data.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 31;
        } else {
          offset = offset + 20;
        }
        get_userPost();
      }
    }
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

  getBussinessProfile() async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String device = '';
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }

      print('Device Name: $device');
      print('User ID: ${_pref.getString('user_id')}');
      print('API Token: ${_pref.getString('userToken')}');

      var res = await getuser_Profile(
        _pref.getString('user_id').toString(),
        _pref.getString('userToken').toString(),
        device,
      );

      // Print the entire response
      print('Full Response: $res');

      // Check if the status is successful
      if (res['status'] == 1) {
        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(res)));

        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');

        var jsonarray = res['user'];
        appusername = jsonarray['username'];
        print('User Name: ${jsonarray['username']}');
      } else {
        print('Error Message: ${res['message']}');
        showCustomToast(res['message']);
      }
    } catch (error, stacktrace) {
      // Catch and print any error that occurs
      print('Error: $error');
      print('Stacktrace: $stacktrace');
    }
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
      widget.user_id.toString(),
      context,
    );

    if (res['status'] == 1) {
      last_seen = res['user']['last_seen'] ?? "";
      print('last_seen: $last_seen');
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(device)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      chat_Id2 = res['chat_id2'] ?? 0;

      profileid = res['profile']['user_id'];
      username = res['user']['username'];
      print('Username From getProfiless: $username');

      instagram_url = res['profile']['instagram_link'];
      youtube_url = res['profile']['youtube_link'];
      facebook_url = res['profile']['facebook_link'];
      linkedin_url = res['profile']['linkedin_link'];
      print('linkedin_url: $linkedin_url');

      twitter_url = res['profile']['twitter_link'];
      telegram_url = res['profile']['telegram_link'];
      print('telegram_url: $telegram_url');
      business_phone_url = res['user']['business_phone'];
      other_email_url = res['user']['other_email'];
      business_name = res['profile']['business_name'];

      email = res['user']['email'] ?? "";
      b_email = res['profile']['other_email'] ?? "";
      website = res['profile']['website'] ?? "";
      bussmbl = res['profile']['business_phone'] ?? "";
      usermbl = res['user']['phoneno'] ?? "";
      address = res['profile']['address'];
      post_count = res['profile']['post_count'] ?? "";
      b_countryCode = res['profile']['countryCode'];

      countryCode = res['user']['countryCode'];
      signup_date = res['user']['signup_date'] ?? "";

      dynamicshortlink = res['profile']['full_url'] ?? "";

      log("MOBILE NUMBER  === $business_phone_url");
      log("MOBILE NUMBER URL === $bussmbl");

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

      view_count = res['profile']['view_count'];
      verify_status = res['profile']['verification_status'];
      trusted_status = res['profile']['trusted_status'];
      gst_verification_status = res['profile']['gst_verification_status'];

      like = res['profile']['is_like'];
      reviews_count = res['profile']['reviews_count'];
      following_count = res['profile']['following_count'];
      followers_count = res['profile']['followers_count'];

      likeCount = res['profile']['like_count'];
      is_follow = res['profile']['is_follow'];
      abot_buss = res['profile']['about_business'] ?? "";
      image_url = res['user']['image_url'];
      is_prime = res['user']['is_prime'];
      crown_color = res['user']['crown_color'];
      print('api responce: $plan_name');
      plan_name = res['user']['plan_name'] ?? "";
      print('app responce: $plan_name');

      gst_number = res['profile']['gst_tax_vat'] ?? '';
      Premises_Type = res['profile']['premises'] ?? '';

      pan_number = res['profile']['pan_number'] ?? '';

      ex_import_number = res['profile']['export_import_number'] ?? '';

      if (res['profile']['production_capacity'] != null) {
        production_capacity = res['profile']['annualcapacity']['name'] ?? '';
      } else {
        production_capacity = '';
      }

      business_type = res['profile']['business_type_name'] ?? '';
      core_business = res['profile']['core_businesses_name'] ?? '';

      product_name = res['profile']['product_name'] ?? '';

      print('product_name_business_profile ${res['profile']['product_name']}');
    } else {
      showCustomToast(res['message']);
    }

    setState(() {});
  }

  get_userPost() async {
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
      '50',
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
              isSuspeded: data['status'],
              productId: data['productId'],
              productType: data['ProductType'],
              unit: data['Unit'],
              postQuntity: data['PostQuntity'],
              productStatus: data['product_status'],
              mainproductImage: data['mainproductImage']);
          buypostlist_data.add(record);
        }

        isload = true;
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      isload = true;
    }
    setState(() {});
    return jsonArray;
  }

  Future<void> profileLikeHandler() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    try {
      var res = await profile_like(
        profileid.toString(),
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        device,
      );

      print('profileid: ${profileid.toString()}');
      print('user_id: ${pref.getString('user_id').toString()}');
      print('userToken: ${pref.getString('userToken').toString()}');
      print('device: $device');

      if (res['status'] == 1) {
        showCustomToast(res['message']);

        var compressedData = GZipCodec().encode(utf8.encode(jsonEncode(res)));
        print('Size of compressed data: ${compressedData.length} bytes');
      } else {
        showCustomToast(res['message']);
      }
    } catch (e) {
      showCustomToast('An error occurred while liking the profile.');
      print('Error: $e');
    }

    setState(() {});
  }

  ViewItem({required BuildContext context, int tabIndex = 0}) {
    return showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        )),
        builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize:
                0.60, // Initial height as a fraction of screen height
            builder: (BuildContext context, ScrollController scrollController) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return ViewWidget(
                    profileid: profileid.toString(),
                    tabIndex: tabIndex,
                  );
                },
              );
            })).then(
      (value) {},
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

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
  }

  void shareImage({
    required String dynamicshortlink,
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
        dynamicshortlink,
        'UserProfile',
        userId,
      );

      // Step 2: Fetch image and save it locally
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load image from the server');
      }

      final bytes = response.bodyBytes;
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/image.jpg';
      File(path).writeAsBytesSync(bytes);

      // Step 3: Prepare share text with the dynamic link
      final shareText = "Name: $UserName\n" +
          "Company: $companyName\n" +
          "Nature of Business: $natureOfBusiness\n" +
          "Core Business: $coreOfBusiness\n" +
          "Location: $location\n" +
          "GST: $gst\n" +
          "Number: $number\n" +
          "Email: $email\n\n" +
          "Plastic4trade is a B2B Plastic Business App, Buy & Sell your Products, Raw Material, Recycle Plastic Scrap, Plastic Machinery, Polymer Price, News, Update for Manufacturers, Traders, Exporters, Importers....\n\n" +
          "More Info: $dynamicLink";

      // Step 4: Share the image and text
      await Share.shareFiles([path], text: shareText);
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error sharing image: $e');
    }
  }
}

// ignore: must_be_immutable
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
  String? assignedName;
  bool? isload;
  late TabController _tabController;
  List<like.Data> dataList = [];
  List<view_pro.Data> dataList1 = [];
  List<share_pro.Data> dataList2 = [];
  int currentPage = 1;
  final int pageSize = 20;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int offset = 0;
  int count = 0;
  bool loadmore = false;
  bool isLoading = false;
  ScrollController _scrollControllerlike = ScrollController();

  final scrollercontroller = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshData();
    scrollercontroller.addListener(_scrollercontroller);

    _tabController =
        TabController(length: 3, vsync: this, initialIndex: widget.tabIndex);
    _scrollControllerlike.addListener(_scrollListenerlike);
    get_like();
    get_share();
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

  @override
  void dispose() {
    scrollercontroller.removeListener(_scrollercontroller);
    _tabController.dispose();
    super.dispose();
  }

  void _scrollListenerlike() {
    if (_scrollControllerlike.position.pixels ==
            _scrollControllerlike.position.maxScrollExtent &&
        !isLoadingMore) {
      // Load more data when scrolled to the bottom
      get_like(loadMore: true);
    }
  }

  Future<void> get_like({bool loadMore = false}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (isLoadingMore || !hasMoreData) return;

    if (loadMore) {
      setState(() {
        isLoadingMore = true;
      });
    }

    var res = await get_profileliked_user(
      widget.profileid,
      pref.getString('user_id').toString(),
      currentPage,
      pageSize,
    );

    if (res['status'] == 1) {
      List<like.Data> newDataList = Get_likeUser.fromJson(res).data ?? [];
      setState(() {
        if (newDataList.length < pageSize) {
          hasMoreData = false; // No more data available
        }

        dataList.addAll(newDataList);
        currentPage++; // Increment page for next load
      });
    } else {
      showCustomToast(res['message']);
    }

    setState(() {
      isLoadingMore = false;
    });
  }

  Future<void> get_view() async {
    if (isLoading) return;

    isLoading = true;
    SharedPreferences pref = await SharedPreferences.getInstance();

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

        if (newData.isNotEmpty) {
          setState(() {
            dataList1.addAll(newData as Iterable<view_pro.Data>);
            loadmore = newData.length == 10;
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
    GetShareUser common = GetShareUser();
    SharedPreferences pref = await SharedPreferences.getInstance();

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

  // Method to refresh data
  Future<void> _refreshData() async {
    // Reset current page and clear the list for fresh data
    setState(() {
      currentPage = 1;
      dataList1.clear(); // Clear the existing data
      hasMoreData = true; // Reset to allow fetching more data
    });

    await get_view(); // Fetch the data again
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
                                      builder: (context) => bussinessprofile(
                                          int.parse(dataList[index]
                                              .userId
                                              .toString())),
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
                                  showCustomToast(
                                      'Upgrade Plan to View Profile');
                                }
                              } else {
                                print('isBusinessProfileView is null');
                              }
                            },
                            child: Card(
                              color: AppColors.backgroundColor,
                              elevation: 9,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
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
                                            ? Column(
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: ShapeDecoration(
                                                      shape: CircleBorder(
                                                        side: BorderSide(
                                                          width: 2,
                                                          color: dataList[index]
                                                                      .crowncolor !=
                                                                  null
                                                              ? Color(int.parse(
                                                                      dataList[
                                                                              index]
                                                                          .crowncolor
                                                                          .toString()
                                                                          .substring(
                                                                              1),
                                                                      radix:
                                                                          16) |
                                                                  0xFF000000)
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons
                                                            .supervised_user_circle_outlined,
                                                        color: AppColors
                                                            .primaryColor,
                                                        size: 45,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 49,
                                                    height: 13,
                                                    alignment: Alignment.center,
                                                    transform: Matrix4
                                                        .translationValues(
                                                            0.0, -10.0, 0.0),
                                                    decoration: ShapeDecoration(
                                                      color: dataList[index]
                                                                  .crowncolor
                                                                  .toString() !=
                                                              null
                                                          ? Color(int.parse(
                                                                  dataList[
                                                                          index]
                                                                      .crowncolor
                                                                      .toString()
                                                                      .substring(
                                                                          1),
                                                                  radix: 16) |
                                                              0xFF000000)
                                                          : Colors.black,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(40),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      dataList[index]
                                                          .planname
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontFamily:
                                                            'assets/fonts/Metropolis-SemiBold.otf',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: -0.24,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : dataList[index]
                                                            .isBusinessProfileView ==
                                                        0 &&
                                                    dataList[index]
                                                            .isBusinessOldView ==
                                                        0
                                                ? Column(
                                                    children: [
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration:
                                                            ShapeDecoration(
                                                          shape: CircleBorder(
                                                            side: BorderSide(
                                                              width: 2,
                                                              color: dataList[index]
                                                                          .crowncolor !=
                                                                      null
                                                                  ? Color(int.parse(
                                                                          dataList[index]
                                                                              .crowncolor
                                                                              .toString()
                                                                              .substring(
                                                                                  1),
                                                                          radix:
                                                                              16) |
                                                                      0xFF000000)
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                            Icons
                                                                .supervised_user_circle_outlined,
                                                            color: AppColors
                                                                .primaryColor,
                                                            size: 45,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 49,
                                                        height: 13,
                                                        alignment:
                                                            Alignment.center,
                                                        transform: Matrix4
                                                            .translationValues(
                                                                0.0,
                                                                -10.0,
                                                                0.0),
                                                        decoration:
                                                            ShapeDecoration(
                                                          color: dataList[index]
                                                                      .crowncolor
                                                                      .toString() !=
                                                                  null
                                                              ? Color(int.parse(
                                                                      dataList[
                                                                              index]
                                                                          .crowncolor
                                                                          .toString()
                                                                          .substring(
                                                                              1),
                                                                      radix:
                                                                          16) |
                                                                  0xFF000000)
                                                              : Colors.black,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        40),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          dataList[index]
                                                              .planname
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 9,
                                                            fontFamily:
                                                                'assets/fonts/Metropolis-SemiBold.otf',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            letterSpacing:
                                                                -0.24,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : dataList[index]
                                                                .isBusinessProfileView ==
                                                            1 &&
                                                        dataList[index]
                                                                .isBusinessOldView ==
                                                            1
                                                    ? Column(
                                                        children: [
                                                          Container(
                                                            width: 51,
                                                            height: 51,
                                                            decoration:
                                                                ShapeDecoration(
                                                              shape:
                                                                  CircleBorder(
                                                                side:
                                                                    BorderSide(
                                                                  width: 2,
                                                                  color: dataList[index]
                                                                              .crowncolor
                                                                              .toString() !=
                                                                          null
                                                                      ? Color(int.parse(dataList[index].crowncolor.toString().substring(1),
                                                                              radix:
                                                                                  16) |
                                                                          0xFF000000)
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                            child: ClipOval(
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: dataList[
                                                                        index]
                                                                    .imageUrl
                                                                    .toString(),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 49,
                                                            height: 13,
                                                            alignment: Alignment
                                                                .center,
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    0.0,
                                                                    -10.0,
                                                                    0.0),
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: dataList[index]
                                                                          .crowncolor
                                                                          .toString() !=
                                                                      null
                                                                  ? Color(int.parse(
                                                                          dataList[index]
                                                                              .crowncolor
                                                                              .toString()
                                                                              .substring(
                                                                                  1),
                                                                          radix:
                                                                              16) |
                                                                      0xFF000000)
                                                                  : Colors
                                                                      .black,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              dataList[index]
                                                                  .planname
                                                                  .toString()
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 9,
                                                                fontFamily:
                                                                    'assets/fonts/Metropolis-SemiBold.otf',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    -0.24,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Column(
                                                        children: [
                                                          Container(
                                                            width: 50,
                                                            height: 50,
                                                            decoration:
                                                                ShapeDecoration(
                                                              shape:
                                                                  CircleBorder(
                                                                side:
                                                                    BorderSide(
                                                                  width: 2,
                                                                  color: dataList[index]
                                                                              .crowncolor !=
                                                                          null
                                                                      ? Color(int.parse(dataList[index].crowncolor.toString().substring(1),
                                                                              radix:
                                                                                  16) |
                                                                          0xFF000000)
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .supervised_user_circle_outlined,
                                                                color: AppColors
                                                                    .primaryColor,
                                                                size: 45,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 49,
                                                            height: 13,
                                                            alignment: Alignment
                                                                .center,
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    0.0,
                                                                    -10.0,
                                                                    0.0),
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: dataList[index]
                                                                          .crowncolor
                                                                          .toString() !=
                                                                      null
                                                                  ? Color(int.parse(
                                                                          dataList[index]
                                                                              .crowncolor
                                                                              .toString()
                                                                              .substring(
                                                                                  1),
                                                                          radix:
                                                                              16) |
                                                                      0xFF000000)
                                                                  : Colors
                                                                      .black,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              dataList[index]
                                                                  .planname
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 9,
                                                                fontFamily:
                                                                    'assets/fonts/Metropolis-SemiBold.otf',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    -0.24,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                        8.sbw,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dataList[index].isBusinessProfileView ==
                                                          1 &&
                                                      dataList[index]
                                                              .isBusinessOldView ==
                                                          0
                                                  ? 'XXXXX ' +
                                                      dataList[index]
                                                          .username!
                                                          .split(' ')
                                                          .last
                                                  : dataList[index]
                                                                  .isBusinessProfileView ==
                                                              0 &&
                                                          dataList[index]
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
                                            Container(
                                              width: 140,
                                              child: Text(
                                                dataList[index]
                                                    .businessTypeName
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.blackColor,
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
                                    Icon(
                                      Icons.arrow_right,
                                      size: 30,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    // Adjust the ListView.builder to show shimmer loader at the end
                    RefreshIndicator(
                      backgroundColor: AppColors.primaryColor,
                      color: AppColors.backgroundColor,
                      onRefresh: _refreshData,
                      child: dataList1.isEmpty
                          ? SizedBox()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
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
                                                  bussinessprofile(int.parse(
                                                      dataList1[index]
                                                          .userId
                                                          .toString())),
                                            ),
                                          ).then((_) {
                                            _refreshData();
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
                                            _refreshData();
                                          });
                                          showCustomToast(
                                              'Upgrade Plan to View Profile');
                                        }
                                      } else {
                                        print('isBusinessProfileView is null');
                                      }
                                    },
                                    child: Card(
                                      color: AppColors.backgroundColor,
                                      elevation: 9,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
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
                                                    ? Column(
                                                        children: [
                                                          Container(
                                                            width: 50,
                                                            height: 50,
                                                            decoration:
                                                                ShapeDecoration(
                                                              shape:
                                                                  CircleBorder(
                                                                side:
                                                                    BorderSide(
                                                                  width: 2,
                                                                  color: dataList1[index]
                                                                              .crowncolor !=
                                                                          null
                                                                      ? Color(int.parse(dataList1[index].crowncolor.toString().substring(1),
                                                                              radix:
                                                                                  16) |
                                                                          0xFF000000)
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .supervised_user_circle_outlined,
                                                                color: AppColors
                                                                    .primaryColor,
                                                                size: 45,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 49,
                                                            height: 13,
                                                            alignment: Alignment
                                                                .center,
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    0.0,
                                                                    -10.0,
                                                                    0.0),
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: dataList1[
                                                                              index]
                                                                          .crowncolor
                                                                          .toString() !=
                                                                      null
                                                                  ? Color(int.parse(
                                                                          dataList1[index]
                                                                              .crowncolor
                                                                              .toString()
                                                                              .substring(
                                                                                  1),
                                                                          radix:
                                                                              16) |
                                                                      0xFF000000)
                                                                  : Colors
                                                                      .black,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              dataList1[index]
                                                                  .planname
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 9,
                                                                fontFamily:
                                                                    'assets/fonts/Metropolis-SemiBold.otf',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    -0.24,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : dataList1[index]
                                                                    .isBusinessProfileView ==
                                                                0 &&
                                                            dataList1[index]
                                                                    .isBusinessOldView ==
                                                                0
                                                        ? Column(
                                                            children: [
                                                              Container(
                                                                width: 50,
                                                                height: 50,
                                                                decoration:
                                                                    ShapeDecoration(
                                                                  shape:
                                                                      CircleBorder(
                                                                    side:
                                                                        BorderSide(
                                                                      width: 2,
                                                                      color: dataList1[index].crowncolor !=
                                                                              null
                                                                          ? Color(int.parse(dataList1[index].crowncolor.toString().substring(1), radix: 16) |
                                                                              0xFF000000)
                                                                          : Colors
                                                                              .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .supervised_user_circle_outlined,
                                                                    color: AppColors
                                                                        .primaryColor,
                                                                    size: 45,
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 49,
                                                                height: 13,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                transform: Matrix4
                                                                    .translationValues(
                                                                        0.0,
                                                                        -10.0,
                                                                        0.0),
                                                                decoration:
                                                                    ShapeDecoration(
                                                                  color: dataList1[index]
                                                                              .crowncolor
                                                                              .toString() !=
                                                                          null
                                                                      ? Color(int.parse(dataList1[index].crowncolor.toString().substring(1),
                                                                              radix:
                                                                                  16) |
                                                                          0xFF000000)
                                                                      : Colors
                                                                          .black,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            40),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  dataList1[
                                                                          index]
                                                                      .planname
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: 9,
                                                                    fontFamily:
                                                                        'assets/fonts/Metropolis-SemiBold.otf',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    letterSpacing:
                                                                        -0.24,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : dataList1[index]
                                                                        .isBusinessProfileView ==
                                                                    1 &&
                                                                dataList1[index]
                                                                        .isBusinessOldView ==
                                                                    1
                                                            ? Column(
                                                                children: [
                                                                  Container(
                                                                    width: 51,
                                                                    height: 51,
                                                                    decoration:
                                                                        ShapeDecoration(
                                                                      shape:
                                                                          CircleBorder(
                                                                        side:
                                                                            BorderSide(
                                                                          width:
                                                                              2,
                                                                          color: dataList1[index].crowncolor.toString() != null
                                                                              ? Color(int.parse(dataList1[index].crowncolor.toString().substring(1), radix: 16) | 0xFF000000)
                                                                              : Colors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        ClipOval(
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        imageUrl: dataList1[index]
                                                                            .imageUrl
                                                                            .toString(),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 49,
                                                                    height: 13,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    transform: Matrix4
                                                                        .translationValues(
                                                                            0.0,
                                                                            -10.0,
                                                                            0.0),
                                                                    decoration:
                                                                        ShapeDecoration(
                                                                      color: dataList1[index].crowncolor.toString() !=
                                                                              null
                                                                          ? Color(int.parse(dataList1[index].crowncolor.toString().substring(1), radix: 16) |
                                                                              0xFF000000)
                                                                          : Colors
                                                                              .black,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(40),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      dataList1[
                                                                              index]
                                                                          .planname
                                                                          .toString()
                                                                          .toString(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            9,
                                                                        fontFamily:
                                                                            'assets/fonts/Metropolis-SemiBold.otf',
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        letterSpacing:
                                                                            -0.24,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Column(
                                                                children: [
                                                                  Container(
                                                                    width: 50,
                                                                    height: 50,
                                                                    decoration:
                                                                        ShapeDecoration(
                                                                      shape:
                                                                          CircleBorder(
                                                                        side:
                                                                            BorderSide(
                                                                          width:
                                                                              2,
                                                                          color: dataList1[index].crowncolor != null
                                                                              ? Color(int.parse(dataList1[index].crowncolor.toString().substring(1), radix: 16) | 0xFF000000)
                                                                              : Colors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .supervised_user_circle_outlined,
                                                                        color: AppColors
                                                                            .primaryColor,
                                                                        size:
                                                                            45,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 49,
                                                                    height: 13,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    transform: Matrix4
                                                                        .translationValues(
                                                                            0.0,
                                                                            -10.0,
                                                                            0.0),
                                                                    decoration:
                                                                        ShapeDecoration(
                                                                      color: dataList1[index].crowncolor.toString() !=
                                                                              null
                                                                          ? Color(int.parse(dataList1[index].crowncolor.toString().substring(1), radix: 16) |
                                                                              0xFF000000)
                                                                          : Colors
                                                                              .black,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(40),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      dataList1[
                                                                              index]
                                                                          .planname
                                                                          .toString(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            9,
                                                                        fontFamily:
                                                                            'assets/fonts/Metropolis-SemiBold.otf',
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        letterSpacing:
                                                                            -0.24,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                8.sbw,
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      dataList1[index].isBusinessProfileView ==
                                                                  1 &&
                                                              dataList1[
                                                                          index]
                                                                      .isBusinessOldView ==
                                                                  0
                                                          ? 'XXXXX ' +
                                                              dataList1[
                                                                      index]
                                                                  .username!
                                                                  .split(' ')
                                                                  .last
                                                          : dataList1[index]
                                                                          .isBusinessProfileView ==
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
                                                              : dataList1[index]
                                                                              .isBusinessProfileView ==
                                                                          1 &&
                                                                      dataList1[
                                                                                  index]
                                                                              .isBusinessOldView ==
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
                                                      width: 140,
                                                      child: Text(
                                                        dataList1[index]
                                                            .businessTypeName
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                            Icon(
                                              Icons.arrow_right,
                                              size: 30,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (loadmore) {
                                  // Show the shimmer loader when loading more data
                                  return ChatShimmerLoader(
                                    width: 175,
                                    height: 100,
                                  );
                                } else {
                                  return SizedBox(); // Show nothing when not loading
                                }
                              },
                            ),
                    ),
                    ListView.builder(
                        padding: const EdgeInsets.all(16),
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
                                      builder: (context) => bussinessprofile(
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
                            child: Card(
                              color: AppColors.backgroundColor,
                              elevation: 9,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
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
                                            ? Column(
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: ShapeDecoration(
                                                      shape: CircleBorder(
                                                        side: BorderSide(
                                                          width: 2,
                                                          color: dataList2[
                                                                          index]
                                                                      .crowncolor !=
                                                                  null
                                                              ? Color(int.parse(
                                                                      dataList2[
                                                                              index]
                                                                          .crowncolor
                                                                          .toString()
                                                                          .substring(
                                                                              1),
                                                                      radix:
                                                                          16) |
                                                                  0xFF000000)
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons
                                                            .supervised_user_circle_outlined,
                                                        color: AppColors
                                                            .primaryColor,
                                                        size: 45,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 49,
                                                    height: 13,
                                                    alignment: Alignment.center,
                                                    transform: Matrix4
                                                        .translationValues(
                                                            0.0, -10.0, 0.0),
                                                    decoration: ShapeDecoration(
                                                      color: dataList2[index]
                                                                  .crowncolor
                                                                  .toString() !=
                                                              null
                                                          ? Color(int.parse(
                                                                  dataList2[
                                                                          index]
                                                                      .crowncolor
                                                                      .toString()
                                                                      .substring(
                                                                          1),
                                                                  radix: 16) |
                                                              0xFF000000)
                                                          : Colors.black,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(40),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      dataList2[index]
                                                          .planname
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontFamily:
                                                            'assets/fonts/Metropolis-SemiBold.otf',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: -0.24,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : dataList2[index]
                                                            .isBusinessProfileView ==
                                                        0 &&
                                                    dataList2[index]
                                                            .isBusinessOldView ==
                                                        0
                                                ? Column(
                                                    children: [
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration:
                                                            ShapeDecoration(
                                                          shape: CircleBorder(
                                                            side: BorderSide(
                                                              width: 2,
                                                              color: dataList2[
                                                                              index]
                                                                          .crowncolor !=
                                                                      null
                                                                  ? Color(int.parse(
                                                                          dataList2[index]
                                                                              .crowncolor
                                                                              .toString()
                                                                              .substring(
                                                                                  1),
                                                                          radix:
                                                                              16) |
                                                                      0xFF000000)
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                            Icons
                                                                .supervised_user_circle_outlined,
                                                            color: AppColors
                                                                .primaryColor,
                                                            size: 45,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 49,
                                                        height: 13,
                                                        alignment:
                                                            Alignment.center,
                                                        transform: Matrix4
                                                            .translationValues(
                                                                0.0,
                                                                -10.0,
                                                                0.0),
                                                        decoration:
                                                            ShapeDecoration(
                                                          color: dataList2[
                                                                          index]
                                                                      .crowncolor
                                                                      .toString() !=
                                                                  null
                                                              ? Color(int.parse(
                                                                      dataList2[
                                                                              index]
                                                                          .crowncolor
                                                                          .toString()
                                                                          .substring(
                                                                              1),
                                                                      radix:
                                                                          16) |
                                                                  0xFF000000)
                                                              : Colors.black,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        40),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          dataList2[index]
                                                              .planname
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 9,
                                                            fontFamily:
                                                                'assets/fonts/Metropolis-SemiBold.otf',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            letterSpacing:
                                                                -0.24,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : dataList2[index]
                                                                .isBusinessProfileView ==
                                                            1 &&
                                                        dataList2[index]
                                                                .isBusinessOldView ==
                                                            1
                                                    ? Column(
                                                        children: [
                                                          Container(
                                                            width: 51,
                                                            height: 51,
                                                            decoration:
                                                                ShapeDecoration(
                                                              shape:
                                                                  CircleBorder(
                                                                side:
                                                                    BorderSide(
                                                                  width: 2,
                                                                  color: dataList2[index]
                                                                              .crowncolor
                                                                              .toString() !=
                                                                          null
                                                                      ? Color(int.parse(dataList2[index].crowncolor.toString().substring(1),
                                                                              radix:
                                                                                  16) |
                                                                          0xFF000000)
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                            child: ClipOval(
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: dataList2[
                                                                        index]
                                                                    .imageUrl
                                                                    .toString(),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 49,
                                                            height: 13,
                                                            alignment: Alignment
                                                                .center,
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    0.0,
                                                                    -10.0,
                                                                    0.0),
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: dataList2[
                                                                              index]
                                                                          .crowncolor
                                                                          .toString() !=
                                                                      null
                                                                  ? Color(int.parse(
                                                                          dataList2[index]
                                                                              .crowncolor
                                                                              .toString()
                                                                              .substring(
                                                                                  1),
                                                                          radix:
                                                                              16) |
                                                                      0xFF000000)
                                                                  : Colors
                                                                      .black,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              dataList2[index]
                                                                  .planname
                                                                  .toString()
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 9,
                                                                fontFamily:
                                                                    'assets/fonts/Metropolis-SemiBold.otf',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    -0.24,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Column(
                                                        children: [
                                                          Container(
                                                            width: 50,
                                                            height: 50,
                                                            decoration:
                                                                ShapeDecoration(
                                                              shape:
                                                                  CircleBorder(
                                                                side:
                                                                    BorderSide(
                                                                  width: 2,
                                                                  color: dataList2[index]
                                                                              .crowncolor !=
                                                                          null
                                                                      ? Color(int.parse(dataList2[index].crowncolor.toString().substring(1),
                                                                              radix:
                                                                                  16) |
                                                                          0xFF000000)
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .supervised_user_circle_outlined,
                                                                color: AppColors
                                                                    .primaryColor,
                                                                size: 45,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 49,
                                                            height: 13,
                                                            alignment: Alignment
                                                                .center,
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    0.0,
                                                                    -10.0,
                                                                    0.0),
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: dataList2[
                                                                              index]
                                                                          .crowncolor
                                                                          .toString() !=
                                                                      null
                                                                  ? Color(int.parse(
                                                                          dataList2[index]
                                                                              .crowncolor
                                                                              .toString()
                                                                              .substring(
                                                                                  1),
                                                                          radix:
                                                                              16) |
                                                                      0xFF000000)
                                                                  : Colors
                                                                      .black,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              dataList2[index]
                                                                  .planname
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 9,
                                                                fontFamily:
                                                                    'assets/fonts/Metropolis-SemiBold.otf',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    -0.24,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
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
                                            Container(
                                              width: 140,
                                              child: Text(
                                                dataList2[index]
                                                    .businessTypeName
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.blackColor,
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
                                    Icon(
                                      Icons.arrow_right,
                                      size: 30,
                                    )
                                  ],
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
          ));
  }
}

// ignore: must_be_immutable
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
      loadmore = false;
    });

    await getFollower();
    scrollercontroller.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    return null;
  }

  Future<void> _refreshDatafollowing() async {
    setState(() {
      getfllowingdata.clear();
      offset = 0;
      loadmore = false;
    });

    await getFollowing();

    scrollercontroller.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

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
            crowncolor: data['crown_color'],
            planname: data['plan_name'],
          );

          getfollowdata.add(record);

          if (getfollowdata.isNotEmpty) {
            setState(() {
              loadmore = getfollowdata.isNotEmpty;
              loadmore = jsonArray.length == 10;
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
            crowncolor: data['crown_color'],
            planname: data['plan_name'],
          );
          getfllowingdata.add(record);
        }

        if (getfllowingdata.isNotEmpty) {
          setState(() {
            loadmore = getfllowingdata.isNotEmpty;

            loadmore = jsonArray.length == 10;
          });
        } else {
          setState(() {
            loadmore = false;
          });
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
                                          bussinessprofile(result.id!),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  result.isBusinessProfileView ==
                                                              1 &&
                                                          result.isBusinessOldView ==
                                                              0
                                                      ? Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration:
                                                                  ShapeDecoration(
                                                                shape:
                                                                    CircleBorder(
                                                                  side:
                                                                      BorderSide(
                                                                    width: 2,
                                                                    color: result.crowncolor !=
                                                                            null
                                                                        ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                            0xFF000000)
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .supervised_user_circle_outlined,
                                                                  color: AppColors
                                                                      .primaryColor,
                                                                  size: 45,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 49,
                                                              height: 13,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              transform: Matrix4
                                                                  .translationValues(
                                                                      0.0,
                                                                      -10.0,
                                                                      0.0),
                                                              decoration:
                                                                  ShapeDecoration(
                                                                color: result
                                                                            .crowncolor !=
                                                                        null
                                                                    ? Color(int.parse(
                                                                            result.crowncolor.toString().substring(
                                                                                1),
                                                                            radix:
                                                                                16) |
                                                                        0xFF000000)
                                                                    : Colors
                                                                        .black,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              40),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                result.planname
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 9,
                                                                  fontFamily:
                                                                      'assets/fonts/Metropolis-SemiBold.otf',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  letterSpacing:
                                                                      -0.24,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : result.isBusinessProfileView ==
                                                                  0 &&
                                                              result.isBusinessOldView ==
                                                                  0
                                                          ? Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration:
                                                                      ShapeDecoration(
                                                                    shape:
                                                                        CircleBorder(
                                                                      side:
                                                                          BorderSide(
                                                                        width:
                                                                            2,
                                                                        color: result.crowncolor !=
                                                                                null
                                                                            ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                                0xFF000000)
                                                                            : Colors.black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .supervised_user_circle_outlined,
                                                                      color: AppColors
                                                                          .primaryColor,
                                                                      size: 45,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 49,
                                                                  height: 13,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  transform: Matrix4
                                                                      .translationValues(
                                                                          0.0,
                                                                          -10.0,
                                                                          0.0),
                                                                  decoration:
                                                                      ShapeDecoration(
                                                                    color: result.crowncolor !=
                                                                            null
                                                                        ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                            0xFF000000)
                                                                        : Colors
                                                                            .black,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              40),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    result
                                                                        .planname
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          9,
                                                                      fontFamily:
                                                                          'assets/fonts/Metropolis-SemiBold.otf',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      letterSpacing:
                                                                          -0.24,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : result.isBusinessProfileView ==
                                                                      1 &&
                                                                  result.isBusinessOldView ==
                                                                      1
                                                              ? Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      width: 51,
                                                                      height:
                                                                          51,
                                                                      decoration:
                                                                          ShapeDecoration(
                                                                        shape:
                                                                            CircleBorder(
                                                                          side:
                                                                              BorderSide(
                                                                            width:
                                                                                2,
                                                                            color: result.crowncolor != null
                                                                                ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) | 0xFF000000)
                                                                                : Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          ClipOval(
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl: result
                                                                              .image
                                                                              .toString(),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: 49,
                                                                      height:
                                                                          13,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      transform: Matrix4.translationValues(
                                                                          0.0,
                                                                          -10.0,
                                                                          0.0),
                                                                      decoration:
                                                                          ShapeDecoration(
                                                                        color: result.crowncolor !=
                                                                                null
                                                                            ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                                0xFF000000)
                                                                            : Colors.black,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(40),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        result
                                                                            .planname
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              9,
                                                                          fontFamily:
                                                                              'assets/fonts/Metropolis-SemiBold.otf',
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          letterSpacing:
                                                                              -0.24,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : Column(
                                                                  children: [
                                                                    Container(
                                                                      width: 50,
                                                                      height:
                                                                          50,
                                                                      decoration:
                                                                          ShapeDecoration(
                                                                        shape:
                                                                            CircleBorder(
                                                                          side:
                                                                              BorderSide(
                                                                            width:
                                                                                2,
                                                                            color: result.crowncolor != null
                                                                                ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) | 0xFF000000)
                                                                                : Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .supervised_user_circle_outlined,
                                                                          color:
                                                                              AppColors.primaryColor,
                                                                          size:
                                                                              45,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: 49,
                                                                      height:
                                                                          13,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      transform: Matrix4.translationValues(
                                                                          0.0,
                                                                          -10.0,
                                                                          0.0),
                                                                      decoration:
                                                                          ShapeDecoration(
                                                                        color: result.crowncolor !=
                                                                                null
                                                                            ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                                0xFF000000)
                                                                            : Colors.black,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(40),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        result
                                                                            .planname
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              9,
                                                                          fontFamily:
                                                                              'assets/fonts/Metropolis-SemiBold.otf',
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          letterSpacing:
                                                                              -0.24,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
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
                                          bussinessprofile(result.id!),
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
                                                      ? Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration:
                                                                  ShapeDecoration(
                                                                shape:
                                                                    CircleBorder(
                                                                  side:
                                                                      BorderSide(
                                                                    width: 2,
                                                                    color: result.crowncolor !=
                                                                            null
                                                                        ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                            0xFF000000)
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .supervised_user_circle_outlined,
                                                                  color: AppColors
                                                                      .primaryColor,
                                                                  size: 45,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 49,
                                                              height: 13,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              transform: Matrix4
                                                                  .translationValues(
                                                                      0.0,
                                                                      -10.0,
                                                                      0.0),
                                                              decoration:
                                                                  ShapeDecoration(
                                                                color: result
                                                                            .crowncolor !=
                                                                        null
                                                                    ? Color(int.parse(
                                                                            result.crowncolor.toString().substring(
                                                                                1),
                                                                            radix:
                                                                                16) |
                                                                        0xFF000000)
                                                                    : Colors
                                                                        .black,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              40),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                result.planname
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 9,
                                                                  fontFamily:
                                                                      'assets/fonts/Metropolis-SemiBold.otf',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  letterSpacing:
                                                                      -0.24,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : result.isBusinessProfileView ==
                                                                  0 &&
                                                              result.isBusinessOldView ==
                                                                  0
                                                          ? Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration:
                                                                      ShapeDecoration(
                                                                    shape:
                                                                        CircleBorder(
                                                                      side:
                                                                          BorderSide(
                                                                        width:
                                                                            2,
                                                                        color: result.crowncolor !=
                                                                                null
                                                                            ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                                0xFF000000)
                                                                            : Colors.black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .supervised_user_circle_outlined,
                                                                      color: AppColors
                                                                          .primaryColor,
                                                                      size: 45,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 49,
                                                                  height: 13,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  transform: Matrix4
                                                                      .translationValues(
                                                                          0.0,
                                                                          -10.0,
                                                                          0.0),
                                                                  decoration:
                                                                      ShapeDecoration(
                                                                    color: result.crowncolor !=
                                                                            null
                                                                        ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                            0xFF000000)
                                                                        : Colors
                                                                            .black,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              40),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    result
                                                                        .planname
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          9,
                                                                      fontFamily:
                                                                          'assets/fonts/Metropolis-SemiBold.otf',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      letterSpacing:
                                                                          -0.24,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : result.isBusinessProfileView ==
                                                                      1 &&
                                                                  result.isBusinessOldView ==
                                                                      1
                                                              ? Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      width: 51,
                                                                      height:
                                                                          51,
                                                                      decoration:
                                                                          ShapeDecoration(
                                                                        shape:
                                                                            CircleBorder(
                                                                          side:
                                                                              BorderSide(
                                                                            width:
                                                                                2,
                                                                            color: result.crowncolor != null
                                                                                ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) | 0xFF000000)
                                                                                : Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          ClipOval(
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl: result
                                                                              .image
                                                                              .toString(),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: 49,
                                                                      height:
                                                                          13,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      transform: Matrix4.translationValues(
                                                                          0.0,
                                                                          -10.0,
                                                                          0.0),
                                                                      decoration:
                                                                          ShapeDecoration(
                                                                        color: result.crowncolor !=
                                                                                null
                                                                            ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                                0xFF000000)
                                                                            : Colors.black,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(40),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        result
                                                                            .planname
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              9,
                                                                          fontFamily:
                                                                              'assets/fonts/Metropolis-SemiBold.otf',
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          letterSpacing:
                                                                              -0.24,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : Column(
                                                                  children: [
                                                                    Container(
                                                                      width: 50,
                                                                      height:
                                                                          50,
                                                                      decoration:
                                                                          ShapeDecoration(
                                                                        shape:
                                                                            CircleBorder(
                                                                          side:
                                                                              BorderSide(
                                                                            width:
                                                                                2,
                                                                            color: result.crowncolor != null
                                                                                ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) | 0xFF000000)
                                                                                : Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .supervised_user_circle_outlined,
                                                                          color:
                                                                              AppColors.primaryColor,
                                                                          size:
                                                                              45,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: 49,
                                                                      height:
                                                                          13,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      transform: Matrix4.translationValues(
                                                                          0.0,
                                                                          -10.0,
                                                                          0.0),
                                                                      decoration:
                                                                          ShapeDecoration(
                                                                        color: result.crowncolor !=
                                                                                null
                                                                            ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                                0xFF000000)
                                                                            : Colors.black,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(40),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        result
                                                                            .planname
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              9,
                                                                          fontFamily:
                                                                              'assets/fonts/Metropolis-SemiBold.otf',
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          letterSpacing:
                                                                              -0.24,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
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
