class Get_likeUser {
  int? _status;
  List<Data>? _data;

  Get_likeUser({int? status, List<Data>? data}) {
    _status = status;
    _data = data;
  }

  int? get status => _status;
  set status(int? status) => _status = status;
  List<Data>? get data => _data;
  set data(List<Data>? data) => _data = data;

  Get_likeUser.fromJson(Map<String, dynamic> json) {
    _status = json['status'];
    if (json['data'] != null) {
      _data = <Data>[];
      json['data'].forEach((v) {
        _data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = _status;
    if (_data != null) {
      data['data'] = _data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? _id;
  String? _userId;
  String? _profileId;
  String? _isLike;
  String? _createdAt;
  String? _updatedAt;
  String? _username;
  String? _userImage;
  String? _imageUrl;
  String? _businessTypeName;
  int? _isBusinessProfileView;
  int? _isBusinessOldView;
  String? _crowncolor;
  String? _planname;

  Data({
    int? id,
    String? userId,
    String? profileId,
    String? isLike,
    String? createdAt,
    String? updatedAt,
    String? username,
    String? userImage,
    String? imageUrl,
    String? businessTypeName,
    int? isBusinessProfileView,
    int? isBusinessOldView,
    String? crowncolor,
    String? planname,
  }) {
    _id = id;
    _userId = userId;
    _profileId = profileId;
    _isLike = isLike;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _username = username;
    _userImage = userImage;
    _imageUrl = imageUrl;
    _businessTypeName = businessTypeName;
    _isBusinessProfileView = isBusinessProfileView;
    _isBusinessOldView = isBusinessOldView;
    _crowncolor = crowncolor;
    _planname = planname;
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get userId => _userId;
  set userId(String? userId) => _userId = userId;
  String? get profileId => _profileId;
  set profileId(String? profileId) => _profileId = profileId;
  String? get isLike => _isLike;
  set isLike(String? isLike) => _isLike = isLike;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get updatedAt => _updatedAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;
  String? get username => _username;
  set username(String? username) => _username = username;
  String? get userImage => _userImage;
  set userImage(String? userImage) => _userImage = userImage;
  String? get imageUrl => _imageUrl;
  set imageUrl(String? imageUrl) => _imageUrl = imageUrl;
  String? get businessTypeName => _businessTypeName;
  set businessTypeName(String? businessTypeName) =>
      _businessTypeName = businessTypeName;
  int? get isBusinessProfileView => _isBusinessProfileView;
  set isBusinessProfileView(int? isBusinessProfileView) =>
      _isBusinessProfileView = isBusinessProfileView;
  int? get isBusinessOldView => _isBusinessOldView;
  set isBusinessOldView(int? isBusinessOldView) =>
      _isBusinessOldView = isBusinessOldView;
  String? get crowncolor => _crowncolor;
  set crowncolor(String? crowncolor) => _crowncolor = crowncolor;
  String? get planname => _planname;
  set planname(String? planname) => _planname = planname;

  Data.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _userId = json['user_id'];
    _profileId = json['profile_id'];
    _isLike = json['isLike'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _username = json['username'];
    _userImage = json['userImage'];
    _imageUrl = json['image_url'];
    _businessTypeName = json['business_type_name'];
    _isBusinessProfileView = json['can_business_profile_view'];
    _isBusinessOldView = json['check_old_view'];
    _crowncolor = json['crown_color'];
    _planname = json['plan_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['user_id'] = _userId;
    data['profile_id'] = _profileId;
    data['isLike'] = _isLike;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['username'] = _username;
    data['userImage'] = _userImage;
    data['image_url'] = _imageUrl;
    data['business_type_name'] = _businessTypeName;
    data['can_business_profile_view'] = _isBusinessProfileView;
    data['check_old_view'] = _isBusinessOldView;
    data['crown_color'] = _crowncolor;
    data['plan_name'] = _planname;
    return data;
  }
}
