// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names, avoid_print, camel_case_types, must_be_immutable, unnecessary_null_comparison, use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:Plastic4trade/model/Get_comment.dart';
import 'dart:io' as io;
import 'package:Plastic4trade/utill/constant.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_interface.dart';
import 'package:Plastic4trade/model/Get_comment.dart' as comment;

class Review extends StatefulWidget {
  String profileid;

  Review(this.profileid, {Key? key}) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  int comment_count = 0;
  String? avg;
  String? av;
  int offset = 0;
  bool? isload;
  int isUserCommented = 0;
  String tokenUserId = '';
  var jsonArray;
  Get_comment getcomment = Get_comment();
  List<comment.Data>? resultList;
  List<comment.Subcomment> subcomment = [];
  List<comment.Data> commentlist_data = [];
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? assignedName;
  int? rate;
  bool gender = false;
  PickedFile? _imagefiles1;
  io.File? file1;
  final ImagePicker _picker = ImagePicker();
  final FocusNode _commentFocusNode = FocusNode();
  final TextEditingController _comment = TextEditingController();
  bool _isloading1 = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
    });
    checknetowork();
  }

  @override
  void dispose() {
    _comment.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("isUserCommented:-${isUserCommented}");
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, "${commentlist_data.length}");
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          elevation: 0,
          title: const Text('Reviews',
              softWrap: false,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: 'Metropolis',
              )),
          leading: InkWell(
            onTap: () {
              setState(() {
                Navigator.pop(context, "${commentlist_data.length}");
              });
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        body: isload == true
            ? Column(
                children: [
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 5.0),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 230,
                              child: RatingBar.builder(
                                ignoreGestures: true,
                                initialRating: double.parse(avg ?? '0.0'),
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                tapOnlyMode: false,
                                itemCount: 5,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: AppColors.orange,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                            ),
                            Text(
                              '${avg ?? "0"}/5',
                              style: const TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-SemiBold.otf'),
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '$comment_count Reviews',
                              style: const TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-SemiBold.otf'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: notificationsetting()),
                ],
              )
            : Center(
                child: CustomLottieContainer(
                  child: Lottie.asset(
                    'assets/loading_animation.json',
                  ),
                ),
              ),
        bottomNavigationBar: isUserCommented == 1
            ? const SizedBox()
            : Container(
                margin: const EdgeInsets.only(left: 10),
                child: SingleChildScrollView(
                  child: AnimatedPadding(
                    padding: MediaQuery.of(context).viewInsets,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.decelerate,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: 230,
                              child: RatingBar.builder(
                                initialRating: 0,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                tapOnlyMode: false,
                                itemCount: 5,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: AppColors.orange,
                                ),
                                onRatingUpdate: (rating) {
                                  rate = rating.toInt();
                                  print(rating.toInt());
                                },
                              ),
                            )),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: TextFormField(
                              controller: _comment,
                              focusNode: _commentFocusNode,
                              keyboardType: TextInputType.multiline,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              ),
                              minLines: 1,
                              maxLines: null,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: "Write Your Feedback Here",
                                labelStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                border: InputBorder.none,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                suffixIcon: GestureDetector(
                                  child: commentlist_data.isNotEmpty &&
                                          commentlist_data[0].commentImageUrl !=
                                              null &&
                                          commentlist_data[0].commentImageUrl !=
                                              'null' &&
                                          commentlist_data[0]
                                              .commentImageUrl!
                                              .isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: commentlist_data[0]
                                              .commentImageUrl
                                              .toString(),
                                          fit: BoxFit.cover,
                                          width: 100.0,
                                          height: 100.0,
                                        )
                                      : file1 != null && file1!.path.isNotEmpty
                                          ? ClipOval(
                                              child: Image.file(
                                                file1!,
                                                height: 30,
                                                width: 30,
                                                fit: BoxFit.fill,
                                              ),
                                            )
                                          : ClipOval(
                                              child: Image.asset(
                                                'assets/addphoto1.png',
                                                height: 30,
                                                width: 30,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                  onTap: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.white,
                                      context: context,
                                      builder: (context) => bottomsheet1(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomButton(
                            buttonText: 'Publish',
                            onPressed: () async {
                              setState(() {
                                if (rate != null) {
                                  add_Review();
                                } else {
                                  showCustomToast('Please Select Rating');
                                }
                              });
                            },
                            isLoading: _isloading1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget bottomsheet1() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile Photo",
            style: TextStyle(fontSize: 18.0),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                  onPressed: () {
                    takephoto1(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera, color: AppColors.primaryColor),
                  label: const Text(
                    'Camera',
                    style: TextStyle(color: AppColors.primaryColor),
                  )),
              TextButton.icon(
                  onPressed: () {
                    takephoto1(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image, color: AppColors.primaryColor),
                  label: const Text(
                    'Gallary',
                    style: TextStyle(color: AppColors.primaryColor),
                  )),
            ],
          )
        ],
      ),
    );
  }

  void takephoto1(ImageSource imageSource) async {
    // ignore: deprecated_member_use
    final pickedfile = await _picker.getImage(source: imageSource);

    _imagefiles1 = pickedfile!;
    file1 = await _cropImage1(imagefile: io.File(_imagefiles1!.path));
    constanst.imagesList.add(file1!);
    Navigator.of(context).pop();
  }

  Future<io.File?> _cropImage1({required io.File imagefile}) async {
    if (imagefile != null) {
      final croppedFile = await ImageCropper().cropImage(
          sourcePath: imagefile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.white,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
          ]);
      if (croppedFile != null) {
        setState(() {});
        return io.File(croppedFile.path);
      }
    } else {
      return null;
    }
    return null;
  }

  add_Review() async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await addReview(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.profileid.toString(),
      rate.toString(),
      _comment.text.toString(),
      file1,
      device,
    );
    setState(() {
      _isloading1 = false;
    });
    print(res);

    if (res['status'] == 1) {
      if (mounted) {
        setState(() {
          showCustomToast('Review submitted successfully!');
          Navigator.pop(context);
        });
      }
    } else {
      showCustomToast(res['message']);
    }
  }

  Widget notificationsetting() {
    return getcomment != null &&
            getcomment.data != null &&
            getcomment.data!.isNotEmpty &&
            commentlist_data.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: commentlist_data.length,
            itemBuilder: (context, index) {
              print("commentlist_data:-${getcomment.data![index].toJson()}");
              Data? record = getcomment.data![index];
              DateTime date1 = DateFormat("yyyy-MM-dd").parse(formattedDate);
              DateTime date2 = DateFormat("yyyy-MM-dd")
                  .parse(record.commentDatetime.toString());

              Duration difference = date1.difference(date2);

              String day;
              int days = difference.inDays;
              int months = difference.inDays ~/ 30;
              int years = difference.inDays ~/ 365;

              if (days <= 30 && days != 0) {
                day = '$days Days ago';
              } else if (months >= 1) {
                day = '$months Months ago';
              } else if (years >= 1) {
                day = '$years Years ago';
              } else {
                day = 'Today';
              }

              return Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 10, top: 10, bottom: 10),
                  child: record.userId == tokenUserId
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SlidableAutoCloseBehavior(
                            child: Slidable(
                              direction: Axis.horizontal,
                              child: GestureDetector(
                                onTap: () {
                                  if (record.userId != null &&
                                      record.userId!.isNotEmpty) {
                                    print(
                                        'User ID for navigate: ${record.userId}');

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => bussinessprofile(
                                          int.parse(record.userId!.toString()),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  width: 50.0,
                                                  height: 50.0,
                                                  margin: const EdgeInsets.only(
                                                      left: 10, right: 5),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff7c94b6),
                                                    image: DecorationImage(
                                                      image: NetworkImage(record
                                                          .userImageUrl
                                                          .toString()),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                50.0)),
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .fromLTRB(
                                                            5.0, 10.0, 0, 0),
                                                        child: Text(
                                                          record.username
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontSize: 14.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-SemiBold.otf'),
                                                        )),
                                                    RatingBar.builder(
                                                      itemSize: 20,
                                                      ignoreGestures: true,
                                                      initialRating:
                                                          double.parse(record
                                                              .rating
                                                              .toString()),
                                                      minRating: 1,
                                                      direction:
                                                          Axis.horizontal,
                                                      allowHalfRating: true,
                                                      tapOnlyMode: false,
                                                      itemCount: 5,
                                                      itemPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 2.0),
                                                      itemBuilder:
                                                          (context, _) =>
                                                              const Icon(
                                                        Icons.star,
                                                        color: AppColors.orange,
                                                      ),
                                                      onRatingUpdate: (rating) {
                                                        print(rating);
                                                      },
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10, right: 20),
                                                  child: Text(day,
                                                      style: const TextStyle(
                                                              fontSize: 12.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf')
                                                          .copyWith(
                                                              color: Colors
                                                                  .black38,
                                                              fontSize: 10)),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      iconSize: 20,
                                                      onPressed: () {
                                                        Edit_Review(
                                                            context,
                                                            widget.profileid,
                                                            record.id
                                                                .toString(),
                                                            record.rating
                                                                .toString(),
                                                            record.comment
                                                                .toString(),
                                                            record
                                                                .commentImageUrl
                                                                .toString());
                                                      },
                                                      icon: Image.asset(
                                                          'assets/edit.png',
                                                          color: AppColors
                                                              .primaryColor,
                                                          width: 20,
                                                          height: 20),
                                                    ),
                                                    IconButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      iconSize: 20,
                                                      onPressed: () {
                                                        setState(() {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return CommanDialog(
                                                                  title:
                                                                      "Review",
                                                                  content:
                                                                      "Do you want to Delete Review",
                                                                  onPressed:
                                                                      () {
                                                                    revove_Reply(record
                                                                            .id
                                                                            .toString())
                                                                        .then(
                                                                            (value) {
                                                                      setState(
                                                                          () {
                                                                        if (value !=
                                                                            null) {
                                                                          commentlist_data
                                                                              .clear();
                                                                          avg =
                                                                              '0.0';
                                                                          comment_count =
                                                                              0;
                                                                          isUserCommented =
                                                                              0;
                                                                          isload =
                                                                              false;
                                                                          get_reviewlist();
                                                                        }
                                                                      });
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                );
                                                              });
                                                        });
                                                      },
                                                      icon: Image.asset(
                                                          'assets/delete.png',
                                                          color: const Color(
                                                              0xFFEE574D),
                                                          width: 20,
                                                          height: 20),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ]),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          record.commentImageUrl != null
                                              ? InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return Dialog(
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          child: Stack(
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height,
                                                                child:
                                                                    InteractiveViewer(
                                                                  child: Image
                                                                      .network(
                                                                    '${record.commentImageUrl.toString()}?${DateTime.now().millisecondsSinceEpoch}',
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 20,
                                                                right: 20,
                                                                child:
                                                                    IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      color: Colors
                                                                          .black),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                      child: Image(
                                                        image: NetworkImage(
                                                            record
                                                                .commentImageUrl
                                                                .toString()),
                                                        fit: BoxFit.cover,
                                                        height: 90,
                                                        width: 100,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(
                                                  width: 20,
                                                ),
                                          Flexible(
                                            child: Container(
                                                alignment: Alignment.topLeft,
                                                padding: const EdgeInsets.only(
                                                    right: 20),
                                                child: Text(
                                                  record.comment.toString() !=
                                                          'null'
                                                      ? record.comment
                                                          .toString()
                                                      : '',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf',
                                                      fontSize: 12,
                                                      color: Colors.black),
                                                  textAlign: TextAlign.justify,
                                                )),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          EditItem(context, widget.profileid,
                                              record.id.toString());
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8, right: 10),
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              'Reply',
                                              style: const TextStyle(
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: record.subcomment!.isEmpty
                                            ? false
                                            : true,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount:
                                              record.subcomment?.length ?? 0,
                                          itemBuilder: (context, colorIndex) {
                                            Subcomment? color =
                                                record.subcomment?[colorIndex];
                                            return GestureDetector(
                                              onTap: () {
                                                if (color.userId != null &&
                                                    color.userId!.isNotEmpty) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            bussinessprofile(
                                                                int.parse(
                                                          color.userId
                                                              .toString(),
                                                        )),
                                                      ));
                                                }
                                              },
                                              child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 30.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                            10.0,
                                                            5.0,
                                                            0,
                                                            5.0,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              color!.userImageUrl !=
                                                                      null
                                                                  ? Container(
                                                                      width:
                                                                          35.0,
                                                                      height:
                                                                          35.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: const Color(
                                                                            0xff7c94b6),
                                                                        image:
                                                                            DecorationImage(
                                                                          image: NetworkImage(color
                                                                              .userImageUrl
                                                                              .toString()),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                        borderRadius: const BorderRadius
                                                                            .all(
                                                                            Radius.circular(35.0)),
                                                                      ),
                                                                    )
                                                                  : Container(
                                                                      width: 80,
                                                                    ),
                                                              Container(
                                                                  width: 200,
                                                                  margin: const EdgeInsets
                                                                      .fromLTRB(
                                                                      5.0,
                                                                      10.0,
                                                                      0,
                                                                      0),
                                                                  child: Text(
                                                                    color.user !=
                                                                                null &&
                                                                            color.user!.username !=
                                                                                null
                                                                        ? color
                                                                            .user!
                                                                            .username
                                                                            .toString()
                                                                        : "Unknow",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14.0,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Colors
                                                                            .black,
                                                                        fontFamily:
                                                                            'assets/fonst/Metropolis-SemiBold.otf'),
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            margin: color
                                                                        .userImageUrl !=
                                                                    null
                                                                ? const EdgeInsets
                                                                    .fromLTRB(
                                                                    50.0,
                                                                    0.0,
                                                                    5.0,
                                                                    10)
                                                                : EdgeInsets
                                                                    .zero,
                                                            child: Text(
                                                              color.comment
                                                                          .toString() !=
                                                                      'null'
                                                                  ? color
                                                                      .comment
                                                                      .toString()
                                                                  : '',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-Black.otf',
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 3,
                                                            )),
                                                      ],
                                                    ),
                                                  )),
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SlidableAutoCloseBehavior(
                            child: Slidable(
                              direction: Axis.horizontal,
                              child: GestureDetector(
                                onTap: () {
                                  if (record.userId != null &&
                                      record.userId!.isNotEmpty) {
                                    // Print the userId
                                    print(
                                        'User ID for navigate: ${record.userId}');

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => bussinessprofile(
                                          int.parse(record.userId!.toString()),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                alignment: Alignment.topCenter,
                                                width: 50.0,
                                                height: 50.0,
                                                margin: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 5,
                                                    top: 10),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff7c94b6),
                                                  image: record.userImageUrl !=
                                                          null
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                              record
                                                                  .userImageUrl!),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null, // Null check added here
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              50.0)),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .fromLTRB(
                                                        5.0, 10.0, 0, 0),
                                                    child: Text(
                                                      record.username != null
                                                          ? record.username
                                                              .toString()
                                                          : '', // Null check added here
                                                      style: const TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                        fontFamily:
                                                            'assets/fonst/Metropolis-SemiBold.otf',
                                                      ),
                                                    ),
                                                  ),
                                                  RatingBar.builder(
                                                    itemSize: 20,
                                                    ignoreGestures: true,
                                                    initialRating: record
                                                                .rating !=
                                                            null
                                                        ? double.parse(record
                                                            .rating
                                                            .toString())
                                                        : 0, // Null check added here
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    tapOnlyMode: false,
                                                    itemCount: 5,
                                                    itemPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 2.0),
                                                    itemBuilder: (context, _) =>
                                                        const Icon(
                                                      Icons.star,
                                                      color: AppColors.orange,
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      print(rating);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20),
                                            child: Text(
                                              day,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf',
                                              ).copyWith(
                                                color: Colors.black38,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          record.commentImageUrl != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Image(
                                                    image: NetworkImage(record
                                                        .commentImageUrl!),
                                                    fit: BoxFit.cover,
                                                    height: 90,
                                                    width: 100,
                                                  ),
                                                )
                                              : const SizedBox(
                                                  width: 20,
                                                ),
                                          Flexible(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              alignment: Alignment.topLeft,
                                              margin: record.commentImageUrl !=
                                                      null
                                                  ? const EdgeInsets.fromLTRB(
                                                      10.0, 0.0, 0.0, 0)
                                                  : EdgeInsets.zero,
                                              child: Text(
                                                record.comment != null
                                                    ? record.comment.toString()
                                                    : '', // Null check added here
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-Black.otf',
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          EditItem(context, widget.profileid,
                                              record.id.toString());
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8, right: 10),
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              'Reply',
                                              style: const TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-Black.otf',
                                              ).copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: record.subcomment != null &&
                                            record.subcomment!
                                                .isNotEmpty, // Null check added here
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount:
                                              record.subcomment?.length ?? 0,
                                          itemBuilder: (context, colorIndex) {
                                            Subcomment? color =
                                                record.subcomment?[colorIndex];
                                            return GestureDetector(
                                              onTap: () {
                                                if (color != null &&
                                                    color.userId != null &&
                                                    color.userId!.isNotEmpty) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          bussinessprofile(
                                                              int.parse(color
                                                                  .userId!
                                                                  .toString())),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 30.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .fromLTRB(
                                                          10.0, 5.0, 0, 5.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          color!.userImageUrl !=
                                                                  null
                                                              ? Container(
                                                                  width: 35.0,
                                                                  height: 35.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xff7c94b6),
                                                                    image:
                                                                        DecorationImage(
                                                                      image: NetworkImage(
                                                                          color
                                                                              .userImageUrl!),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(35.0)),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  width: 80,
                                                                ),
                                                          Container(
                                                            width: 200,
                                                            margin:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    5.0,
                                                                    10.0,
                                                                    0,
                                                                    0),
                                                            child: Text(
                                                              color.user !=
                                                                          null &&
                                                                      color.user!
                                                                              .username !=
                                                                          null
                                                                  ? color.user!
                                                                      .username
                                                                      .toString()
                                                                  : '', // Null check added here
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'assets/fonst/Metropolis-SemiBold.otf',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      margin:
                                                          color.userImageUrl !=
                                                                  null
                                                              ? const EdgeInsets
                                                                  .fromLTRB(
                                                                  50.0,
                                                                  0.0,
                                                                  5.0,
                                                                  10)
                                                              : EdgeInsets.zero,
                                                      child: Text(
                                                        color.comment != null
                                                            ? color.comment
                                                                .toString()
                                                            : '', // Null check added here
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-Black.otf',
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        ),
                                                        maxLines: 3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ));
            })
        : const Text('Not Reviews Found');
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
      )),
      builder: (context) => YourWidget(widget.profileid),
    ).then((value) {
      setState(() {
        get_reviewlist();
        isload = false;
        commentlist_data.clear();
        subcomment.clear();
        subcomment.clear();
      });
    });
  }

  Edit_Review(BuildContext context, String profileid, String comentId,
      String rating, String comment, String commentUrl) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
      )),
      builder: (context) =>
          EditReview(widget.profileid, comentId, rating, comment, commentUrl),
    ).then((value) {
      commentlist_data.clear();
      subcomment.clear();
      subcomment.clear();
      isload = false;
      get_reviewlist();
    });
  }

  EditItem(BuildContext context, String profileid, String comentId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
      )),
      builder: (context) => EditReply(profileid, comentId),
    ).then((value) {
      commentlist_data.clear();
      subcomment.clear();
      subcomment.clear();
      isload = false;
      get_reviewlist();
    });
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      //isprofile=true;
    } else {
      get_reviewlist();

      // get_data();
    }
  }

  revove_Reply(String commentId) async {
    var res = await deletemyreview(commentId);
    print(res);
    if (res['status'] == 1) {
      showCustomToast(res['message']);
    } else {
      showCustomToast(res['message']);
    }
    return res;
  }

  get_reviewlist() async {
    getcomment = Get_comment();
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    String userId = pref.getString('user_id').toString();
    String userToken = pref.getString('userToken').toString();
    var res = await Getcomment(
        profileid: widget.profileid,
        offset: offset.toString(),
        limit: '10',
        userId: userId,
        userToken: userToken,
        device: device);
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      tokenUserId = userId;
      getcomment = Get_comment.fromJson(res);
      resultList = getcomment.data;
      print("getcomment:-${getcomment.toJson()}");
      comment_count = res['comment_count'];
      isUserCommented = res['is_user_commented'];
      avg = res['comment_avg'] ?? "";

      print("COMMENT COUNT == $comment_count");

      print(avg);
      print(av);

      if (res['data'] != null) {
        jsonArray = res['data'];

        for (var data in jsonArray) {
          comment.Data record = comment.Data(
            username: data['username'],
            userId: data['user_id'],
            userImageUrl: data['user_image_url'],
            comment: data['comment'],
            rating: data['rating'],
            commentImageUrl: data['comment_image_url'],
          );
          commentlist_data.add(record);
        }

        isload = true;
        print(commentlist_data);
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      isload = true;
      showCustomToast(res['message']);
    }
    setState(() {});
    return jsonArray;
  }
}

