import 'dart:convert';
import 'package:Plastic4trade/common/commom_dialog_reupload.dart';
import 'package:Plastic4trade/screen/buisness_profile/phisycal_business_directory.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:Plastic4trade/screen/buisness_profile/Bussinessverification.dart';
import 'dart:io' as io;
import 'package:Plastic4trade/screen/buisness_profile/EditBussinessProfile.dart';
import 'package:Plastic4trade/screen/login/Logindetail.dart';
import 'package:Plastic4trade/screen/socialmedia.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Plastic4trade/utill/constant.dart';
import '../../api/api_interface.dart';
import '../../constroller/GetBussinessTypeController.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io' show GZipCodec, Platform;
import '../../widget/MainScreen.dart';

class Bussinessinfo extends StatefulWidget {
  const Bussinessinfo({Key? key}) : super(key: key);

  @override
  State<Bussinessinfo> createState() => _BussinessinfoState();
}

class _BussinessinfoState extends State<Bussinessinfo> {
  PickedFile? _imagefiles;
  final ImagePicker _picker = ImagePicker();
  io.File? file;
  String? path;
  bool isprofile = false;

  @override
  void initState() {
    super.initState();
    checknetowork();
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      isprofile = true;
    } else {
      getBussinessProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return initwidget();
  }

