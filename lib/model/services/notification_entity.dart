class NotificationEntity {
  dynamic deviceType;
  dynamic jobId;
  dynamic senderId;
  String? receiverImage;
  String? senderImage;
  String? receiverName;
  String? senderName;
  String? body;
  dynamic type;
  String? title;
  String? deviceToken;

  NotificationEntity(
      {this.deviceType,
        this.jobId,
        this.senderId,
        this.receiverImage,
        this.senderImage,
        this.receiverName,
        this.senderName,
        this.body,
        this.type,
        this.title,
        this.deviceToken});

  NotificationEntity.fromJson(Map<String, dynamic> json) {
    deviceType = json['deviceType'];
    jobId = json['jobId'];
    senderId = json['senderId'];
    receiverImage = json['Receiver_image'];
    senderImage = json['sender_image'];
    receiverName = json['Receiver_name'];
    senderName = json['sender_name'];
    body = json['body'];
    type = json['type'];
    title = json['title'];
    deviceToken = json['deviceToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceType'] = deviceType;
    data['jobId'] = jobId;
    data['senderId'] = senderId;
    data['Receiver_image'] = receiverImage;
    data['sender_image'] = senderImage;
    data['Receiver_name'] = receiverName;
    data['sender_name'] = senderName;
    data['body'] = body;
    data['type'] = type;
    data['title'] = title;
    data['deviceToken'] = deviceToken;
    return data;
  }
}
