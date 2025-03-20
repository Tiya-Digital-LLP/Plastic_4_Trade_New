// ignore_for_file: non_constant_identifier_names, must_be_immutable, prefer_typing_uninitialized_variables, deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/main.dart';
import 'package:Plastic4trade/model/get_active_plan_model.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_dot_loader.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:Plastic4trade/widget/Tutorial_Videos_dialog.dart';
import 'package:Plastic4trade/widget/custom_dialog_sucsess.dart';

import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gtm/gtm.dart';
import 'package:info_popup/info_popup.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_interface.dart';
import '../../model/premium_plan_model.dart';

class Premiun extends StatefulWidget {
  const Premiun({Key? key}) : super(key: key);

  @override
  State<Premiun> createState() => _PremiunState();
}

class _PremiunState extends State<Premiun> with TickerProviderStateMixin {
  var init_page = 0;
  late TabController _tabController;
  bool isActionSuccessful = false;

  late PageController _pageController;
  bool? load;
  ShowPremiumPlan showPremiumPlan = ShowPremiumPlan();
  List<Plan> showPremiumPlanList = <Plan>[];
  bool loading = false;
  TextEditingController couponController = TextEditingController();
  late String userId;
  String? planId;
  late Razorpay _razorpay;
  int? selectedPlan;
  bool _isloading1 = false;

  String crown_color = '';
  String plan_name = '';
  double? discountedPriceInr;
  int itemIndex = 0;
  String title = 'Premium';
  String? razorpayOrderId;
  String? razorpayOrderIdUsd;

  String userName = '';
  String contact = '';
  String email = '';
  String image = '';
  String countryCode = '';
  Set<int> _disabledButtons = {};
  String screen_id = "0";

  @override
  void initState() {
    GtmUtil.logScreenView(
      'Premium_plan',
      'premiumplan',
    );
    _tabController = TabController(
        length: showPremiumPlanList.length,
        vsync: this,
        initialIndex: init_page);
    _pageController =
        PageController(initialPage: init_page, viewportFraction: 0.8);
    super.initState();
    _loadProfileData();
    checknetowork();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
  }

  Future<void> _loadProfileData() async {
    Map<String, dynamic> profileData = await getProfiles();

    print('Fetched Profile Data: $profileData');

    setState(() {
      userName = profileData['user_name'] ?? '';
      contact = profileData['contact'] ?? '';
      email = profileData['email'] ?? '';
      image = profileData['image_url'] ?? '';
      countryCode = profileData['country_code'] ?? '';
      print('countryCode profileData in setState: $countryCode');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      fetch_premium_plan();
      fetchRazorkey();
      getProfiles();
    }
  }

  Future fetch_premium_plan() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getPremiumPlan(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );
    print("user_id: ${pref.getString('user_id').toString()}");
    print("userToken: ${pref.getString('userToken').toString()}");

    print("Response: $res");

    if (res['status'] == 1) {
      if (res['plan'] != null) {
        showPremiumPlan = ShowPremiumPlan.fromJson(res);
        showPremiumPlanList = showPremiumPlan.plan ?? [];
        selectedPlan = showPremiumPlan.selectedPlan;
        print('selectedPlan: $selectedPlan');
        planId = showPremiumPlanList.isNotEmpty
            ? showPremiumPlanList[0].id.toString()
            : null;
        _tabController.dispose();
        _tabController = TabController(
          length: showPremiumPlanList.length,
          vsync: this,
          initialIndex: init_page,
        );
        load = true;
      } else {
        load = true;
      }
    } else {
      showCustomToast(res['message']);
    }
    setState(() {});
    return load;
  }

  Future<void> getOrderId(int amountInPaise) async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    setState(() {
      _isloading1 = true;
    });
    double amountInINR = amountInPaise / 100;

    print("Converted Price (INR): ${amountInINR.toStringAsFixed(2)}");

    final response = await getorderid(
      amountInPaise,
      device,
    );

    setState(() {
      _isloading1 = false;
    });

    if (response != null) {
      if (response['status'] == 1) {
        razorpayOrderId = response['razorpayOrderId'];
        print('getOrderId: $razorpayOrderId');
      } else {
        print('getOrderIdError: Something went wrong');
      }
    } else {
      print('Error: Received null response from getorderid');
    }

