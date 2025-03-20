class getFollowingList {
  int? status;
  String? message;
  int? totalFollowing;
  List<Result>? result;

  getFollowingList(
      {this.status, this.message, this.totalFollowing, this.result});

  getFollowingList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    totalFollowing = json['totalFollowing'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['totalFollowing'] = this.totalFollowing;
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  int? id;
  String? image;
  String? name;
  String? businessType;
  String? status;
  int? isBusinessProfileView;
  int? isBusinessOldView;
  String? crowncolor;
  String? planname;

  Result({
    this.id,
    this.image,
    this.name,
    this.businessType,
    this.status,
    this.isBusinessProfileView,
    this.isBusinessOldView,
    this.crowncolor,
    this.planname,
  });

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
    businessType = json['businessType'];
    status = json['Status'];
    isBusinessProfileView = json['can_business_profile_view'];
    isBusinessOldView = json['check_old_view'];
    crowncolor = json['crown_color'];
    planname = json['plan_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['name'] = this.name;
    data['businessType'] = this.businessType;
    data['Status'] = this.status;
    data['can_business_profile_view'] = isBusinessProfileView;
    data['check_old_view'] = isBusinessOldView;
    data['crown_color'] = this.crowncolor;
    data['plan_name'] = this.planname;

    return data;
  }
}
