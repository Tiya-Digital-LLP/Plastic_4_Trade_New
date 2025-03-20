class GetInterestedUser {
  int? status;
  String? message;
  List<InterestedUser>? data;

  GetInterestedUser({this.status, this.message, this.data});

  GetInterestedUser.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <InterestedUser>[];
      json['data'].forEach((v) {
        data!.add(InterestedUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class InterestedUser {
  int? id;
  String? username;
  String? email;
  String? password;
  String? countryCode;
  String? secondaryPhoneNo;
  String? secondaryCountryCode;
  String? device;
  String? platform;
  String? phoneNo;
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
  String? sourceId;
  String? registerBy;
  String? employeeId;
  String? city;
  String? country;
  String? state;
  String? databaseCompany;
  String? databaseAddress;
  String? remark;
  String? premiumStartDate;
  String? premiumEndDate;
  String? premiumCreatedDate;
  String? imageUrl;
  String? businessType;
  String? crownColor;
  String? planName;
  int? canBusinessProfileView;
  int? checkOldView;

  InterestedUser({
    this.id,
    this.username,
    this.email,
    this.password,
    this.countryCode,
    this.secondaryPhoneNo,
    this.secondaryCountryCode,
    this.device,
    this.platform,
    this.phoneNo,
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
    this.sourceId,
    this.registerBy,
    this.employeeId,
    this.city,
    this.country,
    this.state,
    this.databaseCompany,
    this.databaseAddress,
    this.remark,
    this.premiumStartDate,
    this.premiumEndDate,
    this.premiumCreatedDate,
    this.imageUrl,
    this.businessType,
    this.crownColor,
    this.planName,
    this.canBusinessProfileView,
    this.checkOldView,
  });

  InterestedUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
    countryCode = json['countryCode'];
    secondaryPhoneNo = json['secondary_phoneno'];
    secondaryCountryCode = json['secondary_country_code'];
    device = json['device'];
    platform = json['platform'];
    phoneNo = json['phoneno'];
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
    sourceId = json['source_id'];
    registerBy = json['register_by'];
    employeeId = json['employee_id'];
    city = json['city'];
    country = json['country'];
    state = json['state'];
    databaseCompany = json['database_company'];
    databaseAddress = json['database_address'];
    remark = json['remark'];
    premiumStartDate = json['premium_start_date'];
    premiumEndDate = json['premium_end_date'];
    premiumCreatedDate = json['premium_created_date'];
    imageUrl = json['image_url'];
    businessType = json['business_type'];
    crownColor = json['crown_color'];
    planName = json['plan_name'];
    canBusinessProfileView = json['can_business_profile_view'];
    checkOldView = json['check_old_view'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['password'] = password;
    data['countryCode'] = countryCode;
    data['secondary_phoneno'] = secondaryPhoneNo;
    data['secondary_country_code'] = secondaryCountryCode;
    data['device'] = device;
    data['platform'] = platform;
    data['phoneno'] = phoneNo;
    data['userImage'] = userImage;
    data['userToken'] = userToken;
    data['signup_date'] = signupDate;
    data['is_block'] = isBlock;
    data['blockDate'] = blockDate;
    data['register_status'] = registerStatus;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['email_code'] = emailCode;
    data['emailCodeDateTime'] = emailCodeDateTime;
    data['sms_code'] = smsCode;
    data['smsCodeDateTime'] = smsCodeDateTime;
    data['forgotpasswordDateTime'] = forgotPasswordDateTime;
    data['verify_email'] = verifyEmail;
    data['verify_sms'] = verifySms;
    data['category_id'] = categoryId;
    data['type_id'] = typeId;
    data['grade_id'] = gradeId;
    data['step_counter'] = stepCounter;
    data['posttype'] = postType;
    data['location_interest'] = locationInterest;
    data['coverImage'] = coverImage;
    data['is_director'] = isDirector;
    data['director_start_date'] = directorStartDate;
    data['director_end_date'] = directorEndDate;
    data['director_created_date'] = directorCreatedDate;
    data['deleted_at'] = deletedAt;
    data['is_exhibitor'] = isExhibitor;
    data['exhibitor_start_date'] = exhibitorStartDate;
    data['exhibitor_end_date'] = exhibitorEndDate;
    data['exhibitor_created_date'] = exhibitorCreatedDate;
    data['prime_start_date'] = primeStartDate;
    data['prime_end_date'] = primeEndDate;
    data['is_prime'] = isPrime;
    data['prime_plan_id'] = primePlanId;
    data['business_profile_count'] = businessProfileCount;
    data['notification_push_count'] = notificationPushCount;
    data['paid_post_remaining'] = paidPostRemaining;
    data['prime_created_at'] = primeCreatedAt;
    data['chat_test'] = chatTest;
    data['is_unsubscribe_from_email'] = isUnsubscribeFromEmail;
    data['unsubscribe_reason'] = unsubscribeReason;
    data['app_version'] = appVersion;
    data['is_premium_user'] = isPremiumUser;
    data['source_id'] = sourceId;
    data['register_by'] = registerBy;
    data['employee_id'] = employeeId;
    data['city'] = city;
    data['country'] = country;
    data['state'] = state;
    data['database_company'] = databaseCompany;
    data['database_address'] = databaseAddress;
    data['remark'] = remark;
    data['premium_start_date'] = premiumStartDate;
    data['premium_end_date'] = premiumEndDate;
    data['premium_created_date'] = premiumCreatedDate;
    data['image_url'] = imageUrl;
    data['business_type'] = businessType;
    data['crown_color'] = crownColor;
    data['plan_name'] = planName;
    data['can_business_profile_view'] = canBusinessProfileView;
    data['check_old_view'] = checkOldView;
    return data;
  }
}
