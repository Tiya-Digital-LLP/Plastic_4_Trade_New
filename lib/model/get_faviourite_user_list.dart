class UserResponse {
  int? status;
  List<UserFav>? data;

  UserResponse({this.status, this.data});

  UserResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <UserFav>[];
      json['data'].forEach((v) {
        data!.add(UserFav.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['status'] = status;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class UserFav {
  int? id;
  String? username;
  String? email;
  String? password;
  String? countryCode;
  String? device;
  String? platform;
  String? phoneno;
  String? userImage;
  String? userToken;
  String? signupDate;
  String? isBlock;
  String? blockDate;
  String? registerStatus;
  String? createdAt;
  String? updatedAt;
  String? emailCode;
  String? emailCodeDateTime;
  String? smsCode;
  String? smsCodeDateTime;
  String? forgotPasswordDateTime;
  String? verifyEmail;
  String? verifySms;
  String? categoryId;
  String? typeId;
  String? gradeId;
  int? stepCounter;
  String? postType;
  String? locationInterest;
  String? coverImage;
  String? isDirector;
  String? directorStartDate;
  String? directorEndDate;
  String? directorCreatedDate;
  String? deletedAt;
  String? isExhibitor;
  String? exhibitorStartDate;
  String? exhibitorEndDate;
  String? exhibitorCreatedDate;
  String? primeStartDate;
  String? primeEndDate;
  int? isPrime;
  int? primePlanId;
  String? businessProfileCount;
  String? notificationPushCount;
  String? paidPostRemaining;
  String? primeCreatedAt;
  String? chatTest;
  int? isUnsubscribeFromEmail;
  String? unsubscribeReason;
  String? appVersion;
  int? isPremiumUser;
  String? premiumStartDate;
  String? premiumEndDate;
  String? premiumCreatedDate;

  UserFav({
    this.id,
    this.username,
    this.email,
    this.password,
    this.countryCode,
    this.device,
    this.platform,
    this.phoneno,
    this.userImage,
    this.userToken,
    this.signupDate,
    this.isBlock,
    this.blockDate,
    this.registerStatus,
    this.createdAt,
    this.updatedAt,
    this.emailCode,
    this.emailCodeDateTime,
    this.smsCode,
    this.smsCodeDateTime,
    this.forgotPasswordDateTime,
    this.verifyEmail,
    this.verifySms,
    this.categoryId,
    this.typeId,
    this.gradeId,
    this.stepCounter,
    this.postType,
    this.locationInterest,
    this.coverImage,
    this.isDirector,
    this.directorStartDate,
    this.directorEndDate,
    this.directorCreatedDate,
    this.deletedAt,
    this.isExhibitor,
    this.exhibitorStartDate,
    this.exhibitorEndDate,
    this.exhibitorCreatedDate,
    this.primeStartDate,
    this.primeEndDate,
    this.isPrime,
    this.primePlanId,
    this.businessProfileCount,
    this.notificationPushCount,
    this.paidPostRemaining,
    this.primeCreatedAt,
    this.chatTest,
    this.isUnsubscribeFromEmail,
    this.unsubscribeReason,
    this.appVersion,
    this.isPremiumUser,
    this.premiumStartDate,
    this.premiumEndDate,
    this.premiumCreatedDate,
  });

  UserFav.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
    countryCode = json['countryCode'];
    device = json['device'];
    platform = json['platform'];
    phoneno = json['phoneno'];
    userImage = json['userImage'];
    userToken = json['userToken'];
    signupDate = json['signup_date'];
    isBlock = json['is_block'];
    blockDate = json['blockDate'];
    registerStatus = json['register_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    emailCode = json['email_code'];
    emailCodeDateTime = json['emailCodeDateTime'];
    smsCode = json['sms_code'];
    smsCodeDateTime = json['smsCodeDateTime'];
    forgotPasswordDateTime = json['forgotpasswordDateTime'];
    verifyEmail = json['verify_email'];
    verifySms = json['verify_sms'];
    categoryId = json['category_id'];
    typeId = json['type_id'];
    gradeId = json['grade_id'];
    stepCounter = json['step_counter'];
    postType = json['posttype'];
    locationInterest = json['location_interest'];
    coverImage = json['coverImage'];
    isDirector = json['is_director'];
    directorStartDate = json['director_start_date'];
    directorEndDate = json['director_end_date'];
    directorCreatedDate = json['director_created_date'];
    deletedAt = json['deleted_at'];
    isExhibitor = json['is_exhibitor'];
    exhibitorStartDate = json['exhibitor_start_date'];
    exhibitorEndDate = json['exhibitor_end_date'];
    exhibitorCreatedDate = json['exhibitor_created_date'];
    primeStartDate = json['prime_start_date'];
    primeEndDate = json['prime_end_date'];
    isPrime = json['is_prime'];
    primePlanId = json['prime_plan_id'];
    businessProfileCount = json['business_profile_count'];
    notificationPushCount = json['notification_push_count'];
    paidPostRemaining = json['paid_post_remaining'];
    primeCreatedAt = json['prime_created_at'];
    chatTest = json['chat_test'];
    isUnsubscribeFromEmail = json['is_unsubscribe_from_email'];
    unsubscribeReason = json['unsubscribe_reason'];
    appVersion = json['app_version'];
    isPremiumUser = json['is_premium_user'];
    premiumStartDate = json['premium_start_date'];
    premiumEndDate = json['premium_end_date'];
    premiumCreatedDate = json['premium_created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['id'] = id;
    dataMap['username'] = username;
    dataMap['email'] = email;
    dataMap['password'] = password;
    dataMap['countryCode'] = countryCode;
    dataMap['device'] = device;
    dataMap['platform'] = platform;
    dataMap['phoneno'] = phoneno;
    dataMap['userImage'] = userImage;
    dataMap['userToken'] = userToken;
    dataMap['signup_date'] = signupDate;
    dataMap['is_block'] = isBlock;
    dataMap['blockDate'] = blockDate;
    dataMap['register_status'] = registerStatus;
    dataMap['created_at'] = createdAt;
    dataMap['updated_at'] = updatedAt;
    dataMap['email_code'] = emailCode;
    dataMap['emailCodeDateTime'] = emailCodeDateTime;
    dataMap['sms_code'] = smsCode;
    dataMap['smsCodeDateTime'] = smsCodeDateTime;
    dataMap['forgotpasswordDateTime'] = forgotPasswordDateTime;
    dataMap['verify_email'] = verifyEmail;
    dataMap['verify_sms'] = verifySms;
    dataMap['category_id'] = categoryId;
    dataMap['type_id'] = typeId;
    dataMap['grade_id'] = gradeId;
    dataMap['step_counter'] = stepCounter;
    dataMap['posttype'] = postType;
    dataMap['location_interest'] = locationInterest;
    dataMap['coverImage'] = coverImage;
    dataMap['is_director'] = isDirector;
    dataMap['director_start_date'] = directorStartDate;
    dataMap['director_end_date'] = directorEndDate;
    dataMap['director_created_date'] = directorCreatedDate;
    dataMap['deleted_at'] = deletedAt;
    dataMap['is_exhibitor'] = isExhibitor;
    dataMap['exhibitor_start_date'] = exhibitorStartDate;
    dataMap['exhibitor_end_date'] = exhibitorEndDate;
    dataMap['exhibitor_created_date'] = exhibitorCreatedDate;
    dataMap['prime_start_date'] = primeStartDate;
    dataMap['prime_end_date'] = primeEndDate;
    dataMap['is_prime'] = isPrime;
    dataMap['prime_plan_id'] = primePlanId;
    dataMap['business_profile_count'] = businessProfileCount;
    dataMap['notification_push_count'] = notificationPushCount;
    dataMap['paid_post_remaining'] = paidPostRemaining;
    dataMap['prime_created_at'] = primeCreatedAt;
    dataMap['chat_test'] = chatTest;
    dataMap['is_unsubscribe_from_email'] = isUnsubscribeFromEmail;
    dataMap['unsubscribe_reason'] = unsubscribeReason;
    dataMap['app_version'] = appVersion;
    dataMap['is_premium_user'] = isPremiumUser;
    dataMap['premium_start_date'] = premiumStartDate;
    dataMap['premium_end_date'] = premiumEndDate;
    dataMap['premium_created_date'] = premiumCreatedDate;
    return dataMap;
  }
}
