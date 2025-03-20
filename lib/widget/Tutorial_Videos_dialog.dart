// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, prefer_typing_uninitialized_variables, depend_on_referenced_packages, camel_case_types, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class Tutorial_Videos_dialog extends StatefulWidget {
  String title;
  String screenId;
  Tutorial_Videos_dialog(this.title, this.screenId, {Key? key})
      : super(key: key);

  @override
  State<Tutorial_Videos_dialog> createState() => _YourWidgetState();
}

class _YourWidgetState extends State<Tutorial_Videos_dialog> {
  String? assignedName;
  bool? load;
  bool availble = false;
  String link = "";
  String content = "";
  String screen_id = "0";
  List<String> videolist = [];
  List<String> videocontent = [];
  @override
  void initState() {
    super.initState();
    checknetowork();
  }

  @override
  Widget build(BuildContext context) {
    return load == true
        ? Dialog(
            alignment: Alignment.center,
            elevation: 0,
            backgroundColor: AppColors.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: AppColors.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              constraints: link != ""
                  ? BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    )
                  : const BoxConstraints(
                      maxHeight: 150,
                      minHeight: 100,
                    ),
              child: Stack(
                children: [
                  link != ""
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            YoutubeViewer(link),
                            SizedBox(height: 5),
                            Flexible(
                              child: Text(
                                content.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 16,
                                      color: AppColors.blackColor,
                                    ),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                            "Video Not Found",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontSize: 15,
                                  color: AppColors.blackColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: AppColors.blackColor,
                          shape: const OvalBorder(),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.backgroundColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Center(
            child: CustomLottieContainer(
              child: Lottie.asset(
                'assets/loading_animation.json',
              ),
            ),
          );
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      get_videolistScreen();
    }
  }

  Future<void> get_videolistScreen() async {
    print('Fetching video list for: ${widget.title}');

    if (widget.title == 'Home') {
      screen_id = "1";
    } else if (widget.title == 'Seller') {
      screen_id = "17";
    } else if (widget.title == 'Buyer') {
      screen_id = "17";
    } else if (widget.title == 'News') {
      screen_id = "2";
    } else if (widget.title == 'More') {
      screen_id = "14";
    } else if (widget.title == 'Exhibition') {
      screen_id = "5";
    } else if (widget.title == 'Directory') {
      screen_id = "4";
    } else if (widget.title == 'PremiumMember') {
      screen_id = "16";
    } else if (widget.title == 'Saved') {
      screen_id = "8";
    } else if (widget.title == 'Videos') {
      screen_id = "6";
    } else if (widget.title == 'Tutorial_Video') {
      screen_id = "15";
    } else if (widget.title == 'ContactUs') {
      screen_id = "7";
    } else if (widget.title == 'Exhibitor') {
      screen_id = "10";
    } else if (widget.title == 'AddwithUs') {
      screen_id = "9";
    } else if (widget.title == 'Chat') {
      screen_id = "11";
    } else if (widget.title == 'Premium') {
      screen_id = "18";
    } else if (widget.title == 'LivePrice') {
      screen_id = "12";
    } else if (widget.title == 'ManagePost') {
      screen_id = "3";
    } else if (widget.title == 'PhysicalBusinessDirectory') {
      screen_id = "19";
    }

    print('Screen ID: $screen_id');

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }

    print('Device: $device');

    var res = await gettutorialvideo_screen(screen_id, device);
    print('Response get_videolistScreen: $res');

    if (res['status'] == 1) {
      if (res['result'] != null && res['result'] is List) {
        var jsonArray = res['result'];
        print('Video List Found: ${jsonArray.length} items');

        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));
        int sizeInBytes = compressedData.length;
        print('Compressed Data Size: $sizeInBytes bytes');

        videolist.clear();
        videocontent.clear();

        for (var data in jsonArray) {
          print('Processing video: ${data['title']}');

          String videoLink = data['video_link'] ?? "";

          if (videoLink.contains("watch?v=")) {
            link = videoLink.split("watch?v=").last;
          } else if (videoLink.contains("youtu.be/")) {
            link = videoLink.split("youtu.be/").last;
          } else {
            continue;
          }

          content = data['title'] ?? "";
          videolist.add(link);
          videocontent.add(content);
        }

        load = true;
      } else if (res['result'] != null && res['result'] is Map) {
        var jsonArray = [res['result']];
        print('Single Video Found');

        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));
        int sizeInBytes = compressedData.length;
        print('Compressed Data Size: $sizeInBytes bytes');

        videolist.clear();
        videocontent.clear();

        String videoLink = jsonArray[0]['video_link'] ?? "";

        if (videoLink.contains("watch?v=")) {
          link = videoLink.split("watch?v=").last;
        } else if (videoLink.contains("youtu.be/")) {
          link = videoLink.split("youtu.be/").last;
        } else {
          print('Invalid video link format');
          return;
        }

        content = jsonArray[0]['title'] ?? "";
        videolist.add(link);
        videocontent.add(content);

        load = true;
      } else {
        load = true;
        print('No result found in the response.');
      }
    } else {
      showCustomToast(res['message']);
      print('Error: ${res['message']}');
    }

    setState(() {});
  }
}

class YoutubeViewer extends StatefulWidget {
  final String videoID;

  const YoutubeViewer(this.videoID, {Key? key}) : super(key: key);

  @override
  _YoutubeViewerState createState() => _YoutubeViewerState();
}

class _YoutubeViewerState extends State<YoutubeViewer> {
  late final YoutubePlayerController controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoID,
      params: const YoutubePlayerParams(
        enableCaption: false,
        showVideoAnnotations: false,
        playsInline: false,
        showFullscreenButton: true,
        pointerEvents: PointerEvents.auto,
        showControls: true,
      ),
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  Future<void> _launchYoutube() async {
    final url = 'https://www.youtube.com/watch?v=${widget.videoID}';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url); // Launch the YouTube URL in the external app/browser
    } else {
      showCustomToast('Could not open YouTube');
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = YoutubePlayer(
      controller: controller,
    );

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: player,
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: _launchYoutube, // Open YouTube when icon is tapped
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.ondemand_video, color: Colors.red),
              SizedBox(width: 5),
              Text("Watch on YouTube",
                  style:
                      TextStyle(color: AppColors.primaryColor, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
