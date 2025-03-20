// ignore_for_file: non_constant_identifier_names, camel_case_types, prefer_typing_uninitialized_variables, unnecessary_null_comparison, deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:Plastic4trade/common/common_dialog_yes_no.dart';
import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/model/GetSalePostList.dart' as homepost;
import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/screen/post/AddPost.dart';
import 'package:Plastic4trade/screen/post/updatePost.dart';
import 'package:Plastic4trade/screen/post/updatePostcopy.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/HomeAppbar.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_manage_posts_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../api/api_interface.dart';
import '../../model/GetSalePostList.dart';
import '../buyer_seller/Buyer_sell_detail.dart';

class Managepost extends StatefulWidget {
  const Managepost({Key? key}) : super(key: key);

  @override
  State<Managepost> createState() => _managepostState();
}

class _managepostState extends State<Managepost>
    with SingleTickerProviderStateMixin {
  List<String> selectedItemValueSale = <String>[];
  List<String> selectedItemValueBuy = <String>[];

  int offset = 0;
  BuildContext? dialogContext;
  bool isload = false;
  Map<String, bool> isLoadingMap = {};
  Map<String, bool> isloadicon1 = {};
  var jsonArray;
  bool isLoading = true;
  GetSalePostList salePostList = GetSalePostList();
  GetSalePostList buyPostList = GetSalePostList();

  List<homepost.Result> resultSaleList = [];
  List<homepost.Result> resultbuyList = [];

  List<homepost.PostColor> colorssale = [];
  List<homepost.PostColor> colorsbuy = [];

  List<homepost.Result> salepostlist_data = [];
  List<homepost.Result> buypostlist_data = [];

  int totalPostBuy = 0;
  int totalPostSale = 0;

  var color_array;
  String title = 'ManagePost';
  int? boostCount, premiumBoostCount, suspend;
  late TabController _tabController;
  int _previousTabIndex = 0;

  bool isSellPostDataLoaded = false;
  bool isBuyPostDataLoaded = false;
  String screen_id = "0";

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _previousTabIndex) {
        setState(() {
          isLoading = true;
        });

        _previousTabIndex = _tabController.index;

        if (_tabController.index == 0 && !isSellPostDataLoaded) {
          _refreshSellPostData().then((_) {
            setState(() {
              isLoading = false;
              isSellPostDataLoaded = true;
            });
          });
        } else if (_tabController.index == 1 && !isBuyPostDataLoaded) {
          _refreshBuyPostDatafollowing().then((_) {
            setState(() {
              isLoading = false;
              isBuyPostDataLoaded = true;
            });
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    });
    checknetowork();

    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  clear_data() {
    selectedItemValueSale.clear();
    selectedItemValueBuy.clear();
    offset = 0;
    colorssale.clear();
    colorsbuy.clear();
    salepostlist_data.clear();
    buypostlist_data.clear();
    resultSaleList.clear();
    resultbuyList.clear();
    salePostList.result = [];
    buyPostList.result = [];
    for (int i = 0; i < salepostlist_data.length; i++) {
      selectedItemValueSale.add(salepostlist_data[i].productStatus.toString());
    }
    for (int i = 0; i < buypostlist_data.length; i++) {
      selectedItemValueBuy.add(buypostlist_data[i].productStatus.toString());
    }
  }

  Future<void> _refreshSellPostData() async {
    setState(() {
      salepostlist_data.clear();
      offset = 0;
    });

    await get_salepostlist();

    return null;
  }

  Future<void> _refreshBuyPostDatafollowing() async {
    setState(() {
      buypostlist_data.clear();
      offset = 0;
    });

    await get_buypostlist();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text('Manage Sell Posts',
            softWrap: false,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontFamily: 'Metropolis',
            )),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                showTutorial_Video(context, title, screen_id);
              },
              child: SizedBox(
                  width: 40,
                  child: Image.asset(
                    'assets/Play.png',
                  ))),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        children: [
          10.sbh,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DefaultTabController(
              length: 2,
              child: Theme(
                data: Theme.of(context).copyWith(
                  tabBarTheme: TabBarTheme(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.primaryColor,
                    ),
                    unselectedLabelColor: Colors.white,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: AppColors.primaryColor.withOpacity(0.15),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    controller: _tabController,
                    labelColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    unselectedLabelColor: Colors.black,
                    unselectedLabelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Sale Post'),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$totalPostSale',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Buy Post'),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$totalPostBuy',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBarView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  isLoading
                      ? managepostWithShimmerLoader(context)
                      : category_Sale(),
                  isLoading
                      ? managepostWithShimmerLoader(context)
                      : category_Buy(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(children: [
        Positioned(
          right: 0,
          bottom: 20,
          child: Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(100)),
            child: IconButton(
              onPressed: () async {
                constanst.redirectpage = "add_post";
                SharedPreferences pref = await SharedPreferences.getInstance();

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
                        builder: (context) => const AddPost(),
                      ),
                    );
                    break;
                  default:
                    print("Unexpected value: ${constanst.step}");
                    break;
                }
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 40),
            ),
          ),
        ),
      ]),
    );
  }

  Widget managepostWithShimmerLoader(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return managePostShimmerLoader(width: 175, height: 130);
      },
    );
  }

  Widget category_Sale() {
    if (salepostlist_data.isEmpty) {
      print('salepostlist_data is empty or null');
      return const Center(child: Text('No Data Found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: isLoading
          ? salepostlist_data.length + 1
          : (salepostlist_data.isEmpty ? 1 : salepostlist_data.length),
      itemBuilder: (context, index) {
        if (index == salepostlist_data.length) {
          if (hasMoreSalePpostDataToLoad() && !salepostlist_data.isEmpty) {
            return isLoading
                ? managePostShimmerLoader(
                    width: 175,
                    height: 130,
                  )
                : SizedBox();
          }
        } else {
          Result? record = salePostList.result![index];

          for (int i = 0; i < salepostlist_data.length; i++) {
            selectedItemValueSale
                .add(salepostlist_data[i].productStatus.toString());
          }

          bool isCurrentCardLoading =
              isLoadingMap[record.productId.toString()] ?? false;

          bool isCurrentCardLoading1 =
              isloadicon1[record.productId.toString()] ?? false;

          return GestureDetector(
            onTap: () {
              setState(() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Buyer_sell_detail(
                              prod_id: record.productId.toString(),
                              post_type: record.postType,
                            )));
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
                border: Border.all(
                  color: record.isPaidPost == 'Paid'
                      ? Colors.red
                      : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: Column(
                children: [
                  8.sbh,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Stack(fit: StackFit.passthrough, children: <Widget>[
                          Container(
                            height: 120,
                            width: 100,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: CachedNetworkImage(
                                imageUrl: record.mainproductImage.toString(),
                                fit: BoxFit.cover,
                                height: 150,
                                width: 170,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                  color: AppColors.greenWithShade,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              child: Text(
                                  '${record.currency}${record.productPrice}',
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w800,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf',
                                      color: Colors.white)),
                            ),
                          ),
                          if (record.isPaidPost == 'Paid')
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
                        ]),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${record.postName}',
                                  style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryColor,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf')
                                      .copyWith(
                                          fontSize: 12, color: Colors.black),
                                  maxLines: 2,
                                  softWrap: false),
                              record.suspend == 1
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          child: Text(
                                            "${record.categoryName} | ${record.productType} | ${record.productGrade}",
                                            style: const TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        'assets/fonst/Metropolis-Black.otf')
                                                .copyWith(
                                                    fontSize: 11,
                                                    color: Colors.black),
                                            maxLines: 1,
                                            softWrap: true,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                          child: Text(
                                            "${record.location}",
                                            style: const TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        'assets/fonst/Metropolis-Black.otf')
                                                .copyWith(
                                                    fontSize: 11,
                                                    color: Colors.black),
                                            maxLines: 1,
                                            softWrap: true,
                                          ),
                                        ),
                                        SizedBox(
                                            height: 20,
                                            child: Row(
                                              children: [
                                                Text('Qty:',
                                                    style: const TextStyle(
                                                            fontSize: 13.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf')
                                                        .copyWith(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black),
                                                    softWrap: false),
                                                Text(
                                                    '${record.postQuntity} ${record.unit}',
                                                    style: const TextStyle(
                                                            fontSize: 13.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf')
                                                        .copyWith(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black),
                                                    maxLines: 1,
                                                    softWrap: false),
                                              ],
                                            )),
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            childAspectRatio:
                                                MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    1000,
                                            crossAxisSpacing: 0.0,
                                            mainAxisSpacing: 0.0,
                                            crossAxisCount: 15,
                                          ),
                                          itemCount:
                                              record.postColor?.length ?? 0,
                                          itemBuilder: (context, colorIndex) {
                                            String colorString =
                                                resultSaleList[index]
                                                    .postColor![colorIndex]
                                                    .haxCode
                                                    .toString();

                                            String newStr =
                                                colorString.substring(1);

                                            Color colors = Color(int.parse(
                                                    newStr,
                                                    radix: 16))
                                                .withOpacity(1.0);
                                            return Container(
                                                margin: EdgeInsets.zero,
                                                padding: EdgeInsets.zero,
                                                child: newStr == 'ffffff'
                                                    ? const Icon(
                                                        Icons.circle_outlined,
                                                        size: 15)
                                                    : Icon(Icons.circle_rounded,
                                                        size: 15,
                                                        color: colors));
                                          },
                                        ),
                                      ],
                                    )
                                  : InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              bottomSheet(context),
                                        );
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  'Your post has been suspended. ',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                                fontFamily:
                                                    'assets/fonts/Metropolis-Black.otf',
                                                color: AppColors.red,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  'Please click here to view the policy',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                                fontFamily:
                                                    'assets/fonts/Metropolis-Black.otf',
                                                color: AppColors.red,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        bottomSheet(context),
                                                  );
                                                },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  record.suspend == 1
                                      ? PopupMenuButton<String>(
                                          onSelected: (value) {
                                            setState(() {
                                              selectedItemValueSale[index] =
                                                  value;
                                              set_prod_status_sell(
                                                  record.productId.toString(),
                                                  value);
                                            });
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return _dropDownItem();
                                          },
                                          child: Container(
                                            width: 90,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  selectedItemValueSale[index],
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Icon(Icons.arrow_drop_down)
                                              ],
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return CommonDialogYesNo(
                                                title: "Delete Post",
                                                content:
                                                    "Are You Sure Want to delete post?",
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _onLoading();
                                                  setState(() {});
                                                  delete_salepost(record
                                                      .productId
                                                      .toString());
                                                },
                                              );
                                            });
                                      });
                                    },
                                    child: Image.asset(
                                      'assets/delete1.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Updatepostcopy(
                                                      'SalePost',
                                                      record.productId
                                                          .toString())));
                                    },
                                    child: Image.asset('assets/edit1.png',
                                        width: 30, height: 30),
                                  ),
                                  record.suspend == 1
                                      ? GestureDetector(
                                          onTap: () async {
                                            if (record.boostCount != null &&
                                                record.boostCount! > 0) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return CommanDialog(
                                                    title: "Purchase Plan",
                                                    content:
                                                        "You have a Remaining Boost Balance of ${record.boostCount}. Would you like to use a boost?",
                                                    onPressed: () async {
                                                      setState(() {
                                                        isLoadingMap[record
                                                            .productId
                                                            .toString()] = true;
                                                      });
                                                      final response =
                                                          await set_pushnotification(
                                                              record.productId
                                                                  .toString());

                                                      setState(() {
                                                        isLoadingMap[record
                                                                .productId
                                                                .toString()] =
                                                            false;
                                                      });

                                                      if (response != null) {
                                                        if (response
                                                            .containsKey(
                                                                'status')) {
                                                          int status = response[
                                                              'status'];
                                                          if (status == -1) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const Premiun(),
                                                              ),
                                                            );
                                                            showCustomToast(
                                                                'Upgrade Plan to Boost Post');
                                                          } else if (status ==
                                                              0) {
                                                            showCustomToast(
                                                                'Invalid Authentication');
                                                          } else if (status ==
                                                              1) {
                                                            Navigator.pop(
                                                                context);

                                                            showCustomToast(
                                                                'Post is Boost');
                                                          }
                                                        } else {
                                                          showCustomToast(
                                                              'Error: Unexpected response format');
                                                          print(
                                                              'Unexpected response format: $response');
                                                        }
                                                      } else {
                                                        showCustomToast(
                                                            'Error: Response is null');
                                                        print(
                                                            'Response is null, this should not happen if API call succeeds.');
                                                      }
                                                    },
                                                  );
                                                },
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Premiun(),
                                                ),
                                              );
                                              showCustomToast(
                                                  'Upgrade Plan to Boost Post');
                                            }
                                          },
                                          child: isCurrentCardLoading
                                              ? Container(
                                                  width: 25,
                                                  height: 25,
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      if (record.boostCount !=
                                                              null &&
                                                          record.boostCount! >
                                                              0)
                                                        TextSpan(
                                                          text: record
                                                              .boostCount
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      WidgetSpan(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 0,
                                                          ),
                                                          child: Image.asset(
                                                            'assets/Boost.png',
                                                            width: 30,
                                                            height: 30,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        )
                                      : SizedBox(),
                                  record.suspend == 1
                                      ? GestureDetector(
                                          onTap: record.isPaidPost == 'Paid'
                                              ? null
                                              : () async {
                                                  if (record.premiumBoostCount !=
                                                          null &&
                                                      record.premiumBoostCount! >
                                                          0) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return CommanDialog(
                                                          title: "Paid Post",
                                                          content:
                                                              "You have a Remaining Paid Post Balance of ${record.boostCount}. Would you like to use a Paid Post?",
                                                          onPressed: () async {
                                                            setState(() {
                                                              isloadicon1[record
                                                                      .productId
                                                                      .toString()] =
                                                                  true;
                                                            });
                                                            final response =
                                                                await set_Premium_post_pushnotification(record
                                                                    .productId
                                                                    .toString());

                                                            setState(() {
                                                              isloadicon1[record
                                                                      .productId
                                                                      .toString()] =
                                                                  false;
                                                            });

                                                            if (response !=
                                                                null) {
                                                              if (response
                                                                  .containsKey(
                                                                      'status')) {
                                                                int status =
                                                                    response[
                                                                        'status'];

                                                                if (status ==
                                                                    -1) {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const Premiun(),
                                                                    ),
                                                                  );
                                                                  showCustomToast(
                                                                      'Upgrade Plan to Premium Post');
                                                                } else if (status ==
                                                                    0) {
                                                                  showCustomToast(
                                                                      'Invalid Authentication');
                                                                } else if (status ==
                                                                    1) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  showCustomToast(
                                                                      'Post is Premium');
                                                                }
                                                              } else {
                                                                showCustomToast(
                                                                    'Error: Unexpected response format');
                                                                print(
                                                                    'Unexpected response format: $response');
                                                              }
                                                            } else {
                                                              showCustomToast(
                                                                  'Error: Response is null');
                                                              print(
                                                                  'Response is null, this should not happen if API call succeeds.');
                                                            }
                                                          },
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Premiun(),
                                                      ),
                                                    );
                                                    showCustomToast(
                                                        'Upgrade Plan to Paid Post');
                                                  }
                                                },
                                          child: isCurrentCardLoading1
                                              ? Container(
                                                  width: 25,
                                                  height: 25,
                                                  child:
                                                      CircularProgressIndicator())
                                              : RichText(
                                                  text: TextSpan(children: [
                                                  if (record.premiumBoostCount !=
                                                          null &&
                                                      record.premiumBoostCount! >
                                                          0)
                                                    TextSpan(
                                                      text: record
                                                          .premiumBoostCount
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  WidgetSpan(
                                                    child: Image.asset(
                                                      'assets/flash.png',
                                                      width: 30,
                                                      height: 30,
                                                    ),
                                                  ),
                                                ])),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  10.sbh,
                  const Divider(color: Colors.grey),
                  3.sbh,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            if (record.isLike == "0") {
                              // Only execute on first tap
                              GtmUtil.logScreenView(
                                'Interested',
                                'like',
                              );
                              Prodlike(record.productId ?? 0);
                              record.isLike = '1';
                              record.likeCount = (record.likeCount ?? 0) + 1;
                              setState(() {});
                            }
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                record.isLike == "0"
                                    ? 'assets/like.png'
                                    : 'assets/like1.png',
                                height: 24,
                                width: 40,
                              ),
                              GestureDetector(
                                onTap: () {
                                  ViewItem(
                                    context,
                                    0,
                                    record.productId ?? 0,
                                    record.userId ?? 0,
                                  );
                                },
                                child: Text(
                                  record.likeCount == 0
                                      ? 'Interested'
                                      : 'Interested (${record.likeCount})',
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ViewItem(
                              context,
                              1,
                              record.productId ?? 0,
                              record.userId ?? 0,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    ViewItem(
                                      context,
                                      1,
                                      record.productId ?? 0,
                                      record.userId ?? 0,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/view1.png',
                                    height: 24,
                                  ),
                                ),
                              ),
                              Text(
                                'Views (${record.isView})',
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            sharecount(record.productId ?? 0);
                            shareImage(
                              url: record.mainproductImage.toString(),
                              share: "post",
                              context: context,
                              postType: record.postType ?? 'default_post_type',
                              prodId: record.productId ?? 0,
                              shorturl: record.postShortUrl.toString(),
                              productName: record.postName.toString(),
                              category: record.categoryName.toString(),
                              type: record.productType.toString(),
                              grade: record.productGrade.toString(),
                              qty: record.postQuntity.toString(),
                              unit: record.unit.toString(),
                              colorsName: record.postColor!.length.toString(),
                              price: record.productPrice.toString(),
                              currency: record.currency.toString(),
                              productDescription: record.toString(),
                              productStatus: record.productStatus.toString(),
                              createDate: record.toString(),
                              updateDate: record.toString(),
                            );
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/send2.png',
                                height: 24,
                                width: 40,
                              ),
                              InkWell(
                                onTap: () {
                                  ViewItem(
                                    context,
                                    2,
                                    record.productId ?? 0,
                                    record.userId ?? 0,
                                  );
                                },
                                child: const Text(
                                  'Share',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  10.sbh,
                ],
              ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget category_Buy() {
    if (buypostlist_data.isEmpty) {
      print('salepostlist_data is empty or null');
      return const Center(child: Text('No Data Found'));
    }
    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemCount: isLoading
            ? buypostlist_data.length + 1
            : (buypostlist_data.isEmpty ? 1 : buypostlist_data.length),
        itemBuilder: (context, index) {
          if (index == buypostlist_data.length) {
            if (hasMoreBuyPostDataToLoad() && !buypostlist_data.isEmpty) {
              return isLoading
                  ? managePostShimmerLoader(
                      width: 175,
                      height: 130,
                    )
                  : SizedBox();
            }
          } else {
            Result? record = buyPostList.result![index];

            for (int i = 0; i < buypostlist_data.length; i++) {
              selectedItemValueBuy
                  .add(buypostlist_data[i].productStatus.toString());
            }

            bool isCurrentCardLoading =
                isLoadingMap[record.productId.toString()] ?? false;

            bool isCurrentCardLoading1 =
                isloadicon1[record.productId.toString()] ?? false;

            return GestureDetector(
              onTap: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Buyer_sell_detail(
                                prod_id: record.productId.toString(),
                                post_type: record.postType,
                              )));
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                  border: Border.all(
                    color: record.isPaidPost == 'Paid'
                        ? Colors.red
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: Column(
                  children: [
                    8.sbh,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(children: [
                        Stack(fit: StackFit.passthrough, children: <Widget>[
                          Container(
                            height: 120,
                            width: 100,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: CachedNetworkImage(
                                imageUrl: record.mainproductImage.toString(),
                                fit: BoxFit.cover,
                                height: 150,
                                width: 170,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                  color: AppColors.greenWithShade,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              child: Text(
                                  '${record.currency}${record.productPrice}',
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w800,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf',
                                      color: Colors.white)),
                            ),
                          ),
                          if (record.isPaidPost == 'Paid')
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
                        ]),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${record.postName}',
                                  style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryColor,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf')
                                      .copyWith(
                                          fontSize: 12, color: Colors.black),
                                  maxLines: 2,
                                  softWrap: false),
                              record.suspend == 1
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            height: 20,
                                            child: Text(
                                                "${record.categoryName} | ${record.productType} | ${record.productGrade}",
                                                style: const TextStyle(
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            'assets/fonst/Metropolis-Black.otf')
                                                    .copyWith(
                                                        fontSize: 11,
                                                        color: Colors.black),
                                                maxLines: 1,
                                                softWrap: true)),
                                        Text(
                                          "${record.location}",
                                          style: const TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-Black.otf')
                                              .copyWith(
                                            fontSize: 11,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          softWrap: true,
                                        ),
                                        SizedBox(
                                            height: 20,
                                            child: Row(
                                              children: [
                                                Text('Qty:',
                                                    style: const TextStyle(
                                                            fontSize: 13.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf')
                                                        .copyWith(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black),
                                                    softWrap: false),
                                                Text(
                                                    '${record.postQuntity} ${record.unit}',
                                                    style: const TextStyle(
                                                            fontSize: 13.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf')
                                                        .copyWith(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black),
                                                    maxLines: 1,
                                                    softWrap: false),
                                              ],
                                            )),
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            childAspectRatio:
                                                MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    1000,
                                            crossAxisSpacing: 0.0,
                                            mainAxisSpacing: 0.0,
                                            crossAxisCount: 15,
                                          ),
                                          itemCount:
                                              record.postColor?.length ?? 0,
                                          itemBuilder: (context, colorIndex) {
                                            String colorString =
                                                resultbuyList[index]
                                                    .postColor![colorIndex]
                                                    .haxCode
                                                    .toString();

                                            String newStr =
                                                colorString.substring(1);

                                            Color colors = Color(int.parse(
                                                    newStr,
                                                    radix: 16))
                                                .withOpacity(1.0);
                                            return Container(
                                                margin: EdgeInsets.zero,
                                                padding: EdgeInsets.zero,
                                                child: newStr == 'ffffff'
                                                    ? const Icon(
                                                        Icons.circle_outlined,
                                                        size: 15)
                                                    : Icon(Icons.circle_rounded,
                                                        size: 15,
                                                        color: colors));
                                          },
                                        ),
                                      ],
                                    )
                                  : InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              bottomSheet(context),
                                        );
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  'Your post has been suspended. ',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                                fontFamily:
                                                    'assets/fonts/Metropolis-Black.otf',
                                                color: AppColors.red,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  'Please click here to view the policy',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                                fontFamily:
                                                    'assets/fonts/Metropolis-Black.otf',
                                                color: AppColors.red,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        bottomSheet(context),
                                                  );
                                                },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  record.suspend == 1
                                      ? PopupMenuButton<String>(
                                          onSelected: (value) {
                                            setState(() {
                                              selectedItemValueBuy[index] =
                                                  value;
                                              set_prod_status_buy(
                                                  record.productId.toString(),
                                                  value);
                                            });
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return _dropDownItem();
                                          },
                                          child: Container(
                                            width: 90,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  selectedItemValueBuy[index],
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Icon(Icons.arrow_drop_down)
                                              ],
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return CommonDialogYesNo(
                                                title: "Delete Post",
                                                content:
                                                    "Are You Sure Want To Delete Post?",
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _onLoading();
                                                  setState(() {});
                                                  delete_buy_post(record
                                                      .productId
                                                      .toString());
                                                },
                                              );
                                            });
                                      });
                                    },
                                    child: Image.asset(
                                      'assets/delete1.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => UpdatePOst(
                                                  'BuyPost',
                                                  record.productId
                                                      .toString())));
                                    },
                                    child: Image.asset('assets/edit1.png',
                                        width: 30, height: 30),
                                  ),
                                  record.suspend == 1
                                      ? GestureDetector(
                                          onTap: () async {
                                            if (record.boostCount != null &&
                                                record.boostCount! > 0) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return CommanDialog(
                                                    title: "Post Boost",
                                                    content:
                                                        "You have a Remaining Boost Balance of ${record.boostCount}. Would you like to use a boost?",
                                                    onPressed: () async {
                                                      setState(() {
                                                        isLoadingMap[record
                                                            .productId
                                                            .toString()] = true;
                                                      });

                                                      final response =
                                                          await set_pushnotification(
                                                        record.productId
                                                            .toString(),
                                                      );

                                                      setState(() {
                                                        isLoadingMap[record
                                                                .productId
                                                                .toString()] =
                                                            false;
                                                      });

                                                      if (response != null) {
                                                        if (response
                                                            .containsKey(
                                                                'status')) {
                                                          int status = response[
                                                              'status'];

                                                          if (status == -1) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const Premiun(),
                                                              ),
                                                            );
                                                            showCustomToast(
                                                                'Upgrade Plan to Boost Post');
                                                          } else if (status ==
                                                              0) {
                                                            showCustomToast(
                                                                'Invalid Authentication');
                                                          } else if (status ==
                                                              1) {
                                                            Navigator.pop(
                                                                context);
                                                            showCustomToast(
                                                                'Post is Boost');
                                                          }
                                                        } else {
                                                          showCustomToast(
                                                              'Error: Unexpected response format');
                                                          print(
                                                              'Unexpected response format: $response');
                                                        }
                                                      } else {
                                                        showCustomToast(
                                                            'Error: Response is null');
                                                        print(
                                                            'Response is null, this should not happen if API call succeeds.');
                                                      }
                                                    },
                                                  );
                                                },
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Premiun(),
                                                ),
                                              );
                                              showCustomToast(
                                                  'Upgrade Plan to Boost Post');
                                            }
                                          },
                                          child: isCurrentCardLoading
                                              ? Container(
                                                  width: 25,
                                                  height: 25,
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      if (record.boostCount !=
                                                              null &&
                                                          record.boostCount! >
                                                              0)
                                                        TextSpan(
                                                          text: record
                                                              .boostCount
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      WidgetSpan(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 0,
                                                          ),
                                                          child: Image.asset(
                                                            'assets/Boost.png',
                                                            width: 30,
                                                            height: 30,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        )
                                      : SizedBox(),
                                  record.suspend == 1
                                      ? GestureDetector(
                                          onTap: record.isPaidPost == 'Paid'
                                              ? null
                                              : () async {
                                                  if (record.premiumBoostCount !=
                                                          null &&
                                                      record.premiumBoostCount! >
                                                          0) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return CommanDialog(
                                                          title: "Paid Post",
                                                          content:
                                                              "You have a Remaining Paid Post Balance of ${record.boostCount}. Would you like to use a Paid Post?",
                                                          onPressed: () async {
                                                            setState(() {
                                                              isloadicon1[record
                                                                      .productId
                                                                      .toString()] =
                                                                  true;
                                                            });

                                                            final response =
                                                                await set_Premium_post_pushnotification(record
                                                                    .productId
                                                                    .toString());

                                                            setState(() {
                                                              isloadicon1[record
                                                                      .productId
                                                                      .toString()] =
                                                                  false;
                                                            });

                                                            if (response !=
                                                                null) {
                                                              if (response
                                                                  .containsKey(
                                                                      'status')) {
                                                                int status =
                                                                    response[
                                                                        'status'];

                                                                if (status ==
                                                                    -1) {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const Premiun(),
                                                                    ),
                                                                  );
                                                                  showCustomToast(
                                                                      'Upgrade Plan to Premium Post');
                                                                } else if (status ==
                                                                    0) {
                                                                  showCustomToast(
                                                                      'Invalid Authentication');
                                                                } else if (status ==
                                                                    1) {
                                                                  Navigator.pop(
                                                                      context);

                                                                  showCustomToast(
                                                                      'Post is Premium');
                                                                }
                                                              } else {
                                                                showCustomToast(
                                                                    'Error: Unexpected response format');
                                                                print(
                                                                    'Unexpected response format: $response');
                                                              }
                                                            } else {
                                                              showCustomToast(
                                                                  'Error: Response is null');
                                                              print(
                                                                  'Response is null, this should not happen if API call succeeds.');
                                                            }

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Premiun(),
                                                      ),
                                                    );
                                                    showCustomToast(
                                                        'Upgrade Plan to Paid Post');
                                                  }
                                                },
                                          child: isCurrentCardLoading1
                                              ? Container(
                                                  width: 25,
                                                  height: 25,
                                                  child:
                                                      CircularProgressIndicator())
                                              : RichText(
                                                  text: TextSpan(children: [
                                                    if (record.premiumBoostCount !=
                                                            null &&
                                                        record.premiumBoostCount! >
                                                            0)
                                                      TextSpan(
                                                        text: record
                                                            .premiumBoostCount
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    WidgetSpan(
                                                      child: Image.asset(
                                                        'assets/flash.png',
                                                        width: 30,
                                                        height: 30,
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    10.sbh,
                    const Divider(color: Colors.grey),
                    3.sbh,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              if (record.isLike == "0") {
                                // Only execute on first tap
                                GtmUtil.logScreenView(
                                  'Interested',
                                  'like',
                                );
                                Prodlike(record.productId ?? 0);
                                record.isLike = '1';
                                record.likeCount = (record.likeCount ?? 0) + 1;
                                setState(() {});
                              }
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  record.isLike == "0"
                                      ? 'assets/like.png'
                                      : 'assets/like1.png',
                                  height: 24,
                                  width: 40,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ViewItem(
                                      context,
                                      0,
                                      record.productId ?? 0,
                                      record.userId ?? 0,
                                    );
                                  },
                                  child: Text(
                                    record.likeCount == 0
                                        ? 'Interested'
                                        : 'Interested (${record.likeCount})',
                                    style: const TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ViewItem(
                                context,
                                1,
                                record.productId ?? 0,
                                record.userId ?? 0,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      ViewItem(
                                        context,
                                        1,
                                        record.productId ?? 0,
                                        record.userId ?? 0,
                                      );
                                    },
                                    child: Image.asset(
                                      'assets/view1.png',
                                      height: 24,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Views (${record.isView})',
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              sharecount(record.productId ?? 0);
                              shareImage(
                                url: record.mainproductImage.toString(),
                                share: "post",
                                context: context,
                                postType:
                                    record.postType ?? 'default_post_type',
                                prodId: record.productId ?? 0,
                                shorturl: record.postShortUrl.toString(),
                                productName: record.postName.toString(),
                                category: record.categoryName.toString(),
                                type: record.productType.toString(),
                                grade: record.productGrade.toString(),
                                qty: record.postQuntity.toString(),
                                unit: record.unit.toString(),
                                colorsName: record.postColor!.length.toString(),
                                price: record.productPrice.toString(),
                                currency: record.currency.toString(),
                                productDescription: record.toString(),
                                productStatus: record.productStatus.toString(),
                                createDate: record.toString(),
                                updateDate: record.toString(),
                              );
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/send2.png',
                                  height: 24,
                                  width: 40,
                                ),
                                InkWell(
                                  onTap: () {
                                    ViewItem(
                                      context,
                                      2,
                                      record.productId ?? 0,
                                      record.userId ?? 0,
                                    );
                                  },
                                  child: const Text(
                                    'Share',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    10.sbh,
                  ],
                ),
              ),
            );
          }
          return SizedBox();
        });
  }

  bool hasMoreSalePpostDataToLoad() {
    int itemsPerPage = 20;
    return salepostlist_data.length % itemsPerPage == 0;
  }

  bool hasMoreBuyPostDataToLoad() {
    int itemsPerPage = 20;
    return buypostlist_data.length % itemsPerPage == 0;
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 6,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.gray,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          10.sbh,
          Text(
            'Post Suspension Notice',
            style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w800,
                color: AppColors.blackColor,
                fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Your post has been suspended for the following reasons:',
            style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: AppColors.blackColor,
                fontFamily: 'assets/fonst/Metropolis-Black.otf'),
          ),
          8.sbh,
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Prohibited Content: Business cards, phone numbers, email addresses, personal names, or company names cannot be included in images or product names.',
                    style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                        fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                  ),
                  5.sbh,
                  const Text(
                    '2. Name Restrictions: Company names are not permitted in personal names or product names.',
                    style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                        fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                  ),
                  5.sbh,
                  const Text(
                    '3. Required Action: Please edit your post or profile to comply with the above policy.',
                    style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                        fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                  ),
                  5.sbh,
                  const Text(
                    '4. Consequences of Violation: Be advised that repeated violations of this policy may result in the blocking of your profile.',
                    style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                        fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _dropDownItem() {
    List<String> ddl = ["Available", "On Going", "Sold Out"];
    return ddl
        .map((value) => PopupMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ))
        .toList();
  }

  void shareImage({
    required String url,
    required String shorturl,
    required String share,
    required BuildContext context,
    required String postType,
    required int prodId,
    required String productName,
    required String category,
    required String type,
    required String grade,
    required String qty,
    required String unit,
    required String colorsName,
    required String price,
    required String currency,
    required String productDescription,
    required String productStatus,
    required String createDate,
    required String updateDate,
  }) async {
    try {
      final dynamicLink =
          await createDynamicLink(shorturl, postType, prodId.toString());
      print("Dynamic Link created: $dynamicLink");
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load image from the server');
      }

      final bytes = response.bodyBytes;
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/image.jpg';
      await File(path).writeAsBytes(bytes);

      // Prepare share text
      final shareText = share == "post"
          ? '${productName}\n'
              '${category}\n'
              '${type}\n'
              '${grade}\n'
              '${qty} ${unit}\n\n'
              'Plastic4trade is a B2B Plastic Business App, Buy & Sale your Products, Raw Material, Recycle Plastic Scrap, Plastic Machinery, Polymer Price, News, Update for Manufacturers, Traders, Exporters, Importers....\n\n'
              'More Info: $dynamicLink\n\n'
          : '${productName}\n'
              '${price}\n'
              '${currency}\n'
              '${category}\n'
              '${type}\n'
              '${grade}\n'
              '${constanst.post_type}\n'
              '${qty} ${unit}\n'
              '${colorsName}\n'
              '${productDescription.toString()}\n'
              '${productStatus.toString()}\n'
              '${createDate}\n'
              '${updateDate}\n'
              'More Info: $dynamicLink';

      await Share.shareFiles([path], text: shareText);
    } catch (e) {}
  }

  ViewItem(BuildContext context, int tabIndex, int prodId, int profileId) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
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
          initialChildSize:
              0.60, // Initial height as a fraction of screen height
          builder: (BuildContext context, ScrollController scrollController) {
            return ViewWidget(
              prod_id: prodId.toString(),
              tabIndex: tabIndex,
            );
          }),
    ).then(
      (value) {},
    );
  }

  getadd_product(int productId) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String device = '';
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }
      print('Device Name: $device');

      var res = await addfav(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        productId.toString(),
        device,
      );

      if (res['status'] == 1) {
        var jsonArray = res['result'];

        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));
        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');

        showCustomToast(res['message']);
        setState(() {});
        return true; // Return true for success
      } else {
        showCustomToast(res['message']);
        return false; // Return false for failure
      }
    } catch (e) {
      print('Error in getadd_product: $e');
      return false; // Return false for any exception
    }
  }

  getremove_product(int productId) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String device = '';
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }
      print('Device Name: $device');

      var res = await removefav(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        productId.toString(),
        device,
      );

      if (res['status'] == 1) {
        var jsonArray = res['result'];

        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));
        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');

        showCustomToast(res['message']);
        setState(() {});
        return true; // Return true for success
      } else {
        showCustomToast(res['message']);
        return false; // Return false for failure
      }
    } catch (e) {
      print('Error in getremove_product: $e');
      return false; // Return false for any exception
    }
  }

  Future<void> Prodlike(int productId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await product_like(
      productId.toString(),
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    var jsonArray;
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      showCustomToast(
        res['message'],
      );
    } else {
      showCustomToast(
        res['message'],
      );
    }
    setState(() {});
    return jsonArray;
  }

  Future<void> sharecount(int productId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getProductShareCount(
      pref.getString('user_id').toString(),
      productId,
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

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      clear_data();
      get_salepostlist();
      get_buypostlist();
    }
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

    var res = await managebuy_PostList(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      pref.getString('user_id').toString(),
      device,
    );
    print('API Response: $res');

    var jsonArray;
    if (res['status'] == 1) {
      totalPostBuy = res['total_post'];
      print('Total Buy Posts: $totalPostBuy');
      jsonArray = res['result'];
      print('JSON Array: $jsonArray');
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      buyPostList = GetSalePostList.fromJson(res);
      resultbuyList = buyPostList.result ?? [];

      if (jsonArray != null) {
        var colorArray;
        for (var data in jsonArray) {
          homepost.Result record = homepost.Result(
            postName: data['PostName'],
            suspend: data['is_approve'],
            categoryName: data['CategoryName'],
            productGrade: data['ProductGrade'],
            currency: data['Currency'],
            productPrice: data['ProductPrice'],
            state: data['State'],
            country: data['Country'],
            location: data['Location'],
            postType: data['PostType'],
            isPaidPost: data['is_paid_post'],
            productId: data['productId'],
            productType: data['ProductType'],
            unit: data['Unit'],
            postQuntity: data['PostQuntity'],
            productStatus: data['product_status'],
            mainproductImage: data['mainproductImage'],
            boostCount: data['remaining_notification'],
            premiumBoostCount: data['remaining_paid_post'],
            isLike: data['isLike'],
            likeCount: data['likeCount'],
            postShortUrl: data['post_url'],
            isFavorite: data['isFavorite'],
            isView: data['view_product'],
          );
          print('boostCount: ${data['remaining_notification']}');
          print('Post Suspend: ${data['is_approve']}');

          print('premiumBoostCount: ${data['remaining_paid_post']}');
          print('Post Record: $record');

          colorArray = data['PostColor'];
          if (colorArray != null) {
            for (var colorData in colorArray) {
              homepost.PostColor colorRecord = homepost.PostColor(
                  colorName: colorData['colorName'],
                  haxCode: colorData['HaxCode']);
              colorsbuy.add(colorRecord);
            }
          }
          buypostlist_data.add(record);
        }
      }
    } else {
      print('Error Message: ${res['message']}');
    }
    setState(() {
      isload = true;
    });
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

    var res = await managesale_PostList(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      pref.getString('user_id').toString(),
      device,
    );
    var jsonArray;
    if (res['status'] == 1) {
      // Extract total posts count
      totalPostSale = res['total_post'];
      print('Total Sale Posts: $totalPostSale');
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      salePostList = GetSalePostList.fromJson(res);
      resultSaleList = salePostList.result ?? [];
      if (res['result'] != null) {
        jsonArray = res['result'];

        var colorArray;
        for (var data in jsonArray) {
          homepost.Result record = homepost.Result(
            postName: data['PostName'],
            suspend: data['is_approve'],
            categoryName: data['CategoryName'],
            productGrade: data['ProductGrade'],
            currency: data['Currency'],
            productPrice: data['ProductPrice'],
            state: data['State'],
            country: data['Country'],
            location: data['Location'],
            postType: data['PostType'],
            isPaidPost: data['is_paid_post'],
            productId: data['productId'],
            productType: data['ProductType'],
            unit: data['Unit'],
            postQuntity: data['PostQuntity'],
            productStatus: data['product_status'],
            mainproductImage: data['mainproductImage'],
            boostCount: data['remaining_notification'],
            premiumBoostCount: data['remaining_paid_post'],
            isLike: data['isLike'],
            likeCount: data['likeCount'],
            postShortUrl: data['post_url'],
            isFavorite: data['isFavorite'],
            isView: data['view_product'],
          );

          print('boostCount: ${data['remaining_notification']}');
          print('Post Suspend: ${data['is_approve']}');

          print('premiumBoostCount: ${data['remaining_paid_post']}');
          print('Post Record: $record');

          colorArray = data['PostColor'];
          if (colorArray != null) {
            for (var data in colorArray) {
              homepost.PostColor record = homepost.PostColor(
                  colorName: data['colorName'], haxCode: data['HaxCode']);
              colorssale.add(record);
            }
          }
          salepostlist_data.add(record);
          print(res['result']);
        }
      }
    } else {
      print('Error Message: ${res['message']}');
    }
    setState(() {
      isload = true;
    });
    return jsonArray;
  }

  set_prod_status_sell(String prodId, String prodStatus) async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await save_prostatus(prodId, prodStatus, device);
    var jsonArray;
    if (res['status'] == 1) {
      setState(() {
        // Update product status locally
        int index =
            salepostlist_data.indexWhere((item) => item.productId == prodId);
        if (index != -1) {
          selectedItemValueSale[index] = prodStatus;
        }
      });
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      // showCustomToast(msg: res['message']);
    } else {
      showCustomToast(res['message']);
    }
    setState(() {});
    return jsonArray;
  }

  set_prod_status_buy(String prodId, String prodStatus) async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await save_prostatus(prodId, prodStatus, device);
    var jsonArray;
    if (res['status'] == 1) {
      setState(() {
        // Update product status locally
        int index =
            buypostlist_data.indexWhere((item) => item.productId == prodId);
        if (index != -1) {
          selectedItemValueBuy[index] = prodStatus;
        }
      });
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      // showCustomToast(msg: res['message']);
    } else {
      showCustomToast(res['message']);
    }
    setState(() {});
    return jsonArray;
  }

  Future<Map<String, dynamic>?> set_pushnotification(String prodId) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      setState(() {
        isLoadingMap[prodId] = true;
      });

      String device = '';
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }
      print('Device Name: $device');

      var res = await push_notification(
        prodId,
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        device,
      );

      print('prodId: $prodId');
      print('user_id: ${pref.getString('user_id').toString()}');
      print('userToken: ${pref.getString('userToken').toString()}');

      print('Full Response: $res');

      setState(() {
        isLoadingMap[prodId] = false;
      });
      if (res != null && res is Map<String, dynamic>) {
        return res;
      } else {
        print('Error: Invalid response format');
        return null;
      }
    } catch (e) {
      setState(() {
        isLoadingMap[prodId] = false;
      });
      print('Error in set_pushnotification: $e');
      showCustomToast('An error occurred. Please try again.');
      return null;
    }
  }

  delete_salepost(String prodId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await deletesalepost(
      prodId,
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      checknetowork();
      showCustomToast(res['message']);
    } else {
      showCustomToast(res['message']);
    }
    setState(() {
      Navigator.pop(context);
    });
    return res;
  }

  delete_buy_post(String prodId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await deletebuypost(
      prodId,
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      checknetowork();
      showCustomToast(res['message']);
    } else {
      showCustomToast(res['message']);
    }
    setState(() {
      Navigator.pop(context);
    });
    return res;
  }

  Future<Map<String, dynamic>?> set_Premium_post_pushnotification(
      String prodId) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      // Show the loader
      setState(() {
        isloadicon1[prodId] = true;
      });

      String device = '';
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }
      print('Device Name: $device');

      // Call the API and store the response
      var res = await premium_post_notification(
        prodId,
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        device,
      );

      print('prodId: $prodId');
      print('user_id: ${pref.getString('user_id').toString()}');
      print('userToken: ${pref.getString('userToken').toString()}');

      // Print the full response for debugging
      print('Full Response: $res');

      // Show the loader
      setState(() {
        isloadicon1[prodId] = false;
      });

      // Return the response if it's a valid map
      if (res != null && res is Map<String, dynamic>) {
        return res;
      } else {
        print('Error: Invalid response format');
        return null;
      }
    } catch (e) {
      // Show the loader
      setState(() {
        isloadicon1[prodId] = false;
      });

      // Handle any errors
      print('Error in set_pushnotification: $e');
      showCustomToast('An error occurred. Please try again.');
      return null;
    }
  }

  void _onLoading() {
    dialogContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
            backgroundColor: AppColors.transperent,
            elevation: 0,
            child: SizedBox(
                width: 300.0,
                height: 150.0,
                child: Center(
                    child: SizedBox(
                        height: 100.0,
                        width: 100.0,
                        child: Center(
                          child: CustomLottieContainer(
                            child: Lottie.asset(
                              'assets/loading_animation.json',
                            ),
                          ),
                        )))));
      },
    );
  }
}
