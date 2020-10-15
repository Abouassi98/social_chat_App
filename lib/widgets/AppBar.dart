import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth/auth_google.dart';
import '../Constant/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../provider/chat_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/auth/auth_google.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat/models/user_form.dart' as userForm;
import 'package:chat/screens/auth.dart';

class AppBenaburr extends StatelessWidget {
  final Stream stream;

  final fbAuth.FirebaseAuth _auth = fbAuth.FirebaseAuth.instance;
  final userForm.User _user = userForm.User();
  final GoogleSignIn googleSign = GoogleSignIn();
  AppBenaburr(this.stream);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (ctx, stramSnapShot) {
                    if (stramSnapShot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (stramSnapShot.connectionState == ConnectionState.none) {
                      return Center(
                          child:
                              Text('فقدت الاتصال بالانترنت رستر الراوتر هههه'));
                    }
                    if (!stramSnapShot.hasData) {
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                        color: Colors.white.withOpacity(0.7),
                      );
                    }

                    final snapShot = stramSnapShot.data.docs;

                    return Stack(
                        children: snapShot.map((data) {
                      if (data.data()['userId'] == Photos.myID) {
                        return Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                            child: StreamBuilder<QuerySnapshot>(
                                stream: userCollection.snapshots(),
                                builder: (ctx, stramSnapShot) {
                                  return CircleAvatar(
                                    radius: 20,
                                    backgroundImage: CachedNetworkImageProvider(
                                        data.data()['UserimageUrl']),
                                  );
                                })
                            // Positioned(
                            //   right: 2,
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //         color: Colors.red,
                            //         borderRadius: BorderRadius.circular(18),
                            //         border:
                            //             Border.all(color: Colors.white, width: 2)),
                            //     child: Padding(
                            //       padding: const EdgeInsets.only(left: 6, right: 6),
                            //       child: Text(
                            //         "+1",
                            //         style: TextStyle(
                            //             fontSize: 17,
                            //             color: Colors.white,
                            //             fontWeight: FontWeight.w600),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            );
                      }
                      if (data.data()['userId'] != Photos.myID)
                        return Container();
                    }).toList());
                  }),
              SizedBox(width: 8),
              Text(
                "Chats",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 17,
              ),
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
