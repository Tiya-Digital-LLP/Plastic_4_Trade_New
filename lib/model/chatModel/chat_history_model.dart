class MyChatHistoryResponse {
  MychatHistory? myChatHistory;
  int? status;
  int? chatPermission;
  String? message;

  MyChatHistoryResponse(
      {this.myChatHistory, this.status, this.chatPermission, this.message});

  MyChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    myChatHistory = json['mychatoverview'] != null
        ? MychatHistory.fromJson(json['mychatoverview'])
        : null;
    status = json['status'];
    chatPermission = json['chat_permission'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (myChatHistory != null) {
      data['mychatoverview'] = myChatHistory!.toJson();
    }
    data['status'] = status;
    data['chat_permission'] = chatPermission;
    data['message'] = message;
    return data;
  }
}

class MychatHistory {
  int? currentPage;
  List<ChatHistoryData>? chatHistoryData;
  String? firstPageUrl;
  int? lastPage;
  String? lastPageUrl;
  String? path;
  int? perPage;
  int? total;

  MychatHistory(
      {this.currentPage,
      this.chatHistoryData,
      this.firstPageUrl,
      this.lastPage,
      this.lastPageUrl,
      this.path,
      this.perPage,
      this.total});

  MychatHistory.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      chatHistoryData = <ChatHistoryData>[];
      json['data'].forEach((v) {
        chatHistoryData!.add(ChatHistoryData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['current_page'] = currentPage;
    if (chatHistoryData != null) {
      data['data'] = chatHistoryData!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['total'] = total;
    return data;
  }
}

class ChatHistoryData {
  int? id;
  int? toId;
  int? fromId;
  String? message;
  String? lastChatAt;
  String? createdAt;
  String? updatedAt;
  int? unreadCount;
  int? isgroup;
  String? username;
  String? userImage;

  ChatHistoryData({
    this.id,
    this.toId,
    this.fromId,
    this.message,
    this.lastChatAt,
    this.createdAt,
    this.updatedAt,
    this.unreadCount,
    this.isgroup,
    this.username,
    this.userImage,
  });

  ChatHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    toId = json['toid'];
    fromId = json['fromid'];
    message = json['message'];
    lastChatAt = json['last_chat_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    unreadCount = json['count_of_enread'];
    isgroup = json['is_group'];
    username = json['username'];
    userImage = json['userImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['toid'] = toId;
    data['fromid'] = fromId;
    data['last_chat_at'] = lastChatAt;
    data['message'] = message;

    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['count_of_enread'] = unreadCount;
    data['is_group'] = isgroup;

    data['username'] = username;
    data['userImage'] = userImage;
    return data;
  }
}
