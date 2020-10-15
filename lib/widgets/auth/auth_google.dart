import 'package:chat/provider/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat/models/user_form.dart' as userForm;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat/screens/tab_screen.dart';
import 'package:chat/screens/auth.dart';
import 'package:shimmer/shimmer.dart';
import '../../screens/social_screens/home.dart';

class AuthGoogle extends StatefulWidget {
  AuthGoogle({Key key}) : super(key: key);

  @override
  _AuthGoogleState createState() => _AuthGoogleState();
}

class _AuthGoogleState extends State<AuthGoogle> {
  String name;
  String email;
  String imageUrl;
  String id;
  bool isLoading = false;
  final fbAuth.FirebaseAuth _auth = fbAuth.FirebaseAuth.instance;
  final userForm.User _user = userForm.User();
  final GoogleSignIn googleSign = GoogleSignIn();
  Future<userForm.User> signUp(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      setState(() {
        isLoading = true;
      });
      final GoogleSignInAccount googleSignInAccount =
          await googleSign.signIn().catchError(
                (error) => Fluttertoast.showToast(
                  msg: 'Please Make sure that you have working internet.',
                ),
              );

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final fbAuth.AuthCredential authCredential =
          fbAuth.GoogleAuthProvider.credential(
              idToken: googleSignInAuthentication.idToken,
              accessToken: googleSignInAuthentication.accessToken);

      final fbAuth.UserCredential authResult =
          await _auth.signInWithCredential(authCredential);
      final fbAuth.User user = authResult.user;
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoURL != null);
      final email = user.email;
      final name = user.displayName;
      final photo = user.photoURL;
      final id = user.uid;
      _user.addUser(email: email, imageUrl: photo, userId: id, userName: name);
      print(name);
      print(email);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      final fbAuth.User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
      preferences.setString('userName', currentUser.displayName);
      preferences.setString('userId', currentUser.uid);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));

      //  Photos.myID=id;
      setState(() {
        isLoading = false;
      });
      return _user.getUserCurrent(currentUser);
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Please Make sure that you have working internet.',
      );
      setState(() {
        isLoading = false;
      });
      return _user.getUserCurrent(null);
    }
  }

  Future<void> signOut(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      if (preferences.containsKey('userName')) {
        await googleSign.signOut().catchError((onError) {
          print(onError.toString());
          Fluttertoast.showToast(msg: 'User Unsuccessfuly Signed Out');
        }).whenComplete(() async {
          await preferences.remove('userName');
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AuthScreen()));
        });
      } else if (preferences.containsKey('user')) {
        await _auth.signOut().catchError((onError) {
          print(onError.toString());
          Fluttertoast.showToast(msg: 'User Unsuccessfuly Signed Out');
        }).whenComplete(() async {
          await preferences.remove('user');
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AuthScreen()));
        });
        Fluttertoast.showToast(msg: 'User Successfuly Signed Out');
      }

      print("User Sign Out");
    } catch (e) {
      Fluttertoast.showToast(msg: 'Sign Out Failed, Please try agein');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.pink,
      highlightColor: Colors.blueAccent,
      child: Stack(children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
          child: OutlineButton(
            splashColor: Colors.grey,
            onPressed: () => signUp(context),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            highlightElevation: 0,
            borderSide: BorderSide(color: Colors.grey[400]),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Image(
                      image: AssetImage('images/google_logo.png'),
                      height: 24,
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(),
      ]),
    );
  }
}
