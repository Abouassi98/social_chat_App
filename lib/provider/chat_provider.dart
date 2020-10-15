import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Constant/constant.dart';

class Photos extends ChangeNotifier {
  static String myID;
  static String fileName = '${DateTime.now()}';
  String myName;
  Future<dynamic> uploadPicture(
      File imageFile, String nameFolder, String nameImage) async {
    StorageReference storgeRefrence =
        FirebaseStorage().ref().child(nameFolder).child(nameImage);
    var _uploadedPhoto = storgeRefrence.putFile(imageFile);

    var completeTask = await _uploadedPhoto.onComplete;
    final downloadUrl = await completeTask.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<dynamic> uploadUserPicture(File imageFile, String myId) async {
    return await uploadPicture(imageFile, 'userImage', myId);
  }

  Future<dynamic> uploadchatPicture(File imageFile) async {
    return await uploadPicture(imageFile, 'chatImage', fileName);
  }

  Future<dynamic> uploadchatRecord(File imageFile) async {
    return await uploadPicture(imageFile, 'chatRecord', fileName);
  }

  Future<dynamic> uploadstoryPicture(File imageFile) async {
    return await uploadPicture(imageFile, 'storyImage', '${DateTime.now()}');
  }

  Future<String> downloadPicture(String myId) async {
    dynamic downloadUrl = await FirebaseStorage()
        .ref()
        .child('chatImage')
        .child(myId)
        .getDownloadURL();

    return downloadUrl;
  }

  Future deletePhoto(String imageUrl) async {
    if (imageUrl != null) {
      StorageReference _storgeRefrence =
          FirebaseStorage.instance.ref().child('chatImage').child(fileName);
      await _storgeRefrence.delete();
    }
  }

  Future<void> getCurrentUserId(String id, String myname) async {
    try {
      final _auth = FirebaseAuth.instance;
      var user = _auth.currentUser;
      if (user != null) {
        id = user.uid;
        myID = id;

        var db = await userCollection.doc(myID).get();
        myname = db.data()['userName'];
        myName = myname;

        print('myId=$myID');
        print('myName=$myname');
      }
    } catch (error) {
      print(error);
    }
  }

  String makeChatRoomId(String userId) {
    String chatRoomId;
    if (myID.hashCode > userId.hashCode) {
      chatRoomId = '$myID-$userId';
    } else {
      chatRoomId = '$userId-$myID';
    }
    return chatRoomId;
  }

  void updateChatRequestField(String documentId, String lastMessage,
      String userId, BuildContext context) {
    userCollection
        .doc(documentId)
        .collection('Messages')
        .doc(makeChatRoomId(userId))
        .set({
      'chatRoomID': makeChatRoomId(userId),
      'chatWith': documentId == Photos.myID ? userId : Photos.myID,
      'lastMessage': lastMessage,
      'timestamp': TimeOfDay.now().format(context),
      'CreatedAt': Timestamp.now(),
    });
  }
}
