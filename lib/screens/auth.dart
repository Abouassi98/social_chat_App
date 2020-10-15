import '../screens/tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/auth/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import '../provider/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:chat/Constant/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './social_screens/home.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> submit(
    String userName,
    String email,
    File image,
    String password,
    bool isLogin,
    String imageUrl,
    BuildContext ctx,
  ) async {
    UserCredential authResult;
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        await pref.setString('user', authResult.user.displayName);
        await pref.setString('uid', authResult.user.uid);
        await pref.setString('password', password);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // List<String> splitList = email.split(" ");
        // List<String> indexList = [];
        // for (int i = 0; i < splitList.length; i++) {
        //   for (int y = 1; y < splitList[i].length + 1; y++) {
        //     indexList.add(splitList[i].substring(0, y).toLowerCase());
        //   }
        // }
        // print(indexList);
        await Provider.of<Photos>(context, listen: false)
            .uploadUserPicture(image, authResult.user.uid)
            .then((result) {
          result != null
              ? setState(() {
                  imageUrl = result;
                  print('a=$imageUrl');
                  Fluttertoast.showToast(msg: 'بحبك يا ولا ');
                })
              : Fluttertoast.showToast(
                  msg: 'الصوره فيها حاجه غلط لو وشك غيهر بحاجه عدله ');
        });

        final user = _auth.currentUser;
        await user.updateProfile(displayName: userName, photoURL: imageUrl);

        await pref.setString('user', userName);
        await pref.setString('uid', authResult.user.uid);
        await pref.setString('password', password);
        print('here ${authResult.user.uid}');
        userCollection.doc(authResult.user.uid).set({
          'email': email,
          'userName': userName,
          'firstName': userName.split(' ')[0],
          'secondName': userName.split(' ')[1],
          //'searchIndex': indexList,
          'UserimageUrl': imageUrl,
          'userId': authResult.user.uid,
          'StoryPhoto': null,
          'isActive': false,
          'uplodedStory': false,
          'id': authResult.user.uid,
          'displayName': user.displayName,
          'bio': '',
          'timestamp': DateTime.now(),
        });
        await followersRef
            .doc(authResult.user.uid)
            .collection('userFollowers')
            .doc(authResult.user.uid)
            .set({});
      }
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (ctx) => Home()));
    } on PlatformException catch (error) {
      var messages = 'في خطا في الاتصال بالنت باين معكش رصيد هههههه';
      if (error.message != null) {
        messages = error.message;
        Fluttertoast.showToast(msg: messages);
      }
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: auth_form(submit, isLoading),
    );
  }
}
//  String email;
//   String username;
//   String password;
//   bool isLogin;
//   AuthResult authResult;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   void login(String email, String password) async {
//     try {
//       authResult = await _auth
//           .signInWithEmailAndPassword(email: email, password: password);
//           notifyListeners();
//     } on PlatformException catch (err) {
//       var messages = 'An error occured,please check your credentials';
//       if (err.message != null) {
//         messages = err.message;
//         Fluttertoast.showToast(msg: messages);
//       }
//     } catch (error) {
//       print(error);
//     }
//   }

//   void signup(String email, String password) async {
//     try {
//       authResult = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);
//       Firestore.instance
//           .collection('users')
//           .document(authResult.user.uid)
//           .setData({
//         'email': email,
//         'username': username,
//       });
//        notifyListeners();
//     } on PlatformException catch (err) {
//       var messages = 'An error occured,please check your credentials';
//       if (err.message != null) {
//         messages = err.message;
//         Fluttertoast.showToast(msg: messages);
//       }
//     } catch (error) {
//       print(error);
//     }
//   }

//   void logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//        notifyListeners();
//     } on PlatformException catch (err) {
//       var messages = 'An error occured,please check your credentials';
//       if (err.message != null) {
//         messages = err.message;
//         Fluttertoast.showToast(msg: messages);
//       }
//     } catch (error) {
//       print(error);
//     }
//   }
