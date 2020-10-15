import 'package:chat/models/logs.dart';

abstract class LogInterface {
  openDb(dbName);
  init();
  addLogs(Log log);
  Future<List<Log>> getLogs();
  deleteLogs(int logId);
  close();
}
