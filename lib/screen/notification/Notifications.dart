/// ignore_for_file: camel_case_types, non_constant_identifier_names, unnecessary_null_comparison, unrelated_type_equality_checks, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/model/GetNotification.dart' as getnotifi;
import 'package:Plastic4trade/model/GetadminNotification.dart'
    as admin_getnotifi;
import 'package:Plastic4trade/screen/Review.dart';
import 'package:Plastic4trade/screen/blog/Blog.dart';
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/screen/buyer_seller/Buyer_sell_detail.dart';
import 'package:Plastic4trade/screen/chat/Chat.dart';
import 'package:Plastic4trade/screen/exhibition/Exhibition.dart';
import 'package:Plastic4trade/screen/liveprice/Liveprice.dart';
import 'package:Plastic4trade/screen/member/Premium.dart';
import 'package:Plastic4trade/screen/notification/NotificationSettingsScreen.dart';
import 'package:Plastic4trade/screen/post/ManagePost.dart';
import 'package:Plastic4trade/screen/video/Tutorial_Videos.dart';
import 'package:Plastic4trade/screen/video/Videos.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_notificaton_shimmer_loader.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_interface.dart';

class notification extends StatefulWidget {
  const notification({Key? key}) : super(key: key);

  @override
  State<notification> createState() => _NotificationState();
}

