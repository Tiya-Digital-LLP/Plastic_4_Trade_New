class ApiResponse {
  int? status;
  String? message;
  List<Result>? result;

  ApiResponse({this.status, this.message, this.result});

  ApiResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
  }
}

class Result {
  int? interestId;
  String? productId;
  String? userId;
  String? username;
  String? businessType;
  String? imageUrl;
  String? createdAt;
  int? isBusinessProfileView;
  int? isBusinessOldView;
  String? crowncolor;
  String? planname;

  Result({
    this.interestId,
    this.productId,
    this.userId,
    this.username,
    this.businessType,
    this.imageUrl,
    this.createdAt,
    this.isBusinessProfileView,
    this.isBusinessOldView,
    this.crowncolor,
    this.planname,
  });

  Result.fromJson(Map<String, dynamic> json) {
    interestId = json['interestId'];
    productId = json['productId'];
    userId = json['userId'];
    username = json['username'];
    businessType = json['business_type'];
    imageUrl = json['profile_image'];
    createdAt = json['created_at'];
    isBusinessProfileView = json['can_business_profile_view'];
    isBusinessOldView = json['check_old_view'];
    crowncolor = json['crown_color'];
    planname = json['plan_name'];
  }
}
