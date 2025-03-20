// ignore_for_file: unnecessary_null_comparison, depend_on_referenced_packages, camel_case_types, must_be_immutable, prefer_interpolation_to_compose_strings, non_constant_identifier_names, prefer_typing_uninitialized_variables, library_prefixes, deprecated_member_use

import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:Plastic4trade/model/CommonPostdetail.dart' as postdetail;
import 'package:Plastic4trade/model/getsimilar_product.dart' as similar_prod;
import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';

import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_chat_shimmer_loader.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_notificaton_shimmer_loader.dart';
import 'package:Plastic4trade/widget/customshimmer/custome_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../api/api_interface.dart';
import '../../model/CommonPostdetail.dart';
import '../../model/get_product_interest.dart' as interest;
import '../../model/get_product_interest.dart';
import '../../model/get_product_share.dart' as productShare;
import '../../model/get_product_share.dart';
import '../../model/get_product_view.dart' as viewInterest;
import '../../model/get_product_view.dart';
import '../../widget/HomeAppbar.dart';
import '../buisness_profile/BussinessProfile.dart';

class Buyer_sell_detail extends StatefulWidget {
  String? post_type;
  String? prod_id;

  Buyer_sell_detail({Key? key, this.post_type, this.prod_id}) : super(key: key);

  @override
  State<Buyer_sell_detail> createState() => _Buyer_sell_detailState();
}

class _Buyer_sell_detailState extends State<Buyer_sell_detail> {
  final scrollercontroller = ScrollController();
  bool isload = false;
  String? packageName;
  PackageInfo? packageInfo;
  int offset = 0;
  int count = 0;
  String appUserId = "";
  String notiId = "";
  String cate_name = "";
  String Grade = "";
  String type = "";
  String qty = "";
  String price = "";
  String currency = "";
  String usernm = "";
  String userMobileNo = "";
  String countryCode = "";
  String username = "";

  String city = "";
  String state = "";
  String country = "";
  int? likecount, viewcount, is_prime, isBusinessProfileView, isBusinessOldView;
  String? isFavorite = "0", unit = "", price_unit = "";
  bool isExpanded = true;
  String profileid = "";
  String is_Follow = "";
  String selfUserId = "";
  String postType = "";
  int? isView, user_id, todayCount;
  String? product_status;
  String? prod_desc;
  String? prod_nm;
  String? loc;
  String create_date = "";
  String update_date = "";
  bool load = false;
  String? location;
  List<postdetail.PostHaxCodeColor>? postHaxCodeColors = [];
  String crown_color = '';
  String plan_name = '';
  String? bussiness_type;
  String? post_short_url;

  String? user_image, main_product;
  var create_formattedDate, update_formattedDate;
  List<String> imagelist = [];
  int getSliderIndex = 0;
  List<similar_prod.Result> simmilar_post_buyer = [];
  List<similar_prod.Result> simmilar_post_saler = [];

  bool isLoading = false;
  bool isLiked = false;

  List<postdetail.PostHaxCodeColor> colors = [];
  String? follow;
  String like = "0";
  String? fav;
  Future? getRalSalerpostFuture;
  Future? getRalBuyerpostFuture;

  @override
  void initState() {
    super.initState();
    scrollercontroller.addListener(_scrollercontroller);
    getPackage();
    checknetowork();
  }

