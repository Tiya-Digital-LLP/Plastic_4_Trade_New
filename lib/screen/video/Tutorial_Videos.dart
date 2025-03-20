// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_video_shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../widget/HomeAppbar.dart';

class Tutorial_Videos extends StatefulWidget {
  const Tutorial_Videos({Key? key}) : super(key: key);

  @override
  State<Tutorial_Videos> createState() => _YourWidgetState();
}

class _YourWidgetState extends State<Tutorial_Videos> {
  String? assignedName;
  bool load = false;
  String link = "";
  String content = "";
  int offset = 0;
  List<String> videolist = [];
  List<String> videocontent = [];
  @override
  void initState() {
    super.initState();
    checknetowork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: CustomeApp('Tutorial_Video'),
        body: load
            ? SingleChildScrollView(
                child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: videolist.length,
                    itemBuilder: (context, index) {
                      return Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14)),
                              color: Colors.white),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    YoutubeViewer(videolist[index]),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      videocontent[index].toString(),
                                      style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(fontSize: 15),
                                    )
                                  ])));
                    }),
              )
            : VideoShimmerLoader(width: 175, height: 300));
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      get_videolist();
    }
  }

  Future<void> get_videolist() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await gettutorialvideolist(
      _pref.getString('user_id').toString(),
      _pref.getString('userToken').toString(),
      offset.toString(),
      device,
    );

    var jsonarray;
    print(res);
    if (res['status'] == 1) {
      if (res['result'] != null) {
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonarray)));
        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');
        jsonarray = res['result'];

        for (var data in jsonarray) {
          String videoLink = data['video_link'];
          if (videoLink.contains("watch?v=")) {
            // Extract the video ID after 'watch?v='
            link = videoLink.split("watch?v=").last;
          } else if (videoLink.contains("youtu.be/")) {
            // Handle short YouTube links as well (e.g., https://youtu.be/videoID)
            link = videoLink.split("youtu.be/").last;
          } else {
            // If video ID extraction fails, skip this entry
            continue;
          }

          content = data['title'];
          videolist.add(link);
          videocontent.add(content);
        }
        load = true;
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      showCustomToast(res['message']);
    }
    return jsonarray;
  }
}

class YoutubeViewer extends StatefulWidget {
  final String videoID;

  const YoutubeViewer(
    this.videoID,
  );

  @override
  _YoutubeViewerState createState() => _YoutubeViewerState();
}

class _YoutubeViewerState extends State<YoutubeViewer>
    with AutomaticKeepAliveClientMixin {
  late final YoutubePlayerController controller;
  bool isPlaying = false;
  bool _showOverlay = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    controller = YoutubePlayerController.fromVideoId(
      params: const YoutubePlayerParams(
        enableCaption: false,
        showVideoAnnotations: false,
        playsInline: false,
        showFullscreenButton: true,
        pointerEvents: PointerEvents.auto,
        showControls: true,
      ),
      videoId: widget.videoID,
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
    super.build(context);

    return Column(
      children: [
        ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(13.05),
          child: Stack(
            children: [
              YoutubePlayer(
                controller: controller,
                aspectRatio: 16 / 9,
              ),
              if (_showOverlay)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showOverlay = false;
                      });
                      controller.playVideo();
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _launchYoutube,
          child: Row(
            children: [
              Icon(Icons.ondemand_video, color: Colors.red),
              SizedBox(width: 5),
              Text(
                "Watch on YouTube",
                style: TextStyle(color: AppColors.primaryColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
