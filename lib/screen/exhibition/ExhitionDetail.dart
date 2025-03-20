// ignore_for_file: import_of_legacy_library_into_null_safe, must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables, depend_on_referenced_packages, unnecessary_null_comparison, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/custom_exhibition_details_shimmer_loader.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../api/api_interface.dart';
import 'dart:io';

import '../../model/get_exhibition_details.dart' as like;
import '../../model/get_exhibition_details.dart';

class ExhitionDetail extends StatefulWidget {
  String blog_id;

  ExhitionDetail({Key? key, required this.blog_id}) : super(key: key);

  @override
  State<ExhitionDetail> createState() => _ExhitionDetailState();
}

class _ExhitionDetailState extends State<ExhitionDetail> {
  PackageInfo? packageInfo;
  String? packageName;
  String? title;
  bool isload = false;
  String? blog_date;
  int? blogId;
  String? long_text;
  String? blog_image;
  String? blog_title;
  String? isLike;
  String? longDescription;
  String? dynamicshortlink;

  String? likeCount, view_counter;

  var create_formattedDate;

  @override
  void initState() {
    checknetowork();
    super.initState();
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      getPackage();
      get_ExhitionDetail();
    }
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
  }

  @override
  Widget build(BuildContext context) {
    return init();
  }

  Widget init() {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: const Text('Exhibition Detail',
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
        ),
        body: isload == true
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                      height: 150,
                      child: CachedNetworkImage(
                        imageUrl: blog_image.toString(),
                      ),
                    ),
                    Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.0),
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                isLike == "0"
                                    ? GestureDetector(
                                        onTap: () {
                                          bloglike(blogId.toString());
                                          isLike = '1';
                                          int like =
                                              int.parse(likeCount.toString());
                                          like = like + 1;
                                          likeCount = like.toString();
                                          setState(() {});
                                        },
                                        child: Image.asset(
                                          'assets/like.png',
                                          width: 30,
                                          height: 20,
                                        ))
                                    : GestureDetector(
                                        onTap: () {
                                          bloglike(blogId.toString());
                                          isLike = '0';
                                          int like =
                                              int.parse(likeCount.toString());
                                          like = like - 1;
                                          likeCount = like.toString();

                                          setState(() {});
                                        },
                                        child: Image.asset(
                                          'assets/like1.png',
                                          width: 30,
                                          height: 20,
                                        )),
                                GestureDetector(
                                  onTap: () {
                                    ViewItem(context);
                                  },
                                  child: Text('Like ($likeCount)',
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontFamily: 'Metropolis',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      )),
                                ),
                              ],
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
                                      dynamicshortlink:
                                          dynamicshortlink.toString(),
                                      url: blog_image.toString(),
                                      title: blog_title.toString(),
                                      prodId: blogId.toString(),
                                      longdesc: longDescription.toString(),
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
                                        'Send',
                                        style: const TextStyle(
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
                        )),
                    Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        width: MediaQuery.of(context).size.width,
                        margin:
                            const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(blog_title.toString(),
                                      style: const TextStyle(
                                              fontSize: 26.0,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(fontSize: 16)),
                                )),
                            Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(create_formattedDate,
                                      style: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf')),
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Could not open the link')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              )
            : customExhibition(
                width: 175,
                height: 800,
              ));
  }

  Future<void> get_ExhitionDetail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await getexbitiondetail(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.blog_id.toString(),
    );

    var jsonArray;
    if (res['status'] == 1) {
      if (res['data'] != null) {
        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');
        jsonArray = res['data'];
        long_text = jsonArray['long_description'];
        blog_date = jsonArray['start_date'];
        blog_title = jsonArray['title'];
        blog_image = jsonArray['image_url'];
        likeCount = jsonArray['like_counter'];
        view_counter = jsonArray['view_counter'].toString();
        isLike = jsonArray['isLike'];
        blogId = jsonArray['id'];
        longDescription = jsonArray['short_description'];
        dynamicshortlink = jsonArray['full_url'];

        DateFormat format = DateFormat("yyyy-MM-dd");
        var curretDate = format.parse(blog_date.toString());

        DateTime? dt1 = DateTime.parse(curretDate.toString());
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

  Future<void> bloglike(String blogid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await exbitionlike_like(
      blogid.toString(),
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

  void shareImage({
    required String dynamicshortlink,
    required String url,
    required String title,
    required String prodId, // Add prodId as a required parameter
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

  ViewItem(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundColor,
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
                return ViewLikes(widget.blog_id);
              },
            );
          }),
    ).then(
      (value) {},
    );
  }
}

class ViewLikes extends StatefulWidget {
  String exhibitionId;

  ViewLikes(this.exhibitionId, {Key? key}) : super(key: key);

  @override
  State<ViewLikes> createState() => _ViewLikesState();
}

class _ViewLikesState extends State<ViewLikes>
    with SingleTickerProviderStateMixin {
  bool? isload;
  List<like.LikedUser> dataList = [];

  @override
  initState() {
    super.initState();
    getInterest(widget.exhibitionId);
  }

  getInterest(blog_id) async {
    EventDetails common = EventDetails();
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getexbitiondetail(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      blog_id,
    );

    print("RESPONSE == ${res}");

    if (res['status'] == 1) {
      common = EventDetails.fromJson(res);
      dataList = common.likedUser ?? [];
      isload = true;
    } else {}
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
              const SizedBox(
                height: 25,
              ),
              const Text("Likes"),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {},
                        child: ListTile(
                          title: Text(
                            dataList[index].username.toString(),
                            style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily:
                                    'assets/fonst/Metropolis-Black.otf'),
                          ),
                          leading: CircleAvatar(
                            radius: 16.0,
                            backgroundImage: NetworkImage(
                              dataList[index].profileImage.toString(),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 240, 238, 238),
                          ),
                        ),
                      );
                    }),
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
