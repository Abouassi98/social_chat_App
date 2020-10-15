import 'package:chat/models/logs.dart';
import 'package:chat/resources/interface/log_interface.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SqliteMethos implements LogInterface {
  Database _db;
  String databaseName = "";
  String tableName = 'Call_Logs';
  // columns
  String id = 'logId';
  String callStatus = 'callStatus';
  String callerPhoto = 'callerPhoto';
  String callerName = 'callerName';
  String reciverPhoto = 'reciverPhoto';
  String reciverName = 'reciverName';
  String timestamp = 'timestamp';
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await init();
    return _db;
  }

  @override
  addLogs(Log log) async {
    var dbClient = await db;
    await dbClient.insert(tableName, log.toMap(log));
    // TODO: implement addLogs
  }

  updateLogs(Log log) async {
    var dbClient = await db;
    await dbClient.update(tableName, log.toMap(log),
        where: '$id=?', whereArgs: [log.logId]);
  }

  @override
  close() async {
    var dbClient = await db;
    // TODO: implement close
    await dbClient.close();
  }

  @override
  deleteLogs(int logId) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableName, where: '$id=?', whereArgs: [logId + 1]);
    // TODO: implement deleteLogs
  }

  @override
  Future<List<Log>> getLogs() async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.query(tableName, columns: [
        id,
        callStatus,
        callerPhoto,
        callerName,
        reciverPhoto,
        reciverName,
        timestamp
      ]);
      List<Log> logList = [];
      if (logList.isNotEmpty) {
        for (Map map in maps) {
          logList.add(Log.fromMap(map));
        }
      }
      return logList;
    } catch (error) {
      return null;
    }
    // TODO: implement getLogs
  }

  onCrate(Database db, int versions) async {
    String createTableQuery =
        "CREATE TABLE $tableName ($id INTEGER PRIMARY KEY,$callerName TEXT, $callerPhoto TEXT, $reciverName TEXT, $reciverPhoto TEXT, $callStatus TEXT, $timestamp TEXT)";
    await db.execute(createTableQuery);
  }

  @override
  init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, databaseName);
    var db = openDatabase(path, version: 1, onCreate: onCrate);
    return db;
    // TODO: implement init
  }

  @override
  openDb(dbName) {
    // TODO: implement openDb
    dbName = databaseName;
  }
}
