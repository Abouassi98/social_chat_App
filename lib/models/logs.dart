class Log {
  String logId;
  String callerPhoto;
  String callerName;
  String reciverPhoto;
  String reciverName;
  String callStatus;
  String timestamp;
  Log(
      {this.logId,
      this.callerName,
      this.callerPhoto,
      this.callStatus,
      this.reciverName,
      this.reciverPhoto,
      this.timestamp});
  Map<String, dynamic> toMap(Log log) {
    Map<String, dynamic> logMap = Map();
    logMap['logId'] = log.logId;
    logMap['callStatus'] = log.callStatus;
    logMap['callerPhoto'] = log.callerPhoto;
    logMap['callerName'] = log.callerName;
    logMap['reciverPhoto'] = log.reciverPhoto;
    logMap['reciverName'] = log.reciverName;
    logMap['timestamp'] = log.timestamp;
    return logMap;
  }

  Log.fromMap(Map logMap) {
    this.logId = logMap['logId'];
    this.callStatus = logMap['callStatus'];
    this.callerPhoto = logMap['callerPhoto'];
    this.callerName = logMap['callerName'];
    this.reciverPhoto = logMap['reciverPhoto'];
    this.reciverName = logMap['reciverName'];
    this.timestamp = logMap['timestamp'];
  }
}
