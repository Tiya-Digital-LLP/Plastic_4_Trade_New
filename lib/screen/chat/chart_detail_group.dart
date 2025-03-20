// ignore_for_file: must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

//import 'package:image_picker/image_picker.dart';
import 'package:Plastic4trade/model/chatModel/chat_history_model.dart';
import 'package:Plastic4trade/screen/chat/camera_gallery_screen.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_interface.dart';
import '../../common/commonImage.dart';
import '../../model/ChatMessage.dart';
import '../../model/chatModel/chat_detail_model.dart';
import '../../model/chatModel/chat_onTime_model.dart';
import '../buisness_profile/BussinessProfile.dart';

class ChartDetailGroup extends StatefulWidget {
  String? user_name;
  String? user_image;
  String? user_id;
  String? chatId;

  ChartDetailGroup(
      {Key? key, this.user_name, this.user_image, this.chatId, this.user_id})
      : super(key: key);

  @override
  State<ChartDetailGroup> createState() => _ChartDetailState();
}

class _ChartDetailState extends State<ChartDetailGroup> {
  bool isSending = false;
  bool isimage = false;
  bool isLoading = false;
  io.File? file;
  bool loadmore = false;
  int offset = 0;
  int count = 0;
  String? senderImage;
  String? appUserId;
  int lastChatsId = 0;
  String? userToken;
  TextEditingController textMessage = TextEditingController();
  List<ChatHistoryData> chatHistoryDataList = <ChatHistoryData>[];
  MyChatHistoryResponse myChatHistoryResponse = MyChatHistoryResponse();
  bool? load = false;

