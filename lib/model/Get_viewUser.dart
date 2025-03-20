class GetViewUser {
  int? status;
  List<Data>? data;

  GetViewUser({this.status, this.data});

  GetViewUser.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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
  int? profileId;
  int? userId;
  String? createdAt;
  String? updatedAt;
  String? username;
  String? userImage;
  String? imageUrl;
  String? businessTypeName;
  int? isBusinessProfileView; // Maps to 'can_business_profile_view'
  int? isBusinessOldView; // Maps to 'check_old_view'
  String? crowncolor;
  String? planname;

  Data({
    this.id,
    this.profileId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.username,
    this.userImage,
    this.imageUrl,
    this.businessTypeName,
    this.isBusinessProfileView,
    this.isBusinessOldView,
    this.crowncolor,
    this.planname,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profileId = json['profile_id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    username = json['username'];
    userImage = json['userImage'];
    imageUrl = json['image_url'];
    businessTypeName = json['business_type_name'];
    isBusinessProfileView = json['can_business_profile_view'];
    isBusinessOldView = json['check_old_view'];
    crowncolor = json['crown_color'];
    planname = json['plan_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['profile_id'] = profileId;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['username'] = username;
    data['userImage'] = userImage;
    data['image_url'] = imageUrl;
    data['business_type_name'] = businessTypeName;
    data['can_business_profile_view'] = isBusinessProfileView;
    data['check_old_view'] = isBusinessOldView;
    data['crown_color'] = crowncolor;
    data['plan_name'] = planname;
    return data;
  }
}