class YourWidget extends StatefulWidget {
  String? profileid;

  YourWidget(this.profileid, {Key? key}) : super(key: key);

  @override
  State<YourWidget> createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  String? assignedName;
  int? rate;
  bool gender = false;
  PickedFile? _imagefiles1;
  io.File? file1;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _comment = TextEditingController();
  bool _isloading1 = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: SingleChildScrollView(
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          child: Column(
            children: [
              const SizedBox(height: 5),
              Image.asset(
                'assets/hori_line.png',
                width: 150,
                height: 5,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 230,
                    child: RatingBar.builder(
                      initialRating: 0,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      tapOnlyMode: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: AppColors.orange,
                      ),
                      onRatingUpdate: (rating) {
                        // int a=int.parse(rating.toString());
                        rate = rating.toInt();
                        print(rating.toInt());
                      },
                    ),
                  )),
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                    child: file1 != null && file1!.path != null
                        ? Image.file(file1!, height: 100, width: 100)
                        : Image.asset('assets/addphoto1.png',
                            height: 100, width: 100),
                    onTap: () {
                      showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          builder: (context) => bottomsheet1());
                    }),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: SizedBox(
                    height: 120,
                    child: TextFormField(
                      controller: _comment,
                      keyboardType: TextInputType.multiline,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: "Write Your Feedback Here",
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  buttonText: 'Publish',
                  onPressed: () async {
                    setState(() {
                      if (rate != null) {
                        add_Review();
                      } else {
                        showCustomToast('Please Select Rating');
                      }
                    });
                  },
                  isLoading: _isloading1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomsheet1() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile Photo",
            style: TextStyle(fontSize: 18.0),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                  onPressed: () {
                    takephoto1(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera, color: AppColors.primaryColor),
                  label: const Text(
                    'Camera',
                    style: TextStyle(color: AppColors.primaryColor),
                  )),
              TextButton.icon(
                  onPressed: () {
                    takephoto1(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image, color: AppColors.primaryColor),
                  label: const Text(
                    'Gallary',
                    style: TextStyle(color: AppColors.primaryColor),
                  )),
            ],
          )
        ],
      ),
    );
  }

  void takephoto1(ImageSource imageSource) async {
    // ignore: deprecated_member_use
    final pickedfile = await _picker.getImage(source: imageSource);

    _imagefiles1 = pickedfile!;
    file1 = await _cropImage1(imagefile: io.File(_imagefiles1!.path));
    constanst.imagesList.add(file1!);
    Navigator.of(context).pop();
  }

  Future<io.File?> _cropImage1({required io.File imagefile}) async {
    if (imagefile != null) {
      final croppedFile = await ImageCropper().cropImage(
          sourcePath: imagefile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.white,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
          ]);
      if (croppedFile != null) {
        setState(() {});
        return io.File(croppedFile.path);
      }
    } else {
      return null;
    }
    return null;
  }

  add_Review() async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await addReview(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.profileid.toString(),
      rate.toString(),
      _comment.text.toString(),
      file1,
      device,
    );
    setState(() {
      _isloading1 = false;
    });
    print(res);

    if (res['status'] == 1) {
      if (mounted) {
        setState(() {
          showCustomToast('Review submitted successfully!');
          Navigator.pop(context);
        });
      }
    } else {
      showCustomToast(res['message']);
    }
  }
}

