import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import './provider/chat_provider.dart';

import './screens/auth.dart';

import './screens/tab_screen.dart';
import './screens/searchScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './models/user_form.dart';
import './screens/social_screens/home.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var user = prefs.getString('userName');
  print(user);
  var emailUser = prefs.getString('user');
  print(emailUser);
  await Firebase.initializeApp();
  runApp(MyApp(user: user, emailUser: emailUser));
}

class MyApp extends StatelessWidget {
  final String user;
  final String emailUser;
  String message;
  MyApp({this.user, this.emailUser});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Photos()),
      ],
      child: StreamProvider.value(
        value: User().currentUser,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AsyChat',
          theme: ThemeData(
            backgroundColor: Colors.pink,
            primarySwatch: Colors.blue,
            accentColor: Colors.deepPurple,
            buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: Colors.pink,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
          home: user == null && emailUser == null ? AuthScreen() : Home(),
          routes: {
            SearchScreen.routedname: (ctx) => SearchScreen(),
            TabScreen.routedname: (ctx) => TabScreen(),
          },
        ),
      ),
    );
  }
}
