import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:flutter/material.dart';
import '../Constant/constant.dart';

class User {
  String email;
  String userId;
  String userName;
  String imageUrl;
  String firstName;
  String secondName;
  User(
      {this.email,
      this.userId,
      this.imageUrl,
      this.userName,
      this.firstName,
      this.secondName});

  User getUserCurrent(fbAuth.User user) {
    return user != null
        ? User(
                email: user.email ?? "",
                userName: user.displayName ?? "",
                userId: user.uid ?? "",
                imageUrl: user.photoURL ?? "",
                firstName: user.displayName.split(' ')[0] ?? "",
                secondName: user.displayName.split(' ')[1]) ??
            ""
        : null;
  }

  Stream<User> get currentUser {
    return _auth.authStateChanges().map(getUserCurrent);
  }

  final fbAuth.FirebaseAuth _auth = fbAuth.FirebaseAuth.instance;
  Future addUser({
    String email,
    String userId,
    String userName,
    String imageUrl,
  }) async {
    // List<String> splitList = email.split(" ");
    // List<String> indexList = [];
    // for (int i = 0; i < splitList.length; i++) {
    //   for (int y = 1; y < splitList[i].length + 1; y++) {
    //     indexList.add(splitList[i].substring(0, y).toLowerCase());
    //   }
    // }
    //print(indexList);
    await FirebaseFirestore.instance
        .collection('followers')
        .doc(userId)
        .collection('userFollowers')
        .doc(userId)
        .set({});
    return await userCollection.doc(userId).set({
      'email': email,
      'userName': userName,
      // 'firstName': firstName,
      // 'secondName': secondName,
      //'searchIndex': indexList,
      'UserimageUrl': imageUrl,
      'userId': userId,
      'isActive': false,
      'StoryPhoto': null,
      'uplodedStory': false,
      'id': userId,
      'displayName': userName,
      'bio': '',
      'timestamp': DateTime.now(),
    });
  }

  User.fromMap(Map<String, dynamic> mapData) {
    this.email = mapData['email'];
    this.imageUrl = mapData['UserimageUrl'];
    this.userName = mapData['userName'];
    this.userId = mapData['userId'];
  }
  Future<fbAuth.User> getCurrentUser() async {
    final currentuser = _auth.currentUser;
    return currentuser;
  }
}
