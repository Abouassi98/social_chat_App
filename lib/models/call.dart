class Call {
  String callerId;
  String callerName;
  String callerPic;
  String reciverId;
  String reciverName;
  String reciverPic;
  String channelId;
  bool hasDialled;
  bool videoCall=false;
  Call(
      {this.callerId,
      this.callerName,
      this.callerPic,
      this.channelId,
      this.hasDialled,
      this.reciverId,
      this.reciverName,
      this.videoCall,
      this.reciverPic});

  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = Map();
    callMap['callerId'] = call.callerId;
    callMap['callerName'] = call.callerName;
    callMap['callerPic'] = call.callerPic;
    callMap['reciverId'] = call.reciverId;
    callMap['reciverName'] = call.reciverName;
    callMap['reciverPic'] = call.reciverPic;
    callMap['videoCall'] = call.videoCall;
    callMap['channelId'] = call.channelId;
    callMap['isDialled'] = call.hasDialled;
    return callMap;
  }

  Call.fromMap(Map callMap) {
    this.callerId = callMap["callerId"];
    this.callerName = callMap["callerName"];
    this.callerPic = callMap["callerPic"];
    this.reciverId = callMap["reciverId"];
    this.reciverName = callMap["reciverName"];
    this.reciverPic = callMap["reciverPic"];
    this.channelId = callMap["channelId"];
    this.hasDialled = callMap["isDialled"];
    this.videoCall = callMap['videoCall'];
  }
}