    setState(() {});
  }

  Future<void> getOrderUsd(int amountInusd) async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    setState(() {
      _isloading1 = true;
    });
    double amountInUsd = amountInusd / 100;

    print("Converted Price (Doller): ${amountInUsd.toStringAsFixed(2)}");

    final response = await getorderforusd(
      amountInusd,
      device,
    );

    setState(() {
      _isloading1 = false;
    });

    if (response != null) {
      if (response['status'] == 1) {
        razorpayOrderIdUsd = response['razorpayOrderId'];
        print('getOrderIdUsd: $razorpayOrderIdUsd');
      } else {
        print('getOrderIdUsdError: Something went wrong');
      }
    } else {
      print('Error: Received null response from getorderid');
    }

    setState(() {});
  }

  Future planClick(int PlanId, String currency, String amount) async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await planclickregister(
      pref.getString('user_id').toString(),
      PlanId,
      device,
      currency,
      amount,
    );
    setState(() {
      _isloading1 = false;
    });
    print("user_id: ${pref.getString('user_id').toString()}");
    print("plan: ${planId.toString()}");
    print("device: $device");
    print("currency: $currency");
    print("amount: $amount");

    print("Response: $res");

    if (res['status'] == 1) {
      print('plan_Click: ${res['message']}');
    } else {
      showCustomToast(res['message']);
    }

    setState(() {});
    return load;
  }

  Future fetch_active_plan() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String userId = pref.getString('user_id') ?? '';
    String userToken = pref.getString('userToken') ?? '';

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    if (userId.isEmpty || userToken.isEmpty) {
      showCustomToast("User ID or API Token is missing");
      return false;
    }

    var res = await activePlan(userId, userToken, device);

    print('API response: $res');

    if (res != null) {
      if (res['status'] == 2) {
        if (res['active_plan'] != null) {
          load = true;

          ActivePlan activePlan = ActivePlan.fromJson(res['active_plan']);
          print('Active Plan: $activePlan');

          showCustomToast(
              'You have already bought the: ${activePlan.planName}');
        } else {
          load = true;
        }
      } else if (res['status'] == 1) {
        if (res['active_plan'] == null) {
          showCustomToast("No active plan available");
        } else {
          ActivePlan activePlan = ActivePlan.fromJson(res['active_plan']);
          print('Active Plan: $activePlan');
        }
      } else {
        showCustomToast(res['message'] ?? 'Unknown error occurred');
      }
    } else {
      showCustomToast("Failed to fetch plan data");
    }

    setState(() {});
    return load;
  }

