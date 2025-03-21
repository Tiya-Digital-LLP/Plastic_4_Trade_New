class GetSalePostList {
  int? status;
  int? totalPost;
  String? message;
  List<Result>? result;

  GetSalePostList({this.status, this.totalPost, this.message, this.result});

  GetSalePostList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalPost = json['total_post'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['total_post'] = status;
    data['message'] = message;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  int? productId;
  int? userId;
  int? boostCount;
  int? premiumBoostCount;

  String? userName;
  int? suspend;

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
  String? city;
  String? state;
  String? country;
  String? longitude;
  String? description;
  String? mainproductImage;
  List<SubproductImage>? subproductImage;
  String? isPaidPost;
  String? isSuspeded;

  String? productStatus;
  String? isLike;
  int? likeCount;
  String? postShortUrl;
  String? isFavorite;
  int? isView;

  Result({
    this.productId,
    this.userId,
    this.boostCount,
    this.premiumBoostCount,
    this.userName,
    this.suspend,
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
    this.city,
    this.state,
    this.country,
    this.longitude,
    this.description,
    this.mainproductImage,
    this.subproductImage,
    this.isPaidPost,
    this.isSuspeded,
    this.productStatus,
    this.isLike,
    this.likeCount,
    this.postShortUrl,
    this.isFavorite,
    this.isView,
  });

  Result.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    userId = json['UserId'];
    boostCount = json['remaining_notification'];
    premiumBoostCount = json['remaining_paid_post'];

    userName = json['UserName'];
    suspend = json['is_approve'];

    userEmail = json['UserEmail'];
    postType = json['PostType'];
    categoryId = json['CategoryId'];
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
    city = json['City'];
    state = json['State'];
    country = json['Country'];
    longitude = json['Longitude'];
    description = json['Description'];
    mainproductImage = json['mainproductImage'];
    if (json['subproductImage'] != null) {
      subproductImage = <SubproductImage>[];
      json['subproductImage'].forEach((v) {
        subproductImage!.add(SubproductImage.fromJson(v));
      });
    }
    isPaidPost = json['is_paid_post'];
    isSuspeded = json['status'];

    productStatus = json['product_status'];
    isLike = json['isLike'];
    likeCount = json['likeCount'];
    postShortUrl = json['post_url'];
    isFavorite = json['isFavorite'];
    isView = json['view_product'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['UserId'] = userId;
    data['remaining_notification'] = boostCount;
    data['remaining_paid_post'] = premiumBoostCount;

    data['UserName'] = userName;
    data['is_approve'] = suspend;

    data['UserEmail'] = userEmail;
    data['PostType'] = postType;
    data['CategoryId'] = categoryId;
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
    data['City'] = city;
    data['State'] = state;
    data['Country'] = country;
    data['Longitude'] = longitude;
    data['Description'] = description;
    data['mainproductImage'] = mainproductImage;
    if (subproductImage != null) {
      data['subproductImage'] =
          subproductImage!.map((v) => v.toJson()).toList();
    }
    data['is_paid_post'] = isPaidPost;
    data['status'] = isSuspeded;

    data['product_status'] = productStatus;
    data['isLike'] = isLike;
    data['likeCount'] = likeCount;
    data['post_url'] = postShortUrl;
    data['isFavorite'] = isFavorite;
    data['view_product'] = isView;

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
  int? productImgeId;
  String? subImageUrl;

  SubproductImage({this.productImgeId, this.subImageUrl});

  SubproductImage.fromJson(Map<String, dynamic> json) {
    productImgeId = json['productImgeId'];
    subImageUrl = json['sub_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productImgeId'] = productImgeId;
    data['sub_image_url'] = subImageUrl;
    return data;
  }
}
