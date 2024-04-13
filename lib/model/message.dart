
class Message {

  String uid;
  String text;
  String dateTime;
  DateTime createdAt;

  Message(this.uid, this.text, this.dateTime, this.createdAt);

  Map<String, dynamic> toMap() {

    Map<String, dynamic> mapMessage = {

      "uid": uid,
      "text": text,
      "dateTime": dateTime,
      "createdAt": createdAt
    };
    return mapMessage;
  }
}