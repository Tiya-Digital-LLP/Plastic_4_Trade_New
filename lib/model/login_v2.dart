class LoginV2 {
  final int status;
  final String message;
  final String emailVerified;
  final UserData userData;

  LoginV2({
    required this.status,
    required this.message,
    required this.emailVerified,
    required this.userData,
  });

  factory LoginV2.fromJson(Map<String, dynamic> json) {
    return LoginV2(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      emailVerified: json['email_verifyed'] ?? '0',
      userData: UserData.fromJson(json['user_data'] ?? {}),
    );
  }
}

class UserData {
  final int id;
  final String? username;
  final String? email;
  final String? password;
  final String countryCode;
  final String? secondaryPhoneNo;
  final String? secondaryCountryCode;
  final String? device;
  final String? platform;
  final String phoneNo;
  final String userImage;
  final String userToken;
  final String? signupDate;
  final int isBlock;
  final String? blockDate;
  final int registerStatus;
  final String createdAt;
  final String updatedAt;
  final String? emailCode;
  final String? emailCodeDateTime;
  final String? smsCode;
  final String? smsCodeDateTime;
  final String? forgotPasswordDateTime;
  final String verifyEmail;
  final int verifySms;
  final String? categoryId;
  final String? typeId;
  final String? gradeId;
  final int stepCounter;
  final String postType;
  final String locationInterest;
  final String coverImage;
  final int isDirector;
  final String? directorStartDate;
  final String? directorEndDate;
  final String? directorCreatedDate;
  final String? deletedAt;
  final int isExhibitor;
  final String? exhibitorStartDate;
  final String? exhibitorEndDate;
  final String? exhibitorCreatedDate;
  final String? primeStartDate;
  final String? primeEndDate;
  final int isPrime;
  final int primePlanId;
  final String businessProfileCount;
  final String notificationPushCount;
  final String paidPostRemaining;
  final String? primeCreatedAt;
  final String chatTest;
  final int isUnsubscribeFromEmail;
  final String? unsubscribeReason;
  final String? appVersion;
  final int isPremiumUser;
  final String? sourceId;
  final String? registerBy;
  final String? employeeId;
  final String? city;
  final String? country;
  final String? state;
  final String? databaseCompany;
  final String? databaseAddress;
  final String? remark;
  final String? premiumStartDate;
  final String? premiumEndDate;
  final String? premiumCreatedDate;

  UserData({
    required this.id,
    this.username,
    this.email,
    this.password,
    required this.countryCode,
    this.secondaryPhoneNo,
    this.secondaryCountryCode,
    this.device,
    this.platform,
    required this.phoneNo,
    required this.userImage,
    required this.userToken,
    this.signupDate,
    required this.isBlock,
    this.blockDate,
    required this.registerStatus,
    required this.createdAt,
    required this.updatedAt,
    this.emailCode,
    this.emailCodeDateTime,
    this.smsCode,
    this.smsCodeDateTime,
    this.forgotPasswordDateTime,
    required this.verifyEmail,
    required this.verifySms,
    this.categoryId,
    this.typeId,
    this.gradeId,
    required this.stepCounter,
    required this.postType,
    required this.locationInterest,
    required this.coverImage,
    required this.isDirector,
    this.directorStartDate,
    this.directorEndDate,
    this.directorCreatedDate,
    this.deletedAt,
    required this.isExhibitor,
    this.exhibitorStartDate,
    this.exhibitorEndDate,
    this.exhibitorCreatedDate,
    this.primeStartDate,
    this.primeEndDate,
    required this.isPrime,
    required this.primePlanId,
    required this.businessProfileCount,
    required this.notificationPushCount,
    required this.paidPostRemaining,
    this.primeCreatedAt,
    required this.chatTest,
    required this.isUnsubscribeFromEmail,
    this.unsubscribeReason,
    this.appVersion,
    required this.isPremiumUser,
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
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      username: json['username'],
      email: json['email'],
      password: json['password'],
      countryCode: json['countryCode'] ?? '',
      secondaryPhoneNo: json['secondary_phoneno'],
      secondaryCountryCode: json['secondary_country_code'],
      device: json['device'],
      platform: json['platform'],
      phoneNo: json['phoneno'] ?? '',
      userImage: json['userImage'] ?? '',
      userToken: json['userToken'] ?? '',
      signupDate: json['signup_date'],
      isBlock: int.tryParse(json['is_block'].toString()) ?? 0,
      blockDate: json['blockDate'],
      registerStatus: json['register_status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      emailCode: json['email_code'],
      emailCodeDateTime: json['emailCodeDateTime'],
      smsCode: json['sms_code'],
      smsCodeDateTime: json['smsCodeDateTime'],
      forgotPasswordDateTime: json['forgotpasswordDateTime'],
      verifyEmail: json['verify_email'] ?? '0',
      verifySms: json['verify_sms'] ?? 0,
      categoryId: json['category_id'],
      typeId: json['type_id'],
      gradeId: json['grade_id'],
      stepCounter: json['step_counter'] ?? 0,
      postType: json['posttype'] ?? '',
      locationInterest: json['location_interest'] ?? '',
      coverImage: json['coverImage'] ?? '',
      isDirector: int.tryParse(json['is_director'].toString()) ?? 0,
      directorStartDate: json['director_start_date'],
      directorEndDate: json['director_end_date'],
      directorCreatedDate: json['director_created_date'],
      deletedAt: json['deleted_at'],
      isExhibitor: int.tryParse(json['is_exhibitor'].toString()) ?? 0,
      exhibitorStartDate: json['exhibitor_start_date'],
      exhibitorEndDate: json['exhibitor_end_date'],
      exhibitorCreatedDate: json['exhibitor_created_date'],
      primeStartDate: json['prime_start_date'],
      primeEndDate: json['prime_end_date'],
      isPrime: json['is_prime'] ?? 0,
      primePlanId: json['prime_plan_id'] ?? 0,
      businessProfileCount: json['business_profile_count'] ?? '0',
      notificationPushCount: json['notification_push_count'] ?? '0',
      paidPostRemaining: json['paid_post_remaining'] ?? '0',
      primeCreatedAt: json['prime_created_at'],
      chatTest: json['chat_test'] ?? '0',
      isUnsubscribeFromEmail: json['is_unsubscribe_from_email'] ?? 0,
      isPremiumUser: json['is_premium_user'] ?? 0,
    );
  }
}
