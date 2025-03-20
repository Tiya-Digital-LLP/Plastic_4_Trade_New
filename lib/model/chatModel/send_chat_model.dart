class SendChatRequest {
  String? userId;
  String? userToken;
  String? toId;
  String? msg;
  String? chatId;

  SendChatRequest(
      {this.userId, this.userToken, this.toId, this.msg, this.chatId});

  SendChatRequest.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userToken = json['userToken'];
    toId = json['toid'];
    msg = json['msg'];
    chatId = json['chat_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['userToken'] = userToken;
    data['toid'] = toId;
    data['msg'] = msg;
    if (chatId != null) data['chat_id'] = chatId;
    return data;
  }
}

class SendChatResponse {
  SendChatModel? sendChatModel;
  int? status;
  String? message;

  SendChatResponse({this.sendChatModel, this.status, this.message});

  SendChatResponse.fromJson(Map<String, dynamic> json) {
    sendChatModel = json['mychatoverview'] != null
        ? new SendChatModel.fromJson(json['mychatoverview'])
        : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sendChatModel != null) {
      data['mychatoverview'] = this.sendChatModel!.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class SendChatModel {
  int? currentPage;
  List<SendChatData>? sendChatData;
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

  SendChatModel(
      {this.currentPage,
      this.sendChatData,
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

  SendChatModel.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      sendChatData = <SendChatData>[];
      json['data'].forEach((v) {
        sendChatData!.add(new SendChatData.fromJson(v));
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
    if (this.sendChatData != null) {
      data['data'] = this.sendChatData!.map((v) => v.toJson()).toList();
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

class SendChatData {
  int? id;
  int? toid;
  int? fromid;
  String? msg;
  String? chatId;
  String? unreadCount;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  int? countOfEnread;
  String? username;
  String? userImage;

  SendChatData(
      {this.id,
      this.toid,
      this.fromid,
      this.msg,
      this.chatId,
      this.unreadCount,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.countOfEnread,
      this.username,
      this.userImage});

  SendChatData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    toid = json['toid'];
    fromid = json['fromid'];
    msg = json['msg'];
    chatId = json['chat_id'];
    unreadCount = json['unread_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    countOfEnread = json['count_of_enread'];
    username = json['username'];
    userImage = json['userImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['toid'] = this.toid;
    data['fromid'] = this.fromid;
    data['msg'] = this.msg;
    data['chat_id'] = this.chatId;
    data['unread_count'] = this.unreadCount;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['count_of_enread'] = this.countOfEnread;
    data['username'] = this.username;
    data['userImage'] = this.userImage;
    return data;
  }
}
