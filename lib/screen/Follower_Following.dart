// ignore_for_file: camel_case_types, unnecessary_null_comparison, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:io';

import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/model/getFollowerList.dart' as getfllow;
import 'package:Plastic4trade/model/getFollowingList.dart' as getfllowing;
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_chat_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_interface.dart';

class follower extends StatefulWidget {
  final initialIndex;
  const follower({Key? key, this.initialIndex}) : super(key: key);

  @override
  State<follower> createState() => _followerState();
}

class _followerState extends State<follower>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<getfllow.Result> getfollowdata = [];
  List<getfllowing.Result> getfllowingdata = [];
  int? totalfollowers = 0, totalfollowing = 0;
  String? followstatus = 'follow';
  bool? loading = false;
  TextEditingController follower_search = TextEditingController();
  TextEditingController following_search = TextEditingController();
  bool isLoading = true;
  int? isBusinessProfileView;
  int? isBusinessOldView;

  final scrollercontroller = ScrollController();
  final scrollercontrollerfollower = ScrollController();
  int _previousTabIndex = 0;

  bool loadmore = false;

  int offset = 0;
  int count = 0;

  @override
  void initState() {
    _tabController = TabController(
        length: 2, initialIndex: widget.initialIndex, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _previousTabIndex) {
        _previousTabIndex = _tabController.index;
        if (_tabController.index == 0) {
          _refreshData();
        } else if (_tabController.index == 1) {
          _refreshDatafollowing();
        }
      }
    });
    checkNetwork();
    super.initState();
    scrollercontroller.addListener(_scrollercontroller);
    scrollercontrollerfollower.addListener(_scrollercontrollerfollower);

    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollercontroller.removeListener(_scrollercontroller);
    scrollercontrollerfollower.removeListener(_scrollercontrollerfollower);
  }

  Future<void> _refreshData() async {
    setState(() {
      getfollowdata.clear();
      offset = 0;
      loadmore = false;
    });

    await getFollower();

    showCustomToast('Data Refreshed');
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

    showCustomToast('Data Refreshed');
    scrollercontrollerfollower.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    return null;
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return initwidget();
  }

  Widget initwidget() {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Followers/Followings',
            softWrap: false,
            style: TextStyle(
              fontSize: 20.0,
              color: AppColors.blackColor,
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
              color: AppColors.blackColor,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              10.sbh,
              Padding(
                padding: const EdgeInsets.all(6),
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
                        // ignore: deprecated_member_use
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
                                Text('Followers'),
                                SizedBox(width: 6),
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$totalfollowers',
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
                                Text('Following'),
                                SizedBox(width: 6),
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$totalfollowing',
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
                child: TabBarView(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    isLoading ? ChatWithShimmerLoader(context) : follower(),
                    isLoading ? ChatWithShimmerLoader(context) : following(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget ChatWithShimmerLoader(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ChatShimmerLoader(width: 175, height: 100);
      },
    );
  }

  Widget follower() {
    return RefreshIndicator(
      backgroundColor: AppColors.primaryColor,
      color: AppColors.backgroundColor,
      onRefresh: () async {
        _refreshData();
      },
      child: Column(
        children: [
          5.sbh,
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0.0, 8.0),
            child: SizedBox(
              height: 50,
              child: TextFormField(
                controller: follower_search,
                style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackColor,
                    fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r"[a-zA-Z]+|\s"),
                  ),
                ],
                decoration: InputDecoration(
                  fillColor: AppColors.backgroundColor,
                  filled: true,
                  hintText: "Search User",
                  hintStyle: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf')
                      .copyWith(color: AppColors.black45Color),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  prefixIcon: const Icon(Icons.search),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 1, color: AppColors.black45Color),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        width: 1, color: AppColors.black45Color),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onFieldSubmitted: (value) {
                  getfollowdata.clear();

                  getFollower();
                  setState(() {});
                },
                onChanged: (value) {
                  if (value.isEmpty) {
                    getfollowdata.clear();
                    getFollower();
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollercontrollerfollower,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: getfollowdata.length + (loadmore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < getfollowdata.length) {
                    getfllow.Result result = getfollowdata[index];
                    return GestureDetector(
                      onTap: () {
                        print('outsideTap');
                        final int? userId = getfollowdata[index].id;

                        final int? isBusinessProfileView =
                            getfollowdata[index].isBusinessProfileView;

                        if (isBusinessProfileView != null) {
                          print(
                              'isBusinessProfileView value: $isBusinessProfileView');

                          if (isBusinessProfileView == 1) {
                            print('Redirecting to other_user_profile');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    bussinessprofile(userId!),
                              ),
                            ).then((_) {
                              getFollower();
                            });
                          } else if (isBusinessProfileView == 0) {
                            print('Redirecting to Premium');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => Premiun(),
                              ),
                            ).then((_) {
                              getFollower();
                            });
                            showCustomToast('Upgrade Plan to View Profile');
                          }
                        } else {
                          print('isBusinessProfileView is null');
                        }
                      },
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      result.isBusinessProfileView == 1 &&
                                              result.isBusinessOldView == 0
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: ShapeDecoration(
                                                    shape: CircleBorder(
                                                      side: BorderSide(
                                                        width: 2,
                                                        color: result
                                                                    .crowncolor !=
                                                                null
                                                            ? Color(int.parse(
                                                                    result
                                                                        .crowncolor
                                                                        .toString()
                                                                        .substring(
                                                                            1),
                                                                    radix: 16) |
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
                                                  transform:
                                                      Matrix4.translationValues(
                                                          0.0, -10.0, 0.0),
                                                  decoration: ShapeDecoration(
                                                    color: result.crowncolor !=
                                                            null
                                                        ? Color(int.parse(
                                                                result
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
                                                          BorderRadius.circular(
                                                              40),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    result.planname.toString(),
                                                    textAlign: TextAlign.center,
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
                                          : result.isBusinessProfileView == 0 &&
                                                  result.isBusinessOldView == 0
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape: CircleBorder(
                                                          side: BorderSide(
                                                            width: 2,
                                                            color: result
                                                                        .crowncolor !=
                                                                    null
                                                                ? Color(int.parse(
                                                                        result
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
                                                      alignment:
                                                          Alignment.center,
                                                      transform: Matrix4
                                                          .translationValues(
                                                              0.0, -10.0, 0.0),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: result
                                                                    .crowncolor !=
                                                                null
                                                            ? Color(int.parse(
                                                                    result
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
                                                        result.planname
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
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 51,
                                                          height: 51,
                                                          decoration:
                                                              ShapeDecoration(
                                                            shape: CircleBorder(
                                                              side: BorderSide(
                                                                width: 2,
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
                                                              ),
                                                            ),
                                                          ),
                                                          child: ClipOval(
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: result
                                                                  .image
                                                                  .toString(),
                                                              fit: BoxFit.cover,
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
                                                            color: result
                                                                        .crowncolor !=
                                                                    null
                                                                ? Color(int.parse(
                                                                        result
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
                                                            result.planname
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 50,
                                                          height: 50,
                                                          decoration:
                                                              ShapeDecoration(
                                                            shape: CircleBorder(
                                                              side: BorderSide(
                                                                width: 2,
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
                                                            color: result
                                                                        .crowncolor !=
                                                                    null
                                                                ? Color(int.parse(
                                                                        result
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
                                                            result.planname
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            result.isBusinessProfileView == 1 &&
                                                    result.isBusinessOldView ==
                                                        0
                                                ? 'XXXXX ' +
                                                    result.name!.split(' ').last
                                                : result.isBusinessProfileView ==
                                                            0 &&
                                                        result.isBusinessOldView ==
                                                            0
                                                    ? 'XXXXX ' +
                                                        result.name!
                                                            .split(' ')
                                                            .last
                                                    : result.isBusinessProfileView ==
                                                                1 &&
                                                            result.isBusinessOldView ==
                                                                1
                                                        ? result.name.toString()
                                                        : 'XXXXX ' +
                                                            result.name!
                                                                .split(' ')
                                                                .last,
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.blackColor,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          2.sbh,
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Text(
                                              result.businessType ?? 'N/A',
                                              style: const TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.blackColor,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-Black.otf'),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  12.sbw,
                                  result.isFollowing == 0
                                      ? GestureDetector(
                                          onTap: () {
                                            result.isFollowing = 1;
                                            setState(() {});

                                            setfollowUnfollow(
                                                '1', result.id.toString());
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            height: 30,
                                            width: 100,
                                            child: Center(
                                              child: const Text(
                                                'Follow',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.backgroundColor,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return CommanDialog(
                                                  title: "Followers",
                                                  content:
                                                      "Do you want to Unfollow",
                                                  onPressed: () {
                                                    result.isFollowing = 0;
                                                    setState(() {});

                                                    setfollowUnfollow('0',
                                                        result.id.toString());
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            height: 30,
                                            width: 100,
                                            child: Center(
                                              child: const Text(
                                                'Followed',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.backgroundColor,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget following() {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshDatafollowing();
      },
      child: Column(
        children: <Widget>[
          5.sbh,
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0.0, 5.0),
            child: SizedBox(
              height: 50,
              child: TextFormField(
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.blackColor,
                  fontFamily: 'assets/fonst/Metropolis-Black.otf',
                ),
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.text,
                controller: following_search,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r"[a-zA-Z]+|\s"),
                  ),
                ],
                onFieldSubmitted: (value) {
                  getfollowdata.clear();
                  getFollowing();
                  setState(() {});
                },
                onChanged: (value) {
                  if (value.isEmpty) {
                    getfollowdata.clear();
                    getFollowing();
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  fillColor: AppColors.backgroundColor,
                  filled: true,
                  hintText: "Search User",
                  hintStyle: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf')
                      .copyWith(color: AppColors.black45Color),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  prefixIcon: const Icon(Icons.search),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        width: 1, color: AppColors.black45Color),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        width: 1, color: AppColors.black45Color),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollercontroller,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: getfllowingdata.length + (loadmore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < getfllowingdata.length) {
                        getfllowing.Result result = getfllowingdata[index];
                        return GestureDetector(
                          onTap: () {
                            print('outsideTap');
                            final int? userId = getfllowingdata[index].id;

                            final int? isBusinessProfileView =
                                getfllowingdata[index].isBusinessProfileView;

                            if (isBusinessProfileView != null) {
                              print(
                                  'isBusinessProfileView value: $isBusinessProfileView');

                              if (isBusinessProfileView == 1) {
                                print('Redirecting to other_user_profile');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        bussinessprofile(userId!),
                                  ),
                                ).then((_) {
                                  getFollowing();
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
                                  getFollowing();
                                });
                                showCustomToast('Upgrade Plan to View Profile');
                              }
                            } else {
                              print('isBusinessProfileView is null');
                            }
                          },
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
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          result.isBusinessProfileView == 1 &&
                                                  result.isBusinessOldView == 0
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape: CircleBorder(
                                                          side: BorderSide(
                                                            width: 2,
                                                            color: result
                                                                        .crowncolor !=
                                                                    null
                                                                ? Color(int.parse(
                                                                        result
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
                                                      alignment:
                                                          Alignment.center,
                                                      transform: Matrix4
                                                          .translationValues(
                                                              0.0, -10.0, 0.0),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: result
                                                                    .crowncolor !=
                                                                null
                                                            ? Color(int.parse(
                                                                    result
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
                                                        result.planname
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
                                              : result.isBusinessProfileView ==
                                                          0 &&
                                                      result.isBusinessOldView ==
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
                                                            color: result
                                                                        .crowncolor !=
                                                                    null
                                                                ? Color(int.parse(
                                                                        result
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
                                                            result.planname
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                                              1 &&
                                                          result.isBusinessOldView ==
                                                              1
                                                      ? Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
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
                                                                    color: result.crowncolor !=
                                                                            null
                                                                        ? Color(int.parse(result.crowncolor.toString().substring(1), radix: 16) |
                                                                            0xFF000000)
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: ClipOval(
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
                                                        ),
                                          10.sbw,
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                                .split(' ')
                                                                .last
                                                        : result.isBusinessProfileView ==
                                                                    1 &&
                                                                result.isBusinessOldView ==
                                                                    1
                                                            ? result.name
                                                                .toString()
                                                            : 'XXXXX ' +
                                                                result.name!
                                                                    .split(' ')
                                                                    .last,
                                                style: const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.blackColor,
                                                    fontFamily:
                                                        'assets/fonst/Metropolis-Black.otf'),
                                              ),
                                              2.sbh,
                                              Container(
                                                width: 160,
                                                child: Text(
                                                  result.businessType ?? 'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.blackColor,
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
                                      12.sbw,
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        height: 30,
                                        width: 100,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return CommanDialog(
                                                      title: "Following",
                                                      content:
                                                          "Do you want to Unfollow",
                                                      onPressed: () {
                                                        getfllowingdata
                                                            .removeAt(index);
                                                        totalfollowing =
                                                            getfllowingdata
                                                                .length;
                                                        setfollowUnfollow(
                                                          '0',
                                                          result.id.toString(),
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  });
                                            });

                                            setState(() {});
                                          },
                                          child: Center(
                                            child: Text(
                                              'Unfollow',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                    })),
          ),
        ],
      ),
    );
  }

  Future<void> checkNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      getFollower();
      getFollowing();
      loading = true;
    }
  }

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 50) ==
        (scrollercontroller.position.maxScrollExtent - 50)) {
      loadmore = false;
      if (getfllowingdata.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 10;
        } else {
          offset = offset + 10;
        }
        getFollowing();
      }
    }
  }

  void _scrollercontrollerfollower() {
    if ((scrollercontrollerfollower.position.pixels - 50) ==
        (scrollercontrollerfollower.position.maxScrollExtent - 50)) {
      loadmore = false;
      if (getfollowdata.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 10;
        } else {
          offset = offset + 10;
        }
        getFollower();
      }
    }
  }

  Future<void> getFollower() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';

    print('Device Name: $device');

    var res = await getFollowerLists(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      pref.getString('user_id').toString(),
      follower_search.text,
      device,
    );

    print('Full Response: $res');

    if (res['status'] == 1 &&
        res['result'] != null &&
        res['result'].isNotEmpty) {
      var jsonarray = res['result'];
      totalfollowers = res['totalFollowers'];

      print('Followers Data: $jsonarray');

      for (var data in jsonarray) {
        getfllow.Result record = getfllow.Result(
          isFollowing: data['is_following'],
          name: data['name'],
          businessType: data['businessType'],
          id: data['id'],
          image: data['image'],
          status: data['Status'],
          isBusinessProfileView: data['can_business_profile_view'],
          isBusinessOldView: data['check_old_view'],
          planname: data['plan_name'],
          crowncolor: data['crown_color'],
        );

        getfollowdata.add(record);
      }

      setState(() {
        loadmore = jsonarray.length == 10;
      });
    } else {
      setState(() {
        loadmore = false;
      });
      print('Error Message: ${res['message']}');
    }
  }

  Future<void> getFollowing() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';

    var res = await getfollwingList(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      pref.getString('user_id').toString(),
      following_search.text.toString(),
      device,
    );

    if (res['status'] == 1 &&
        res['result'] != null &&
        res['result'].isNotEmpty) {
      var jsonArray = res['result'];
      totalfollowing = res['totalFollowing'];

      for (var data in jsonArray) {
        getfllowing.Result record = getfllowing.Result(
          name: data['name'],
          businessType: data['businessType'],
          id: data['id'],
          image: data['image'],
          status: data['Status'],
          isBusinessProfileView: data['can_business_profile_view'],
          isBusinessOldView: data['check_old_view'],
          planname: data['plan_name'],
          crowncolor: data['crown_color'],
        );
        getfllowingdata.add(record);
      }

      setState(() {
        loadmore = jsonArray.length == 10;
      });
    } else {
      setState(() {
        loadmore = false;
      });
      print('Error Message GetFollowing: ${res['message']}');
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
}
