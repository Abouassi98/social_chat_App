import 'package:chat/models/call.dart';
import 'package:chat/Constant/constant.dart';

class CallMethods {
  Future<bool> makeCall({Call call}) async {
    try {
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);
      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);
      await callCollection.doc(call.callerId).set(hasDialledMap);
      await callCollection.doc(call.reciverId).set(hasNotDialledMap);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> endCall({Call call}) async {
    try {
      await callCollection.doc(call.callerId).delete();
      await callCollection.doc(call.reciverId).delete();
      return true;
    } catch (error) {
      return false;
    }
  }
}
