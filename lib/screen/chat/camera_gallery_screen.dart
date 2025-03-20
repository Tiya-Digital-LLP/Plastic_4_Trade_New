// New Screen for Camera and Gallery Tabs
// ignore_for_file: deprecated_member_use

import 'dart:io' as io;
import 'dart:io';

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/model/chatModel/chat_onTime_model.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CameraGalleryScreen extends StatefulWidget {
  String? user_id;
  String? chatId;
  CameraGalleryScreen({Key? key, this.chatId, this.user_id}) : super(key: key);

  @override
  State<CameraGalleryScreen> createState() => _CameraGalleryScreenState();
}

class _CameraGalleryScreenState extends State<CameraGalleryScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  io.File? file;
  late TabController _tabController;
  TextEditingController commentMessage = TextEditingController();
  bool isLoading = false;
  SendMessageRecord sendMessageRecord = SendMessageRecord();
  int lastChatsId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Call takephoto for the initial tab when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      takephoto(ImageSource.gallery); // Default to the first tab (Camera)
    });

    // Add a listener to handle tab changes when tapping on tabs
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Trigger takephoto based on the selected tab
        if (_tabController.index == 0) {
          takephoto(ImageSource.camera); // Camera tab selected
        } else if (_tabController.index == 1) {
          takephoto(ImageSource.gallery); // Gallery tab selected
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Option'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.camera), text: 'Camera'),
              Tab(icon: Icon(Icons.image), text: 'Gallery'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildCameraTab(),
            _buildGalleryTab(),
          ],
        ),
      ),
    );
  }

  // Camera Tab Content
  Widget _buildCameraTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        30.sbh,
        GestureDetector(
          onTap: () {
            takephoto(ImageSource.camera);
          },
          child: file != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.file(
                    file!,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.fill,
                  ),
                )
              : Image.asset('assets/addphoto1.png', height: 100, width: 100),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: TextField(
                        cursorHeight: 15,
                        controller: commentMessage,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        minLines: 1,
                        maxLines: null,
                        onChanged: (value) {
                          setState(() {
                            if (value.toString().isEmpty) {}
                          });
                        },
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: "Write your Comment here",
                          hintMaxLines: 1,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10),
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.61),
                            fontSize: 11,
                            fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 1, color: Color(0x49011042)),
                            borderRadius: BorderRadius.circular(41),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 1, color: Color(0x49011042)),
                            borderRadius: BorderRadius.circular(41),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 1, color: Color(0x49011042)),
                            borderRadius: BorderRadius.circular(41),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        fetchSendChat(
                          message: commentMessage.text,
                          imageFile: file,
                        ).then((res) {
                          setState(() {
                            commentMessage.clear();
                          });
                        });
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Gallery Tab Content
  Widget _buildGalleryTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        30.sbh,
        GestureDetector(
          onTap: () {
            takephoto(ImageSource.gallery);
          },
          child: file != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.file(
                    file!,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.fill,
                  ),
                )
              : Image.asset('assets/addphoto1.png', height: 100, width: 100),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: TextField(
                        cursorHeight: 15,
                        controller: commentMessage,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        minLines: 1,
                        maxLines: null,
                        onChanged: (value) {
                          setState(() {
                            if (value.toString().isEmpty) {}
                          });
                        },
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: "Write your Comment here",
                          hintMaxLines: 1,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10),
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.61),
                            fontSize: 11,
                            fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 1, color: Color(0x49011042)),
                            borderRadius: BorderRadius.circular(41),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 1, color: Color(0x49011042)),
                            borderRadius: BorderRadius.circular(41),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 1, color: Color(0x49011042)),
                            borderRadius: BorderRadius.circular(41),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        fetchSendChat(
                          message: commentMessage.text,
                          imageFile: file,
                        ).then((res) {
                          setState(() {
                            commentMessage.clear();
                          });
                        });
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void takephoto(ImageSource imageSource) async {
    final pickedfile =
        await _picker.pickImage(source: imageSource, imageQuality: 100);
    if (pickedfile != null) {
      io.File imageFile = io.File(pickedfile.path);
      int fileSizeInBytes = imageFile.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024;

      if (kDebugMode) {
        print('Original image size: $fileSizeInKB KB');
      }

      if (fileSizeInKB > 5000) {
        showCustomToast('Please Select an image below 5 MB');
        return;
      }

      io.File? processedFile = imageFile;

      if (fileSizeInKB <= 100) {
        processedFile = await _cropImage(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
      } else if (fileSizeInKB > 100) {
        processedFile = await _cropImage(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
        processedFile = await _compressImage(processedFile);
      }

      double processedFileSizeInKB = processedFile!.lengthSync() / 1024;
      if (kDebugMode) {
        print('Processed image size: $processedFileSizeInKB KB');
      }

      if (mounted) {
        setState(() {
          file = processedFile;
        });

        if (file != null) {
          constanst.imagesList.add(file!);
        }
      } else {
        showCustomToast('API response was null');
      }
    } else {
      showCustomToast('Please select an image');
      return;
    }
  }

  Future<io.File?> _cropImage(io.File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedFile != null) {
      return io.File(croppedFile.path);
    } else {
      return null;
    }
  }

  Future<io.File?> _compressImage(io.File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/temp.jpg';

    int quality = 90;
    io.File? compressedFile;

    while (true) {
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
      );

      if (result == null) {
        return null;
      }

      compressedFile = io.File(result.path);
      double fileSizeInKB = compressedFile.lengthSync() / 1024;

      if (fileSizeInKB <= 100) {
        break;
      }

      quality -= 10;
      if (quality <= 0) {
        break;
      }
    }

    return compressedFile;
  }

  Future<void> fetchSendChat({required String message, File? imageFile}) async {
    print("Fetching SharedPreferences...");
    SharedPreferences pref = await SharedPreferences.getInstance();
    print("SharedPreferences fetched successfully.");

    // Printing SharedPreferences values
    print("User ID: ${pref.getString('user_id')}");
    print("API Token: ${pref.getString('userToken')}");

    print("Sending chat message...");
    print("user_id: ${pref.getString('user_id').toString()}");
    print("userToken: ${pref.getString('userToken').toString()}");
    print("user_id: ${widget.user_id}");
    print("chatId: ${widget.chatId}");

    var res = await get_SendChat(
      userId: pref.getString('user_id').toString(),
      userToken: pref.getString('userToken').toString(),
      toId: widget.user_id.toString(),
      comment: message,
      chatId: widget.chatId.toString(),
      image: imageFile,
    );

    print("Response received: $res");

    if (res['status'] == 1) {
      print("Message sent successfully.");
      setState(() {
        sendMessageRecord = SendMessageRecord.fromJson(res['record']);
        lastChatsId = sendMessageRecord.id ?? 0;
        commentMessage.text = '';
        Navigator.pop(context);
      });
      print("State updated with new message record.");
    } else {
      print("Message sending failed with error: ${res['message']}");
      showCustomToast(res['message']);
    }

    setState(() {
      isLoading = true;
    });
    print("Loading state set to true.");

    return res;
  }
}
