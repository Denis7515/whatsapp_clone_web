
class ChatModel {

  String fromUserID;
  String toUserID;
  String lastMessage;
  String toUsername;
  String toUserEmail;
  String toUserImage;

  ChatModel(
    this.fromUserID,
    this.toUserID,
    this.lastMessage,
    this.toUsername,
    this.toUserEmail,
    this.toUserImage,
  );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> mapChat = {
      "fromUserID": fromUserID,
      "toUserID": toUserID,
      "lastMessage": lastMessage,
      "toUsername": toUsername,
      "toUserEmail": toUserEmail,
      "toUserImage": toUserImage,
    };
    return mapChat;
  }
}
