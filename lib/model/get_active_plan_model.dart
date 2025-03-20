class ActivePlan {
  final int? id;
  final int? userId;
  final int? planId;
  final String? planName;
  final String? transactionId;
  final String? livePrice;
  final String? news;
  final String? chat;
  final int? businessProfile;
  final int? notificationAds;
  final int? paidPost;
  final String? directory;
  final String? exhibition;
  final int? timeDuration;
  final String? priceInr;
  final String? priceDollar;
  final String? endDate;
  final String? couponDiscount;
  final String? couponName;
  final String? salesmanId;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  ActivePlan({
    this.id,
    this.userId,
    this.planId,
    this.planName,
    this.transactionId,
    this.livePrice,
    this.news,
    this.chat,
    this.businessProfile,
    this.notificationAds,
    this.paidPost,
    this.directory,
    this.exhibition,
    this.timeDuration,
    this.priceInr,
    this.priceDollar,
    this.endDate,
    this.couponDiscount,
    this.couponName,
    this.salesmanId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ActivePlan.fromJson(Map<String, dynamic> json) {
    return ActivePlan(
      id: json['id'],
      userId: json['user_id'],
      planId: json['plan_id'],
      planName: json['plan_name'],
      transactionId: json['transection_id'],
      livePrice: json['live_price'],
      news: json['news'],
      chat: json['chat'],
      businessProfile: json['business_profile'],
      notificationAds: json['notification_ads'],
      paidPost: json['paid_post'],
      directory: json['directory'],
      exhibition: json['exhibition'],
      timeDuration: json['time_duration'],
      priceInr: json['price_inr'],
      priceDollar: json['price_dollar'],
      endDate: json['end_date'],
      couponDiscount: json['coupon_discount'],
      couponName: json['coupon_name'],
      salesmanId: json['salesman_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'plan_name': planName,
      'transection_id': transactionId,
      'live_price': livePrice,
      'news': news,
      'chat': chat,
      'business_profile': businessProfile,
      'notification_ads': notificationAds,
      'paid_post': paidPost,
      'directory': directory,
      'exhibition': exhibition,
      'time_duration': timeDuration,
      'price_inr': priceInr,
      'price_dollar': priceDollar,
      'end_date': endDate,
      'coupon_discount': couponDiscount,
      'coupon_name': couponName,
      'salesman_id': salesmanId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}