  final scrollController = ScrollController();
  ChatDetailsResponse chatDetailsResponse = ChatDetailsResponse();
  List<ChatDetailsData> chatDetailsDataList = <ChatDetailsData>[];
  GetOnTimeChatResponse getOnTimeChatResponse = GetOnTimeChatResponse();
  List<ChatDetailsData> getOnTimeChatList = <ChatDetailsData>[];
  SendMessageRecord sendMessageRecord = SendMessageRecord();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollercontroller);
    fetchChatDetails(page: 1);
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      fetchChatOnTime(lastChatId: lastChatsId, excludeCurrentUser: true);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _scrollercontroller() {
    if ((scrollController.position.pixels - 50) ==
        (scrollController.position.maxScrollExtent - 50)) {
      loadmore = false;
      if (chatDetailsDataList.isNotEmpty) {
        count++;

        fetchChatDetails(page: count);
      }
    }
  }

  Future<void> fetchChatDetails({required int page}) async {
    // Debugging SharedPreferences initialization
    print("Initializing SharedPreferences...");
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Debugging retrieved preferences
    appUserId = pref.getString('user_id').toString();
    userToken = pref.getString('userToken').toString();
    senderImage = pref.getString("userImage").toString();
    appUserId = pref.getString("user_id").toString();

    print("Retrieved SharedPreferences values:");
    print("appUserId: $appUserId");
    print("userToken: $userToken");
    print("senderImage: $senderImage");

    // Debugging API request parameters
    print("Calling get_chatDetails with:");
    print("userId: ${appUserId ?? pref.getString('user_id').toString()}");
    print("userToken: ${userToken ?? pref.getString('userToken').toString()}");
    print("chatId: ${widget.chatId}");
    print("page: $page");

    var res = await get_chatDetails(
      userId: appUserId ?? pref.getString('user_id').toString(),
      userToken: userToken ?? pref.getString('userToken').toString(),
      chatId: widget.chatId,
      page: page,
    );

    print("Response from get_chatDetails: $res");

    setState(() {
      if (res['status'] == 1) {
        print("Status is 1, processing chat details");
        chatDetailsResponse = ChatDetailsResponse.fromJson(res);

        if (chatDetailsResponse.mychatDetails != null &&
            chatDetailsResponse.mychatDetails!.chatDetailsData != null) {
          chatDetailsDataList =
              chatDetailsResponse.mychatDetails!.chatDetailsData ?? [];
          print("Chat details data list length: ${chatDetailsDataList.length}");

          if (chatDetailsDataList.isNotEmpty) {
            lastChatsId = chatDetailsDataList.first.id ?? 0;
            print("Last Chat ID: $lastChatsId");
          } else {
            lastChatsId = 0; // Default value if the list is empty
            print("Chat details data list is empty, setting lastChatsId to 0");
          }
        }
      } else {
        print("Status is not 1, showing custom toast: ${res['message']}");
        showCustomToast(res['message']);
      }
      loadmore = true;
      isLoading = true;
      print("SetState completed: loadmore=$loadmore, isLoading=$isLoading");
    });

    return res;
  }

  Future<void> fetchChatOnTime(
      {required int lastChatId, bool excludeCurrentUser = false}) async {
    if (lastChatId != 0) {
      var res;
      SharedPreferences pref = await SharedPreferences.getInstance();
      _timer.cancel();
      get_newmessages(
              userId: appUserId ?? pref.getString('user_id').toString(),
              userToken: userToken ?? pref.getString('userToken').toString(),
              chatId: widget.chatId,
              lastChatId: lastChatId.toString())
          .then((res) {
        setState(() {
          if (res['status'] == 1) {
            getOnTimeChatResponse = GetOnTimeChatResponse.fromJson(res);
            if (getOnTimeChatResponse.getOnTimeChat != null &&
                getOnTimeChatResponse.getOnTimeChat!.isNotEmpty) {
              getOnTimeChatList = getOnTimeChatResponse.getOnTimeChat ?? [];
              // Filter out messages that are already in the chatDetailsDataList
              List<ChatDetailsData> newMessages = getOnTimeChatList
                  .where((message) => !chatDetailsDataList.any(
                      (existingMessage) => existingMessage.id == message.id))
                  .toList();
              // Update lastChatsId only if the message is not sent by the current user
              if (!excludeCurrentUser) {
                lastChatsId = getOnTimeChatList.first.id ?? 0;
              }
              // Insert new messages to the beginning of the chatDetailsDataList
              chatDetailsDataList.insertAll(0, newMessages);
            }
          } else {
            print("fetchChatOnTime:-${res}");
          }
          loadmore = true;
          isLoading = true;
          _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
            fetchChatOnTime(lastChatId: lastChatsId, excludeCurrentUser: true);
          });
        });
      });
      return res;
    }
  }

  Future<void> fetchSendChat({required String message, File? imageFile}) async {
    print("Fetching SharedPreferences...");
    SharedPreferences pref = await SharedPreferences.getInstance();
    print("SharedPreferences fetched successfully.");

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
      msg: message,
      chatId: widget.chatId.toString(),
      image: imageFile,
    );

    print("Response received: $res");

    if (res['status'] == 1) {
      print("Message sent successfully.");
      setState(() {
        sendMessageRecord = SendMessageRecord.fromJson(res['record']);
        lastChatsId = sendMessageRecord.id ?? 0;
        textMessage.text = '';
        fetchChatDetails(page: 0);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              child: ClipOval(
                child: widget.user_name == 'Group'
                    ? FadeInImage(
                        placeholderFit: BoxFit.cover,
                        alignment: Alignment.center,
                        image: NetworkImage(profileErrorImage),
                        placeholder: NetworkImage(profileErrorImage),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.network(profileErrorImage);
                        },
                        fit: BoxFit.cover,
                      )
                    : FadeInImage(
                        placeholderFit: BoxFit.cover,
                        alignment: Alignment.center,
                        image: NetworkImage(
                          widget.user_image ?? profileErrorImage,
                        ),
                        placeholder: NetworkImage(
                          widget.user_image ?? profileErrorImage,
                        ),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.network(profileErrorImage);
                        },
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.user_name ?? "Unknown",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.24,
                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                overflow: TextOverflow.ellipsis,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
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
      body: Column(
        children: [
          Expanded(
              child: isLoading == true
                  ? buildListMessage()
                  : Center(
                      child: CustomLottieContainer(
                        child: Lottie.asset(
                          'assets/loading_animation.json',
                        ),
                      ),
                    )),
          addchat()
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return chatDetailsDataList.isNotEmpty
        ? ListView.builder(
            reverse: true,
            itemCount: chatDetailsDataList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final record = chatDetailsDataList[index];
              var datetime;
              if (record.createdAt != null) {
                DateTime parsedDateTime = DateTime.parse(record.createdAt!);
                DateTime localDateTime = parsedDateTime.toLocal();
                datetime = getTextForDate(localDateTime);
              }
              return Padding(
                padding: const EdgeInsets.only(top: 11, right: 8, left: 8),
                child: Column(
                  children: [
                    (record.fromid.toString() == appUserId)
                        ? SizedBox.shrink() // Don't display anything
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (record.fromid != null &&
                                      record.fromid != "null" &&
                                      record.fromid != "") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => bussinessprofile(
                                          int.parse(
                                            record.fromid.toString(),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  child: ClipOval(
                                    child: FadeInImage(
                                      placeholderFit: BoxFit.cover,
                                      alignment: Alignment.center,
                                      image: NetworkImage(record.userImage ??
                                          profileErrorImage),
                                      placeholder: NetworkImage(
                                          record.userImage ??
                                              profileErrorImage),
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.network(profileErrorImage);
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE5E5EA),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(13.0),
                                    bottomLeft: Radius.circular(0.0),
                                    topLeft: Radius.circular(13.0),
                                    bottomRight: Radius.circular(13.0),
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width / 1.3,
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (record.fromid != null &&
                                                record.fromid != "null" &&
                                                record.fromid != "") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      bussinessprofile(
                                                          int.parse(record
                                                              .fromid
                                                              .toString())),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            record.fromUserName.toString(),
                                            style: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 11,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.41,
                                            ),
                                          ),
                                        ),
                                        record.msg != null &&
                                                record.msg != "null" &&
                                                record.msg != "" &&
                                                record.msg!.isNotEmpty &&
                                                record.msg!.startsWith(
                                                    "https://www.plastic4trade.com/")
                                            ? Container(
                                                width: 175.16,
                                                height: 175.16,
                                                margin: const EdgeInsets.only(
                                                    bottom: 5),
                                                alignment: Alignment.center,
                                                decoration: ShapeDecoration(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            13.05),
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13.05),
                                                  child: FadeInImage(
                                                    placeholderFit:
                                                        BoxFit.cover,
                                                    alignment: Alignment.center,
                                                    image: NetworkImage(
                                                        record.msg ??
                                                            chatErrorImage),
                                                    placeholder: NetworkImage(
                                                        record.msg ??
                                                            chatErrorImage),
                                                    imageErrorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.network(
                                                          chatErrorImage);
                                                    },
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  record.userImageUrl != null &&
                                                          record.userImageUrl!
                                                              .isNotEmpty
                                                      ? InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Dialog(
                                                                  insetPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  child: Stack(
                                                                    children: [
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        height: MediaQuery.of(context)
                                                                            .size
                                                                            .height,
                                                                        child:
                                                                            InteractiveViewer(
                                                                          child:
                                                                              Image.network(
                                                                            '${record.userImageUrl}',
                                                                            fit:
                                                                                BoxFit.contain,
                                                                            width:
                                                                                MediaQuery.of(context).size.width,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: 20,
                                                                        right:
                                                                            20,
                                                                        child:
                                                                            IconButton(
                                                                          icon: Icon(
                                                                              Icons.clear,
                                                                              color: Colors.black),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Container(
                                                              width: 100,
                                                              height: 100,
                                                              child:
                                                                  FadeInImage(
                                                                placeholderFit:
                                                                    BoxFit
                                                                        .cover,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                image:
                                                                    NetworkImage(
                                                                  record.userImageUrl ??
                                                                      profileErrorImage,
                                                                ),
                                                                placeholder:
                                                                    NetworkImage(
                                                                  record.userImageUrl ??
                                                                      profileErrorImage,
                                                                ),
                                                                imageErrorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Image
                                                                      .network(
                                                                    profileErrorImage,
                                                                  );
                                                                },
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox.shrink(),
                                                  3.sbh,
                                                  record.msg != null
                                                      ? InkWell(
                                                          onTap: () {
                                                            if (record.fromid !=
                                                                    null &&
                                                                record.fromid !=
                                                                    "null" &&
                                                                record.fromid !=
                                                                    "") {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      bussinessprofile(int.parse(record
                                                                          .fromid
                                                                          .toString())),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Text(
                                                            record.msg ?? "",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              letterSpacing:
                                                                  -0.41,
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox.shrink(),
                                                  3.sbh,
                                                  record.commentmsg != null
                                                      ? InkWell(
                                                          onTap: () {
                                                            if (record.fromid !=
                                                                    null &&
                                                                record.fromid !=
                                                                    "null" &&
                                                                record.fromid !=
                                                                    "") {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      bussinessprofile(int.parse(record
                                                                          .fromid
                                                                          .toString())),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Text(
                                                            record.commentmsg ??
                                                                "",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'assets/fonst/Metropolis-Black.otf',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              letterSpacing:
                                                                  -0.41,
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                        const SizedBox(height: 2),
                                        InkWell(
                                          onTap: () {
                                            if (record.fromid != null &&
                                                record.fromid != "null" &&
                                                record.fromid != "") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      bussinessprofile(
                                                          int.parse(record
                                                              .fromid
                                                              .toString())),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            datetime,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 9,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf',
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: -0.41,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    if (record.fromid.toString() == appUserId)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(13.0),
                                bottomRight: Radius.circular(0.0),
                                topLeft: Radius.circular(13.0),
                                bottomLeft: Radius.circular(13.0),
                              ),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width / 1.3,
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    record.msg != null &&
                                            record.msg != "null" &&
                                            record.msg != "" &&
                                            record.msg!.isNotEmpty &&
                                            record.msg!.startsWith(
                                                "https://www.plastic4trade.com/")
                                        ? Container(
                                            width: 175.16,
                                            height: 175.16,
                                            margin: const EdgeInsets.only(
                                                bottom: 5),
                                            alignment: Alignment.center,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        13.05),
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(13.05),
                                              child: FadeInImage(
                                                placeholderFit: BoxFit.cover,
                                                alignment: Alignment.center,
                                                image: NetworkImage(
                                                    chatDetailsResponse
                                                            .profilePic ??
                                                        chatErrorImage),
                                                placeholder: NetworkImage(
                                                    chatDetailsResponse
                                                            .profilePic ??
                                                        chatErrorImage),
                                                imageErrorBuilder: (context,
                                                    error, stackTrace) {
                                                  return Image.network(
                                                      chatErrorImage);
                                                },
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              record.userImageUrl != null &&
                                                      record.userImageUrl!
                                                          .isNotEmpty
                                                  ? InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Dialog(
                                                              insetPadding:
                                                                  EdgeInsets
                                                                      .zero,
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
                                                                        '${record.userImageUrl}',
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        width: MediaQuery.of(context)
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
                                                                          color:
                                                                              Colors.black),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
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
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10),
                                                        ),
                                                        child: Container(
                                                          width: 100,
                                                          height: 100,
                                                          child: FadeInImage(
                                                            placeholderFit:
                                                                BoxFit.cover,
                                                            alignment: Alignment
                                                                .center,
                                                            image: NetworkImage(
                                                              record.userImageUrl ??
                                                                  profileErrorImage,
                                                            ),
                                                            placeholder:
                                                                NetworkImage(
                                                              record.userImageUrl ??
                                                                  profileErrorImage,
                                                            ),
                                                            imageErrorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Image
                                                                  .network(
                                                                profileErrorImage,
                                                              );
                                                            },
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                              3.sbh,
                                              record.msg != null
                                                  ? InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                bussinessprofile(
                                                                    record
                                                                        .fromid!),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        record.msg ?? "",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-Black.otf',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: -0.41,
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                              3.sbh,
                                              record.commentmsg != null
                                                  ? InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                bussinessprofile(
                                                                    record
                                                                        .fromid!),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        record.commentmsg ?? "",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-Black.otf',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: -0.41,
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                    const SizedBox(height: 2),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                bussinessprofile(
                                                    record.fromid!),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        datetime,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.41,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      bussinessprofile(record.fromid!),
                                ),
                              );
                            },
                            child: Container(
                              width: 18,
                              height: 18,
                              child: ClipOval(
                                child: FadeInImage(
                                  placeholderFit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  image: NetworkImage(
                                      senderImage ?? profileErrorImage),
                                  placeholder: NetworkImage(
                                      senderImage ?? profileErrorImage),
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Image.network(profileErrorImage);
                                  },
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          )
        : Center(child: const Text("No data available"));
  }

  Future<void> fetchDeleteChatHistory({required String id}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var res = await get_deletecChat(
        userId: pref.getString('user_id').toString(),
        userToken: pref.getString('userToken').toString(),
        chatId: id);
    if (res['status'] == 1) {
      chatHistoryDataList.removeWhere((e) => e.id == id);
      showCustomToast(res['message']);
      print('${res['message']}');
      Navigator.pop(context);
    } else {
      showCustomToast(res['message']);
    }
    setState(() {
      loadmore = true;
    });
    return res;
  }

  Future<void> fetchChatHistory() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var res = await get_chatHistory(
        userId: pref.getString('user_id').toString(),
        userToken: pref.getString('userToken').toString());

    if (res != null && res['status'] == 1) {
      myChatHistoryResponse = MyChatHistoryResponse.fromJson(res);

      // ignore: unnecessary_null_comparison
      if (myChatHistoryResponse != null) {
        if (myChatHistoryResponse.chatPermission == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Premiun(),
            ),
          );
          showCustomToast('Upgrade Plan to View Chat');
          return;
        }

        chatHistoryDataList.clear();
        if (myChatHistoryResponse.myChatHistory != null &&
            myChatHistoryResponse.myChatHistory!.chatHistoryData != null) {
          chatHistoryDataList =
              myChatHistoryResponse.myChatHistory!.chatHistoryData ?? [];

          chatHistoryDataList.sort((a, b) {
            if (a.createdAt != null && b.createdAt != null) {
              DateTime timeA = DateTime.parse(a.createdAt!);
              DateTime timeB = DateTime.parse(b.createdAt!);
              return timeB.compareTo(timeA);
            }
            return 0;
          });
        }
      }
    } else {
      showCustomToast(res != null ? res['message'] : 'Unknown error');
    }
    setState(() {
      load = true;
    });
    return res;
  }

  String getTextForDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    if (isSameDay(now, dateTime)) {
      return DateFormat("h:mm a").format(dateTime);
    } else if (isYesterday(now, dateTime)) {
      return "Yesterday";
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTime);
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isYesterday(DateTime date1, DateTime date2) {
    final difference = date1.difference(date2);
    return difference.inDays == 1 &&
        date1.day - date2.day == 1 &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  Widget addchat() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
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
                      controller: textMessage,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      minLines: 1,
                      maxLines: null,
                      onChanged: ((value) {
                        setState(() {
                          if (value.toString().isEmpty) {}
                        });
                      }),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: "Write your message here",
                        hintMaxLines: 1,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10),
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.6100000143051147),
                          fontSize: 11,
                          fontFamily: 'assets/fonst/Metropolis-SemiBold.otf',
                          fontWeight: FontWeight.w400,
                        ),
                        suffixIcon: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraGalleryScreen(
                                  user_id: widget.user_id,
                                  chatId: widget.chatId,
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.camera,
                            color: AppColors.primaryColor,
                          ),
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
                  isSending
                      ? SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            if (textMessage.text.trim().isEmpty) {
                              showCustomToast('Write Your Message First');
                              return;
                            }
                            setState(() {
                              isSending = true;
                            });
                            fetchSendChat(
                              message: textMessage.text,
                              imageFile: file,
                            ).then((res) {
                              setState(() {
                                isSending = false;
                                textMessage.clear();
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
    );
  }

  Widget bottomsheet() {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.camera,
                      color: AppColors.primaryColor,
                    ),
                    label: const Text(
                      'Camera',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.image,
                      color: AppColors.primaryColor,
                    ),
                    label: const Text(
                      'Gallery',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }

  ViewItem(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) => const YourWidget(),
    );
  }
}

class YourWidget extends StatefulWidget {
  const YourWidget({Key? key}) : super(key: key);

  @override
  State<YourWidget> createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  String? assignedName;
  bool gender = false;
  io.File? file;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  GestureDetector(
                      child: Image.asset(
                        "assets/add_image.png",
                        width: 150,
                        height: 120,
                      ),
                      onTap: () {
                        showDialog(
                          barrierColor: Colors.black26,
                          context: context,
                          builder: (context) {
                            setState(() {});
                            return bottomsheet();
                          },
                        );
                      }),
                  const SizedBox(
                    width: 68,
                    child: Text(
                      'Image',
                      style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                      child: Image.asset(
                        "assets/add_doc.png",
                        width: 150,
                        height: 120,
                      ),
                      onTap: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();

                        if (result != null) {
                          PlatformFile files = result.files.first;
                          constanst.messages.add(
                            ChatMessage(
                                messageContent: "",
                                userType: "sender",
                                msgtype: "pdf",
                                fillname: files.name),
                          );
                        } else {}
                      }),
                  const SizedBox(
                    width: 68,
                    child: Text(
                      'Attach Document',
                      style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }

  Widget bottomsheet() {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.camera,
                      color: AppColors.primaryColor,
                    ),
                    label: const Text('Camera'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Gallary'),
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}
