import 'package:flutter/cupertino.dart';

import '../resources/db/hive_methods.dart';
import '../resources/db/sqLite_Methods.dart';
import 'package:meta/meta.dart';
import '../models/logs.dart';

class LogRepository {
  static var dbObject;
  static bool isHive;

  static init({@required bool isHive, @required String dbName}) {
    dbObject = isHive ? HiveMethods() : SqliteMethos();
    dbObject.openDb(dbName);
    dbObject.init();
  }

  static addLogs(Log log) => dbObject.addLogs(log);
  static deleteLogs(int log) => dbObject.deleteLogs(log);
  static getLogs() => dbObject.getLogs();
  static close() => dbObject.close();
}