// Function to fetch the Razorpay key and use it
  Future<String?> fetchRazorkey() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userToken = pref.getString('userToken') ?? '';

    String device = '';
    if (kIsWeb) {
      device = 'web';
    } else if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var response = await razerpayKey(userToken, device);

    if (response != null) {
      print('API response from fetchRazorkey: $response');

      if (response['status'] == 1) {
        String razorpayKey = response['razorpay_key'];
        print('Razorpay Key: $razorpayKey');

        return razorpayKey;
      } else {
        print('Razorpay key fetch failed: ${response['status']}');
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: showPremiumPlanList.length,
        initialIndex: init_page,
        child: Scaffold(
          backgroundColor: AppColors.greyBackground,
          appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 100),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              title: const Text('Premium',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Metropolis',
                    fontWeight: FontWeight.w600,
                    height: 0.05,
                    letterSpacing: -0.24,
                  )),
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 25,
                  color: Colors.black,
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    showTutorial_Video(context, title, screen_id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 13),
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: Image.asset(
                        'assets/Play.png',
                      ),
                    ),
                  ),
                ),
              ],
              bottom: TabBar(
                dividerColor: Colors.transparent,
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                isScrollable: true,
                onTap: (value) {
                  setState(() {
                    init_page = value;
                    _pageController.jumpToPage(init_page);
                  });
                },
                tabs: showPremiumPlanList
                    .map((e) => _buildCommanTab(title: e.name.toString()))
                    .toList(),
              ),
            ),
          ),
          body: TabBarView(
            children: showPremiumPlanList.map((e) => demo(init_page)).toList(),
          ),
        ));
  }

  Future<void> showTutorial_Video(
      BuildContext context, String title, String screenId) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Tutorial_Videos_dialog(title, screenId);
      },
    );
  }

  Widget _buildCommanTab({required String title}) {
    return Tab(
        child: Text(title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'Metropolis',
              fontWeight: FontWeight.w600,
              height: 0.09,
            )));
  }

  Widget demo(initPage) {
    return PageView.builder(
      controller: _pageController,
      itemCount: showPremiumPlanList.length,
      pageSnapping: false,
      itemBuilder: (BuildContext context, int itemIndex) {
        return load == true
            ? _buildCarouselItem(context, itemIndex)
            : Center(
                child: CustomLottieContainer(
                  child: Lottie.asset(
                    'assets/loading_animation.json',
                  ),
                ),
              );
      },
      onPageChanged: (value) {
        setState(() {
          init_page = value;
          _tabController.animateTo(init_page);
        });
      },
    );
  }

  // List<Color> _getPlanGradient(String planName) {
  //   switch (planName) {
  //     case "Free":
  //       return [
  //         Color(0xFFE59898),
  //         Color(0xFFF44242),
  //         Color(0xFFFF0000)
  //       ]; // Elegant gray gradient
  //     case "Basic Plan":
  //       return [
  //         Color(0xFFECBF6F),
  //         Color(0xFFF3B544),
  //         Color(0xFFFDA403)
  //       ]; // Light to deep blue
  //     case "Standard Plan":
  //       return [
  //         Color(0xFF6DB4DA),
  //         Color(0xFF42A5DB),
  //         Color(0xFF008DDA)
  //       ]; // Soft green transition
  //     case "Premium Plan":
  //       return [
  //         Color(0xFFB0A8ED),
  //         Color(0xFF9F95F4),
  //         Color(0xFF8576FF)
  //       ]; // Soft to rich gold
  //     case "Gold Plan":
  //       return [
  //         Color(0xFFF2DE46),
  //         Color(0xFFEBDD73),
  //         Color(0xFFF2DE46)
  //       ]; // Luxury gold gradient
  //     default:
  //       return [
  //         Color(0xFFF2DE46),
  //         Color(0xFF3498DB),
  //         Color(0xFF2980B9)
  //       ]; // Turquoise blue default
  //   }
  // }

  Widget _buildCarouselItem(BuildContext context, int itemIndex) {
    bool isOfferValid = (countryCode == '+91' ||
            countryCode == '+92' ||
            countryCode == '+880' ||
            countryCode == '+94' ||
            countryCode == '+975' ||
            countryCode == '+977')
        ? (showPremiumPlanList[itemIndex].offername != null &&
            showPremiumPlanList[itemIndex].offername!.isNotEmpty &&
            showPremiumPlanList[itemIndex].offername != '0')
        : (showPremiumPlanList[itemIndex].offernamedoller != null &&
            showPremiumPlanList[itemIndex].offernamedoller!.isNotEmpty &&
            showPremiumPlanList[itemIndex].offernamedoller != '0');

    String offerName = (countryCode == '+91' ||
            countryCode == '+92' ||
            countryCode == '+880' ||
            countryCode == '+94' ||
            countryCode == '+975' ||
            countryCode == '+977')
        ? showPremiumPlanList[itemIndex].offername ?? ''
        : showPremiumPlanList[itemIndex].offernamedoller ?? '';

    String priceText = (countryCode == '+91' ||
            countryCode == '+92' ||
            countryCode == '+880' ||
            countryCode == '+94' ||
            countryCode == '+975' ||
            countryCode == '+977')
        ? '₹${showPremiumPlanList[itemIndex].planoriginalprice}/${showPremiumPlanList[itemIndex].timeDurationInText ?? "Month"}'
        : '\$${showPremiumPlanList[itemIndex].planoriginalpricedoller}/${showPremiumPlanList[itemIndex].timeDurationInText ?? "Month"}';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3FA6A6A6),
            blurRadius: 16.32,
            offset: Offset(0, 3.26),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Image.asset(
                    showPremiumPlanList[itemIndex].name!.toLowerCase() == "free"
                        ? 'assets/Premium1.png'
                        : 'assets/Premium2.png',
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.18,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   height: MediaQuery.of(context).size.height * 0.18,
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: _getPlanGradient(
                //           showPremiumPlanList[itemIndex].name.toString()),
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       stops: [
                //         0.2,
                //         0.6,
                //         1.0
                //       ], // Multi-stop gradient for smooth transition
                //     ),
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: [
                //       BoxShadow(
                //         color: _getPlanGradient(showPremiumPlanList[itemIndex]
                //                 .name
                //                 .toString())[1]
                //             .withOpacity(0.4),
                //         blurRadius: 20,
                //         spreadRadius: 2,
                //         offset: Offset(0, 4),
                //       ),
                //     ],
                //   ),
                // ),
                Positioned(
                  top: -15,
                  left: -15,
                  child: Center(
                    child: showPremiumPlanList[itemIndex].currentPlan == 0
                        ? SizedBox.shrink()
                        : Image.asset(
                            'assets/Active_badge.png',
                            height: 100,
                          ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.050,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      showPremiumPlanList[itemIndex].name ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Text(
                      '${(countryCode == '+91' || countryCode == '+92' || countryCode == '+880' || countryCode == '+94' || countryCode == '+975' || countryCode == '+977') ? "₹${showPremiumPlanList[itemIndex].priceInr}" : "\$${showPremiumPlanList[itemIndex].priceDoller}"}/${showPremiumPlanList[itemIndex].timeDurationInText ?? "Month"}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: showPremiumPlanList[itemIndex].services!.length,
              itemBuilder: (context, index) {
                return _buildShowPlanList(
                    services: showPremiumPlanList[itemIndex].services![index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        showPremiumPlanList[itemIndex].name ?? "",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.24),
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Price:',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.24),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          (countryCode == '+91' ||
                                  countryCode == '+92' ||
                                  countryCode == '+880' ||
                                  countryCode == '+94' ||
                                  countryCode == '+975' ||
                                  countryCode == '+977')
                              ? '₹${showPremiumPlanList[itemIndex].priceInr}/${showPremiumPlanList[itemIndex].timeDurationInText ?? "Month"}'
                              : '\$${showPremiumPlanList[itemIndex].priceDoller}/${showPremiumPlanList[itemIndex].timeDurationInText ?? "Month"}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isOfferValid)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          '$offerName Price:',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        priceText,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize:
                          Size(MediaQuery.of(context).size.width * 0.9, 46),
                      backgroundColor: showPremiumPlanList
                              .every((plan) => plan.currentPlan == 0)
                          ? const Color(0xFF292D32)
                          : (showPremiumPlanList[itemIndex].currentPlan == 1 &&
                                      showPremiumPlanList[itemIndex]
                                              .isRemaining !=
                                          null &&
                                      showPremiumPlanList[itemIndex]
                                              .isRemaining! >
                                          15) ||
                                  showPremiumPlanList[itemIndex]
                                          .name!
                                          .toLowerCase() ==
                                      "free" ||
                                  (selectedPlan != null &&
                                      showPremiumPlanList[itemIndex].id !=
                                          null &&
                                      showPremiumPlanList[itemIndex].id! <
                                          selectedPlan!)
                              ? Colors.grey
                              : const Color(0xFF292D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: (showPremiumPlanList[itemIndex].currentPlan ==
                                    1 &&
                                showPremiumPlanList[itemIndex].isRemaining !=
                                    null &&
                                showPremiumPlanList[itemIndex].isRemaining! >
                                    15) ||
                            showPremiumPlanList[itemIndex]
                                    .name!
                                    .toLowerCase() ==
                                "free" ||
                            (selectedPlan != null &&
                                showPremiumPlanList[itemIndex].id != null &&
                                showPremiumPlanList[itemIndex].id! <
                                    selectedPlan!)
                        ? null
                        : () async {
                            setState(() {
                              _disabledButtons
                                  .add(showPremiumPlanList[itemIndex].id ?? 0);
                            });

                            if (showPremiumPlanList[itemIndex]
                                    .name!
                                    .toLowerCase() ==
                                "free") {
                              showCustomToast("This plan is already in use.");
                              return;
                            }

                            if (kDebugMode) {
                              print('Button pressed');
                              print(
                                  'User Name: ${userName.isNotEmpty ? userName : 'Unknown User'}');
                              print(
                                  'Contact: ${contact.isNotEmpty ? contact : 'No contact'}');
                              print('Email: $email');
                              print(
                                  'Original Price (INR): ${showPremiumPlanList[itemIndex].planoriginalprice}');
                              print(
                                  'Plan ID: ${showPremiumPlanList[itemIndex].id}');
                            }

                            SharedPreferences pref =
                                await SharedPreferences.getInstance();

                            if (countryCode == '+91' ||
                                countryCode == '+92' ||
                                countryCode == '+880' ||
                                countryCode == '+94' ||
                                countryCode == '+975' ||
                                countryCode == '+977') {
                              int amountInPaise = (double.parse(
                                          showPremiumPlanList[itemIndex]
                                              .planoriginalprice
                                              .toString()) *
                                      100)
                                  .round();
                              await getOrderId(amountInPaise);
                            } else {
                              int amountInUsd = (double.parse(
                                          showPremiumPlanList[itemIndex]
                                              .planoriginalpricedoller
                                              .toString()) *
                                      100)
                                  .round();
                              await getOrderUsd(amountInUsd);
                            }
                            String? deviceId = await _getDeviceId();

                            if (deviceId != null) {
                              await pref.setString('device_id', deviceId);
                              print('Device ID saved: $deviceId');
                            } else {
                              print('Device ID is null.');
                            }

                            String device = '';
                            if (Platform.isAndroid) {
                              device = 'android';
                            } else if (Platform.isIOS) {
                              device = 'ios';
                            }
                            print('Device Name: $device');

                            String? razorpayKey = await fetchRazorkey();
                            print('razorpayKey: $razorpayKey');

                            String? razorpayOrderIdToUse =
                                razorpayOrderId ?? razorpayOrderIdUsd;

                            var options = _preparePaymentOptions(
                              razorpayOrderIdToUse.toString(),
                              showPremiumPlanList[itemIndex].id.toString(),
                              razorpayKey,
                              pref,
                              deviceId,
                              device,
                            );

                            String getCurrencySymbol(String countryCode) {
                              if (countryCode == '+91' ||
                                  countryCode == '+92' ||
                                  countryCode == '+880' ||
                                  countryCode == '+94' ||
                                  countryCode == '+975' ||
                                  countryCode == '+977') {
                                return '₹';
                              } else {
                                return '\$';
                              }
                            }

                            int getCurrency(String countryCode, int itemIndex) {
                              if (countryCode == '+91' ||
                                  countryCode == '+92' ||
                                  countryCode == '+880' ||
                                  countryCode == '+94' ||
                                  countryCode == '+975' ||
                                  countryCode == '+977') {
                                return int.parse(showPremiumPlanList[itemIndex]
                                    .planoriginalprice
                                    .toString());
                              } else {
                                return int.parse(showPremiumPlanList[itemIndex]
                                    .planoriginalpricedoller
                                    .toString());
                              }
                            }

                            String currencySymbol =
                                getCurrencySymbol(countryCode);

                            planClick(
                              showPremiumPlanList[itemIndex].id ?? 0,
                              currencySymbol,
                              getCurrency(countryCode, itemIndex).toString(),
                            );
                            onClicked(showPremiumPlanList[itemIndex].id ?? 0);

                            print('Razorpay options: $options');
                            _razorpay.open(options);

                            setState(() {});
                          },
                    child: Stack(
                      children: [
                        if (!_isloading1)
                          Text(
                            showPremiumPlanList
                                    .every((plan) => plan.currentPlan == 0)
                                ? "Buy Now"
                                : (showPremiumPlanList[itemIndex].currentPlan ==
                                        1
                                    ? (showPremiumPlanList[itemIndex]
                                                    .isRemaining !=
                                                null &&
                                            showPremiumPlanList[itemIndex]
                                                    .isRemaining! <=
                                                15
                                        ? "Renew Now"
                                        : "Active Plan")
                                    : (showPremiumPlanList[itemIndex]
                                                .name!
                                                .toLowerCase() ==
                                            "free"
                                        ? "Free"
                                        : (selectedPlan !=
                                                    null &&
                                                showPremiumPlanList[itemIndex]
                                                        .id !=
                                                    null &&
                                                showPremiumPlanList[itemIndex]
                                                        .id! <
                                                    selectedPlan!)
                                            ? "Buy Now"
                                            : "Upgrade Now")),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        if (_isloading1)
                          Center(
                            child: CustomDotLoader(
                              child: Lottie.asset('assets/Dot_Lottie.json'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get the device ID
  Future<String?> _getDeviceId() async {
    String? deviceId;
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
    return deviceId;
  }

// Helper method to prepare the payment options
  Map<String, dynamic> _preparePaymentOptions(
    String orderId,
    String planId,
    String? razorpayKey,
    SharedPreferences pref,
    String? deviceId,
    String? device,
  ) {
    return {
      'key': razorpayKey,
      'name': userName.isNotEmpty ? userName : 'Unknown User',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': contact.isNotEmpty ? contact : 'No contact',
        'email': email,
      },
      "order_id": orderId,
      'notes': {
        'plan_id': planId,
        'user_id': pref.getString('user_id') ?? '0',
        'employee_id': showPremiumPlanList[itemIndex].employee_id ?? 0,
        'device_id': deviceId,
        "order_id": orderId,
        "device": device,
      },
      'external': {
        'wallets': ['paytm']
      },
      'image': image.isNotEmpty ? image : 'assets/account.png',
    };
  }

  void onClicked(int planId) {
    setState(() {
      final Plan selectedPlan = showPremiumPlanList.firstWhere(
        (plan) => plan.id == planId,
        orElse: () => Plan(id: 0, name: 'Unknown Plan'),
      );

      String planName = selectedPlan.name!;

      print('Selected Plan ID: $planId, Plan Name: $planName');

      pushTrackingEvents(planId.toString(), planName);
    });
  }

  void pushTrackingEvents(String planId, String planName) async {
    try {
      final gtm = await Gtm.instance;
      gtm.push(
        planName,
        parameters: {
          'PlanId': planId,
          'PlanName': planName,
        },
      );
      print('GTM event pushed for PlanId: $planId with PlanName: $planName');

      await FirebaseAnalytics.instance.logEvent(
        name: planName,
        parameters: {
          'PlanId': planId,
          'PlanName': planName,
        },
      );
      print(
          'Firebase Analytics event pushed for PlanId: $planId with PlanName: $planName');
    } on PlatformException {
      print('Exception occurred while pushing events for PlanId: $planId');
    }
  }

  Future<Map<String, dynamic>> getProfiles() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = Platform.isAndroid ? 'android' : 'ios';

    try {
      var res = await getbussinessprofile(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        device,
        pref.getString('user_id').toString(),
        context,
      );

      print('API Response: $res'); // Log the full API response

      if (res['status'] == 1) {
        // Safely handle null fields
        var user = res['user'] ?? {};
        var profile = res['profile'] ?? {};

        print(
            "Country Code for Premium Plan: ${user['countryCode'] ?? ''}"); // Log country code

        return {
          'user_name': user['username'] ?? '',
          'phone_no': user['phoneno'] ?? '',
          'country_code': user['countryCode'] ?? '',
          'contact': user['phoneno'] ?? '',
          'email': user['email'] ?? '',
          'business_type_name': profile['business_type_name'] ?? '',
          'business_name': profile['business_name'] ?? '',
          'company_address': profile['address'] ?? '',
          'image_url': user['image_url'] ?? '',
        };
      } else {
        print('API Error: ${res['message']}');
        return {};
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return {};
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showDialog(
        context: context,
        builder: (context) {
          return CommanDialog(
            title: "Payment Failed",
            content: "Please Retry to the Payment!",
            onPressed: () {
              Navigator.pop(context);
            },
          );
        });
    if (kDebugMode) {
      print("Metadata:${response.error.toString()}");
    }
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String userId = pref.getString('user_id') ?? '';
    String userToken = pref.getString('userToken') ?? '';

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    // Retrieve the current value of primeid and increment it
    int primeId = int.tryParse(init_page.toString()) ?? 0;
    primeId += 1;

    String? transactionId = response.paymentId;
    if (transactionId == null) {
      print("Payment ID is null.");
      return;
    }

    String coupon = couponController.text;

    String amount = (countryCode == '+91' ||
            countryCode == '+92' ||
            countryCode == '+880' ||
            countryCode == '+94' ||
            countryCode == '+975' ||
            countryCode == '+977')
        ? '₹${showPremiumPlanList[init_page].planoriginalprice}'
        : '\$${showPremiumPlanList[init_page].planoriginalpricedoller}';

    if (kDebugMode) {
      print("Payment Success");
      print("Payment ID: $transactionId");
      print("User ID: $userId");
      print("User Token: $userToken");
      print("Prime ID: $primeId");
      print("Transaction ID: $transactionId");
      print("Paid Amount: $amount");
      print("Coupon: $coupon");
    }

    var responseApi = await purchaseplan(
      userId,
      userToken,
      primeId.toString(),
      transactionId,
      amount.toString(),
      coupon,
      device,
    );

    if (responseApi != null && responseApi['status'] == 1) {
      showCustomToast('Purchase successful!');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(0),
        ),
      );
    } else {
      showCustomToast(responseApi['message'] ?? 'Purchase failed');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogSucsess(
          context,
          title: 'Your payment was successful!',
          message: 'Your payment id: $transactionId!',
          price: '$amount',
        );
      },
    );
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  void showSuccessDialog(
    BuildContext context,
    String title,
    String message,
    String price,
  ) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 80,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/Successmark.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black45Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black45Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                price,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black45Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shadowColor: AppColors.primaryColor,
                        elevation: 3,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Download Invoice',
                        style: TextStyle(
                          color: AppColors.backgroundColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showAlertDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      backgroundColor: Colors.white,
      actions: [
        TextButton(
          child: Text(
            "OK",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _buildShowPlanList({required Services services}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                (services.value!.toUpperCase() == "NO")
                    ? const Icon(
                        Icons.cancel,
                        color: AppColors.red,
                        size: 20,
                      )
                    : Icon(
                        Icons.check_circle,
                        color: AppColors.greenWithShade,
                        size: 20,
                      ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  services.title ?? "Unknown",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.24,
                      fontFamily: 'assets/fonst/Metropolis-SemiBold.otf'),
                ),
              ],
            ),
            (services.description != null)
                ? InfoPopupWidget(
                    contentMaxWidth: MediaQuery.of(context).size.width / 2,
                    contentTitle: services.description ?? "No Information",
                    arrowTheme: InfoPopupArrowTheme(
                      color: Colors.black.withOpacity(0.6000000238418579),
                      arrowDirection: ArrowDirection.down,
                    ),
                    contentTheme: InfoPopupContentTheme(
                      infoContainerBackgroundColor:
                          Colors.black.withOpacity(0.6000000238418579),
                      infoTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'assets/fonst/Metropolis-Black.otf',
                        fontWeight: FontWeight.w600,
                      ),
                      contentPadding: const EdgeInsets.all(10),
                      contentBorderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                      infoTextAlign: TextAlign.justify,
                    ),
                    dismissTriggerBehavior:
                        PopupDismissTriggerBehavior.anyWhere,
                    areaBackgroundColor: Colors.transparent,
                    indicatorOffset: Offset.zero,
                    contentOffset: Offset.zero,
                    onControllerCreated: (controller) {
                      print('Info Popup Controller Created');
                    },
                    onAreaPressed: (InfoPopupController controller) {
                      print('Area Pressed');
                    },
                    infoPopupDismissed: () {
                      print('Info Popup Dismissed');
                    },
                    onLayoutMounted: (Size size) {
                      print('Info Popup Layout Mounted');
                    },
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.black,
                      size: 20,
                    ),
                  )
                : const SizedBox()
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
