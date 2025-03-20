class ProductShare {
  int? status;
  List<Data>? data;

  ProductShare({this.status, this.data});

  ProductShare.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? userId;
  String? profileId;
  String? createdAt;
  String? updatedAt;
  String? username;
  String? businessType;

  String? userImage;
  String? imageUrl;
  int? isBusinessProfileView;
  int? isBusinessOldView;
  String? crowncolor;
  String? planname;

  Data({
    this.id,
    this.userId,
    this.profileId,
    this.createdAt,
    this.updatedAt,
    this.username,
    this.businessType,
    this.userImage,
    this.imageUrl,
    this.isBusinessProfileView,
    this.isBusinessOldView,
    this.crowncolor,
    this.planname,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'].toString();
    profileId = json['profile_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    username = json['username'];
    businessType = json['business_type'];
    userImage = json['userImage'];
    imageUrl = json['image_url'];
    isBusinessProfileView = json['can_business_profile_view'];
    isBusinessOldView = json['check_old_view'];
    crowncolor = json['crown_color'];
    planname = json['plan_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['profile_id'] = profileId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['username'] = username;
    data['business_type'] = businessType;
    data['userImage'] = userImage;
    data['image_url'] = imageUrl;
    data['can_business_profile_view'] = isBusinessProfileView;
    data['check_old_view'] = isBusinessOldView;
    data['crown_color'] = crowncolor;
    data['plan_name'] = planname;
    return data;
  }
}
