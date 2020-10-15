import 'package:flutter/material.dart';
import '../../screens/tab_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../screens/auth.dart';

final GoogleSignIn googleSign = GoogleSignIn();
final _auth = FirebaseAuth.instance;
AppBar header(context,
    {bool isAppTitle = false, var titleText, removeBackButton = false}) {
  return AppBar(
    leading: PopupMenuButton(
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'signOut',
          child: ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('SignOut'),
          ),
        ),
      ],
      onSelected: (value) async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        try {
          if (preferences.containsKey('userName')) {
            await googleSign.signOut().catchError((onError) {
              print(onError.toString());
              Fluttertoast.showToast(msg: 'User Unsuccessfuly Signed Out');
            }).whenComplete(() async {
              await preferences.remove('userName');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AuthScreen()));
            });
          } else if (preferences.containsKey('user')) {
            await _auth.signOut().catchError((onError) {
              print(onError.toString());
              Fluttertoast.showToast(msg: 'User Unsuccessfuly Signed Out');
            }).whenComplete(() async {
              await preferences.remove('user');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AuthScreen()));
            });
            Fluttertoast.showToast(msg: 'User Successfuly Signed Out');
          }

          print("User Sign Out");
        } catch (e) {
          Fluttertoast.showToast(msg: 'Sign Out Failed, Please try agein');
        }
      },
    ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.message,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(TabScreen.routedname);
        },
      ),
    ],
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? 'Blazingram' : titleText,
      style: TextStyle(
        color: Colors.black,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50 : 22,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.fade,
    ),
    centerTitle: true,
    backgroundColor: Colors.white70,
  );
}
