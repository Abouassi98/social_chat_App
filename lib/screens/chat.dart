import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import '../widgets/chat/message.dart';
import '../widgets/chat/new_message.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Constant/constant.dart';
import 'dart:io';
import 'package:chat/utils/call_Utils.dart';
import 'package:chat/models/user_form.dart' as userForm;
import 'package:chat/provider/chat_provider.dart';
import '../models/call.dart';
import 'callScreens/pickup_Screens.dart';
import 'package:chat/utils/permissions.dart';
import 'contacts.dart';

class chat_screen extends StatefulWidget {
  static const routedname = '/chat_screen';
  final image;
  String chatId;
  String idTo;
  String myId;
  userForm.User reciver;
  bool isActive;

  final firstname;
  chat_screen(
      {this.image,
      this.chatId,
      this.myId,
      this.isActive,
      this.idTo,
      this.reciver,
      this.firstname});
  @override
  _chat_screenState createState() => _chat_screenState();
}

class _chat_screenState extends State<chat_screen> {
  final formKey = GlobalKey<FormState>();
  @override
  Stream _stream;
  userForm.User sender;

  userForm.User myUser = userForm.User();
  void initState() {
    setState(() {
      _stream = chatCollection
          .doc(widget.chatId)
          .collection(widget.chatId)
          .orderBy('CreatedAt', descending: true)
          .snapshots();
    });

    myUser.getCurrentUser().then((user) {
      setState(() {
        sender = userForm.User(
          userId: user.uid,
          userName: user.displayName,
          imageUrl: user.photoURL,
        );
      });
    });

    // TODO: implement initState
    // final fbm = FirebaseMessaging();
    // fbm.configure(
    //   onMessage: (msg) {
    //     print(msg);
    //     return;
    //   },
    //   onLaunch: (msg) {
    //     print(msg);
    //     return;
    //   },
    //   onResume: (msg) {
    //     print(msg);
    //     return;
    //   },
    // );
    // fbm.subscribeToTopic('chat');
    super.initState();
    print(Photos.myID);
  }

  @override
  Widget build(BuildContext context) {
    return Photos.myID != null
        ? StreamBuilder<DocumentSnapshot>(
            stream: callCollection.doc(Photos.myID).snapshots(),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return Center(child: CircularProgressIndicator());
              // }
              // if (snapshot.connectionState == ConnectionState.none) {
              //   return Center(
              //       child: Text('فقدت الاتصال بالانترنت رستر الراوتر هههه'));
              // }
              if (snapshot.hasData && snapshot.data.data() != null) {
                Call call = Call.fromMap(snapshot.data.data());
                if (!call.hasDialled &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!call.hasDialled) {
                  return (PickupScreens(
                    call: call,
                    myId: widget.myId,
                  ));
                }
              }
              return Scaffold(
                appBar: AppBar(
                  titleSpacing: 1,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  backgroundColor: Colors.white,
                  elevation: 2,
                  title: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: ListTile(
                        leading: widget.isActive
                            ? Stack(
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        widget.image),
                                    radius: MediaQuery.of(context).size.height *
                                        0.030,
                                    backgroundColor: Colors.grey[300],
                                  ),
                                  Positioned(
                                    top: 30,
                                    left: 30,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 8,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : CircleAvatar(
                                backgroundImage:
                                    CachedNetworkImageProvider(widget.image),
                                radius:
                                    MediaQuery.of(context).size.height * 0.028,
                                backgroundColor: Colors.grey[300],
                              ),
                        title: Text(
                          widget.firstname,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle:
                            widget.isActive ? Text('Active') : Container(),
                        trailing: Container(
                          width: MediaQuery.of(context).size.width * 0.37,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.call,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  await Permissions
                                          .cameraAndMicrophonePermissionsGranted()
                                      ? CallUtils.dial(
                                          from: sender,
                                          to: widget.reciver,
                                          context: context,
                                          videoCall: false,
                                        )
                                      : {};
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.video_call,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  await Permissions
                                          .cameraAndMicrophonePermissionsGranted()
                                      ? CallUtils.dial(
                                          from: sender,
                                          to: widget.reciver,
                                          context: context,
                                          videoCall: true,
                                        )
                                      : {};
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.info,
                                  color: Colors.blue,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // actions: [
                    //   DropdownButton(
                    //     underline: Container(),
                    //     icon: Icon(
                    //       Icons.more_vert,
                    //       color: Theme.of(context).primaryIconTheme.color,
                    //     ),
                    // items: [
                    //   DropdownMenuItem(
                    //     child: Container(
                    //       child: Row(
                    //         children: <Widget>[
                    //           Icon(Icons.exit_to_app),
                    //           SizedBox(
                    //             width: 8,
                    //           ),
                    //           Text('Logout'),
                    //         ],
                    //       ),
                    //     ),
                    //     value: 'logout',
                    //   )
                    // ],
                    // onChanged: (itemIdentifer) {
                    //   if (itemIdentifer == 'logout') {
                    //     FirebaseAuth.instance.signOut();
                    //   }
                    // },
                    //   ),
                    // ],
                  ),
                ),
                body: Column(
                  children: <Widget>[
                    Expanded(
                      child: Message(
                        isActive: widget.isActive,
                        chatId: widget.chatId,
                        stream: _stream,
                        idTo: widget.idTo,
                      ),
                    ),
                    new_message(
                      chatId: widget.chatId,
                      idTo: widget.idTo,
                    ),
                  ],
                ),
              );
            })
        : Scaffold(
            body: Container(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
