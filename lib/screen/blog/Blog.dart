// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/customshimmer/news_custom_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:Plastic4trade/model/getBlog.dart' as getblog;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:Plastic4trade/screen/blog/BlogDetail.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_interface.dart';

class Blog extends StatefulWidget {
  const Blog({Key? key}) : super(key: key);

  @override
  State<Blog> createState() => _BlogState();
}

class _BlogState extends State<Blog> {
  String? packageName;
  PackageInfo? packageInfo;
  List<getblog.Result> getblogsdata = [];
  bool isload = false;
  @override
  void initState() {
    checknetowork();

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

  Widget init() {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          title: const Text('Blog',
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
        body: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5), child: Blog()));
  }

  bool BlogDataToLoad() {
    int itemsPerPage = 20;
    return getblogsdata.length % itemsPerPage == 0;
  }

  Widget Blog() {
    return RefreshIndicator(
      backgroundColor: AppColors.primaryColor,
      color: AppColors.backgroundColor,
      onRefresh: () async {
        await get_Blog();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: getblogsdata.isEmpty ? 1 : getblogsdata.length + 1,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == getblogsdata.length) {
            if (BlogDataToLoad()) {
              return NewsShimmerLoader(
                width: 175,
                height: 200,
              );
            } else {
              return SizedBox();
            }
          } else if (getblogsdata.isEmpty) {
            return NewsShimmerLoader(
              width: 175,
              height: 200,
            );
          } else {
            getblog.Result result = getblogsdata[index];
            return GestureDetector(
              onTap: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BlogDetail(blog_id: result.blogId.toString()),
                    ));
              }),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13.05)),
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13.05),
                      child: CachedNetworkImage(
                        imageUrl: result.blogImage.toString(),
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.blogTitle.toString(),
                            maxLines: 2,
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Metropolis',
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                            overflow: TextOverflow.ellipsis),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Call the bloglike function
                                bloglike(result.blogId.toString());

                                // Toggle the like state and update like count
                                if (result.isLike == "0") {
                                  result.isLike = '1'; // Update to liked state
                                  int like =
                                      int.parse(result.likeCount.toString()) +
                                          1; // Increment like count
                                  result.likeCount =
                                      like.toString(); // Update the like count
                                } else {
                                  result.isLike =
                                      '0'; // Update to unliked state
                                  int like =
                                      int.parse(result.likeCount.toString()) -
                                          1; // Decrement like count
                                  result.likeCount =
                                      like.toString(); // Update the like count
                                }

                                // Update the state to reflect changes
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  // Use ImageIcon for consistency with the original code
                                  ImageIcon(
                                    AssetImage(result.isLike == "0"
                                        ? 'assets/like.png'
                                        : 'assets/like1.png'),
                                    size: 17,
                                  ),
                                  const SizedBox(
                                      width:
                                          8), // Add spacing between icon and text
                                  Text(
                                    'Like (${result.likeCount ?? 0})',
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {},
                                    iconSize: 17,
                                    icon: const Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 17,
                                    )),
                                Text('View (${result.viewCounter})',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontFamily: 'Metropolis',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ))
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                shareImage(
                                  dynamicshortlink:
                                      result.dynamicLink.toString(),
                                  url: result.blogImage.toString(),
                                  title: result.blogTitle.toString(),
                                  prodId: result.blogId.toString(),
                                  longdesc: result.longContent.toString(),
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      padding: const EdgeInsets.all(0),
                                      onPressed: () {
                                        shareImage(
                                          dynamicshortlink:
                                              result.dynamicLink.toString(),
                                          url: result.blogImage.toString(),
                                          title: result.blogTitle.toString(),
                                          prodId: result.blogId.toString(),
                                          longdesc:
                                              result.longContent.toString(),
                                        );
                                      },
                                      iconSize: 17,
                                      icon: const ImageIcon(
                                        AssetImage('assets/Send.png'),
                                        size: 17,
                                      )),
                                  const Text('Share',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontFamily: 'Metropolis',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ))
                                ],
                              ),
                            ),
                            const SizedBox(),
                          ],
                        )
                      ],
                    ),
                  )
                ]),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      getPackage();
      get_Blog();
    }
  }

  Future<void> get_Blog() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getblogs(
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
        for (var data in jsonArray) {
          getblog.Result record = getblog.Result(
            blogId: data['blogId'],
            blogTitle: data['BlogTitle'],
            blogImage: data['BlogImage'],
            isLike: data['isLike'],
            likeCount: data['likeCount'],
            viewCounter: data['view_counter'],
            longContent: data['short_description'],
            dynamicLink: data['full_url'],
          );
          getblogsdata.add(record);
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

  Future<void> bloglike(String blogid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await blog_like(
      blogid.toString(),
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
      if (res['result'] != null) {
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
    setState(() {});
    return jsonArray;
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
          await createDynamicLink(dynamicshortlink, 'Blog', prodId);

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
