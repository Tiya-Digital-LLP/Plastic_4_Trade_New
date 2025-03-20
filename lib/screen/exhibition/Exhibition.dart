// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, depend_on_referenced_packages

import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/customshimmer/news_custom_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:Plastic4trade/screen/exhibition/ExhitionDetail.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Plastic4trade/model/GetUpcomingExhibition.dart' as getnews;
import 'package:http/http.dart' as http;
import '../../api/api_interface.dart';
import '../../constroller/GetCategoryController.dart';
import '../../widget/HomeAppbar.dart';
import 'dart:io';
import '../../utill/constant.dart';
import 'package:Plastic4trade/model/GetCategory.dart' as cat;

import 'package:path_provider/path_provider.dart';

class Exhibition extends StatefulWidget {
  const Exhibition({Key? key}) : super(key: key);

  @override
  State<Exhibition> createState() => _ExhibitionState();
}

class _ExhibitionState extends State<Exhibition>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool unread = false, isload = false, alldata = true;
  List<getnews.Data> getupexbitiondata = [];
  List<getnews.Data> getpastexbitiondata = [];
  String? packageName, create_formattedDate, end_formattedDate;
  PackageInfo? packageInfo;
  String limit = "20";
  int selectedIndex = 0, _defaultChoiceIndex = -1;
  String category_filter_id = "";
  final scrollercontroller = ScrollController();
  int count = 0;
  int offset = 0;

  @override
  void initState() {
    checknetowork();
    _tabController = TabController(length: 2, vsync: this);
    scrollercontroller.addListener(_scrollercontroller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return init();
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      getPackage();
      get_UpcomingExhibition(offset.toString());
      get_pastExhibition(offset.toString());
      get_categorylist();
    }
  }

  Widget init() {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: CustomeApp('Exhibition'),
        body: Column(children: [
          horiztallist(),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
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
                    tabs: const [
                      Tab(
                        child: Text(
                          'Upcoming Exhibition',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Metropolis',
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Past Exhibition',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Metropolis',
                          ),
                        ),
                      ),
                    ],
                    onTap: (value) {
                      if (value == 0) {
                        unread = true;
                        alldata = false;
                      } else if (value == 1) {
                        alldata = true;
                        unread = false;
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _tabController,
                children: [upcoming_exhibition(), past_exhibition()]),
          ),
        ]));
  }

  Widget upcoming_exhibition() {
    return RefreshIndicator(
      backgroundColor: AppColors.primaryColor,
      color: Colors.white,
      onRefresh: () async {
        get_UpcomingExhibition('0');
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: getupexbitiondata.isEmpty ? 1 : getupexbitiondata.length + 1,
        shrinkWrap: true,
        controller: scrollercontroller,
        itemBuilder: (context, index) {
          if (index == getupexbitiondata.length) {
            if (hasUpcomingDataToLoad()) {
              return NewsShimmerLoader(
                width: 175,
                height: 200,
              );
            } else {
              return SizedBox();
            }
          } else if (getupexbitiondata.isEmpty) {
            return NewsShimmerLoader(
              width: 175,
              height: 200,
            );
          } else {
            getnews.Data result = getupexbitiondata[index];
            DateTime? startDate = DateTime.parse(result.startDate.toString());
            DateTime? endDate = DateTime.parse(result.endDate.toString());

            create_formattedDate = startDate != null
                ? DateFormat('dd MMMM yyyy').format(startDate)
                : "";
            end_formattedDate = endDate != null
                ? DateFormat('dd MMMM yyyy').format(endDate)
                : "";

            return GestureDetector(
                onTap: (() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ExhitionDetail(blog_id: result.id.toString()),
                    ),
                  );
                }),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.05)),
                  child: Container(
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
                        ]),
                    child: Column(children: [
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13.05),
                          child: CachedNetworkImage(
                            imageUrl: result.imageUrl.toString(),
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.title.toString(),
                                maxLines: 2,
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined,
                                      size: 20),
                                  Text(
                                    "${create_formattedDate!} - ${end_formattedDate!}",
                                    style: const TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'assets/fonst/Metropolis-Black.otf')
                                        .copyWith(fontSize: 11),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  ImageIcon(
                                    AssetImage('assets/location.png'),
                                    size: 15,
                                  ),
                                  5.sbw,
                                  Expanded(
                                    child: Text(
                                      result.location.toString(),
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Metropolis',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(result.metaDescription.toString(),
                                  maxLines: 2,
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontFamily: 'Metropolis',
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  )),
                              const SizedBox(height: 7),
                              const Divider(height: 2.0, thickness: 2),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                      height: 18,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          result.isLike == "0"
                                              ? GestureDetector(
                                                  onTap: () {
                                                    Exhibitionlike(
                                                        result.id.toString());
                                                    result.isLike = '1';
                                                    int like = int.parse(result
                                                        .likeCounter
                                                        .toString());
                                                    like = like + 1;
                                                    result.likeCounter =
                                                        like.toString();
                                                    setState(() {});
                                                  },
                                                  child: Image.asset(
                                                    'assets/like.png',
                                                    width: 30,
                                                    height: 28,
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    Exhibitionlike(
                                                        result.id.toString());
                                                    result.isLike = '0';
                                                    int like = int.parse(result
                                                        .likeCounter
                                                        .toString());
                                                    like = like - 1;
                                                    result.likeCounter =
                                                        like.toString();
                                                    setState(() {});
                                                  },
                                                  child: Image.asset(
                                                    'assets/like1.png',
                                                    width: 30,
                                                    height: 28,
                                                  )),
                                          Text(
                                            'Interested (${result.likeCounter})',
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                              fontFamily: 'Metropolis',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      )),
                                  SizedBox(
                                    height: 18,
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                            onTap: () {},
                                            child: const ImageIcon(
                                              AssetImage('assets/show.png'),
                                              color: Colors.black,
                                              size: 20,
                                            )),
                                        const SizedBox(width: 2),
                                        Text(result.viewCounter.toString(),
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                              fontFamily: 'Metropolis',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ))
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height: 18,
                                      child: GestureDetector(
                                        onTap: () {
                                          shareImage(
                                            dynamicshortlink:
                                                result.dynamicLink.toString(),
                                            url: result.imageUrl.toString(),
                                            title: result.title.toString(),
                                            prodId: result.id.toString(),
                                            longdesc: result.longDescription
                                                .toString(),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const ImageIcon(
                                                AssetImage('assets/Send.png')),
                                            const SizedBox(width: 2),
                                            const Text('Share',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontFamily: 'Metropolis',
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ))
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                              Container(
                                height: 15,
                              ),
                            ]),
                      ),
                    ]),
                  ),
                ));
          }
        },
      ),
    );
  }

  bool hasUpcomingDataToLoad() {
    int itemsPerPage = 20;
    return getupexbitiondata.length % itemsPerPage == 0;
  }

  Widget past_exhibition() {
    return RefreshIndicator(
      backgroundColor: AppColors.primaryColor,
      color: Colors.white,
      onRefresh: () async {
        get_pastExhibition('0');
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            getpastexbitiondata.isEmpty ? 1 : getpastexbitiondata.length + 1,
        shrinkWrap: true,
        controller: scrollercontroller,
        itemBuilder: (context, index) {
          if (index == getpastexbitiondata.length) {
            if (hasPastDataToLoad()) {
              return NewsShimmerLoader(
                width: 175,
                height: 200,
              );
            } else {
              return SizedBox();
            }
          } else if (getpastexbitiondata.isEmpty) {
            return NewsShimmerLoader(
              width: 175,
              height: 200,
            );
          } else {
            getnews.Data result = getpastexbitiondata[index];
            DateTime? startDate = DateTime.parse(result.startDate.toString());
            DateTime? endDate = DateTime.parse(result.endDate.toString());

            create_formattedDate = startDate != null
                ? DateFormat('dd MMMM yyyy').format(startDate)
                : "";
            end_formattedDate = endDate != null
                ? DateFormat('dd MMMM yyyy').format(endDate)
                : "";

            return GestureDetector(
              onTap: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ExhitionDetail(blog_id: result.id.toString()),
                    ));
              }),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13.05)),
                child: Container(
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
                      ]),
                  child: Column(children: [
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13.05),
                        child: CachedNetworkImage(
                          imageUrl: result.imageUrl.toString(),
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(result.title.toString(),
                                maxLines: 2,
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                )),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined,
                                    size: 15),
                                Text(
                                  "${create_formattedDate!} - ${end_formattedDate!}",
                                  style: const TextStyle(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf')
                                      .copyWith(fontSize: 11),
                                )
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const ImageIcon(
                                    AssetImage('assets/location.png'),
                                    size: 15),
                                Expanded(
                                  child: Text(
                                    result.location.toString(),
                                    style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'assets/fonst/Metropolis-Black.otf')
                                        .copyWith(fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(result.metaDescription.toString(),
                                maxLines: 2,
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                )),
                            const SizedBox(height: 7),
                            const Divider(height: 2.0, thickness: 2),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                    height: 18,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        result.isLike == "0"
                                            ? GestureDetector(
                                                onTap: () {
                                                  Exhibitionlike(
                                                      result.id.toString());
                                                  result.isLike = '1';
                                                  int like = int.parse(result
                                                      .likeCounter
                                                      .toString());
                                                  like = like + 1;
                                                  result.likeCounter =
                                                      like.toString();

                                                  setState(() {});
                                                },
                                                child: Image.asset(
                                                  'assets/like.png',
                                                  width: 30,
                                                  height: 28,
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  Exhibitionlike(
                                                      result.id.toString());
                                                  result.isLike = '0';
                                                  int like = int.parse(result
                                                      .likeCounter
                                                      .toString());
                                                  like = like - 1;
                                                  result.likeCounter =
                                                      like.toString();

                                                  setState(() {});
                                                },
                                                child: Image.asset(
                                                  'assets/like1.png',
                                                  width: 30,
                                                  height: 28,
                                                )),
                                        Text(
                                            'Interested (${result.likeCounter})',
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                              fontFamily: 'Metropolis',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ))
                                      ],
                                    )),
                                SizedBox(
                                  height: 18,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {},
                                          child: const ImageIcon(
                                            AssetImage('assets/show.png'),
                                            color: Colors.black,
                                            size: 20,
                                          )),
                                      const SizedBox(width: 2),
                                      Text(result.viewCounter.toString(),
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            fontFamily: 'Metropolis',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ))
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: 18,
                                    child: GestureDetector(
                                      onTap: () {
                                        shareImage(
                                          dynamicshortlink:
                                              result.dynamicLink.toString(),
                                          url: result.imageUrl.toString(),
                                          title: result.title.toString(),
                                          prodId: result.id.toString(),
                                          longdesc:
                                              result.longDescription.toString(),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          const ImageIcon(
                                              AssetImage('assets/Send.png')),
                                          const SizedBox(width: 2),
                                          const Text('Share',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontFamily: 'Metropolis',
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ))
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                            Container(
                              height: 15,
                            ),
                          ]),
                    ),
                  ]),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  bool hasPastDataToLoad() {
    int itemsPerPage = 20;
    return getpastexbitiondata.length % itemsPerPage == 0;
  }

  Widget horiztallist() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
          shrinkWrap: false,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: constanst.catdata.length,
          itemBuilder: (context, index) {
            cat.Result result = constanst.catdata[index];
            return Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Wrap(spacing: 6.0, runSpacing: 6.0, children: <Widget>[
                  ChoiceChip(
                    label:
                        Text(constanst.catdata[index].categoryName.toString()),
                    selected: _defaultChoiceIndex == index,
                    selectedColor: AppColors.blackColor,
                    onSelected: (bool selected) {
                      setState(() {
                        _defaultChoiceIndex = selected ? index : -1;

                        if (_tabController.index == 0) {
                          if (_defaultChoiceIndex == -1) {
                            category_filter_id = "";
                            getupexbitiondata.clear();
                            get_UpcomingExhibition('0');
                          } else {
                            category_filter_id = result.categoryId.toString();
                            getupexbitiondata.clear();
                            get_UpcomingExhibition('0');
                          }
                        } else if (_tabController.index == 1) {
                          if (_defaultChoiceIndex == -1) {
                            category_filter_id = "";
                            getupexbitiondata.clear();
                            get_UpcomingExhibition('0');
                          } else {
                            category_filter_id = result.categoryId.toString();
                            getupexbitiondata.clear();
                            get_UpcomingExhibition('0');
                          }
                        }
                      });
                    },
                    side: BorderSide.none,
                    backgroundColor: AppColors.greyBackground,
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
                  )
                ]));
          }),
    );
  }

  Future<void> get_UpcomingExhibition(String offset) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getupcoming_exbition(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      limit,
      category_filter_id,
    );

    var jsonArray;
    if (res['status'] == 1) {
      if (res['data'] != null) {
        jsonArray = res['data'];

        for (var data in jsonArray) {
          // Check if the data already exists to avoid duplicates
          if (!getupexbitiondata.any((existing) => existing.id == data['id'])) {
            getnews.Data record = getnews.Data(
              id: data['id'],
              isLike: data['isLike'],
              viewCounter: data['view_counter'],
              metaDescription: data['meta_description'],
              startDate: data['start_date'],
              endDate: data['end_date'],
              location: data['location'],
              imageUrl: data['image_url'],
              likeCounter: data['like_counter'],
              title: data['title'],
              longDescription: data['short_description'],
              dynamicLink: data['full_url'],
            );

            // Append new data to the existing list
            getupexbitiondata.add(record);
          }
        }
      }
    } else {
      showCustomToast(res['message']);
    }

    // Update UI
    if (mounted) {
      setState(() {});
    }

    return jsonArray;
  }

  Future<void> get_pastExhibition(String offset) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    getpastexbitiondata.clear();

    var res = await getpast_exbition(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      offset.toString(),
      limit,
      category_filter_id,
    );

    var jsonArray;
    if (res['status'] == 1) {
      if (res['data'] != null) {
        jsonArray = res['data'];

        for (var data in jsonArray) {
          getnews.Data record = getnews.Data(
            id: data['id'],
            isLike: data['isLike'],
            viewCounter: data['view_counter'],
            metaDescription: data['meta_description'],
            startDate: data['start_date'],
            endDate: data['end_date'],
            location: data['location'],
            imageUrl: data['image_url'],
            likeCounter: data['like_counter'],
            title: data['title'],
            longDescription: data['short_description'],
            dynamicLink: data['full_url'],
          );

          getpastexbitiondata.add(record);
        }
      } else {
        isload = true;
      }
    } else {
      isload = true;
      showCustomToast(res['message']);
    }

    if (mounted) {
      setState(() {});
    }

    return jsonArray;
  }

  Future<void> Exhibitionlike(String newsId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await exbitionlike_like(
      newsId.toString(),
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
    );

    if (res['status'] == 1) {
      showCustomToast(res['message']);
    } else {
      showCustomToast(res['message']);
    }

    setState(() {});
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
  }

  void shareImage({
    required String dynamicshortlink,
    required String url,
    required String title,
    required String prodId,
    required String longdesc,
  }) async {
    try {
      // Step 1: Create dynamic link
      final dynamicLink =
          await createDynamicLink(dynamicshortlink, 'Exhibition', prodId);

      // Step 2: Parse the image URL and fetch the image
      final imageUrl = Uri.parse(url);
      final response = await http.get(imageUrl);

      if (response.statusCode != 200) {
        throw Exception('Failed to load image from the server');
      }

      // Step 3: Save the image temporarily
      final bytes = response.bodyBytes;
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/image.jpg';
      await File(path).writeAsBytes(bytes);

      // Step 4: Prepare the share text with dynamic link
      final shareText = title +
          "\n\n" +
          '$longdesc' +
          "\n\n" +
          'Plastic4trade is a B2B Plastic Business App, Buy & Sale your Products, Raw Material, Recycle Plastic Scrap, Plastic Machinery, Polymer Price, News, Update for Manufacturers, Traders, Exporters, Importers...' +
          "\n\n" +
          'More Info: $dynamicLink';

      // Step 5: Share the image and the text
      await Share.shareFiles([path], text: shareText);
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  void _scrollercontroller() {
    if (scrollercontroller.position.pixels ==
        scrollercontroller.position.maxScrollExtent) {
      if (_tabController.index == 0) {
        count++;
        if (count == 1) {
          offset = offset + 20;
        } else {
          offset = offset + 20;
        }
        get_UpcomingExhibition(offset.toString());
      } else if (_tabController.index == 1) {
        count++;

        if (count == 1) {
          offset = offset + 20;
        } else {
          offset = offset + 20;
        }
        get_pastExhibition(offset.toString());
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
      isload = true;
      setState(() {});
    });
  }
}