class EditReview extends StatefulWidget {
  String? profileid, comment, comment_url;
  String? comment_id, rating;

  EditReview(this.profileid, this.comment_id, this.rating, this.comment,
      this.comment_url,
      {Key? key})
      : super(key: key);

  @override
  State<EditReview> createState() => _EditReviewState();
}

class _EditReviewState extends State<EditReview> {
  String? assignedName;
  int? rate = 0;
  bool gender = false;
  io.File? file1;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _comment = TextEditingController();
  bool _isloading1 = false;
  File? _imagefiles;

  @override
  void initState() {
    super.initState();
    if (widget.comment != null &&
        widget.comment != 'null' &&
        widget.comment!.isNotEmpty) {
      _comment.text = widget.comment.toString();
    }
    if (widget.rating != null &&
        widget.rating != 'null' &&
        widget.rating!.isNotEmpty) {
      rate = int.parse(widget.rating.toString());
    } else {
      rate = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("widget.comment_url:-${widget.comment_url}");
    print("widget.comment_url:-${_comment.text}");
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        child: SingleChildScrollView(
          child: AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 5),
                Image.asset(
                  'assets/hori_line.png',
                  width: 150,
                  height: 5,
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 230,
                      child: RatingBar.builder(
                        initialRating: double.parse(rate.toString()),
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        tapOnlyMode: false,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: AppColors.orange,
                        ),
                        onRatingUpdate: (rating) {
                          rate = rating.toInt();
                          print(rating.toInt());
                        },
                      ),
                    )),
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    child: widget.comment_url != null &&
                            widget.comment_url!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.comment_url.toString(),
                            fit: BoxFit.cover,
                            width: 100.0,
                            height: 100.0,
                          )
                        : file1 != null
                            ? Image.file(
                                file1!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print("Error loading local file: $error");
                                  return Image.asset(
                                    'assets/addphoto1.png',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/addphoto1.png',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.white,
                        context: context,
                        builder: (context) => bottomsheet1(),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      height: 120,
                      child: TextFormField(
                        controller: _comment,
                        keyboardType: TextInputType.multiline,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: "Write Your Feedback Here",
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    buttonText: 'Publish',
                    onPressed: () async {
                      setState(() {
                        if (_comment.text.isNotEmpty) {
                          edit_Review();
                        } else {
                          showCustomToast('Please Fill the Feedback here.');
                        }
                      });
                    },
                    isLoading: _isloading1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomsheet1() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile Photo",
            style: TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                icon: const Icon(Icons.camera, color: Colors.blue),
                label: const Text(
                  'Camera',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                icon: const Icon(Icons.image, color: Colors.blue),
                label: const Text(
                  'Gallery',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> takePhoto(ImageSource imageSource) async {
    try {
      final pickedFile =
          await _picker.pickImage(source: imageSource, imageQuality: 100);
      if (pickedFile == null) {
        Fluttertoast.showToast(msg: "No image selected.");
        print("User canceled image picking.");
        return;
      }

      io.File imageFile = io.File(pickedFile.path);

      int fileSizeInBytes = imageFile.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024;
      print("Original image size: $fileSizeInKB KB");

      if (fileSizeInKB >= 5000) {
        Fluttertoast.showToast(msg: "Please select an image below 5 MB.");
        Navigator.pop(context);
        return;
      }

      io.File? processedFile = await _cropImage1(imageFile);
      if (processedFile == null) {
        Fluttertoast.showToast(msg: "Failed to crop image.");
        print("Cropping failed or was canceled.");
        return;
      }

      double processedFileSizeInKB = processedFile.lengthSync() / 1024;
      print("Processed image size: $processedFileSizeInKB KB");

      setState(() {
        if (_imagefiles != null) {
          FileImage(_imagefiles!).evict();
        }
        _imagefiles = processedFile;
      });

      print("Image successfully processed.");
      Navigator.pop(context);
    } catch (e) {
      print("Error during photo processing: $e");
      Fluttertoast.showToast(msg: "An error occurred. Please try again.");
    }
  }

  Future<io.File?> _cropImage1(io.File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile == null) {
        print("Cropping canceled by user.");
        return null;
      }

      print("Cropped file path: ${croppedFile.path}");
      return io.File(croppedFile.path);
    } catch (e) {
      print("Error during cropping: $e");
      return null;
    }
  }

  edit_Review() async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    var res = await editReview(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.comment_id.toString(),
      rate.toString(),
      _comment.text.toString(),
      file1,
    );

    setState(() {
      _isloading1 = false;
    });

    print(res);
    if (res['status'] == 1) {
      showCustomToast('Review submitted successfully!');

      Navigator.pop(context);
    } else {
      showCustomToast(res['message']);
    }
  }
}

class EditReply extends StatefulWidget {
  String? profileid;
  String? commentid;

  EditReply(this.profileid, this.commentid, {Key? key}) : super(key: key);

  @override
  State<EditReply> createState() => _EditWidgetState();
}

class _EditWidgetState extends State<EditReply> {
  String? assignedName;
  int? rate;
  bool gender = false;
  io.File? file1;
  final TextEditingController _comment = TextEditingController();
  bool _isloading1 = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        child: SingleChildScrollView(
          child: AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 5),
                Image.asset(
                  'assets/hori_line.png',
                  width: 150,
                  height: 5,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      height: 120,
                      child: TextFormField(
                        controller: _comment,
                        keyboardType: TextInputType.multiline,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: "Write Your Feedback Here",
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    buttonText: 'Publish',
                    onPressed: () async {
                      setState(() {
                        if (_comment.text.isNotEmpty) {
                          add_Reply();
                        } else {
                          showCustomToast('Please Fill the Feedback here.');
                        }
                      });
                    },
                    isLoading: _isloading1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  add_Reply() async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();

    var res = await addReply(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      widget.commentid.toString(),
      widget.profileid.toString(),
      _comment.text.toString(),
    );
    setState(() {
      _isloading1 = false;
    });
    print(res);
    if (res['status'] == 1) {
      showCustomToast(res['message']);

      Navigator.pop(context);
    } else {
      showCustomToast(res['message']);
    }
  }
}
