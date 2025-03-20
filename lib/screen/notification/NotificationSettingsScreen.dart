import 'dart:io';
import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/model/notification_settings_model.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notificationsetting extends StatefulWidget {
  const Notificationsetting({Key? key}) : super(key: key);

  @override
  State<Notificationsetting> createState() => _NotificationsettingState();
}

class _NotificationsettingState extends State<Notificationsetting> {
  NotificationSettings? notificationSettings;

  @override
  void initState() {
    super.initState();
    fetchNotificationSettings();
  }

  Future<void> fetchNotificationSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';

    // Fetching the current notification settings
    NotificationSettings? settings = await getNotificationSettings(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    if (settings != null) {
      setState(() {
        notificationSettings = settings;
      });
    }
  }

  Future<bool> updateNotificationSetting(bool value, String settingKey) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Get user preferences from SharedPreferences
    String userId = pref.getString('user_id').toString();
    String userToken = pref.getString('userToken').toString();

    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    // Keep the current state of all settings in a map
    Map<String, int> settingsMap = {
      "postComment": notificationSettings!.settings!.postComment,
      "favourite": notificationSettings!.settings!.favourite,
      "businessProfileLike":
          notificationSettings!.settings!.businessProfileLike,
      "userFollow": notificationSettings!.settings!.userFollow,
      "userUnfollow": notificationSettings!.settings!.userUnfollow,
      "livePrice": notificationSettings!.settings!.livePrice,
      "quickNews": notificationSettings!.settings!.quickNews,
      "news": notificationSettings!.settings!.news,
      "blog": notificationSettings!.settings!.blog,
      "video": notificationSettings!.settings!.video,
      "banner": notificationSettings!.settings!.banner,
      "chat": notificationSettings!.settings!.chat,
      "salePost": notificationSettings!.settings!.salePost,
      "buyPost": notificationSettings!.settings!.buyPost,
      "domestic": notificationSettings!.settings!.domestic,
      "international": notificationSettings!.settings!.international,
      "categoryTypeGradeMatch":
          notificationSettings!.settings!.categoryTypeGradeMatch,
      "followers": notificationSettings!.settings!.followers,
      "postInterested": notificationSettings!.settings!.postInterested,
    };

    // Update only the toggled setting
    settingsMap[settingKey] = value ? 1 : 0;

    try {
      // Make the API call to update the notification setting
      NotificationSettings? updatedSettings = await updateNotificationSettings(
        userId,
        userToken,
        device,
        settingsMap["postComment"]!,
        settingsMap["favourite"]!,
        settingsMap["businessProfileLike"]!,
        settingsMap["userFollow"]!,
        settingsMap["userUnfollow"]!,
        settingsMap["livePrice"]!,
        settingsMap["quickNews"]!,
        settingsMap["news"]!,
        settingsMap["blog"]!,
        settingsMap["video"]!,
        settingsMap["banner"]!,
        settingsMap["chat"]!,
        settingsMap["salePost"]!,
        settingsMap["buyPost"]!,
        settingsMap["domestic"]!,
        settingsMap["international"]!,
        settingsMap["categoryTypeGradeMatch"]!,
        settingsMap["followers"]!,
        settingsMap["postInterested"]!,
      );

      if (updatedSettings != null) {
        setState(() {
          notificationSettings = updatedSettings;
        });
        showCustomToast('Settings updated successfully!');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error updating notification settings: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Notification Settings',
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
      ),
      body: notificationSettings == null
          ? const Center(child: CircularProgressIndicator())
          : notificationsetting(),
    );
  }

  Widget notificationsetting() {
    final settings = notificationSettings!.settings!;

    List<Map<String, dynamic>> settingsList = [
      {
        "title": "Sell Post",
        "key": "salePost",
        "value": settings.salePost == 1
      },
      {"title": "Buy Post", "key": "buyPost", "value": settings.buyPost == 1},
      {"title": "Domestic", "key": "domestic", "value": settings.domestic == 1},
      {
        "title": "International",
        "key": "international",
        "value": settings.international == 1
      },
      {
        "title": "Category, Type, Grade Match",
        "key": "categoryTypeGradeMatch",
        "value": settings.categoryTypeGradeMatch == 1
      },
      {
        "title": "Followers",
        "key": "followers",
        "value": settings.followers == 1
      },
      {
        "title": "Post Interested",
        "key": "postInterested",
        "value": settings.postInterested == 1
      },
      {
        "title": "Post Comment",
        "key": "postComment",
        "value": settings.postComment == 1
      },
      {
        "title": "Favourite",
        "key": "favourite",
        "value": settings.favourite == 1
      },
      {
        "title": "Business Profile Like",
        "key": "businessProfileLike",
        "value": settings.businessProfileLike == 1
      },
      {
        "title": "User Follow",
        "key": "userFollow",
        "value": settings.userFollow == 1
      },
      {
        "title": "User Unfollow",
        "key": "userUnfollow",
        "value": settings.userUnfollow == 1
      },
      {
        "title": "Live Price",
        "key": "livePrice",
        "value": settings.livePrice == 1
      },
      {
        "title": "Quick News",
        "key": "quickNews",
        "value": settings.quickNews == 1
      },
      {"title": "News", "key": "news", "value": settings.news == 1},
      {"title": "Blog", "key": "blog", "value": settings.blog == 1},
      {"title": "Video", "key": "video", "value": settings.video == 1},
      {"title": "Banner", "key": "banner", "value": settings.banner == 1},
      {"title": "Chat", "key": "chat", "value": settings.chat == 1},
    ];

    return Container(
      margin: const EdgeInsets.all(10.0),
      child: ListView.builder(
        itemCount: settingsList.length,
        itemBuilder: (context, index) {
          final item = settingsList[index];
          return SizedBox(
            height: 65,
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0, 5.0, 0.0),
                      child: Icon(
                        Icons.notifications_none,
                        color: Colors.black54,
                        size: 30,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item["title"],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Switch(
                          value: item["value"] as bool,
                          onChanged: (bool value) async {
                            // Store the previous value in case we need to revert if the API call fails
                            bool previousValue = item["value"] as bool;

                            // Update the local state immediately to reflect the switch change
                            setState(() {
                              item["value"] = value;
                            });

                            // Call the API to update the notification setting on the server
                            bool apiSuccess = await updateNotificationSetting(
                                value, item["key"]);

                            if (!apiSuccess) {
                              // If API call fails, revert the state back to the previous value
                              setState(() {
                                item["value"] = previousValue;
                              });
                            }
                          },
                          activeColor: AppColors.primaryColor,
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
