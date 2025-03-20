// ignore_for_file: prefer_typing_uninitialized_variables, import_of_legacy_library_into_null_safe, depend_on_referenced_packages, non_constant_identifier_names, unnecessary_null_comparison, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/widget/customshimmer/news_custom_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:Plastic4trade/model/getNews.dart' as getnews;
import 'package:Plastic4trade/model/QuickNews.dart' as getquicknews;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:Plastic4trade/screen/news/NewsDetail.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/api_interface.dart';

// ignore: must_be_immutable
class News extends StatefulWidget {
  int initialIndex = 0;
  News({Key? key, required this.initialIndex}) : super(key: key);

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<getnews.Result> getnewsdata = [];
  List<getquicknews.Result> getQuicknewsdata = [];
  bool isload = false;

  String? packageName;
  int offset = 0;
  int count = 0;
  final scrollercontroller = ScrollController();
  final scrollernewscontroller = ScrollController();

  var create_formattedDate;
  PackageInfo? packageInfo;
  int sameDateCount = 0;
  List showdate = [];

  @override
  void initState() {
    checknetowork();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex);
    scrollercontroller.addListener(_scrollercontroller);
    scrollernewscontroller.addListener(_scrollernewscontroller);

    super.initState();
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
  }

  @override
  Widget build(BuildContext context) {
    return init();
  }

  Future<bool> _onbackpress(BuildContext context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MainScreen(0)));
    return Future.value(true);
  }

  Widget init() {
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
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  DefaultTabController(
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
                              child: Text(
                                'Quick News',
                              ),
                            ),
                            Tab(
                              child: Text(
                                'News',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 11,
                  ),
                  Expanded(
                    child: TabBarView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          Quicknews(),
                          news(),
                        ]),
                  )
                ],
              ),
            )));
  }

  void _scrollercontroller() {
    if (scrollercontroller.position.pixels ==
        scrollercontroller.position.maxScrollExtent) {
      if (_tabController.index == 0) {
        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        get_QuickNews();
      }
    }
  }

  Widget news() {
    return RefreshIndicator(
      backgroundColor: AppColors.primaryColor,
      color: AppColors.backgroundColor,
      onRefresh: _refreshNews,
      child: FutureBuilder(
        future: getRalSalerpostFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('No Similar Post Found');
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
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: getnewsdata.isEmpty ? 1 : getnewsdata.length + 1,
              shrinkWrap: true,
              controller: scrollernewscontroller,
              itemBuilder: (context, index) {
                if (index == getnewsdata.length) {
                  if (categorySaleToLoad()) {
                    return NewsShimmerLoader(
                      width: 175,
                      height: 200,
                    );
                  } else {
                    return SizedBox();
                  }
                } else if (getnewsdata.isEmpty) {
                  return NewsShimmerLoader(
                    width: 175,
                    height: 200,
                  );
                } else {
                  getnews.Result result = getnewsdata[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetail(news_id: result.newsId.toString()),
                            ),
                          );
                        },
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
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(10.0),
                                height: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13.05),
                                  child: CachedNetworkImage(
                                    imageUrl: result.newsImage.toString(),
                                    fit: BoxFit.fill,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: Text(
                                      result.newsTitle.toString(),
                                      maxLines: 2,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: 'Metropolis',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.24,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          result.isLike == "0"
                                              ? IconButton(
                                                  iconSize: 17,
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  onPressed: () {
                                                    Newslike(result.newsId
                                                        .toString());
                                                    result.isLike = '1';
                                                    int like = int.parse(result
                                                        .likeCount
                                                        .toString());
                                                    like = like + 1;
                                                    result.likeCount =
                                                        like.toString();
                                                    setState(() {});
                                                  },
                                                  icon: const ImageIcon(
                                                    size: 17,
                                                    AssetImage(
                                                        'assets/like.png'),
                                                  ),
                                                )
                                              : IconButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  onPressed: () {
                                                    Newslike(result.newsId
                                                        .toString());
                                                    result.isLike = '0';
                                                    int like = int.parse(result
                                                        .likeCount
                                                        .toString());
                                                    like = like - 1;
                                                    result.likeCount =
                                                        like.toString();
                                                    setState(() {});
                                                  },
                                                  icon: const ImageIcon(
                                                    size: 17,
                                                    color:
                                                        AppColors.primaryColor,
                                                    AssetImage(
                                                        'assets/like1.png'),
                                                  ),
                                                ),
                                          Text(
                                            'Like (${result.likeCount})',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontFamily: 'Metropolis',
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: -0.24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            iconSize: 17,
                                            padding: const EdgeInsets.all(0),
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.remove_red_eye_outlined,
                                              size: 17,
                                            ),
                                          ),
                                          Text(
                                            'View (${result.viewCounter})',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontFamily: 'Metropolis',
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: -0.24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          shareImage(
                                            dynamicshortlink:
                                                result.dynamicLink.toString(),
                                            url: result.newsImage.toString(),
                                            title: result.newsTitle.toString(),
                                            prodId: result.newsId.toString(),
                                            longdesc:
                                                result.longContent.toString(),
                                          );
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                iconSize: 14,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                onPressed: () {
                                                  shareImage(
                                                    dynamicshortlink: result
                                                        .dynamicLink
                                                        .toString(),
                                                    url: result.newsImage
                                                        .toString(),
                                                    title: result.newsTitle
                                                        .toString(),
                                                    prodId: result.newsId
                                                        .toString(),
                                                    longdesc: result.longContent
                                                        .toString(),
                                                  );
                                                },
                                                icon: const ImageIcon(
                                                  AssetImage('assets/Send.png'),
                                                  size: 14,
                                                ),
                                              ),
                                              const Text(
                                                'Share',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontFamily: 'Metropolis',
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: -0.24,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  bool hasMoreDataToLoad() {
    int itemsPerPage = 20;
    return getnewsdata.length % itemsPerPage == 0;
  }

  Widget Quicknews() {
    return RefreshIndicator(
      backgroundColor: AppColors.primaryColor,
      color: AppColors.backgroundColor,
      onRefresh: _refreshQuickNews,
      child: ListView.builder(
        controller: scrollercontroller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: getQuicknewsdata.isEmpty ? 1 : getQuicknewsdata.length + 1,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == getQuicknewsdata.length) {
            if (hasMoreQuickNewsToLoad()) {
              return NewsShimmerLoader(
                width: 175,
                height: 200,
              );
            } else {
              return SizedBox();
            }
          } else if (getQuicknewsdata.isEmpty) {
            return NewsShimmerLoader(
              width: 175,
              height: 200,
            );
          } else {
            getquicknews.Result record = getQuicknewsdata[index];
            print('Response: ${record.toJson()}');
            print('image for quicknews: ${record.imageUrl}');
            String displayDate = "";
            if (record.newsDate != null) {
              create_formattedDate = DateFormat("dd-MMM-yyyy").format(
                  DateFormat("yyyy-MM-dd").parse(record.newsDate.toString()));
              displayDate = dateConverter(create_formattedDate);
            }
            return GestureDetector(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(displayDate.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            height: 0.06,
                            fontFamily: 'Metropolis',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.24,
                          )),
                    ),
                  if (index > 0 && getQuicknewsdata[index - 1].newsDate != null)
                    dateConverter(DateFormat("dd-MMM-yyyy").format(
                                DateTime.parse(getQuicknewsdata[index - 1]
                                    .newsDate
                                    .toString()))) !=
                            displayDate
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(displayDate.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w600,
                                  height: 0.06,
                                  letterSpacing: -0.24,
                                )),
                          )
                        : const SizedBox(),
                  Container(
                    padding: const EdgeInsets.all(10),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            image: DecorationImage(
                              image: (() {
                                try {
                                  // ignore: null_check_always_fails
                                  return NetworkImage(record.imageUrl!);
                                } catch (e) {
                                  print('Error loading image: $e');
                                  return AssetImage(
                                          'assets/plastic4trade logo final 1 (2).png')
                                      as ImageProvider<Object>;
                                }
                              })(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  '${record.newsTitle}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Metropolis',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  create_formattedDate!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontFamily: 'Metropolis',
                                    fontWeight: FontWeight.w400,
                                    height: 0.20,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                              ),
                              Html(
                                data: record.longDescription!,
                                style: {
                                  "p": Style(
                                    fontSize: FontSize(12),
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.24,
                                    fontFamily: 'Metropolis',
                                  ),
                                  "body": Style(
                                    fontSize: FontSize(12),
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.24,
                                    fontFamily: 'Metropolis',
                                  ),
                                },
                                onLinkTap: (String? url,
                                    Map<String, String> attributes, _) async {
                                  if (url != null) {
                                    final Uri uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Could not open the link'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                shrinkWrap: true,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  bool hasMoreQuickNewsToLoad() {
    int itemsPerPage = 20;
    return getQuicknewsdata.length % itemsPerPage == 0;
  }

  Future<void> _refreshNews() async {
    getnewsdata.clear();
    await get_News();
  }

  Future<void> _refreshQuickNews() async {
    getQuicknewsdata.clear();
    await get_QuickNews();
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      //isprofile=true;
    } else {
      getPackage();
      get_News();
      get_QuickNews();
      // get_data();
    }
  }

  bool categorySaleToLoad() {
    int itemsPerPage = 20;
    return getnewsdata.length % itemsPerPage == 0 && getnewsdata.isNotEmpty;
  }

  Future? getRalSalerpostFuture;

  void _scrollernewscontroller() {
    if ((scrollernewscontroller.position.pixels - 50) ==
        (scrollernewscontroller.position.maxScrollExtent - 50)) {
      if (getnewsdata.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        getRalSalerpostFuture = get_News();
      } else if (getnewsdata.isNotEmpty) {
        count++;
        if (categorySaleToLoad()) {
          offset = offset + 20;
          getRalSalerpostFuture = get_News();
        }
      }
    }
  }

  Future<void> get_News() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getnewss(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
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
          getnews.Result record = getnews.Result(
            newsId: data['newsId'],
            newsTitle: data['newsTitle'],
            newsImage: data['newsImage'],
            isLike: data['isLike'],
            likeCount: data['likeCount'],
            viewCounter: data['viewCounter'],
            longContent: data['short_description'],
            dynamicLink: data['full_url'],
          );

          getnewsdata.add(record);
        }

        if (mounted) {
          setState(() {});
        }
      }
    } else {
      showCustomToast(res['message']);
    }
    return jsonArray;
  }

  Future<void> get_QuickNews() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getQuicknews(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
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
          getquicknews.Result record = getquicknews.Result(
            id: data['id'],
            longDescription: data['long_description'],
            newsTitle: data['news_title'],
            newsImage: data['image_url'],
            newsDate: data['news_date'],
          );

          getQuicknewsdata.add(record);
        }
        isload = true;
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      showCustomToast(res['message']);
    }

    return jsonArray;
  }

  Future<void> Newslike(String newsId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await news_like(
      newsId.toString(),
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
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

        isload = true;

        // setState(() {});
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

  String dateConverter(String myDate) {
    String date;
    DateTime convertedDate = DateFormat("dd-MMM-yyyy").parse(myDate.toString());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final dateToCheck = convertedDate;
    final checkDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);

    if (checkDate == today) {
      date = "Today";
    } else if (checkDate == yesterday) {
      date = "Yesterday";
    } else if (checkDate == tomorrow) {
      date = "Tomorrow";
    } else {
      date = myDate;
    }
    return date;
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
          await createDynamicLink(dynamicshortlink, 'News', prodId);

      print('Dynamic link: $dynamicLink');

      // Step 2: Parse the image URL and fetch the image
      final uri = Uri.parse(url);
      final response = await http.get(uri);

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
}
