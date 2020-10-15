import 'dart:math';
import 'package:chat/resources/log_repository.dart';
import 'package:chat/resources/call_Methods.dart';
import 'package:chat/models/call.dart';
import 'package:chat/models/user_form.dart';
import 'package:chat/screens/callScreens/call_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/Constant/constant.dart';
import 'package:intl/intl.dart';
import 'package:chat/models/logs.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({User to, User from, context, bool videoCall}) async {
    Call call = Call(
      callerId: from.userId,
      callerName: from.userName,
      callerPic: from.imageUrl,
      reciverId: to.userId,
      reciverName: to.userName,
      reciverPic: to.imageUrl,
      channelId: Random().nextInt(1000).toString(),
    );
    Log log = Log(
      callerName: from.userName,
      callerPhoto: from.imageUrl,
      callStatus: "dialled",
      reciverName: to.userName,
      reciverPhoto: to.imageUrl,
      timestamp: DateTime.now().toString(),
    );
    bool callmad = await callMethods.makeCall(call: call);
    if (videoCall) {
      await callCollection.doc(from.userId).update({'videoCall': true});
      await callCollection.doc(to.userId).update({'videoCall': true});
    } else {
      await callCollection.doc(from.userId).update({'videoCall': false});
      await callCollection.doc(to.userId).update({'videoCall': false});
    }
    call.hasDialled = true;
    if (callmad) {
      LogRepository.addLogs(log);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CallScreen(call: call, videoCall: videoCall)));
    }
  }

  static String formatDateString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(dateTime);
  }
}