  void getPackage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    appUserId = pref.getString('user_id').toString();
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SingleChildScrollView(
        controller: scrollercontroller,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: <Widget>[
                        load == false
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(100.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Lottie.asset(
                                        'assets/image_animation.json',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : imagelist.length == 1
                                ? GestureDetector(
                                    onTap: () {
                                      _showFullScreenSliderDialog(context, 0);
                                    },
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16.0),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: imagelist[0].toString(),
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 321,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 321,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.black.withOpacity(0.6),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : slider(),
                        if (imagelist.length > 1)
                          Positioned(
                            top: 300,
                            right: 15,
                            child: SizedBox(
                              height: 8,
                              child: ListView.builder(
                                itemCount: imagelist.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: getSliderIndex == index ? 14 : 7,
                                    height: 7,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(
                                          getSliderIndex == index ? 3.5 : 3.5),
                                      color: getSliderIndex == index
                                          ? AppColors.primaryColor
                                          : const Color(0xFFD9D9D9),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        Positioned(
                          top: 30,
                          left: 15,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Material(
                              type: MaterialType.transparency,
                              child: Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: ShapeDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: const CircleBorder(),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 15,
                          top: 30,
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: ShapeDecoration(
                                  color: Colors.white
                                      .withOpacity(0.15000000596046448),
                                  shape: const OvalBorder(),
                                ),
                                child: isFavorite == "1"
                                    ? GestureDetector(
                                        onTap: () {
                                          print("data:-$isFavorite");

                                          setState(() {
                                            isFavorite = "0";
                                          });

                                          getremove_product().then((success) {
                                            if (!success) {
                                              setState(() {
                                                isFavorite = "1";
                                              });
                                            }
                                          });
                                        },
                                        child: Icon(
                                          Icons.bookmark,
                                          color: AppColors.greyBackground,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          print("data:-$isFavorite");

                                          setState(() {
                                            isFavorite = "1";
                                          });

                                          getadd_product().then((success) {
                                            if (!success) {
                                              setState(() {
                                                isFavorite = "0";
                                              });
                                            }
                                          });
                                        },
                                        child: Icon(
                                          size: 30,
                                          isFavorite == "1"
                                              ? Icons.bookmark_outlined
                                              : Icons.bookmark_outline_rounded,
                                          color: isFavorite == "1"
                                              ? AppColors.primaryColor
                                              : AppColors.greyBackground,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  sharecount();

                                  shareImage(
                                    url: main_product.toString(),
                                    share: "post",
                                    context: context,
                                    postType:
                                        widget.post_type ?? 'default_post_type',
                                    prodId: widget.prod_id ?? 'default_prod_id',
                                    shorturl: post_short_url.toString(),
                                  );
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: ShapeDecoration(
                                    color: Colors.white
                                        .withOpacity(0.15000000596046448),
                                    shape: const OvalBorder(),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            10.sbh,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  load == false
                      ? Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13.05),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x3FA6A6A6),
                                blurRadius: 16.32,
                                offset: Offset(0, 3.26),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Shimmer.fromColors(
                            baseColor: AppColors.grayHighforshimmer,
                            highlightColor: AppColors.grayLightforshimmer,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: 20,
                                  width: 150,
                                  color: AppColors.grayHighforshimmer,
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height: 250,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.grayHighforshimmer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: ShapeDecoration(
                            color: Colors.white,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prod_nm.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.greenWithShade,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '$currency $price',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (price_unit != null &&
                                            price_unit != "null" &&
                                            price_unit != "" &&
                                            price_unit!.isNotEmpty)
                                          Text(
                                            '/$price_unit',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0x3000945E),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Text(
                                      product_status.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.black.withOpacity(0.19),
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Text(
                                      (widget.post_type == 'BuyPost')
                                          ? "Buy Post"
                                          : (widget.post_type == 'SalePost')
                                              ? "Sale Post"
                                              : "",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildCommanData(
                                  title: "Category", data: cate_name),
                              _buildCommanData(title: "Type", data: type),
                              _buildCommanData(title: "Grade", data: Grade),
                              _buildCommanData(
                                  title: "Quantity", data: "$qty $unit"),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 85,
                                    child: Text(
                                      'Color: ',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 45,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            postHaxCodeColors?.length ?? 0,
                                        itemBuilder: (context, colorIndex) {
                                          postdetail.PostHaxCodeColor result =
                                              postHaxCodeColors![colorIndex];
                                          String colorString =
                                              result.haxCode.toString();
                                          String newStr =
                                              colorString.substring(1);

                                          Color colors = Color(
                                            int.parse(newStr, radix: 16),
                                          ).withOpacity(1.0);
                                          return Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                newStr == 'ffffff'
                                                    ? const Icon(
                                                        Icons.circle_outlined,
                                                        size: 18,
                                                      )
                                                    : Icon(
                                                        Icons.circle_rounded,
                                                        size: 18,
                                                        color: colors,
                                                      ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    colorIndex + 1 ==
                                                            postHaxCodeColors
                                                                ?.length
                                                        ? postHaxCodeColors![
                                                                colorIndex]
                                                            .colorName
                                                            .toString()
                                                        : '${postHaxCodeColors![colorIndex].colorName.toString()},',
                                                    overflow:
                                                        TextOverflow.visible,
                                                    maxLines: 1,
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              Visibility(
                                visible: isBusinessProfileView == 1 &&
                                    isBusinessOldView == 1,
                                child: Container(
                                  child: Text(
                                    prod_desc.toString(),
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 15,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Updated on $update_formattedDate',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    'Posted on $create_formattedDate',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.grey),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (like == "0") {
                                        // Only execute on first tap
                                        GtmUtil.logScreenView(
                                          'Interested',
                                          'like',
                                        );
                                        Prodlike();
                                        like = '1';
                                        likecount = (likecount ?? 0) + 1;
                                        setState(() {});
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          like == "0"
                                              ? 'assets/like.png'
                                              : 'assets/like1.png',
                                          height: 24,
                                          width: 40,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            ViewItem(
                                              context: context,
                                              tabIndex: 0,
                                            );
                                          },
                                          child: Text(
                                            'Interested ($likecount)',
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
                                        context: context,
                                        tabIndex: 1,
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              ViewItem(
                                                context: context,
                                                tabIndex: 1,
                                              );
                                            },
                                            child: Image.asset(
                                              'assets/view1.png',
                                              height: 24,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Views ($viewcount)',
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
                                      sharecount();
                                      shareImage(
                                        url: main_product.toString(),
                                        share: "post",
                                        context: context,
                                        postType: widget.post_type ??
                                            'default_post_type',
                                        prodId:
                                            widget.prod_id ?? 'default_prod_id',
                                        shorturl: post_short_url.toString(),
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
                                              context: context,
                                              tabIndex: 2,
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
                                  isFavorite == "1"
                                      ? GestureDetector(
                                          onTap: () {
                                            print("data:-$isFavorite");

                                            setState(() {
                                              isFavorite = "0";
                                            });

                                            getremove_product().then((success) {
                                              if (!success) {
                                                setState(() {
                                                  isFavorite = "1";
                                                });
                                              }
                                            });
                                          },
                                          child: Icon(
                                            Icons.bookmark_outlined,
                                            color: AppColors.primaryColor,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            print("data:-$isFavorite");

                                            setState(() {
                                              isFavorite = "1";
                                            });

                                            getadd_product().then((success) {
                                              if (!success) {
                                                setState(() {
                                                  isFavorite = "0";
                                                });
                                              }
                                            });
                                          },
                                          child: Icon(
                                            isFavorite == "1"
                                                ? Icons.bookmark_outlined
                                                : Icons
                                                    .bookmark_outline_rounded,
                                            color: isFavorite == "1"
                                                ? AppColors.primaryColor
                                                : Colors.black.withOpacity(0.7),
                                          ),
                                        ),
                                ],
                              )
                            ],
                          ),
                        ),
                ],
              ),
            ),
            10.sbh,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (like == "0") {
                        // Only execute on first tap
                        GtmUtil.logScreenView(
                          'Interested',
                          'like',
                        );
                        Prodlike();
                        like = '1'; // Set to liked state permanently
                        likecount = (likecount ?? 0) +
                            1; // Increment like count only once
                        setState(() {}); // Update the UI
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.6),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      elevation: 2,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            like == "0"
                                ? Icons.thumb_up_outlined
                                : Icons.thumb_up,
                            size: 28,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'I\'m Interested (${likecount ?? 0})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
              child: Column(
                children: [
                  load == false
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NotificationShimmerLoader(
                              width: 175, height: 115),
                        )
                      : Column(children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: Colors.white,
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          (isBusinessProfileView == 1 &&
                                                  isBusinessOldView == 1)
                                              ? GestureDetector(
                                                  onTap: () async {
                                                    GtmUtil.logScreenView(
                                                      'Business_Profile_View',
                                                      'profileview',
                                                    );

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            bussinessprofile(
                                                                user_id!),
                                                      ),
                                                    ).then((_) {
                                                      if (widget.post_type ==
                                                          'BuyPost') {
                                                        get_BuyerPostDatil();
                                                      } else if (widget
                                                              .post_type ==
                                                          'SalePost') {
                                                        get_SalePostDatil();
                                                      }
                                                    });
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Column(
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
                                                                  color: crown_color !=
                                                                          null
                                                                      ? Color(int.parse(crown_color.substring(1),
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
                                                                imageUrl: user_image
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
                                                              color: crown_color !=
                                                                      null
                                                                  ? Color(int.parse(
                                                                          crown_color.substring(
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
                                                              plan_name
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
                                                      10.sbw,
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: selfUserId !=
                                                                    user_id
                                                                        .toString()
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3.2
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    1.5,
                                                            child: Text(
                                                              capitalizeEachWord(
                                                                  usernm
                                                                      .toString()),
                                                              style:
                                                                  const TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    -0.24,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-SemiBold.otf',
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: selfUserId !=
                                                                    user_id
                                                                        .toString()
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3.2
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    1.5,
                                                            child: Text(
                                                              bussiness_type !=
                                                                      null
                                                                  ? bussiness_type!
                                                                      .replaceAll(
                                                                          ",",
                                                                          ", ")
                                                                  : "",
                                                              style: TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.50),
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-Black.otf',
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const ImageIcon(
                                                                AssetImage(
                                                                    'assets/location.png'),
                                                                size: 15,
                                                              ),
                                                              const SizedBox(
                                                                  width: 3),
                                                              SizedBox(
                                                                width: selfUserId !=
                                                                        user_id
                                                                            .toString()
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        4
                                                                    : MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        2,
                                                                child: Text(
                                                                  location
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    letterSpacing:
                                                                        -0.24,
                                                                    fontFamily:
                                                                        'assets/fonst/Metropolis-Black.otf',
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape: CircleBorder(
                                                          side: BorderSide(
                                                            width: 2,
                                                            color: crown_color !=
                                                                    null
                                                                ? Color(int.parse(
                                                                        crown_color
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
                                                      alignment:
                                                          Alignment.center,
                                                      transform: Matrix4
                                                          .translationValues(
                                                              0.0, -10.0, 0.0),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: crown_color !=
                                                                null
                                                            ? Color(int.parse(
                                                                    crown_color
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
                                                        plan_name.toString(),
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
                                                ),
                                        ],
                                      ),
                                      const SizedBox(width: 10),
                                      if (isBusinessProfileView == 1 &&
                                          isBusinessOldView == 0)
                                        ElevatedButton(
                                          onPressed: () async {
                                            GtmUtil.logScreenView(
                                              'Business_Profile_View',
                                              'profileview',
                                            );

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    bussinessprofile(user_id!),
                                              ),
                                            ).then((_) {
                                              if (widget.post_type ==
                                                  'BuyPost') {
                                                get_BuyerPostDatil();
                                              } else if (widget.post_type ==
                                                  'SalePost') {
                                                get_SalePostDatil();
                                              }
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            backgroundColor:
                                                AppColors.primaryColor,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            elevation: 2,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              widget.post_type == 'BuyPost'
                                                  ? 'Contact Buyer Now'
                                                  : widget.post_type ==
                                                          'SalePost'
                                                      ? 'Contact Seller Now'
                                                      : 'Click to View Profile',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily:
                                                    'assets/fonts/Metropolis-SemiBold.otf',
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      else if (isBusinessProfileView != 1 &&
                                          isBusinessOldView != 1)
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Premiun(),
                                              ),
                                            );
                                            showCustomToast(
                                                'Upgrade Plan to View Profile');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            backgroundColor:
                                                AppColors.primaryColor,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            elevation: 2,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              widget.post_type == 'BuyPost'
                                                  ? 'Contact Buyer Now'
                                                  : widget.post_type ==
                                                          'SalePost'
                                                      ? 'Contact Seller Now'
                                                      : 'Click to View Profile',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily:
                                                    'assets/fonts/Metropolis-SemiBold.otf',
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                  if (selfUserId != user_id.toString())
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  (selfUserId == user_id.toString())
                                      ? SizedBox()
                                      : Row(
                                          children: [
                                            GestureDetector(
                                              onTap: is_Follow == "0"
                                                  ? () {
                                                      followUnfollowUser("1");
                                                      is_Follow = "1";
                                                      setState(() {});
                                                    }
                                                  : () {},
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 32,
                                                    height: 32,
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        const ShapeDecoration(
                                                      color: AppColors
                                                          .primaryColor,
                                                      shape: OvalBorder(),
                                                    ),
                                                    child: Image.asset(
                                                        "assets/follow1.png",
                                                        fit: BoxFit.cover),
                                                  ),
                                                  Text(
                                                    is_Follow == "0"
                                                        ? 'Follow'
                                                        : 'Followed',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontSize: 11,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: -0.24,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            isBusinessProfileView == 1 &&
                                                    isBusinessOldView == 0
                                                ? GestureDetector(
                                                    onTap: () {
                                                      String message;

                                                      if (widget.post_type ==
                                                          'BuyPost') {
                                                        message =
                                                            'Please Click Contact Buyer now';
                                                      } else if (widget
                                                              .post_type ==
                                                          'SalePost') {
                                                        message =
                                                            'Please Click Contact Seller now';
                                                      } else {
                                                        message =
                                                            'Please click to share via WhatsApp';
                                                      }

                                                      showCustomToast(message);
                                                    },
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.topRight,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Container(
                                                              width: 32,
                                                              height: 32,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  const ShapeDecoration(
                                                                color: AppColors
                                                                    .primaryColor,
                                                                shape:
                                                                    OvalBorder(),
                                                              ),
                                                              child:
                                                                  Image.asset(
                                                                "assets/account.png",
                                                                height: 25,
                                                                width: 25,
                                                                fit: BoxFit
                                                                    .cover,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            const Text(
                                                              'Profile',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: AppColors
                                                                    .primaryColor,
                                                                fontSize: 11,
                                                                fontFamily:
                                                                    'assets/fonts/Metropolis-Black.otf',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                letterSpacing:
                                                                    -0.24,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (todayCount !=
                                                                null &&
                                                            todayCount != -1)
                                                          Positioned(
                                                            right: 0,
                                                            top: 0,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: Text(
                                                                todayCount
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () async {
                                                      if (isBusinessProfileView ==
                                                          1) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                bussinessprofile(
                                                                    user_id!),
                                                          ),
                                                        ).then((_) {
                                                          if (widget
                                                                  .post_type ==
                                                              'BuyPost') {
                                                            get_BuyerPostDatil();
                                                          } else if (widget
                                                                  .post_type ==
                                                              'SalePost') {
                                                            get_SalePostDatil();
                                                          }
                                                        });
                                                      } else if (isBusinessProfileView ==
                                                          0) {
                                                        print(
                                                            'Redirecting to Premium');
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                Premiun(),
                                                          ),
                                                        );
                                                        showCustomToast(
                                                            'Upgrade Plan to View Profile');
                                                      }
                                                    },
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.topRight,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Container(
                                                              width: 32,
                                                              height: 32,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  const ShapeDecoration(
                                                                color: AppColors
                                                                    .primaryColor,
                                                                shape:
                                                                    OvalBorder(),
                                                              ),
                                                              child:
                                                                  Image.asset(
                                                                "assets/account.png",
                                                                height: 25,
                                                                width: 25,
                                                                fit: BoxFit
                                                                    .cover,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            const Text(
                                                              'Profile',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: AppColors
                                                                    .primaryColor,
                                                                fontSize: 11,
                                                                fontFamily:
                                                                    'assets/fonts/Metropolis-Black.otf',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                letterSpacing:
                                                                    -0.24,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (todayCount !=
                                                                null &&
                                                            todayCount != -1)
                                                          Positioned(
                                                            right: 0,
                                                            top: 0,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: Text(
                                                                todayCount
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                            const SizedBox(width: 10),
                                            isBusinessProfileView == 1
                                                ? GestureDetector(
                                                    onTap: () async {
                                                      if (isBusinessOldView ==
                                                          0) {
                                                        String message;

                                                        if (widget.post_type ==
                                                            'BuyPost') {
                                                          message =
                                                              'Please Click Contact Buyer Now';
                                                        } else if (widget
                                                                .post_type ==
                                                            'SalePost') {
                                                          message =
                                                              'Please Click Contact Seller Now';
                                                        } else {
                                                          message =
                                                              'Please click to share via WhatsApp';
                                                        }

                                                        showCustomToast(
                                                            message);

                                                        return;
                                                      }

                                                      setState(() {
                                                        isLoading = true;
                                                      });

                                                      try {
                                                        shareWhatsappImage(
                                                          postname: prod_nm
                                                              .toString(),
                                                          appUsername: username
                                                              .toString(),
                                                          countryCode:
                                                              countryCode,
                                                          shorturl:
                                                              post_short_url
                                                                  .toString(),
                                                          prodId: widget
                                                                  .prod_id ??
                                                              'default_prod_id',
                                                          url: main_product
                                                              .toString(),
                                                          usernm:
                                                              usernm.toString(),
                                                          userMobileNo:
                                                              userMobileNo
                                                                  .toString(),
                                                          postType: widget
                                                                  .post_type ??
                                                              'default_post_type',
                                                        );
                                                      } catch (e) {
                                                        print("Error: $e");
                                                      } finally {
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                      }
                                                    },
                                                    child: Column(
                                                      children: [
                                                        if (isLoading)
                                                          Container(
                                                            width: 28,
                                                            height: 28,
                                                            child:
                                                                CircularProgressIndicator(),
                                                          )
                                                        else
                                                          Container(
                                                            width: 32,
                                                            height: 32,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                const ShapeDecoration(
                                                              color: AppColors
                                                                  .primaryColor,
                                                              shape:
                                                                  OvalBorder(),
                                                            ),
                                                            child: Image.asset(
                                                                'assets/whatsapp.png',
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                        const Text(
                                                          'WS',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .primaryColor,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'assets/fonts/Metropolis-Black.otf',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            letterSpacing:
                                                                -0.24,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Premiun(),
                                                        ),
                                                      );
                                                      showCustomToast(
                                                          'Upgrade Plan to Share WhatsApp');
                                                    },
                                                    child: Column(
                                                      children: [
                                                        if (isLoading)
                                                          Container(
                                                            width: 28,
                                                            height: 28,
                                                            child:
                                                                CircularProgressIndicator(),
                                                          )
                                                        else
                                                          Container(
                                                            width: 32,
                                                            height: 32,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                const ShapeDecoration(
                                                              color: AppColors
                                                                  .primaryColor,
                                                              shape:
                                                                  OvalBorder(),
                                                            ),
                                                            child: Image.asset(
                                                                'assets/whatsapp.png',
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                        const Text(
                                                          'WS',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .primaryColor,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'assets/fonts/Metropolis-Black.otf',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            letterSpacing:
                                                                -0.24,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  15.sbh,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Similar Posts',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Metropolis',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.24,
                        ),
                      ),
                      (widget.post_type == 'BuyPost')
                          ? categoryBuy()
                          : categorySale()
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
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

  Widget _buildCommanData({required String title, required String data}) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                '$title:',
                style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: 'assets/fonst/Metropolis-SemiBold.otf'),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.6),
              child: Text(
                data,
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: 'assets/fonst/Metropolis-SemiBold.otf'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget slider() {
    return GFCarousel(
      height: 321,
      autoPlay: true,
      pagerSize: 2.0,
      viewportFraction: 1.0,
      aspectRatio: 2,
      items: imagelist.map(
        (url) {
          return GestureDetector(
            onTap: () {
              GtmUtil.logScreenView(
                'Product_Image_View_Buyer_seller',
                'imagepreview',
              );
              _showFullScreenSliderDialog(context, 0);
            },
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: CachedNetworkImage(
                    imageUrl: url.toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
      onPageChanged: (index) {
        setState(() {
          getSliderIndex = index;
        });
      },
    );
  }

  Widget categoryBuy() {
    return FutureBuilder(
      future: getRalBuyerpostFuture,
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
                childAspectRatio: MediaQuery.of(context).size.width / 650,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: simmilar_post_buyer.isEmpty
                  ? 1
                  : simmilar_post_buyer.length + 2,
              itemBuilder: (context, index) {
                if (index < simmilar_post_buyer.length) {
                  similar_prod.Result result = simmilar_post_buyer[index];
                  return GestureDetector(
                    onTap: (() async {
                      GtmUtil.logScreenView(
                        'Similar_Post_Open_Buyer_seller',
                        'similarpost',
                      );
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();

                      if (pref.getBool('isWithoutLogin') == true) {
                        showLoginDialog(context);
                      } else {
                        print("ID = ${result.productId.toString()}");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Buyer_sell_detail(
                                  prod_id: result.productId.toString(),
                                  post_type: result.postType.toString()),
                            ));
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
                          const SizedBox(
                              height: 10.0), // Added spacing between elements
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                                      height:
                                          5.0), // Added spacing between elements
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
                                      height:
                                          5.0), // Added spacing between elements
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
                                      height:
                                          5.0), // Added spacing between elements
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
                } else if (index == simmilar_post_buyer.length ||
                    index == simmilar_post_buyer.length + 1) {
                  if (categoryBuyerToLoad()) {
                    print('Empty CustomShimmerLoader triggered1');

                    return CustomShimmerLoader(
                      width: 175,
                      height: 200,
                    );
                  } else {
                    print('Empty else branch triggered');
                    return SizedBox.shrink();
                  }
                } else {
                  print('Empty CustomShimmerLoader triggered2');

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

  bool categoryBuyerToLoad() {
    int itemsPerPage = 20;
    return simmilar_post_buyer.length % itemsPerPage == 0 &&
        simmilar_post_buyer.isNotEmpty;
  }

  Widget categorySale() {
    return FutureBuilder(
      future: getRalSalerpostFuture,
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
                childAspectRatio: MediaQuery.of(context).size.width / 650,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: simmilar_post_saler.isEmpty
                  ? 1
                  : simmilar_post_saler.length + 2,
              itemBuilder: (context, index) {
                if (index < simmilar_post_saler.length) {
                  similar_prod.Result result = simmilar_post_saler[index];
                  return GestureDetector(
                    onTap: (() async {
                      GtmUtil.logScreenView(
                        'Similar_Post_Open_Buyer_seller',
                        'similarpost',
                      );
                      constanst.productId = result.productId.toString();
                      constanst.post_type = result.postType.toString();

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
                          const SizedBox(
                              height: 10.0), // Added spacing between elements
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                                      height:
                                          5.0), // Added spacing between elements
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
                                      height:
                                          5.0), // Added spacing between elements
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
                                      height:
                                          5.0), // Added spacing between elements
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
                } else if (index == simmilar_post_saler.length ||
                    index == simmilar_post_saler.length + 1) {
                  if (categorySaleToLoad()) {
                    print('Empty CustomShimmerLoader triggered1');

                    return CustomShimmerLoader(
                      width: 175,
                      height: 200,
                    );
                  } else {
                    print('Empty else branch triggered');
                    return SizedBox.shrink();
                  }
                } else {
                  print('Empty CustomShimmerLoader triggered2');

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

  bool categorySaleToLoad() {
    int itemsPerPage = 20;
    return simmilar_post_saler.length % itemsPerPage == 0 &&
        simmilar_post_saler.isNotEmpty;
  }

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 50) ==
        (scrollercontroller.position.maxScrollExtent - 50)) {
      if (simmilar_post_buyer.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        getRalBuyerpostFuture = get_ral_buyerpost();
      } else if (simmilar_post_saler.isNotEmpty) {
        count++;
        if (categorySaleToLoad()) {
          offset = offset + 20;
          getRalSalerpostFuture = get_ral_salerpost();
        }
        if (categoryBuyerToLoad()) {
          offset = offset + 20;
          getRalSalerpostFuture = get_ral_buyerpost();
        }
      }
    }
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      getProfiless();
      showCustomToast(
        widget.post_type.toString(),
      );
      print("post_type:-${widget.post_type}");
      if (widget.post_type == 'BuyPost') {
        get_BuyerPostDatil();
        getRalBuyerpostFuture = get_ral_buyerpost();
      } else if (widget.post_type == 'SalePost') {
        get_SalePostDatil();
        getRalSalerpostFuture = get_ral_salerpost();
      }
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
      pref.getString('user_id').toString(),
      context,
    );

    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(device)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      username = res['user']['username'];
      print('Username From getProfiless: $username');
    } else {
      showCustomToast(res['message']);
    }

    setState(() {});
  }

  getadd_product() async {
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
        widget.prod_id.toString(),
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
        isFavorite = "1";
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

  getremove_product() async {
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
        widget.prod_id.toString(),
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
        isFavorite = "0";
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
      user_id.toString(),
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    var jsonArray;

    if (response['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      showCustomToast(
        response['message'],
      );
    } else {
      showCustomToast(
        response['message'],
      );
    }
    setState(() {});
    return jsonArray;
  }

  getcolorlist() {
    Expanded(
      child: FutureBuilder(
          future: get_BuyerPostDatil(),
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
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    postdetail.PostHaxCodeColor record = colors[index];

                    return Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 15,
                          color: Color(
                            int.parse(
                              record.haxCode.toString(),
                            ),
                          ),
                        ),
                        Text(
                          record.colorName.toString(),
                        )
                      ],
                    );
                  });
            }
          }),
    );
  }

  void _showFullScreenSliderDialog(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20.0),
                minScale: 0.5,
                maxScale: 4.0,
                child: GFCarousel(
                  height: MediaQuery.of(context).size.height,
                  initialPage: initialIndex,
                  viewportFraction: 1.0,
                  aspectRatio: 2,
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  items: imagelist.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: url.toString(),
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width,
                      ),
                    );
                  }).toList(),
                  onPageChanged: (index) {
                    setState(() {});
                  },
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  get_ral_buyerpost() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await similar_product_buyer(
      widget.prod_id.toString(),
      '20',
      offset.toString(),
      device,
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
          similar_prod.Result record = similar_prod.Result(
            postName: data['PostName'],
            categoryName: data['CategoryName'],
            productGrade: data['ProductGrade'],
            currency: data['Currency'],
            productPrice: data['ProductPrice'],
            state: data['State'],
            country: data['Country'],
            postType: data['PostType'],
            productId: data['productId'],
            productType: data['ProductType'],
            mainproductImage: data['mainproductImage'],
            isPaidPost: data['is_paid_post'],
          );
          simmilar_post_buyer.add(record);
        }
        setState(() {
          postType = simmilar_post_buyer.first.postType ?? "";
        });
      }
    } else {
      showCustomToast(
        res['message'],
      );
    }
    return jsonArray;
  }

  get_ral_salerpost() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await similar_product_saler(
      widget.prod_id.toString(),
      '20',
      offset.toString(),
      device,
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
          similar_prod.Result record = similar_prod.Result(
            postName: data['PostName'],
            categoryName: data['CategoryName'],
            productGrade: data['ProductGrade'],
            currency: data['Currency'],
            productPrice: data['ProductPrice'],
            state: data['State'],
            country: data['Country'],
            postType: data['PostType'],
            productId: data['productId'],
            productType: data['ProductType'],
            mainproductImage: data['mainproductImage'],
            isPaidPost: data['is_paid_post'],
          );
          simmilar_post_saler.add(record);
        }
        setState(() {
          postType = simmilar_post_saler.first.postType ?? "";
        });
      }
    } else {
      showCustomToast(
        res['message'],
      );
    }
    return jsonArray;
  }

  get_BuyerPostDatil() async {
    CommonPostdetail commonPostdetail = CommonPostdetail();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getPost_datail(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.prod_id.toString(),
      notiId.toString(),
      device,
      crown_color,
      plan_name,
    );

    selfUserId = pref.getString('user_id').toString();
    print('selfUserId:-$selfUserId');

    var jsonArray, subjsonarray, color_array;
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      commonPostdetail = CommonPostdetail.fromJson(res);
      List<postdetail.Result>? results = commonPostdetail.result;

      if (results != null && results.isNotEmpty) {
        postdetail.Result firstResult = results[0];
        postHaxCodeColors = firstResult.postHaxCodeColor;
      }
      if (res['result'] != null) {
        jsonArray = res['result'];
        print("bbprofile:-${res['result']}");
        imagelist.clear();
        for (var data in jsonArray) {
          cate_name = data['CategoryName'];
          Grade = data['ProductGrade'];
          type = data['ProductType'];
          qty = data['PostQuntity'];
          prod_desc = data['Description'];
          Grade = data['ProductGrade'];
          product_status = data['product_status'];
          price = data['ProductPrice'];
          currency = data['Currency'];
          prod_nm = data['PostName'];
          create_date = data['new_created_date'];
          update_date = data['new_updated_date'];
          location = data['Location'];
          like = data['isLike'];
          subjsonarray = data['subproductImage'];
          color_array = data['PostHaxCodeColor'];
          likecount = data['likeCount'];
          isFavorite = data['isFavorite'];
          is_Follow = data['isFollow'];
          post_short_url = data['post_url'];

          is_prime = data['is_prime'];
          viewcount = data['isView'];
          isBusinessProfileView = data['can_business_profile_view'];
          isBusinessOldView = data['check_old_view'];

          unit = data['Unit'];
          crown_color = data['crown_color'];
          print('api responce: $crown_color');
          plan_name = data['plan_name'];
          print('app responce: $plan_name');
          usernm = data['Username'] ?? 'Unknown';
          userMobileNo = data['user_mobile_no'];
          countryCode = data['countryCode'];

          user_id = data['UserId'];
          print('user_id:-$user_id');

          todayCount = data['remaining_profile_view'];

          price_unit = data['unit_of_price'];
          user_image = data['UserImage'];
          bussiness_type = data['BusinessType'];
          main_product = data['mainproductImage'];
        }

        imagelist.add(main_product!);

        DateFormat format = DateFormat("dd-MM-yyyy");
        var curret_date = format.parse(create_date);
        var updat_date = format.parse(update_date);
        DateTime? dt1 = DateTime.parse(
          curret_date.toString(),
        );
        DateTime? dt2 = DateTime.parse(
          updat_date.toString(),
        );
        // print(dt1);
        create_formattedDate =
            dt1 != null ? DateFormat('dd MMMM, yyyy').format(dt1) : "";
        update_formattedDate =
            dt2 != null ? DateFormat('dd MMMM, yyyy').format(dt2) : "";
      }
      if (color_array != null) {
        for (var data in color_array) {
          postdetail.PostHaxCodeColor record = postdetail.PostHaxCodeColor(
            colorName: data['colorName'],
            haxCode: data['HaxCode'],
          );
          colors.add(record);
        }
      }
      // Process sub-images if available
      if (subjsonarray != null) {
        for (var data in subjsonarray) {
          imagelist.add(data['sub_image_url']!);
        }
      }
      main_product = imagelist.first;

      load = true;
      setState(() {});
    } else {
      showCustomToast(
        res['message'],
      );
    }
    return jsonArray;
  }

  get_SalePostDatil() async {
    CommonPostdetail commonPostdetail = CommonPostdetail();
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getPost_datail1(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.prod_id.toString(),
      notiId.toString(),
      device,
      crown_color,
      plan_name,
    );

    selfUserId = pref.getString('user_id').toString();
    print('selfUserId:-$selfUserId');

    var jsonArray, subjsonarray, color_array;

    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      commonPostdetail = CommonPostdetail.fromJson(res);
      List<postdetail.Result>? results = commonPostdetail.result;

      if (results != null && results.isNotEmpty) {
        postdetail.Result firstResult = results[0];
        postHaxCodeColors = firstResult.postHaxCodeColor;
      }
      if (res['result'] != null) {
        jsonArray = res['result'];
        imagelist.clear();

        for (var data in jsonArray) {
          cate_name = data['CategoryName'];
          Grade = data['ProductGrade'];
          type = data['ProductType'];
          qty = data['PostQuntity'];
          prod_desc = data['Description'];
          Grade = data['ProductGrade'];
          product_status = data['product_status'];
          price = data['ProductPrice'];
          currency = data['Currency'];
          prod_nm = data['PostName'];
          create_date = data['new_created_date'];
          update_date = data['new_updated_date'];
          location = data['Location'];
          like = data['isLike'];
          subjsonarray = data['subproductImage'];
          color_array = data['PostHaxCodeColor'];
          likecount = data['likeCount'];
          isFavorite = data['isFavorite'];
          is_Follow = data['isFollow'];
          post_short_url = data['post_url'];

          is_prime = data['is_prime'];
          viewcount = data['isView'];
          isBusinessProfileView = data['can_business_profile_view'];
          isBusinessOldView = data['check_old_view'];

          unit = data['Unit'];
          usernm = data['Username'] ?? 'Unknown';
          crown_color = data['crown_color'];
          print('api responce: $crown_color');
          plan_name = data['plan_name'];
          print('app responce: $plan_name');
          userMobileNo = data['user_mobile_no'];
          countryCode = data['countryCode'];

          user_id = data['UserId'];
          print('user_id:-$user_id');
          todayCount = data['remaining_profile_view'];

          price_unit = data['unit_of_price'];
          user_image = data['UserImage'];
          bussiness_type = data['BusinessType'];
          main_product = data['mainproductImage'];
        }

        imagelist.add(main_product!);
        DateFormat format = DateFormat("dd-MM-yyyy");
        var curret_date = format.parse(create_date);
        var updat_date = format.parse(update_date);
        DateTime? dt1 = DateTime.parse(
          curret_date.toString(),
        );
        DateTime? dt2 = DateTime.parse(
          updat_date.toString(),
        );

        create_formattedDate =
            dt1 != null ? DateFormat('dd MMMM, yyyy').format(dt1) : "";
        update_formattedDate =
            dt2 != null ? DateFormat('dd MMMM, yyyy').format(dt2) : "";
      }
      if (color_array != null) {
        for (var data in color_array) {
          postdetail.PostHaxCodeColor record = postdetail.PostHaxCodeColor(
            colorName: data['colorName'],
            haxCode: data['HaxCode'],
          );
          colors.add(record);
        }
      }

      // Process sub-images if available
      if (subjsonarray != null) {
        for (var data in subjsonarray) {
          imagelist.add(data['sub_image_url']!);
        }
      }
      main_product = imagelist.first;
      load = true;
      setState(() {});
    } else {
      showCustomToast(
        res['message'],
      );
    }
    return jsonArray;
  }

  void shareImage({
    required String url,
    required String shorturl,
    required String share,
    required BuildContext context,
    required String postType,
    required String prodId,
  }) async {
    try {
      final dynamicLink = await createDynamicLink(shorturl, postType, prodId);
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
          ? '${postType.toLowerCase() == 'buypost' ? 'Buy Post' : 'Sell Post'}\n'
              '${prod_nm!}\n'
              '${cate_name}\n'
              '${type}\n'
              '${Grade}\n'
              '${qty} ${unit!}\n\n'
              'Plastic4trade is a B2B Plastic Business App, Buy & Sale your Products, Raw Material, Recycle Plastic Scrap, Plastic Machinery, Polymer Price, News, Update for Manufacturers, Traders, Exporters, Importers....\n\n'
              'More Info: $dynamicLink\n\n'
          : '${prod_nm!}\n'
              '${price}\n'
              '${currency}\n'
              '${cate_name}\n'
              '${type}\n'
              '${Grade}\n'
              '${constanst.post_type}\n'
              '${qty} ${unit!}\n'
              '${postHaxCodeColors!.first.colorName.toString()}\n'
              '${prod_desc.toString()}\n'
              '${product_status.toString()}\n'
              '${create_formattedDate}\n'
              '${update_formattedDate}\n'
              'More Info: $dynamicLink';

      await Share.shareFiles([path], text: shareText);
    } catch (e) {
//
    }
  }

  Future<void> shareWhatsappImage({
    required String url,
    required String shorturl,
    required String prodId,
    required String countryCode,
    required String userMobileNo,
    required String usernm,
    required String appUsername,
    required String postType,
    required String postname,
  }) async {
    try {
      final dynamicLink = await createDynamicLink(shorturl, postType, prodId);
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

      final whatsappMessage = 'Hello $usernm,\n'
          'I am $appUsername.\n'
          'I saw your ${postType.toLowerCase() == 'buypost' ? 'Buy Post' : 'Sell Post'} of $postname on Plastic4Trade App.\n'
          'I want to know more about it.\n\n'
          'Click to View: \n$dynamicLink';

      // Share image and message
      await Share.shareFiles([path], text: whatsappMessage);
    } catch (e) {
      print('Error sharing WhatsApp image: $e');
    }
  }

  Future<void> Prodlike() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await product_like(
      widget.prod_id.toString(),
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

  ViewItem({required BuildContext context, int tabIndex = 0}) {
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
          initialChildSize:
              0.60, // Initial height as a fraction of screen height
          builder: (BuildContext context, ScrollController scrollController) {
            return ViewWidget(
              prod_id: widget.prod_id.toString(),
              tabIndex: tabIndex,
            );
          }),
    ).then(
      (value) {},
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

    var res = await getProductShareCount(
      pref.getString('user_id').toString(),
      widget.prod_id,
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
}

class ViewWidget extends StatefulWidget {
  String prod_id;
  int tabIndex = 0;

  ViewWidget({
    Key? key,
    required this.prod_id,
    required this.tabIndex,
  }) : super(key: key);

  @override
  State<ViewWidget> createState() => _ViewWidgetState();
}

class _ViewWidgetState extends State<ViewWidget>
    with SingleTickerProviderStateMixin {
  bool? isload;
  late TabController _tabController;
  List<interest.Result> dataList = [];
  List<viewInterest.Data> dataList1 = [];
  List<productShare.Data> dataList2 = [];
  int offset = 0;
  int count = 0;
  bool loadmore = false;
  bool isLoading = false;
  final scrollercontroller = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollercontroller.addListener(_scrollercontroller);

    _tabController =
        TabController(length: 3, vsync: this, initialIndex: widget.tabIndex);
    getInterest(widget.prod_id);
    getViews(widget.prod_id);
    getShare(widget.prod_id);
  }

  @override
  void dispose() {
    scrollercontroller.removeListener(_scrollercontroller);
    _tabController.dispose();
    super.dispose();
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
        getViews(
          widget.prod_id,
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      offset = 0;
      dataList1.clear();
    });

    await getViews(
      widget.prod_id,
    );

    showCustomToast('Data Refreshed');
    scrollercontroller.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    return null;
  }

  getInterest(prod_id) async {
    ApiResponse common = ApiResponse();
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getProductInterest(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.prod_id.toString(),
      device,
    );
    if (res['status'] == 1) {
      common = ApiResponse.fromJson(res);
      dataList = common.result ?? [];
      isload = true;
    } else {}
    setState(() {});
  }

  Future<void> getViews(prod_id) async {
    if (isLoading) return; // Prevent multiple concurrent calls

    SharedPreferences pref = await SharedPreferences.getInstance();
    isLoading = true;

    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    try {
      var res = await getProductView(
        prod_id,
        offset,
        pref.getString('user_id').toString(),
        device,
      );

      if (res['status'] == 1) {
        GetProductView common = GetProductView.fromJson(res);
        List<viewInterest.Data> newData =
            (common.data ?? []).cast<viewInterest.Data>();

        setState(() {
          if (newData.isNotEmpty) {
            dataList1.addAll(newData);
            loadmore = newData.length == 10;
          } else {
            loadmore = false; // No more data to load
          }
        });
      } else {
        setState(() {
          loadmore = false; // Stop load more on failure
        });
        showCustomToast(res['message']);
      }
    } catch (error) {
      print('Error fetching product views: $error');
      showCustomToast('Error fetching product views');
      setState(() {
        loadmore = false; // Ensure loadmore is false on error
      });
    } finally {
      isLoading = false; // Ensure loading state is reset
    }
  }

  getShare(productId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    ProductShare common = ProductShare();

    var res = await getProductShare(
      pref.getString('user_id').toString(),
      productId,
    );

    if (res['status'] == 1) {
      common = ProductShare.fromJson(res);
      dataList2 = common.data ?? [];
      isload = true;
    } else {
      showCustomToast(res['message']);
    }
    setState(() {});
  }

  void shareApp({required String url}) async {
    final ByteData bytesImage = await rootBundle.load('assets/appLogo.jpeg');
    final bytes = bytesImage.buffer.asUint8List();
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(bytes);

    await Share.shareFiles([path],
        text: 'Plastic4trade is a B2B Plastic Business App, Buy & Sale your Products, Raw Material, Recycle Plastic Scrap, Plastic Machinery, Polymer Price, News, Update for Manufacturers, Traders, Exporters, Importers...' +
            "\n" +
            '\n' +
            'Open App' +
            '\n' +
            'Android:' +
            '\n' +
            'https://play.google.com/store/apps/details?id=com.p4t.plastic4trade' +
            '\n' +
            '\n'
                'IOS:' +
            '\n' +
            'https://apps.apple.com/app/plastic4trade/id6450507332');
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
                dividerColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Interested'),
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
                              if (dataList[index].isBusinessProfileView == 0 &&
                                  dataList[index].isBusinessOldView == 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Premiun(),
                                  ),
                                ).then((_) {
                                  getInterest(widget.prod_id);
                                });
                                showCustomToast('Upgrade Plan to View Profile');
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => bussinessprofile(
                                      int.parse(
                                          dataList[index].userId.toString()),
                                    ),
                                  ),
                                ).then((_) {
                                  getInterest(widget.prod_id);
                                });
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
                                                    .businessType
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
                    RefreshIndicator(
                      backgroundColor: AppColors.primaryColor,
                      color: AppColors.backgroundColor,
                      onRefresh: () async {
                        _refreshData();
                      },
                      child: dataList1.isEmpty
                          ? SizedBox()
                          : ListView.builder(
                              controller: scrollercontroller,
                              padding: const EdgeInsets.all(16),
                              shrinkWrap: true,
                              itemCount: dataList1.length + (loadmore ? 1 : 0),
                              itemBuilder: (BuildContext context, int index) {
                                if (index < dataList1.length) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (dataList1[index]
                                                  .isBusinessProfileView ==
                                              0 &&
                                          dataList1[index].isBusinessOldView ==
                                              0) {
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
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                bussinessprofile(
                                              int.parse(dataList1[index]
                                                  .userId
                                                  .toString()),
                                            ),
                                          ),
                                        ).then((_) {
                                          _refreshData();
                                        });
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
                                                                              .crowncolor
                                                                              .toString() !=
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
                                                                      color: dataList1[index].crowncolor.toString() !=
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
                                                                          color: dataList1[index].crowncolor.toString() != null
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
                                                            .businessType
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
                                  return ChatShimmerLoader(
                                    width: 175,
                                    height: 100,
                                  );
                                } else {
                                  return SizedBox();
                                }
                              }),
                    ),
                    ListView.builder(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        itemCount: dataList2.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              if (dataList2[index].isBusinessProfileView == 0 &&
                                  dataList2[index].isBusinessOldView == 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Premiun(),
                                  ),
                                ).then((_) {
                                  getShare(widget.prod_id);
                                });
                                showCustomToast('Upgrade Plan to View Profile');
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => bussinessprofile(
                                      int.parse(
                                          dataList1[index].userId.toString()),
                                    ),
                                  ),
                                ).then((_) {
                                  getShare(widget.prod_id);
                                });
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
                                                    .businessType
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
            child: CustomLottieContainer(
              child: Lottie.asset(
                'assets/loading_animation.json',
              ),
            ),
          );
  }
}
