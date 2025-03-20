// ignore_for_file: depend_on_referenced_packages, import_of_legacy_library_into_null_safe, must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, unnecessary_null_comparison

import 'dart:convert';

import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/custom_exhibition_details_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../api/api_interface.dart';
import 'dart:io';

class NewsDetail extends StatefulWidget {
  String news_id;

  NewsDetail({Key? key, required this.news_id}) : super(key: key);

  @override
  State<NewsDetail> createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  PackageInfo? packageInfo;
  String? packageName;
  String? title;
  bool isload = false;
  String? news_date, news_url;
  int? newsId, view_counter;
  String? long_text, ShortContent, longContent;
  String? news_image;
  String? news_title;
  String? isLike;
  String? likeCount;
  var create_formattedDate;

  @override
  void initState() {
    checknetowork();
    //_tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      //isprofile=true;
    } else {
      getPackage();
      get_NewsDetail();

      // get_data();
    }
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
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
        title: const Text(
          'News Detail',
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
      body: isload
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                  height: 150,
                  child: CachedNetworkImage(
                    imageUrl: news_image.toString(),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.0),
                  padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          newslike(newsId.toString());
                          // Toggle isLike and update likeCount accordingly
                          if (isLike == "0") {
                            isLike = '1';
                            int like = int.parse(likeCount.toString()) + 1;
                            likeCount = like.toString();
                          } else {
                            isLike = '0';
                            int like = int.parse(likeCount.toString()) - 1;
                            likeCount = like.toString();
                          }
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              isLike == "0"
                                  ? 'assets/like.png'
                                  : 'assets/like1.png',
                              width: 50,
                              height: 28,
                            ),
                            Text(
                              'Like ($likeCount)',
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontFamily: 'Metropolis',
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          width: 126,
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/view1.png',
                                height: 25,
                                width: 40,
                              ),
                              Text(
                                'Views ($view_counter)',
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
                          width: 90,
                          child: GestureDetector(
                            onTap: () {
                              shareImage(
                                url: news_image.toString(),
                                title: news_title.toString(),
                                prodId: newsId.toString(),
                                longdesc: longContent.toString(),
                                shortdynamiclink: news_url.toString(),
                              );
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/send2.png',
                                  height: 25,
                                  width: 40,
                                ),
                                Text(
                                  'Share',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontFamily: 'Metropolis',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              news_title.toString(),
                              style: const TextStyle(
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf')
                                  .copyWith(fontSize: 16),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              create_formattedDate,
                              style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Html(
                              data: long_text,
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Could not open the link')),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    )),
              ]),
            )
          : Center(
              child: customExhibition(
              width: 175,
              height: 800,
            )),
    );
  }

  Future<void> get_NewsDetail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getnewssdetail(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.news_id.toString(),
      device,
    );

    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');
        jsonArray = res['result'];
        ShortContent = jsonArray['ShortContent'];
        long_text = jsonArray['LongContent'];
        news_date = jsonArray['newsDate'];
        news_title = jsonArray['newsTitle'];
        news_image = jsonArray['newsImage'];
        likeCount = jsonArray['likeCount'];
        isLike = jsonArray['isLike'];
        newsId = jsonArray['newsId'];
        view_counter = jsonArray['viewCounter'];
        longContent = jsonArray['short_description'];
        news_url = jsonArray['news_url'];

        DateFormat format = DateFormat("yyyy-MM-dd");
        var curretDate = format.parse(
          news_date.toString(),
        );

        DateTime? dt1 = DateTime.parse(
          curretDate.toString(),
        );

        // print(dt1);
        create_formattedDate =
            dt1 != null ? DateFormat('dd MMMM, yyyy').format(dt1) : "";

        isload = true;
        setState(() {});
      } else {
        showCustomToast(res['message']);
      }
      return jsonArray;
    }
  }

  Future<void> newslike(String newsid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await news_like(
      newsid.toString(),
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');
        jsonArray = res['result'];

        isload = true;

        if (mounted) {
          setState(() {});
        }
      }
      showCustomToast(res['message']);
    } else {
      showCustomToast(res['message']);
    }
    return jsonArray;
  }

  void shareImage({
    required String url,
    required String title,
    required String prodId,
    required String longdesc,
    required String shortdynamiclink,
  }) async {
    try {
      // Step 1: Create dynamic link
      final dynamicLink =
          await createDynamicLink(shortdynamiclink, 'News', prodId);

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
