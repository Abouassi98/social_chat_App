import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import './activity_feed.dart';
import 'package:firebase_auth/firebase_auth.dart' as users;
import './profile copy.dart';
import './search.dart';
import './timeline.dart';
import './upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _auth = users.FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final postRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final storageRef = FirebaseStorage.instance.ref();
final timestamp = DateTime.now();
User currentUser = User(
  id: _auth.currentUser.uid,
  displayName: _auth.currentUser.displayName,
  email: _auth.currentUser.email,
  photoUrl: _auth.currentUser.photoURL,
  username: _auth.currentUser.displayName,
  bio: '',
);

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isAuth = false;
  PageController pageController;
  int pageIndx = 0;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
    Future.delayed(Duration(seconds: 2), () async {
      await createUserFirestore();
    });
    // Firebase.initializeApp();
    // googleSignIn.onCurrentUserChanged.listen((account) {
    //   handleSignIn(account);
    // }, onError: (error) {
    //   print(error);
    // });
    // //Reauthenticate user when app is re-Opened...
    // googleSignIn.signInSilently(suppressErrors: false).then((account) {
    //   handleSignIn(account);
    // }, onError: (error) {
    //   print(error);
    // });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserFirestore();
      setState(() {
        isAuth = true;
      });
      configurePushNotifications();
      configLocalNotification();
    } else {
      setState(
        () {
          isAuth = false;
        },
      );
    }
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.example.fluttershare'
          : 'com.example.fluttershare',
      'Flutter Notification demo',
      'channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(
        0,
        message['notification'].toString(),
        message['body'].toString(),
        platformChannelSpecifics,
        payload: json.encode(message));

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getIosPermession();

    _firebaseMessaging.getToken().then((token) {
      print('firebase messaging token :$token\n');
      usersRef.doc(user.id).update({'androidNotificationToken': token});
    });
    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message)async{},
      // onResume: (Map<String, dynamic> message)async{},
      onMessage: (Map<String, dynamic> message) async {
        print('on message :$message\n');
        final String receiverId = message['data']['receiver'];
        final String body = message['notification']['body'];
      },
    );
  }

  getIosPermession() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print('settings registered:$settings');
    });
  }

  createUserFirestore() async {
    print('ffffffffffffffffffffffffffffffffffffffffffffffffffffff');

    final googleUser = googleSignIn.currentUser;
    final user = _auth.currentUser;

    var doc = await usersRef.doc(user.uid).get();

    if (!doc.exists) {
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: null,
        ),
      );
      usersRef.doc(googleUser.id).set({
        'id': googleUser.id,
        'username': username,
        'photoUrl': googleUser.photoUrl,
        'email': googleUser.email,
        'displayName': googleUser.displayName,
        'bio': '',
        'timestamp': timestamp,
      });
      //make new user their own follower(to include their post in time line)
      await followersRef
          .doc(googleUser.id)
          .collection('userFollowers')
          .doc(googleUser.id)
          .set({});

      doc = await usersRef.doc(googleUser.id).get();
    }
    // setState(() {
    //   currentUser = User.fromDocument(doc);
    // });
  }

  login() {
    googleSignIn.signIn();
  }

  signOut() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      pageIndx = pageIndex;
    });
  }

  changePage(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser.id),
        ],
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white70,
        border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 0.7)),
        currentIndex: pageIndx,
        onTap: changePage,
        activeColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera, size: 35),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );

    // return RaisedButton(
    //   onPressed: signOut,
    //   child: Text(
    //     'Signout...',
    //   ),
    // );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.teal,
            Theme.of(context).primaryColor,
          ], begin: Alignment.topRight, end: Alignment.bottomLeft),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Blazigram',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildAuthScreen();
  }
}
