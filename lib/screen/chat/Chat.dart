// ignore_for_file: prefer_typing_uninitialized_variables, unrelated_type_equality_checks, unnecessary_null_comparison

import 'dart:async';
import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/screen/chat/chart_detail_group.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/Tutorial_Videos_dialog.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_chat_shimmer_loader.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_interface.dart';
import '../../common/commonImage.dart';
import '../../model/chatModel/chat_history_model.dart';
import 'ChartDetail.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  MyChatHistoryResponse myChatHistoryResponse = MyChatHistoryResponse();
  bool? load = false;
  bool loadmore = false;
  List<ChatHistoryData> chatHistoryDataList = <ChatHistoryData>[];
  bool isLoading = true;
  bool notificationTapped = false;
  String screen_id = "0";
  String title = 'Chat';
  @override
  void initState() {
    fetchChatHistory();
    super.initState();
    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  Widget ChatWithShimmerLoader(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ChatShimmerLoader(width: 175, height: 100);
      },
    );
  }

  Future<void> fetchChatHistory() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var res = await get_chatHistory(
        userId: pref.getString('user_id').toString(),
        userToken: pref.getString('userToken').toString());

    if (res != null && res['status'] == 1) {
      myChatHistoryResponse = MyChatHistoryResponse.fromJson(res);

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
            if (a.lastChatAt != null && b.lastChatAt != null) {
              DateTime timeA = DateTime.parse(a.lastChatAt!);
              DateTime timeB = DateTime.parse(b.lastChatAt!);
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

  Future<void> fetchDeleteChatHistory({required int id}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var res = await get_deletecChat(
        userId: pref.getString('user_id').toString(),
        userToken: pref.getString('userToken').toString(),
        chatId: id.toString());

    print("user_id: ${pref.getString('user_id').toString()}");
    print("userToken: ${pref.getString('userToken').toString()}");
    print("chatId: ${id}");
    if (res['status'] == 1) {
      chatHistoryDataList.removeWhere((e) => e.id == id);
      showCustomToast(res['message']);
      fetchChatHistory();
    } else {
      showCustomToast(res['message']);
    }
    setState(() {
      loadmore = true;
    });
    return res;
  }

  void _onLoading() {
    BuildContext dialogContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
            backgroundColor: AppColors.transperent,
            elevation: 0,
            child: SizedBox(
                width: 300.0,
                height: 150.0,
                child: Center(
                    child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: Center(
                          child: CustomLottieContainer(
                            child: Lottie.asset(
                              'assets/loading_animation.json',
                            ),
                          ),
                        )))));
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(dialogContext).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: const Text(
          'Messages',
          softWrap: false,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: 'Metropolis',
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showTutorial_Video(context, title, screen_id);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 40,
                child: Image.asset(
                  'assets/Play.png',
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 8, 10, 8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0.0, 5.0),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                  textCapitalization: TextCapitalization.words,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Search People or Messages",
                    hintStyle: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf')
                        .copyWith(color: Colors.black45),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    prefixIcon: const Icon(Icons.search),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(15.0)),
                    border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading ? ChatWithShimmerLoader(context) : chatlist(),
            )
          ],
        ),
      ),
    );
  }

  Future<void> showTutorial_Video(
      BuildContext context, String title, String screenId) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Tutorial_Videos_dialog(title, screenId);
      },
    );
  }

  Widget chatlist() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount:
          chatHistoryDataList.isEmpty ? 1 : chatHistoryDataList.length + 1,
      itemBuilder: (context, index) {
        if (index == chatHistoryDataList.length) {
          if (hasChatDataToLoad() && !chatHistoryDataList.isEmpty) {
            return ChatShimmerLoader(
              width: 175,
              height: 100,
            );
          } else {
            return SizedBox();
          }
        } else {
          ChatHistoryData record = chatHistoryDataList[index];
          var date;
          if (record.lastChatAt != null) {
            DateTime parsedDateTime = DateTime.parse(record.lastChatAt!);
            DateTime localDateTime = parsedDateTime.toLocal();
            date = getTextForDate(localDateTime);
          }
          print("countOfEnread:-${record.toJson()}");

          return Column(
            children: [
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CommanDialog(
                        title: "Delete Chat",
                        content: "Are You Sure Want To Delete This Chat?",
                        onPressed: () {
                          setState(() {
                            _onLoading();
                            fetchDeleteChatHistory(id: record.id ?? 0);
                            Navigator.of(context).pop();
                          });
                        },
                      );
                    },
                  );
                },
                onTap: () async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  if (record.isgroup == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChartDetail(
                          user_id: pref.getString('user_id').toString() ==
                                  record.fromId.toString()
                              ? record.toId.toString()
                              : record.fromId.toString(),
                          user_image: record.userImage,
                          user_name: record.username,
                          chatId: record.id.toString(),
                        ),
                      ),
                    ).then((value) {
                      fetchChatHistory();
                      setState(() {});
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChartDetailGroup(
                          user_id: pref.getString('user_id').toString() ==
                                  record.fromId.toString()
                              ? record.toId.toString()
                              : record.fromId.toString(),
                          user_image: record.userImage,
                          user_name: record.username,
                          chatId: record.id.toString(),
                        ),
                      ),
                    ).then((value) {
                      fetchChatHistory();
                      setState(() {});
                    });
                  }
                },
                child: Container(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.05),
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
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (record.toId != null &&
                                    record.toId.toString() != "") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          bussinessprofile(record.toId!),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                child: ClipOval(
                                  clipBehavior: Clip.antiAlias,
                                  child: record.username == 'Group'
                                      ? FadeInImage(
                                          placeholderFit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          image: NetworkImage(
                                            profileErrorImage,
                                          ),
                                          placeholder: NetworkImage(
                                            profileErrorImage,
                                          ),
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.network(
                                                profileErrorImage);
                                          },
                                          fit: BoxFit.cover,
                                        )
                                      : FadeInImage(
                                          placeholderFit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          image: NetworkImage(
                                            record.userImage ??
                                                profileErrorImage,
                                          ),
                                          placeholder: NetworkImage(
                                            record.userImage ??
                                                profileErrorImage,
                                          ),
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.network(
                                              profileErrorImage,
                                            );
                                          },
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.username ?? "Unknown",
                                    style: TextStyle(
                                      color: record.unreadCount == 0
                                          ? Colors.black
                                          : AppColors.primaryColor,
                                      fontSize: 14,
                                      fontWeight: record.unreadCount == 0
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        1.76,
                                    child: Text(record.message ?? "",
                                        style: TextStyle(
                                          color: record.unreadCount == 0
                                              ? Colors.black
                                              : AppColors.primaryColor,
                                          fontSize: 12,
                                          fontWeight: record.unreadCount == 0
                                              ? FontWeight.w400
                                              : FontWeight.w700,
                                          letterSpacing: -0.24,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IntrinsicWidth(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(date,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                      letterSpacing: -0.24,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf'),
                                  maxLines: 1,
                                  softWrap: false),
                              SizedBox(
                                  height: record.unreadCount == 0 ? 35 : 12),
                              Visibility(
                                visible: record.unreadCount != 0,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle),
                                  child: Text(
                                    "${record.unreadCount ?? 0}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
            ],
          );
        }
      },
    );
  }

  bool hasChatDataToLoad() {
    int itemsPerPage = 20;
    return chatHistoryDataList.length % itemsPerPage == 0;
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
}
