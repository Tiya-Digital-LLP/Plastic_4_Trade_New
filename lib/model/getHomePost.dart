class getHomePost {
  int? status;
  String? message;
  List<Result>? result;
  bool? emailVerified;
  Users? users;

  getHomePost(
      {this.status, this.message, this.result, this.emailVerified, this.users});

  getHomePost.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    emailVerified = json['email_verified'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
    users = json['users'] != null ? Users.fromJson(json['users']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['email_verified'] = emailVerified;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    if (users != null) {
      data['users'] = users!.toJson();
    }
    return data;
  }
}

class Result {
  int? productId;
  int? userId;
  String? userName;
  String? userEmail;
  String? postType;
  String? categoryId;
  String? categoryName;
  String? postName;
  String? productTypeId;
  String? productType;
  String? productGradeId;
  String? productGrade;
  String? currency;
  String? productPrice;
  String? unit;
  String? postQuntity;
  List<PostColor>? postColor;
  String? location;
  String? latitude;
  String? longitude;
  String? city;
  String? state;
  String? country;
  String? description;
  String? mainproductImage;
  List<SubproductImage>? subproductImage;
  String? isPaidPost;

  Result({
    this.productId,
    this.userId,
    this.userName,
    this.userEmail,
    this.postType,
    this.categoryId,
    this.categoryName,
    this.postName,
    this.productTypeId,
    this.productType,
    this.productGradeId,
    this.productGrade,
    this.currency,
    this.productPrice,
    this.unit,
    this.postQuntity,
    this.postColor,
    this.location,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.description,
    this.mainproductImage,
    this.subproductImage,
    this.isPaidPost,
  });

  Result.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    userId = json['UserId'];
    userName = json['UserName'];
    userEmail = json['UserEmail'];
    postType = json['PostType'];
    categoryId = json['categoryId'];
    categoryName = json['CategoryName'];
    postName = json['PostName'];
    productTypeId = json['ProductTypeId'];
    productType = json['ProductType'];
    productGradeId = json['ProductGradeId'];
    productGrade = json['ProductGrade'];
    currency = json['Currency'];
    productPrice = json['ProductPrice'];
    unit = json['Unit'];
    postQuntity = json['PostQuntity'];
    if (json['PostColor'] != null) {
      postColor = <PostColor>[];
      json['PostColor'].forEach((v) {
        postColor!.add(PostColor.fromJson(v));
      });
    }
    location = json['Location'];
    latitude = json['Latitude'];
    longitude = json['Longitude'];
    city = json['City'];
    state = json['State'];
    country = json['Country'];
    description = json['Description'];
    mainproductImage = json['mainproductImage'];
    if (json['subproductImage'] != null) {
      subproductImage = <SubproductImage>[];
      json['subproductImage'].forEach((v) {
        subproductImage!.add(SubproductImage.fromJson(v));
      });
    }
    isPaidPost = json['is_paid_post'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['UserId'] = userId;
    data['UserName'] = userName;
    data['UserEmail'] = userEmail;
    data['PostType'] = postType;
    data['categoryId'] = categoryId;
    data['CategoryName'] = categoryName;
    data['PostName'] = postName;
    data['ProductTypeId'] = productTypeId;
    data['ProductType'] = productType;
    data['ProductGradeId'] = productGradeId;
    data['ProductGrade'] = productGrade;
    data['Currency'] = currency;
    data['ProductPrice'] = productPrice;
    data['Unit'] = unit;
    data['PostQuntity'] = postQuntity;
    if (postColor != null) {
      data['PostColor'] = postColor!.map((v) => v.toJson()).toList();
    }
    data['Location'] = location;
    data['Latitude'] = latitude;
    data['Longitude'] = longitude;
    data['City'] = city;
    data['State'] = state;
    data['Country'] = country;
    data['Description'] = description;
    data['mainproductImage'] = mainproductImage;
    if (subproductImage != null) {
      data['subproductImage'] =
          subproductImage!.map((v) => v.toJson()).toList();
    }
    data['is_paid_post'] = isPaidPost;
    return data;
  }
}

class PostColor {
  String? colorId;
  String? colorName;
  String? haxCode;

  PostColor({this.colorId, this.colorName, this.haxCode});

  PostColor.fromJson(Map<String, dynamic> json) {
    colorId = json['colorId'];
    colorName = json['colorName'];
    haxCode = json['HaxCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['colorId'] = colorId;
    data['colorName'] = colorName;
    data['HaxCode'] = haxCode;
    return data;
  }
}

class SubproductImage {
  int? productImageId;
  String? subImageUrl;

  SubproductImage({this.productImageId, this.subImageUrl});

  SubproductImage.fromJson(Map<String, dynamic> json) {
    productImageId = json['productImageId'];
    subImageUrl = json['sub_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productImageId'] = productImageId;
    data['sub_image_url'] = subImageUrl;
    return data;
  }
}

class Users {
  int? id;
  String? username;
  String? email;
  String? countryCode;
  String? phoneno;
  String? userImage;
  String? userToken;
  String? signupDate;
  String? registerStatus;
  int? isPremiumUser;
  String? premiumStartDate;
  String? premiumEndDate;
  String? isDirector;
  String? directorStartDate;
  String? directorEndDate;
  String? isExhibitor;
  String? exhibitorStartDate;
  String? exhibitorEndDate;
  int? stepcounter;

  Users({
    this.id,
    this.username,
    this.email,
    this.countryCode,
    this.phoneno,
    this.userImage,
    this.userToken,
    this.signupDate,
    this.registerStatus,
    this.isPremiumUser,
    this.premiumStartDate,
    this.premiumEndDate,
    this.isDirector,
    this.directorStartDate,
    this.directorEndDate,
    this.isExhibitor,
    this.exhibitorStartDate,
    this.exhibitorEndDate,
    this.stepcounter,
  });

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    countryCode = json['countryCode'];
    phoneno = json['phoneno'];
    userImage = json['userImage'];
    userToken = json['userToken'];
    signupDate = json['signup_date'];
    registerStatus = json['register_status'];
    isPremiumUser = json['is_premium_user'];
    premiumStartDate = json['premium_start_date'];
    premiumEndDate = json['premium_end_date'];
    isDirector = json['is_director'];
    directorStartDate = json['director_start_date'];
    directorEndDate = json['director_end_date'];
    isExhibitor = json['is_exhibitor'];
    exhibitorStartDate = json['exhibitor_start_date'];
    exhibitorEndDate = json['exhibitor_end_date'];
    stepcounter = json['step_counter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['countryCode'] = countryCode;
    data['phoneno'] = phoneno;
    data['userImage'] = userImage;
    data['userToken'] = userToken;
    data['signup_date'] = signupDate;
    data['register_status'] = registerStatus;
    data['is_premium_user'] = isPremiumUser;
    data['premium_start_date'] = premiumStartDate;
    data['premium_end_date'] = premiumEndDate;
    data['is_director'] = isDirector;
    data['director_start_date'] = directorStartDate;
    data['director_end_date'] = directorEndDate;
    data['is_exhibitor'] = isExhibitor;
    data['exhibitor_start_date'] = exhibitorStartDate;
    data['exhibitor_end_date'] = exhibitorEndDate;
    data['step_counter'] = stepcounter;
    return data;
  }
}
