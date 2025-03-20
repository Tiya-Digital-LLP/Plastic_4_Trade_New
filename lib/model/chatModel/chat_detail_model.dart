class ChatDetailsResponse {
  MychatDetails? mychatDetails;
  int? status;
  String? message;
  String? profilePic;

  ChatDetailsResponse(
      {this.mychatDetails, this.status, this.message, this.profilePic});

  ChatDetailsResponse.fromJson(Map<String, dynamic> json) {
    mychatDetails = json['mychatoverview'] != null
        ? new MychatDetails.fromJson(json['mychatoverview'])
        : null;
    status = json['status'];
    message = json['message'];
    profilePic = json['profile_pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mychatDetails != null) {
      data['mychatoverview'] = this.mychatDetails!.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    data['profile_pic'] = this.profilePic;
    return data;
  }
}

class MychatDetails {
  int? currentPage;
  List<ChatDetailsData>? chatDetailsData;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  MychatDetails(
      {this.currentPage,
      this.chatDetailsData,
      this.firstPageUrl,
      this.from,
      this.lastPage,
      this.lastPageUrl,
      this.nextPageUrl,
      this.path,
      this.perPage,
      this.prevPageUrl,
      this.to,
      this.total});

  MychatDetails.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      chatDetailsData = <ChatDetailsData>[];
      json['data'].forEach((v) {
        chatDetailsData!.add(new ChatDetailsData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.chatDetailsData != null) {
      data['data'] = this.chatDetailsData!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class ChatDetailsData {
  int? id;
  int? toid;
  int? fromid;
  String? msg;
  String? commentmsg;
  int? chatId;
  int? readStatus;
  int? deletedByUserId;
  String? image;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? fromUserName;
  String? userImage;
  String? userImageUrl;

  ChatDetailsData({
    this.id,
    this.toid,
    this.fromid,
    this.msg,
    this.commentmsg,
    this.chatId,
    this.readStatus,
    this.deletedByUserId,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.fromUserName,
    this.userImage,
    this.userImageUrl,
  });

  ChatDetailsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    toid = json['toid'];
    fromid = json['fromid'];
    msg = json['msg'];
    commentmsg = json['image_comment'];

    chatId = json['chat_id'];
    readStatus = json['read_status'];
    deletedByUserId = json['deleted_by_user_id'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    fromUserName = json['from_user_name'];
    userImage = json['userImage'];
    userImageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['toid'] = this.toid;
    data['fromid'] = this.fromid;
    data['msg'] = this.msg;
    data['image_comment'] = this.commentmsg;

    data['chat_id'] = this.chatId;
    data['read_status'] = this.readStatus;
    data['deleted_by_user_id'] = this.deletedByUserId;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['from_user_name'] = this.fromUserName;
    data['userImage'] = this.userImage;
    data['image_url'] = this.userImageUrl;

    return data;
  }
}
