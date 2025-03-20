// ignore_for_file: depend_on_referenced_packages, unnecessary_null_comparison, non_constant_identifier_names, prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'dart:io';

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_video_shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../widget/HomeAppbar.dart';

class Videos extends StatefulWidget {
  const Videos({Key? key}) : super(key: key);

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  final ScrollController _scrollerController = ScrollController();
  bool _isLoading = false;
  int _offset = 0;
  int _count = 0;
  List<String> _videoList = [];
  List<String> _videoContentList = [];

  @override
  void initState() {
    super.initState();
    _scrollerController.addListener(_onScroll);
    _checkNetwork();
  }

  void _onScroll() {
    if (_scrollerController.position.atEdge &&
        _scrollerController.position.pixels != 0) {
      if (_videoList.isNotEmpty) {
        _count++;
        _offset += (_count == 1) ? 21 : 20;
        _loadVideos();
      }
    }
  }

  Future<void> _checkNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('No internet connection available');
    } else {
      _loadVideos();
    }
  }

  Future<void> _loadVideos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';

    var res = await getvideolist(
      userId: prefs.getString('user_id') ?? '',
      userToken: prefs.getString('userToken') ?? '',
      offset: _offset.toString(),
      limit: _count.toString(),
      device: device,
    );

    if (res['status'] == 1 && res['result'] != null) {
      List<dynamic> videos = res['result'];
      for (var video in videos) {
        _videoList.add(video['videoendUrl']);
        _videoContentList.add(video['videoTitle']);
      }

      _videoList = _videoList.reversed.toList();
      _videoContentList = _videoContentList.reversed.toList();

      setState(() {
        _isLoading = true;
      });
    } else {
      showCustomToast(res['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: CustomeApp('Videos'),
      body: _isLoading
          ? _videoList.isNotEmpty
              ? ListView.builder(
                  controller: _scrollerController,
                  itemCount: _videoList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(13.05)),
                          color: Colors.white,
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(13.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              YoutubeViewer(_videoList[index]),
                              Text(
                                _videoContentList[index],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(child: Text("No videos available"))
          : VideoShimmerLoader(width: 175, height: 300),
    );
  }
}

class YoutubeViewer extends StatefulWidget {
  final String videoID;

  const YoutubeViewer(this.videoID);

  @override
  _YoutubeViewerState createState() => _YoutubeViewerState();
}

class _YoutubeViewerState extends State<YoutubeViewer>
    with AutomaticKeepAliveClientMixin {
  late final YoutubePlayerController _controller;
  bool _showOverlay = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
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
    _controller.close();
    super.dispose();
  }

  Future<void> _launchYoutube() async {
    final url = 'https://www.youtube.com/watch?v=${widget.videoID}';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
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
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
              if (_showOverlay)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showOverlay = false;
                      });
                      _controller.playVideo();
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