class _NotificationState extends State<notification>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<admin_getnotifi.Result> getallnotifydata = [];
  List<getnotifi.Result> getnotifydata = [];
  List<admin_getnotifi.Result> unread_getnotifydata = [];
  bool unread = false, isload = false, alldata = true, allNotification = true;
  String create_formattedDate = "", limit = "20";
  String read_status = "1";
  int offset = 0;
  int count = 0;
  int tabIndex = 0;
  final scrollercontroller = ScrollController();
  bool isLoading = true;
  int? isBusinessProfileView;
  Map<String, bool> iconVisibilityMap = {};
  Map<String, bool> iconVisibilityMap1 = {};
  Map<String, bool> iconVisibilityMap2 = {};

  List<bool> isIconPressedList2 = [];

  @override
  void initState() {
    super.initState();

    // Initialize TabController and add listener
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Initialize the scroll controller
    scrollercontroller.addListener(_scrollercontroller);

    // Check network connection
    checknetowork();

    // Load initial data
    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Print the current tab index to check which tab is being selected
    print('Selected Tab: ${_tabController.index}');

    // Handle API calls based on selected tab
    switch (_tabController.index) {
      case 0:
        // Tab 0: Fetch all notifications
        print("Making API call for all notifications (Tab 0)");
        fetch_allNotification(offset: offset.toString(), limit: '20');
        break;

      case 1:
        print("Making API call for notifications (Tab 1)");
        get_notification(read_status, offset.toString(), '20');

        break;

      case 2:
        print("Making API call for unread notifications (Tab 2)");
        get_notification_unread(read_status, offset.toString(), '20');

        break;

      default:
        print("Unknown tab selected");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return init();
  }

  Widget init() {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          title: const Text(
            'Notifications',
            softWrap: false,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontFamily: 'Metropolis',
            ),
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
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const Notificationsetting()));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/Setting.png',
                  width: 31,
                  height: 31,
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DefaultTabController(
                    length: 3,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        tabBarTheme: TabBarTheme(
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: AppColors.primaryColor,
                          ),
                          unselectedLabelColor: Colors.white,
                        ),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.8,
                        height: 45,
                        margin: const EdgeInsets.only(bottom: 15.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          // ignore: deprecated_member_use
                          color: AppColors.primaryColor.withOpacity(0.15),
                        ),
                        child: TabBar(
                          onTap: (value) {
                            if (value == 0) {
                              allNotification = true;
                              unread = false;
                              alldata = false;
                            } else if (value == 1) {
                              allNotification = false;
                              alldata = true;
                              unread = false;
                            } else if (value == 2) {
                              allNotification = false;
                              unread = true;
                              alldata = false;
                            }
                            setState(() {
                              tabIndex = value;
                            });
                          },
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          controller: _tabController,
                          labelColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          unselectedLabelColor: Colors.black,
                          unselectedLabelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          tabs: [
                            Tab(
                              child: Text(
                                'All',
                              ),
                            ),
                            Tab(
                              child: Text(
                                'User',
                              ),
                            ),
                            Tab(
                              child: Text(
                                'Admin',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  tabIndex != 2
                      ? Container(
                          height: 45,
                          margin: const EdgeInsets.only(bottom: 15, left: 15),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                get_allread();

                                fetch_allNotification(
                                    offset: offset.toString(), limit: '20');
                                get_notification(
                                    read_status, offset.toString(), '20');
                                get_notification_unread(
                                    read_status, offset.toString(), '20');
                              });
                            },
                            child: Text(
                              'Mark all as read',
                              style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryColor,
                                      fontFamily:
                                          'assets/fonst/Metropolis-Black.otf')
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ))
                      : const SizedBox(),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    isLoading
                        ? notificationWithShimmerLoader(context)
                        : RefreshIndicator(
                            backgroundColor: AppColors.primaryColor,
                            color: Colors.white,
                            onRefresh: () async {
                              await fetch_allNotification(
                                  offset: '0', limit: '20');
                            },
                            child: allnotificationsetting(),
                          ),
                    isLoading
                        ? notificationWithShimmerLoader(context)
                        : RefreshIndicator(
                            backgroundColor: AppColors.primaryColor,
                            color: Colors.white,
                            onRefresh: () async {
                              await get_notification('0', '0', '20');
                            },
                            child: notificationsetting()),
                    isLoading
                        ? notificationWithShimmerLoader(context)
                        : RefreshIndicator(
                            backgroundColor: AppColors.primaryColor,
                            color: Colors.white,
                            onRefresh: () async {
                              await get_notification_unread('0', '0', '20');
                            },
                            child: notificationsetting_unread())
                  ]),
            ),
          ],
        ));
  }

  void _scrollercontroller() {
    if (scrollercontroller.position.pixels ==
        scrollercontroller.position.maxScrollExtent) {
      if (allNotification) {
        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        fetch_allNotification(offset: offset.toString(), limit: limit);
      } else if (unread) {
        read_status = "0";

        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        get_notification_unread(read_status, offset.toString(), limit);
      } else if (alldata) {
        count++;
        read_status = "";

        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        get_notification(read_status, offset.toString(), limit);
      }
    }
  }

  Widget notificationWithShimmerLoader(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 10,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return NotificationShimmerLoader(width: 175, height: 115);
      },
    );
  }

  bool allNotificationDataToLoad() {
    int itemsPerPage = 20;
    return getallnotifydata.length % itemsPerPage == 0;
  }

  Widget allnotificationsetting() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: getallnotifydata.isEmpty ? 1 : getallnotifydata.length + 1,
        padding: const EdgeInsets.fromLTRB(3.0, 0, 3.0, 0),
        controller: scrollercontroller,
        itemBuilder: (context, index) {
          if (index == getallnotifydata.length) {
            if (allNotificationDataToLoad() && !getallnotifydata.isEmpty) {
              return NotificationShimmerLoader(
                width: 175,
                height: 115,
              );
            } else {
              return SizedBox();
            }
          } else {
            admin_getnotifi.Result result = getallnotifydata[index];
            DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");

            var curret_date = format.parse(
              result.time.toString(),
            );

            DateTime? dt1 = DateTime.parse(
              curret_date.toString(),
            );

            print(result.isRead);

            // ignore: unnecessary_null_comparison
            create_formattedDate = dt1 != null
                ? DateFormat('dd MMM, yyyy hh:mm aaa', 'en_US').format(dt1)
                : "";

            return GestureDetector(
              onTap: () {
                print(
                    "notificationType: ${result.notificationType}, type: ${result.type}");
                print(
                    "Navigating first, then calling is_Read with notificationId: ${result.notificationId}");

                // Perform navigation immediately
                switch (result.notificationType.toString().toLowerCase()) {
                  case "chat_notification":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Chat(),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });

                    break;

                  case "profile like":
                  case "follower_profile_like":
                  case "business profile dislike":
                  case "profile_view":
                  case "followuser":
                  case "followuser_for_follower":
                  case "unfollowuser":
                  case "profile_share":
                    if (result.fromUserId.toString().isNotEmpty) {
                      if (isBusinessProfileView == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Premiun(),
                          ),
                        ).then((_) {
                          fetch_allNotification(
                              offset: offset.toString(), limit: limit);
                        });
                        showCustomToast('Upgrade Plan to View Profile');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => bussinessprofile(
                              int.parse(result.fromUserId.toString()),
                            ),
                          ),
                        ).then((_) {
                          fetch_allNotification(
                              offset: offset.toString(), limit: limit);
                        });
                      }
                    }
                    break;

                  case "post_rejected":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Managepost(),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });
                    break;

                  case "profile_review":
                    if (result.fromUserId.toString().isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Review(result.fromUserId.toString()),
                        ),
                      ).then((_) {
                        fetch_allNotification(
                            offset: offset.toString(), limit: limit);
                      });
                    }
                    break;

                  case "salepost":
                  case "post_view":
                  case "post_share":
                    if (result.salepostId != null &&
                        result.salepostId!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Buyer_sell_detail(
                            post_type: 'SalePost',
                            prod_id: result.salepostId,
                          ),
                        ),
                      ).then((_) {
                        fetch_allNotification(
                            offset: offset.toString(), limit: limit);
                      });
                    } else if (result.buypostId != null &&
                        result.buypostId!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Buyer_sell_detail(
                            post_type: 'BuyPost',
                            prod_id: result.buypostId,
                          ),
                        ),
                      ).then((_) {
                        fetch_allNotification(
                            offset: offset.toString(), limit: limit);
                      });
                    }
                    break;

                  case "live_price":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LivepriceScreen(),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });
                    break;

                  case "quicknews":
                  case "quick_news_notification":
                  case "news":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(3),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });
                    break;

                  case "blog":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Blog(),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });
                    break;

                  case "video":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Videos(),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });
                    break;

                  case "tutorial_video":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Tutorial_Videos(),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });
                    break;

                  case "exhibition":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Exhibition(),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });
                    break;

                  case "banner":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(0),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });
                    break;

                  case "plan_list":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Premiun(),
                      ),
                    ).then((_) {
                      fetch_allNotification(
                          offset: offset.toString(), limit: limit);
                    });
                    break;

                  default:
                    print("Unknown notification type");
                }

                // Call the API asynchronously in the background
                Future.delayed(Duration.zero, () async {
                  try {
                    await is_Read(result.notificationId.toString());
                    print("is_Read completed");
                  } catch (e) {
                    print("Error calling is_Read: $e");
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (result.fromUserId.toString().isNotEmpty) {
                            await is_Read(result.notificationId.toString());
                            if (isBusinessProfileView == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Premiun(),
                                ),
                              ).then((_) {
                                fetch_allNotification(
                                    offset: offset.toString(), limit: limit);
                              });
                              showCustomToast('Upgrade Plan to View Profile');
                            } else if (isBusinessProfileView == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => bussinessprofile(
                                    int.parse(result.fromUserId.toString()),
                                  ),
                                ),
                              ).then((_) {
                                fetch_allNotification(
                                    offset: offset.toString(), limit: limit);
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => bussinessprofile(
                                    int.parse(result.fromUserId.toString()),
                                  ),
                                ),
                              ).then((_) {
                                fetch_allNotification(
                                    offset: offset.toString(), limit: limit);
                              });
                            }
                          }
                        },
                        child: ClipRRect(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox.fromSize(
                            size: const Size.fromRadius(38),
                            child: (result.type == "post_view" ||
                                    result.type == "post_share" ||
                                    result.type == "post like" ||
                                    result.type == "product_post")
                                ? Image(
                                    errorBuilder: (context, object, trace) {
                                      return Image.asset(
                                          'assets/plastic4trade logo final 1 (2).png');
                                    },
                                    image: NetworkImage(
                                      result.postImage.toString(),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    fit: BoxFit.fill,
                                  )
                                : Image(
                                    errorBuilder: (context, object, trace) {
                                      return Image.asset(
                                          'assets/plastic4trade logo final 1 (2).png');
                                    },
                                    image: NetworkImage(
                                        result.profilepic.toString()),
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                      10.sbw,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      result.heading.toString(),
                                      style: TextStyle(
                                              fontWeight: result.isRead == 0
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                              color: AppColors.primaryColor,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(
                                        fontSize: 13,
                                        color: result.isRead == 0
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(create_formattedDate,
                                      style: TextStyle(
                                              fontWeight: result.isRead == 0
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(
                                        fontSize: 12,
                                        color: result.isRead == 0
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                      maxLines: 1,
                                      softWrap: false),
                                ],
                              ),
                              3.sbh,
                              Text(
                                result.description.toString(),
                                style: TextStyle(
                                        fontWeight: result.isRead == 0
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: AppColors.primaryColor,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf')
                                    .copyWith(
                                  fontSize: 12,
                                  color: result.isRead == 0
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              3.sbh,
                              GestureDetector(
                                onTap: () async {
                                  if (result.fromUserId.toString().isNotEmpty) {
                                    await is_Read(
                                        result.notificationId.toString());

                                    if (isBusinessProfileView == 0) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Premiun(),
                                        ),
                                      ).then((_) {
                                        fetch_allNotification(
                                            offset: offset.toString(),
                                            limit: limit);
                                      });
                                      showCustomToast(
                                          'Upgrade Plan to View Profile');
                                    } else if (isBusinessProfileView == 1) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              bussinessprofile(
                                            int.parse(
                                                result.fromUserId.toString()),
                                          ),
                                        ),
                                      ).then((_) {
                                        fetch_allNotification(
                                            offset: offset.toString(),
                                            limit: limit);
                                      });
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              bussinessprofile(
                                            int.parse(
                                                result.fromUserId.toString()),
                                          ),
                                        ),
                                      ).then((_) {
                                        fetch_allNotification(
                                            offset: offset.toString(),
                                            limit: limit);
                                      });
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          child: Image.asset(
                                            'assets/plastic4trade logo final 1 (2).png',
                                            height: 25,
                                            width: 25,
                                          ),
                                        ),
                                        result.fromUserId.toString() == 0
                                            ? Text(result.name.toString(),
                                                style: TextStyle(
                                                        fontSize: 13.0,
                                                        fontWeight: result
                                                                    .isRead ==
                                                                0
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                        fontFamily:
                                                            'assets/fonst/Metropolis-Black.otf')
                                                    .copyWith(
                                                  fontSize: 12,
                                                  color: result.isRead == 0
                                                      ? Colors.black
                                                      : Colors.grey,
                                                ),
                                                maxLines: 1,
                                                softWrap: false)
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2),
                                                child: Text(
                                                    result.name.toString(),
                                                    style: TextStyle(
                                                            fontSize: 13.0,
                                                            fontWeight:
                                                                result.isRead ==
                                                                        0
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .w400,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf')
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: result.isRead == 0
                                                          ? Colors.black
                                                          : Colors.grey,
                                                    ),
                                                    maxLines: 1,
                                                    softWrap: false),
                                              ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            iconVisibilityMap[result
                                                .notificationId
                                                .toString()] = false;

                                            if (result.ischeckadminuser ==
                                                "1") {
                                              adminremove_notification(result
                                                      .notificationId
                                                      .toString())
                                                  .then((_) async {
                                                await fetch_allNotification(
                                                    offset: '0', limit: '20');
                                              });
                                            } else {
                                              remove_notification(result
                                                      .notificationId
                                                      .toString())
                                                  .then((_) async {
                                                await fetch_allNotification(
                                                    offset: '0', limit: '20');
                                              });
                                            }
                                          });
                                        },
                                        child: iconVisibilityMap[result
                                                    .notificationId
                                                    .toString()] ??
                                                true
                                            ? Icon(
                                                Icons.delete,
                                                color: AppColors.red,
                                              )
                                            : Icon(
                                                Icons.delete,
                                                color: AppColors.gray,
                                              ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget notificationsetting() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: scrollercontroller,
      itemCount: getnotifydata.isEmpty ? 1 : getnotifydata.length + 1,
      padding: const EdgeInsets.fromLTRB(3.0, 0, 3.0, 0),
      itemBuilder: (context, index) {
        if (index == getnotifydata.length) {
          if (notificationDataToLoad() && !getnotifydata.isEmpty) {
            return NotificationShimmerLoader(
              width: 175,
              height: 115,
            );
          } else {
            return SizedBox();
          }
        } else {
          getnotifi.Result result = getnotifydata[index];
          DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");

          var currentDate = format.parse(
            result.time.toString(),
          );

          DateTime? dt1 = DateTime.parse(
            currentDate.toString(),
          );

          print(result.isRead);
          // ignore: unnecessary_null_comparison
          create_formattedDate = dt1 != null
              ? DateFormat('dd MMMM, yyyy hh:mm aaa ').format(dt1)
              : "";
          return GestureDetector(
            onTap: () async {
              print(
                  "Calling is_Read with notificationId: ${result.notificationId}");

              print("notificationType:-${result.notificationType}");
              switch (result.notificationType.toString().toLowerCase()) {
                case "chat_notification":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Chat(),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                case "profile like":
                case "follower_profile_like":
                case "business profile dislike":
                case "profile_view":
                case "followuser":
                case "followuser_for_follower":
                case "unfollowuser":
                case "profile_share":
                  if (result.fromUserId.toString().isNotEmpty) {
                    if (isBusinessProfileView == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Premiun(),
                        ),
                      );
                      showCustomToast('Upgrade Plan to View Profile');
                    } else if (isBusinessProfileView == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => bussinessprofile(
                            int.parse(result.fromUserId.toString()),
                          ),
                        ),
                      ).then((_) {
                        get_notification(read_status, offset.toString(), '20');
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => bussinessprofile(
                            int.parse(result.fromUserId.toString()),
                          ),
                        ),
                      ).then((_) {
                        get_notification(read_status, offset.toString(), '20');
                      });
                    }
                  }
                  break;

                // Add other cas

                case "profile_review":
                  if (result.fromUserId.toString().isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Review(result.fromUserId.toString()),
                      ),
                    ).then((_) {
                      get_notification(read_status, offset.toString(), '20');
                    });
                  }
                  break;

                case "post_rejected":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Managepost(),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                case "salepost":
                case "post_view":
                case "post_share":
                  if (result.salepostId != null &&
                      result.salepostId!.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Buyer_sell_detail(
                          post_type: 'SalePost',
                          prod_id: result.salepostId,
                        ),
                      ),
                    ).then((_) {
                      get_notification(read_status, offset.toString(), '20');
                    });
                  } else {
                    if (result.buypostId!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Buyer_sell_detail(
                            post_type: 'BuyPost',
                            prod_id: result.buypostId,
                          ),
                        ),
                      ).then((_) {
                        get_notification(read_status, offset.toString(), '20');
                      });
                    }
                  }
                  break;

                case "live_price":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LivepriceScreen(),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                case "quicknews":
                case "quick_news_notification":
                case "news":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(3),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                case "blog":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Blog(),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                case "video":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Videos(),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                case "tutorial_video":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Tutorial_Videos(),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                case "exhibition":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Exhibition(),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                case "banner":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(0),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                case "plan_list":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Premiun(),
                    ),
                  ).then((_) {
                    get_notification(read_status, offset.toString(), '20');
                  });
                  break;

                default:
                  print("Unknown notification type");
              }
              // Call the API asynchronously in the background
              Future.delayed(Duration.zero, () async {
                try {
                  await is_Read(result.notificationId.toString());
                  print("is_Read completed");
                } catch (e) {
                  print("Error calling is_Read: $e");
                }
              });
            },
            child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            if (result.fromUserId.toString().isNotEmpty) {
                              await is_Read(result.notificationId.toString());

                              if (isBusinessProfileView == 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Premiun(),
                                  ),
                                ).then((_) {
                                  get_notification(
                                      read_status, offset.toString(), '20');
                                });
                                showCustomToast('Upgrade Plan to View Profile');
                              } else if (isBusinessProfileView == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => bussinessprofile(
                                      int.parse(result.fromUserId.toString()),
                                    ),
                                  ),
                                ).then((_) {
                                  get_notification(
                                      read_status, offset.toString(), '20');
                                });
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => bussinessprofile(
                                      int.parse(result.fromUserId.toString()),
                                    ),
                                  ),
                                ).then((_) {
                                  get_notification(
                                      read_status, offset.toString(), '20');
                                });
                              }
                            }
                          } catch (e) {
                            print("Error in onTap: $e");
                          }
                        },
                        child: ClipRRect(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox.fromSize(
                            size: const Size.fromRadius(38),
                            child: (result.type == "post_view" ||
                                    result.type == "post_share" ||
                                    result.type == "post like" ||
                                    result.type == "product_post")
                                ? Image(
                                    errorBuilder: (context, object, trace) {
                                      return Image.asset(
                                          'assets/plastic4trade logo final 1 (2).png');
                                    },
                                    image: NetworkImage(
                                      result.postImage.toString(),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    fit: BoxFit.fill,
                                  )
                                : Image(
                                    errorBuilder: (context, object, trace) {
                                      return Image.asset(
                                          'assets/plastic4trade logo final 1 (2).png');
                                    },
                                    image: NetworkImage(
                                        result.profilepic.toString()),
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                      10.sbw,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      result.heading.toString(),
                                      style: TextStyle(
                                              fontWeight: result.isRead == "0"
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                              color: AppColors.primaryColor,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(
                                        fontSize: 13,
                                        color: result.isRead == "0"
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(create_formattedDate,
                                      style: TextStyle(
                                              fontWeight: result.isRead == "0"
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(
                                        fontSize: 12,
                                        color: result.isRead == "0"
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                      maxLines: 1,
                                      softWrap: false),
                                ],
                              ),
                              3.sbh,
                              Text(
                                result.description.toString(),
                                style: TextStyle(
                                        fontWeight: result.isRead == "0"
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: AppColors.primaryColor,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf')
                                    .copyWith(
                                  fontSize: 12,
                                  color: result.isRead == "0"
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (result.fromUserId.toString().isNotEmpty) {
                                    await is_Read(
                                        result.notificationId.toString());

                                    if (isBusinessProfileView == 0) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Premiun(),
                                        ),
                                      ).then((_) {
                                        get_notification(read_status,
                                            offset.toString(), '20');
                                      });
                                      showCustomToast(
                                          'Upgrade Plan to View Profile');
                                    } else if (isBusinessProfileView == 1) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              bussinessprofile(
                                            int.parse(
                                                result.fromUserId.toString()),
                                          ),
                                        ),
                                      ).then((_) {
                                        get_notification(read_status,
                                            offset.toString(), '20');
                                      });
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              bussinessprofile(
                                            int.parse(
                                                result.fromUserId.toString()),
                                          ),
                                        ),
                                      ).then((_) {
                                        get_notification(read_status,
                                            offset.toString(), '20');
                                      });
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          child: Image.asset(
                                            'assets/plastic4trade logo final 1 (2).png',
                                            height: 25,
                                            width: 25,
                                          ),
                                        ),
                                        result.fromUserId.toString() == 0
                                            ? Text(result.name.toString(),
                                                style: TextStyle(
                                                        fontSize: 13.0,
                                                        fontWeight: result
                                                                    .isRead ==
                                                                "0"
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                        fontFamily:
                                                            'assets/fonst/Metropolis-Black.otf')
                                                    .copyWith(
                                                  fontSize: 12,
                                                  color: result.isRead == "0"
                                                      ? Colors.black
                                                      : Colors.grey,
                                                ),
                                                maxLines: 1,
                                                softWrap: false)
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2),
                                                child: Text(
                                                    result.name.toString(),
                                                    style: TextStyle(
                                                            fontSize: 13.0,
                                                            fontWeight:
                                                                result.isRead ==
                                                                        "0"
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .w400,
                                                            fontFamily:
                                                                'assets/fonst/Metropolis-Black.otf')
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color:
                                                          result.isRead == "0"
                                                              ? Colors.black
                                                              : Colors.grey,
                                                    ),
                                                    maxLines: 1,
                                                    softWrap: false),
                                              ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            iconVisibilityMap1[result
                                                .notificationId
                                                .toString()] = false;
                                            if (result.ischeckadminuser ==
                                                "1") {
                                              adminremove_notification(
                                                result.notificationId
                                                    .toString(),
                                              ).then((_) async {
                                                await get_notification(
                                                    read_status, '0', '20');
                                              });
                                            } else {
                                              remove_notification(
                                                result.notificationId
                                                    .toString(),
                                              ).then((_) async {
                                                await get_notification(
                                                    read_status, '0', '20');
                                              });
                                            }
                                          });
                                        },
                                        child: iconVisibilityMap1[result
                                                    .notificationId
                                                    .toString()] ??
                                                true
                                            ? Icon(
                                                Icons.delete,
                                                color: AppColors.red,
                                              )
                                            : Icon(
                                                Icons.delete,
                                                color: AppColors.gray,
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
                    ],
                  ),
                )),
          );
        }
      },
    );
  }

  bool notificationDataToLoad() {
    int itemsPerPage = 20;
    return getnotifydata.length % itemsPerPage == 0;
  }

  Widget notificationsetting_unread() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            unread_getnotifydata.isEmpty ? 1 : unread_getnotifydata.length + 1,
        padding: const EdgeInsets.fromLTRB(3.0, 0, 3.0, 0),
        controller: scrollercontroller,
        itemBuilder: (context, index) {
          if (index == unread_getnotifydata.length) {
            if (notificationUnreadDataToLoad() &&
                !unread_getnotifydata.isEmpty) {
              return NotificationShimmerLoader(
                width: 175,
                height: 115,
              );
            } else {
              return SizedBox();
            }
          } else {
            admin_getnotifi.Result result = unread_getnotifydata[index];
            DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");

            var curret_date = format.parse(
              result.time.toString(),
            );

            DateTime? dt1 = DateTime.parse(
              curret_date.toString(),
            );

            // ignore: unnecessary_null_comparison
            create_formattedDate = dt1 != null
                ? DateFormat('dd MMM, yyyy hh:mm aaa', 'en_US').format(dt1)
                : "";
            return GestureDetector(
              onTap: () {
                print("notificationType:-${result.notificationType}");
                switch (result.notificationType.toString().toLowerCase()) {
                  case "profile like":
                  case "follower_profile_like":
                  case "business profile dislike":
                  case "profile_view":
                  case "followuser":
                  case "followuser_for_follower":
                  case "unfollowuser":
                  case "profile_share":
                    if (result.fromUserId.toString().isNotEmpty) {
                      isBusinessProfileView == 0;

                      if (isBusinessProfileView != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Premiun(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => bussinessprofile(
                              int.parse(result.fromUserId.toString()),
                            ),
                          ),
                        );
                      }
                    }
                    break;

                  // Add other cas

                  case "profile_review":
                    if (result.fromUserId.toString().isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Review(result.fromUserId.toString()),
                        ),
                      );
                    }
                    break;

                  case "salepost":
                  case "post_view":
                  case "post_share":
                    if (result.salepostId != null &&
                        result.salepostId!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Buyer_sell_detail(
                            post_type: 'SalePost',
                            prod_id: result.salepostId,
                          ),
                        ),
                      );
                    } else {
                      if (result.buypostId!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Buyer_sell_detail(
                              post_type: 'BuyPost',
                              prod_id: result.buypostId,
                            ),
                          ),
                        );
                      }
                    }
                    break;

                  case "live_price":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LivepriceScreen(),
                      ),
                    );
                    break;

                  case "quicknews":
                  case "quick_news_notification":
                  case "news":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(3),
                      ),
                    );
                    break;

                  case "blog":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Blog(),
                      ),
                    );
                    break;

                  case "video":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Videos(),
                      ),
                    );
                    break;

                  case "tutorial_video":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Tutorial_Videos(),
                      ),
                    );
                    break;

                  case "exhibition":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Exhibition(),
                      ),
                    );
                    break;

                  case "banner":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(0),
                      ),
                    );
                    break;

                  case "plan_list":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Premiun(),
                      ),
                    );
                    break;

                  default:
                    print("Unknown notification type");
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox.fromSize(
                          size: const Size.fromRadius(38),
                          child: Image(
                            errorBuilder: (context, object, trace) {
                              return Image.asset(
                                  'assets/plastic4trade logo final 1 (2).png');
                            },
                            image: NetworkImage(result.profilepic.toString()),
                            width: MediaQuery.of(context).size.width / 1.2,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      10.sbw,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      result.heading.toString(),
                                      style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryColor,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(
                                              fontSize: 13,
                                              color: Colors.black),
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(create_formattedDate,
                                      style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontFamily:
                                                  'assets/fonst/Metropolis-Black.otf')
                                          .copyWith(
                                              fontSize: 12,
                                              color: Colors.black),
                                      maxLines: 1,
                                      softWrap: false),
                                ],
                              ),
                              3.sbh,
                              Text(
                                result.description.toString(),
                                style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf')
                                    .copyWith(
                                        fontSize: 12, color: Colors.black),
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              3.sbh,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        child: Image.asset(
                                          'assets/plastic4trade logo final 1 (2).png',
                                          height: 25,
                                          width: 25,
                                        ),
                                      ),
                                      result.fromUserId.toString() == 0
                                          ? Text(result.name.toString(),
                                              style: const TextStyle(
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'assets/fonst/Metropolis-Black.otf')
                                                  .copyWith(
                                                      fontSize: 12,
                                                      color: Colors.black),
                                              maxLines: 1,
                                              softWrap: false)
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              child: Text(
                                                  result.name.toString(),
                                                  style: const TextStyle(
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'assets/fonst/Metropolis-Black.otf')
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color: Colors.black),
                                                  maxLines: 1,
                                                  softWrap: false),
                                            ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () {
                                        setState(
                                          () {
                                            iconVisibilityMap2[result
                                                .notificationId
                                                .toString()] = false;

                                            adminremove_notification(result
                                                    .notificationId
                                                    .toString())
                                                .then(
                                              (_) async {
                                                await get_notification_unread(
                                                  read_status,
                                                  '0',
                                                  '20',
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: iconVisibilityMap2[result
                                                  .notificationId
                                                  .toString()] ??
                                              true
                                          ? Icon(
                                              Icons.delete,
                                              color: AppColors.red,
                                            )
                                          : Icon(
                                              Icons.delete,
                                              color: AppColors.gray,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  bool notificationUnreadDataToLoad() {
    int itemsPerPage = 20;
    return unread_getnotifydata.length % itemsPerPage == 0;
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      fetch_allNotification(offset: offset.toString(), limit: '20');
      get_notification(read_status, offset.toString(), '20');
      read_status = "0";
      get_notification_unread(read_status, offset.toString(), '20');
    }
  }

  Future<void> fetch_allNotification(
      {required String offset, required String limit}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';

    print('Device Name: $device');

    var res = await getAllnotification(
      userId: pref.getString('user_id').toString(),
      userToken: pref.getString('userToken').toString(),
      offset: offset,
      limit: limit,
      device: device,
    );

    print('Full Response: ${jsonEncode(res)}');

    if (res['status'] == 1 && res['result'] != null) {
      if (offset == '0') {
        getallnotifydata.clear(); // Clear data on refresh
      }

      var jsonarray = res['result'];
      for (var data in jsonarray) {
        print('Processing notification: ${data['notificationId']}');
        admin_getnotifi.Result record = admin_getnotifi.Result(
          notificationId: data['notificationId'],
          blogId: data['blog_id'],
          newsId: data['news_id'],
          type: data['type'],
          advertiseId: data['advertise_id'],
          buypostId: data['buypost_id'],
          description: data['description'],
          fromUserId: data['from_user_id'] != null
              ? int.parse(data['from_user_id'].toString())
              : 0,
          heading: data['heading'],
          livepriceId: data['liveprice_id'],
          notificationType: data['notification_type'],
          postImage: data['post_image'],
          profilepic: data['profilepic'],
          salepostId: data['salepost_id'],
          time: data['time'],
          name: data['name'],
          isAdminNotificationTable: data['is_admin_notification_table'],
          ischeckadminuser: data['notification_source'],
          isRead: int.tryParse(data['is_read'].toString()) ?? 2,
        );

        getallnotifydata.add(record);
      }

      isload = true;
      if (mounted) {
        setState(() {}); // Ensure UI update
      }
    } else if (res['status'] == 2) {
      isload = true;
    } else {
      isload = true;
      showCustomToast(res['message']);
    }
  }

  Future<void> get_notification(
      String isread, String offset, String limit) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    try {
      var res = await getnotification(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        isread,
        offset,
        limit,
        device,
      );

      if (res['status'] == 1) {
        if (res['result'] != null) {
          // Clear data for a fresh load if `offset` is 0
          if (offset == '0') {
            getnotifydata.clear();
          }

          var jsonArray = res['result'];

          // Compress JSON data using Gzip compression for size check (optional)
          List<int> compressedData =
              GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));
          print('Size of compressed data: ${compressedData.length} bytes');

          for (var data in jsonArray) {
            getnotifi.Result record = getnotifi.Result(
              notificationId: data['notificationId'],
              blogId: data['blog_id'],
              newsId: data['news_id'],
              type: data['type'],
              advertiseId: data['advertise_id'],
              buypostId: data['buypost_id'],
              description: data['description'],
              followId: data['follow_id'],
              fromUserId: data['from_user_id'],
              heading: data['heading'],
              isFollow: data['is_follow'],
              livepriceId: data['liveprice_id'],
              notificationType: data['notification_type'],
              otherImage: data['other_image'],
              postImage: data['post_image'],
              profilepic: data['profilepic'],
              salepostId: data['salepost_id'],
              time: data['time'],
              name: data['name'],
              isRead: data['is_read'],
              ischeckadminuser: data['notification_source'],
            );

            // Add parsed record to the data list
            getnotifydata.add(record);
          }

          // Update business profile view variable if required
          isBusinessProfileView = jsonArray.isNotEmpty
              ? jsonArray.last['can_business_profile_view']
              : false;

          // Refresh UI
          if (mounted) {
            setState(() {});
          }
        }
      } else {
        // Handle unsuccessful status
        showCustomToast(res['message']);
      }
    } catch (error) {
      print('Error fetching notifications: $error');
      showCustomToast('Failed to load notifications. Please try again.');
    }
  }

  Future<void> get_notification_unread(
      String isRead, String offset, String limit) async {
    try {
      // Get user preferences
      SharedPreferences pref = await SharedPreferences.getInstance();

      // Determine device type
      String device = Platform.isAndroid ? 'android' : 'ios';
      print('Device Type: $device');

      // Fetch user ID and API token
      String? userId = pref.getString('user_id');
      String? apiToken = pref.getString('userToken');

      if (userId == null || apiToken == null) {
        print('Error: User ID or API Token is missing');
        return;
      }

      print('Fetching notifications for User ID: $userId');

      // Call API
      var response = await getadminnotification(
        userId,
        apiToken,
        isRead,
        offset,
        limit,
        device,
      );

      // Log full API response for debugging
      print('API Response: $response');

      // Check API response
      if (response['status'] == 1 && response['result'] != null) {
        if (offset == '0') {
          unread_getnotifydata.clear();
        }
        // Compress JSON data for logging purposes
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(response['result'])));
        print('Compressed Data Size: ${compressedData.length} bytes');

        List<dynamic> jsonArray = response['result'];

        // Process each notification
        for (var data in jsonArray) {
          admin_getnotifi.Result record = admin_getnotifi.Result(
            notificationId: data['notificationId'],
            blogId: data['blog_id'],
            newsId: data['news_id'],
            type: data['type'],
            advertiseId: data['advertise_id'],
            buypostId: data['buypost_id'],
            description: data['description'],
            fromUserId: data['from_user_id'],
            heading: data['heading'],
            livepriceId: data['liveprice_id'],
            notificationType: data['notification_type'],
            otherImage: data['other_image'],
            postImage: data['post_image'],
            profilepic: data['profilepic'],
            salepostId: data['salepost_id'],
            time: data['time'],
            name: data['name'],
            isRead: data['is_read'],
          );

          unread_getnotifydata.add(record);
        }

        isload = true;
        print(
            'Notifications successfully loaded: ${unread_getnotifydata.length}');
      } else if (response['status'] == 2) {
        // No notifications available
        isload = true;
        print('No unread notifications found.');
      } else {
        // API returned an error
        isload = true;
        String errorMessage = response['message'] ?? 'Unknown error occurred';
        print('Error: $errorMessage');
        showCustomToast(errorMessage);
      }

      // Refresh UI if mounted
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle exceptions
      print('Error occurred while fetching notifications: $e');
      showCustomToast('Failed to fetch notifications.');
    }
  }

  Future<void> remove_notification(String notify_id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Log the user_id, userToken, and notify_id
    print("User ID: ${pref.getString('user_id')}");
    print("API Token: ${pref.getString('userToken')}");
    print("Notification ID: $notify_id");

    // Make the API call
    var res = await remove_noty(pref.getString('user_id').toString(),
        pref.getString('userToken').toString(), notify_id);

    // Log the response from the API
    print("Response from API remove_notification: $res");

    // Handle the response
    if (res['status'] == 1) {
      if (offset == '0') {
        getallnotifydata.clear();

        getnotifydata.clear();

        unread_getnotifydata.clear();
      }
      print("Notification removed successfully.");
      setState(() {});
      if (mounted) {
        setState(() {});
      }
    } else {
      print("Error removing notification: ${res['message']}");
      showCustomToast(res['message']);
    }
  }

  Future<void> is_Read(String notify_id) async {
    try {
      print("is_Read called with notify_id: $notify_id");

      SharedPreferences pref = await SharedPreferences.getInstance();
      String? userId = pref.getString('user_id');
      String? apiToken = pref.getString('userToken');

      print(
          "Retrieved from SharedPreferences - user_id: $userId, userToken: $apiToken");

      var res =
          await isread_noti(userId.toString(), apiToken.toString(), notify_id);

      print("API response: $res");

      if (res['status'] == 1) {
        print("API call successful, status: ${res['status']}");
        if (mounted) {
          setState(() {});
          print("setState called as widget is mounted.");
        }
      } else {
        print(
            "API call failed, status: ${res['status']}, message: ${res['message']}");
        showCustomToast(res['message']);
      }
    } catch (e) {
      print("Error in is_Read: $e");
    }
  }

  Future<void> adminremove_notification(String notify_id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Log the user_id and userToken values
    print("User ID: ${pref.getString('user_id')}");
    print("API Token: ${pref.getString('userToken')}");

    // Make the API call
    var res = await adminremove_noty(pref.getString('user_id').toString(),
        pref.getString('userToken').toString(), notify_id);

    // Log the response
    print("Response from API adminremove_notification: $res");

    // Handle the response
    if (res['status'] == 1) {
      print("Notification removed successfully.");
      setState(() {});
      if (mounted) {
        setState(() {});
      }
    } else {
      print("Error removing notification: ${res['message']}");
      showCustomToast(res['message']);
    }
  }

  remove_item(notify_id) {
    final index = getnotifydata.indexWhere(
        (element) => element.notificationId.toString() == notify_id);

    setState(() {
      getnotifydata.removeAt(index);
    });

    setState(() {
      unread_getnotifydata.removeAt(index);
    });

    setState(() {});
  }

  Future<void> get_allread() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    // Clear previous data before fetching new notifications
    getallnotifydata.clear();
    getnotifydata.clear();
    unread_getnotifydata.clear();

    // Fetch read notifications
    var res = await getread_all(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));
      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      // Set a flag indicating loading is complete
      isload = true;
    } else {
      // Show error message if the API call fails
      showCustomToast(res['message']);
    }
  }
}
