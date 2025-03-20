class NotificationSettings {
  bool success;
  Settings? settings;

  NotificationSettings({required this.success, this.settings});

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      success: json['success'],
      settings: json.containsKey('settings') && json['settings'] != null
          ? Settings.fromJson(json['settings'])
          : null,
    );
  }
}

class Settings {
  int userId;
  int postComment;
  int favourite;
  int businessProfileLike;
  int userFollow;
  int userUnfollow;
  int livePrice;
  int quickNews;
  int news;
  int blog;
  int video;
  int banner;
  int chat;
  int salePost;
  int buyPost;
  int domestic;
  int international;
  int categoryTypeGradeMatch;
  int followers;
  int postInterested;

  Settings({
    required this.userId,
    required this.postComment,
    required this.favourite,
    required this.businessProfileLike,
    required this.userFollow,
    required this.userUnfollow,
    required this.livePrice,
    required this.quickNews,
    required this.news,
    required this.blog,
    required this.video,
    required this.banner,
    required this.chat,
    required this.salePost,
    required this.buyPost,
    required this.domestic,
    required this.international,
    required this.categoryTypeGradeMatch,
    required this.followers,
    required this.postInterested,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      userId: json['user_id'],
      postComment: json['post_comment'],
      favourite: json['favourite'],
      businessProfileLike: json['business_profile_like'],
      userFollow: json['user_follow'],
      userUnfollow: json['user_unfollow'],
      livePrice: json['live_price'],
      quickNews: json['quick_news'],
      news: json['news'],
      blog: json['blog'],
      video: json['video'],
      banner: json['banner'],
      chat: json['chat'],
      salePost: json['sale_post'],
      buyPost: json['buy_post'],
      domestic: json['domestic'],
      international: json['international'],
      categoryTypeGradeMatch: json['category_type_grade_match'],
      followers: json['followers'],
      postInterested: json['post_interested'],
    );
  }
}
