class ShowPremiumPlan {
  List<Plan>? plan;
  int? status;
  String? message;
  int? selectedPlan; // Add the current_plan field

  // Constructor with optional parameters
  ShowPremiumPlan({this.plan, this.status, this.message, this.selectedPlan});

  // Named constructor to initialize from JSON
  ShowPremiumPlan.fromJson(Map<String, dynamic> json) {
    if (json['plan'] != null) {
      plan = <Plan>[];
      json['plan'].forEach((v) {
        plan!.add(Plan.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
    selectedPlan = json['current_plan_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (plan != null) {
      data['plan'] = plan!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['message'] = message;
    data['current_plan_id'] = selectedPlan;
    return data;
  }
}

class Plan {
  int? id;
  int? employee_id;
  String? sequence;
  String? name;
  String? livePrice;
  String? livePriceDecription;
  String? news;
  String? newsDecription;
  String? chat;
  String? chatDescription;
  String? showMyContact;
  String? otherContactShow;
  int? businessProfile;
  String? businessProfileDecription;
  int? notificationAds;
  String? notificationAdsDescription;
  int? paidPost;
  String? paidPostDecription;
  String? directory;
  String? directoryDescription;
  String? exhibition;
  String? exhibitionDecription;
  int? timeDuration;
  String? timeDurationInText;
  String? priceInr;
  String? priceDoller;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  int? isActive; // 0 for inactive, 1 for active
  int? isRemaining; // 0 for inactive, 1 for active
  int? currentPlan; // 0 for inactive, 1 for active

  List<Services>? services;
  String? discount; // Change the type to String
  String? discountinr; // Change the type to String
  String? discountdoller; // Change the type to String
  String? offername; // Change the type to String
  String? offernamedoller; // Change the type to String

  String? offerdifference; // Change the type to String

  String? planoriginalprice; // Change the type to String
  String? planoriginalpricedoller; // Change the type to String

  Plan({
    this.id,
    this.employee_id,
    this.sequence,
    this.name,
    this.livePrice,
    this.livePriceDecription,
    this.news,
    this.newsDecription,
    this.chat,
    this.chatDescription,
    this.showMyContact,
    this.otherContactShow,
    this.businessProfile,
    this.businessProfileDecription,
    this.notificationAds,
    this.notificationAdsDescription,
    this.paidPost,
    this.paidPostDecription,
    this.directory,
    this.directoryDescription,
    this.exhibition,
    this.exhibitionDecription,
    this.timeDuration,
    this.timeDurationInText,
    this.priceInr,
    this.priceDoller,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isActive,
    this.isRemaining,
    this.currentPlan,
    this.services,
    this.discount, // Initialize discount
    this.discountinr,
    this.discountdoller,
    this.offername,
    this.offernamedoller,
    this.offerdifference,
    this.planoriginalprice,
    this.planoriginalpricedoller,
  });

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employee_id = json['employee_id'];
    sequence = json['sequence'];
    name = json['name'];
    livePrice = json['live_price'];
    livePriceDecription = json['live_price_decription'];
    news = json['news'];
    newsDecription = json['news_decription'];
    chat = json['chat'];
    chatDescription = json['chat_description'];
    showMyContact = json['show_my_contact'];
    otherContactShow = json['other_contact_show'];
    businessProfile = json['business_profile'];
    businessProfileDecription = json['business_profile_decription'];
    notificationAds = json['notification_ads'];
    notificationAdsDescription = json['notification_ads_description'];
    paidPost = json['paid_post'];
    paidPostDecription = json['paid_post_decription'];
    directory = json['directory'];
    directoryDescription = json['directory_description'];
    exhibition = json['exhibition'];
    exhibitionDecription = json['exhibition_decription'];
    timeDuration = json['time_duration'];
    timeDurationInText = json['time_duration_in_text'];
    priceInr = json['price_inr'];
    priceDoller = json['price_doller'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    isActive = json['is_active']; // Parse isActive
    isRemaining = json['remaining_days']; // Parse isActive

    currentPlan = json['current_plan']; // Parse isActive

    discount = json['discount']?.toString(); // Parse discount as String
    discountinr = json['admin_discounted_price_inr']
        ?.toString(); // Parse discount as String
    discountdoller = json['admin_discounted_price_doller']
        ?.toString(); // Parse discount as String
    offername = json['offer_name']?.toString(); // Parse discount as String
    offernamedoller =
        json['offer_name_for_doller']?.toString(); // Parse discount as String

    offerdifference =
        json['difference']?.toString(); // Parse discount as String

    planoriginalprice =
        json['plan_original_price']?.toString(); // Parse discount as String

    planoriginalpricedoller = json['plan_original_price_doller']
        ?.toString(); // Parse discount as String

    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(Services.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_id'] = employee_id;
    data['sequence'] = sequence;
    data['name'] = name;
    data['live_price'] = livePrice;
    data['live_price_decription'] = livePriceDecription;
    data['news'] = news;
    data['news_decription'] = newsDecription;
    data['chat'] = chat;
    data['chat_description'] = chatDescription;
    data['show_my_contact'] = showMyContact;
    data['other_contact_show'] = otherContactShow;
    data['business_profile'] = businessProfile;
    data['business_profile_decription'] = businessProfileDecription;
    data['notification_ads'] = notificationAds;
    data['notification_ads_description'] = notificationAdsDescription;
    data['paid_post'] = paidPost;
    data['paid_post_decription'] = paidPostDecription;
    data['directory'] = directory;
    data['directory_description'] = directoryDescription;
    data['exhibition'] = exhibition;
    data['exhibition_decription'] = exhibitionDecription;
    data['time_duration'] = timeDuration;
    data['time_duration_in_text'] = timeDurationInText;
    data['price_inr'] = priceInr;
    data['price_doller'] = priceDoller;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['is_active'] = isActive;
    data['current_plan'] = currentPlan;
    data['remaining_days'] = isRemaining;

    if (discount != null) {
      data['discount'] = discount; // Add discount to the JSON map
    }
    if (discountinr != null) {
      data['admin_discounted_price_inr'] =
          discountinr; // Add discount to the JSON map
    }
    if (discountdoller != null) {
      data['admin_discounted_price_doller'] =
          discountdoller; // Add discount to the JSON map
    }
    if (offername != null) {
      data['offer_name'] = offername; // Add discount to the JSON map
    }
    if (offernamedoller != null) {
      data['offer_name_for_doller'] =
          offernamedoller; // Add discount to the JSON map
    }
    if (offerdifference != null) {
      data['difference'] = offerdifference; // Add discount to the JSON map
    }
    if (planoriginalprice != null) {
      data['plan_original_price'] =
          planoriginalprice; // Add discount to the JSON map
    }
    if (planoriginalpricedoller != null) {
      data['plan_original_price_doller'] =
          planoriginalpricedoller; // Add discount to the JSON map
    }
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Services {
  String? title;
  String? value;
  String? description;

  Services({this.title, this.value, this.description});

  Services.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    data['description'] = this.description;
    return data;
  }
}