  Future<bool> _onbackpress(BuildContext context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MainScreen(4)));

    return Future.value(true);
  }

  Widget initwidget() {
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
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColors.greyBackground,
            appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
              title: const Text('Profile Settings',
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Metropolis',
                  )),
              leading: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MainScreen(4)));
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
            ),
            body: isprofile
                ? SingleChildScrollView(
                    child: Container(
                        child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(50.0),
                          child: SafeArea(
                              top: true,
                              left: true,
                              right: true,
                              maintainBottomViewPadding: true,
                              child: Column(
                                children: [
                                  path != null
                                      ? imageprofile(context)
                                      : imageprofile1(context),
                                ],
                              )),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(13),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditBussinessProfile()));
                                },
                                child: Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(13.05),
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
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const EditBussinessProfile()));
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                height: 60,
                                                child: Center(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                      Align(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20.0),
                                                          child: Text(
                                                              'Business Info',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets/fonst/Metropolis-Black.otf')),
                                                        ),
                                                      ),
                                                    ]))),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditBussinessProfile()));
                                              },
                                              child: Image.asset(
                                                'assets/forward.png',
                                                height: 18,
                                                width: 50,
                                              ),
                                            ),
                                          ])),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PhisycalBusinessDirectory()));
                                },
                                child: Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(13.05),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(
                                            height: 60,
                                            child: Center(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                  Align(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20.0),
                                                      child: Text(
                                                          'Physical Business Directory',
                                                          style: TextStyle(
                                                              fontSize: 17.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'assets\fonst\Metropolis-Black.otf')),
                                                    ),
                                                  ),
                                                ]))),
                                        Image.asset(
                                          'assets/forward.png',
                                          height: 18,
                                          width: 50,
                                        )
                                      ]),
                                ),
                              ),
                              10.sbh,
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Bussinessverification()));
                                },
                                child: Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(13.05),
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
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Bussinessverification()));
                                    },
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(
                                              height: 60,
                                              child: Center(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                    Align(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20.0),
                                                        child: Text(
                                                            'Business Verification',
                                                            style: TextStyle(
                                                                fontSize: 17.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'assets\fonst\Metropolis-Black.otf')),
                                                      ),
                                                    ),
                                                  ]))),
                                          Image.asset(
                                            'assets/forward.png',
                                            height: 18,
                                            width: 50,
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const socialmedia()));
                                },
                                child: Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(13.05),
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
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    socialmedia()));
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(
                                                height: 60,
                                                child: Center(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                      Align(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20.0),
                                                          child: Text(
                                                              'Social Media URL',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'assets\fonst\Metropolis-Black.otf')),
                                                        ),
                                                      ),
                                                    ]))),
                                            Image.asset(
                                              'assets/forward.png',
                                              height: 18,
                                              width: 50,
                                            )
                                          ])),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginDetail()));
                                },
                                child: Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(13.05),
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
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginDetail()));
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: 55,
                                              child: Center(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Align(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20.0),
                                                        child: Text(
                                                            'Login Details',
                                                            style: TextStyle(
                                                                fontSize: 17.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'assets\fonst\Metropolis-Black.otf')),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Image.asset(
                                              'assets/forward.png',
                                              height: 18,
                                              width: 50,
                                            )
                                          ])),
                                ),
                              ),
                            ])),
                      ],
                    )),
                  )
                : Center(
                    child: CustomLottieContainer(
                    child: Lottie.asset(
                      'assets/loading_animation.json',
                    ),
                  ))));
  }

  Widget imageprofile(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => bottomsheet(),
          );
        },
        child: Stack(
          children: <Widget>[
            CircleAvatar(
              radius: 100.0,
              backgroundImage: file != null
                  ? FileImage(file!)
                  : NetworkImage(
                      '${path!}?${DateTime.now().millisecondsSinceEpoch}',
                    ) as ImageProvider,
              backgroundColor: Color.fromARGB(255, 240, 238, 238),
            ),
            Positioned(
              bottom: 3.0,
              right: 5.0,
              child: Container(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => bottomsheet(),
                    );
                  },
                  child: ImageIcon(
                    AssetImage('assets/Vector (1).png'),
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageprofile1(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 60.0,
            backgroundImage: _imagefiles != null
                ? FileImage(file!)
                : AssetImage('assets/Ellipse 1.png') as ImageProvider,
            backgroundColor: Color.fromARGB(255, 240, 238, 238),
          ),
          Positioned(
            bottom: 3.0,
            right: 5.0,
            child: Container(
                width: 40,
                height: 33,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primaryColor,
                  onPressed: () {},
                  child: ImageIcon(AssetImage('assets/Vector (1).png')),
                )),
          ),
        ],
      ),
    );
  }

  getBussinessProfile() async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String device = '';
      if (Platform.isAndroid) {
        device = 'android';
      } else if (Platform.isIOS) {
        device = 'ios';
      }

      print('Device Name: $device');
      print('User ID: ${_pref.getString('user_id')}');
      print('API Token: ${_pref.getString('userToken')}');

      var res = await getuser_Profile(
        _pref.getString('user_id').toString(),
        _pref.getString('userToken').toString(),
        device,
      );

      // Print the entire response
      print('Full Response: $res');

      // Check if the status is successful
      if (res['status'] == 1) {
        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(res)));

        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');

        var jsonarray = res['user'];

        print('User Image URL: ${jsonarray['image_url']}');
        path =
            jsonarray['image_url'] ?? 'assets/plastic4trade logo final 1 (4)';
        _pref.setString('userImage', path!).toString();
        constanst.image_url = _pref.getString('userImage').toString();

        isprofile = true;

        setState(() {});
      } else {
        print('Error Message: ${res['message']}');
        showCustomToast(res['message']);
      }
    } catch (error, stacktrace) {
      // Catch and print any error that occurs
      print('Error: $error');
      print('Stacktrace: $stacktrace');
    }
  }

  void get_data() async {
    GetBussinessTypeController bt = GetBussinessTypeController();
    constanst.bt_data = bt.getBussiness_Type();

    constanst.bt_data!.then((value) {
      for (var item in value) {
        constanst.btype_data.add(item);
      }
    });

    // setState(() {});
    print(constanst.btype_data);
  }

  Widget bottomsheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          Text(
            "Choose Profile Photo",
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                  onPressed: () {
                    takephoto(ImageSource.camera);
                  },
                  icon: Icon(Icons.camera, color: AppColors.primaryColor),
                  label: Text(
                    'Camera',
                    style: TextStyle(color: AppColors.primaryColor),
                  )),
              TextButton.icon(
                  onPressed: () {
                    takephoto(ImageSource.gallery);
                  },
                  icon: Icon(Icons.image, color: AppColors.primaryColor),
                  label: Text(
                    'Gallary',
                    style: TextStyle(color: AppColors.primaryColor),
                  )),
            ],
          )
        ],
      ),
    );
  }

  void takephoto(ImageSource imageSource) async {
    final pickedfile =
        // ignore: deprecated_member_use
        await _picker.getImage(source: imageSource, imageQuality: 100);
    io.File? imageFile = io.File(pickedfile!.path);

    // Check file size
    int fileSizeInBytes = imageFile.lengthSync();
    double fileSizeInKB = fileSizeInBytes / 1024;
    if (fileSizeInKB > 3000) {
      showCustomToast('Please select an image below 5 MB');
      return;
    }

    _imagefiles = pickedfile;
    file = await _cropImage(imagefile: io.File(_imagefiles!.path));

    var response = await noPromotionCheck(image: file);
    if (response != null) {
      int status = response['status'];

      if (status == 1) {
        print('Status 1: not show image');
        Navigator.of(context).pop();
        Saveimage();
        return;
      } else if (status == 2) {
        showCustomToast('Warning: Text detected in the image');
        Navigator.of(context).pop();
        Saveimage();
        return;
      } else if (status == 3) {
        Navigator.of(context).pop();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return CommomDialogReupload(
                title: "Upload Image",
                content:
                    "Not Allowed in Image: Business cards, phone number, email ID, and company name.",
                onPressed: () {
                  setState(() {
                    constanst.imagesList.remove(file);
                    file = null;
                  });
                  Navigator.of(context).pop();
                },
              );
            });
        return;
      }
    } else {
      showCustomToast('API response was null');
      return;
    }

    Navigator.of(context).pop();
  }

  Future<io.File?> _cropImage({required io.File imagefile}) async {
    if (_imagefiles != null) {
      final croppedFile = await ImageCropper().cropImage(
          sourcePath: _imagefiles!.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: AppColors.primaryColor,
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

  Saveimage() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    print(_pref.getString('user_id').toString());

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await saveProfile(
      _pref.getString('user_id').toString(),
      _pref.getString('userToken').toString(),
      file,
      device,
    );

    print(res);
    if (res['status'] == 1) {
      showCustomToast('Profile Update ');
      getBussinessProfile();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen(0)));
    } else {
      showCustomToast(res['message']);
    }
  }
}
