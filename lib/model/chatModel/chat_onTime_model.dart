import 'chat_detail_model.dart';

class GetOnTimeChatResponse {
  List<ChatDetailsData>? getOnTimeChat;
  int? status;
  String? message;

  GetOnTimeChatResponse({this.getOnTimeChat, this.status, this.message});

  GetOnTimeChatResponse.fromJson(Map<String, dynamic> json) {
    if (json['mychatoverview'] != null) {
      getOnTimeChat = <ChatDetailsData>[];
      json['mychatoverview'].forEach((v) {
        getOnTimeChat!.add(ChatDetailsData.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (getOnTimeChat != null) {
      data['mychatoverview'] = getOnTimeChat!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class SendMessageResponse {
  int? status;
  String? message;
  SendMessageRecord? sendMessageRecord;

  SendMessageResponse({this.status, this.message, this.sendMessageRecord});

  SendMessageResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    sendMessageRecord = json['record'] != null
        ? SendMessageRecord.fromJson(json['record'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (sendMessageRecord != null) {
      data['record'] = sendMessageRecord!.toJson();
    }
    return data;
  }
}

class SendMessageRecord {
  int? toid;
  int? fromid;
  String? msg;
  int? chatId;
  int? readStatus;
  String? updatedAt;
  String? createdAt;
  int? id;

  SendMessageRecord(
      {this.toid,
      this.fromid,
      this.msg,
      this.chatId,
      this.readStatus,
      this.updatedAt,
      this.createdAt,
      this.id});

  SendMessageRecord.fromJson(Map<String, dynamic> json) {
    toid = json['toid'];
    fromid = json['fromid'];
    msg = json['msg'];
    chatId = json['chat_id'];
    readStatus = json['read_status'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['toid'] = toid;
    data['fromid'] = fromid;
    data['msg'] = msg;
    data['chat_id'] = chatId;
    data['read_status'] = readStatus;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
