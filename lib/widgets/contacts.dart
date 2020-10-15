import 'package:chat/models/user_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/FullPhoto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../provider/chat_provider.dart';
import '../screens/chat.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/Constant/constant.dart';

class ContactsWidget extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: userCollection.snapshots(),
        builder: (context, contactSnapshot) {
          if (contactSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (contactSnapshot.connectionState == ConnectionState.none) {
            return Center(
                child: Text('فقدت الاتصال بالانترنت رستر الراوتر هههه'));
          }
          final snapShot = contactSnapshot.data.documents;
          if (!contactSnapshot.hasData) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
              color: Colors.white.withOpacity(0.7),
            );
          }
          return ListView(
              key: formKey,
              reverse: true,
              primary: false,
              shrinkWrap: true,
              children: snapShot.map((data) {
                if (data.data()['userId'] == Photos.myID) return Container();
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(Photos.myID)
                        .collection('Messages')
                        .where('chatWith', isEqualTo: data.data()['userId'])
                        .orderBy('CreatedAt', descending: true)
                        .snapshots(),
                    builder: (ctx, chatListSnapshot) {
                      if (chatListSnapshot.data == null) {
                        return Container();
                      } else if (chatListSnapshot.data.documents.length == 0) {
                        return Container();
                      }
                      return GestureDetector(
                        onTap: () {
                          String chatId =
                              Provider.of<Photos>(context, listen: false)
                                  .makeChatRoomId(data.data()['userId']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => chat_screen(
                                chatId: chatId,
                                myId: Photos.myID,
                                firstname:
                                    data.data()['userName'].split(' ')[0],
                                image: data.data()['UserimageUrl'],
                                idTo: data.data()['userId'],
                                isActive: data.data()['isActive'],
                                reciver: User(
                                    userId: data.data()['userId'],
                                    userName:
                                        data.data()['userName'].split(' ')[0],
                                    imageUrl: data.data()['UserimageUrl']),
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: (data.data()['uplodedStory'] &&
                                  data.data()['uplodedStory'] != null)
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullPhoto(
                                                  url:
                                                      data.data()['StoryPhoto'],
                                                )));
                                  },
                                  child: CircleAvatar(
                                    radius: MediaQuery.of(context).size.height *
                                        0.038,
                                    backgroundColor: Colors.blue,
                                    child: CircleAvatar(
                                      backgroundImage:
                                          data.data()['uplodedStory']
                                              ? CachedNetworkImageProvider(
                                                  data.data()['StoryPhoto'])
                                              : CachedNetworkImageProvider(
                                                  data.data()['UserimageUrl']),
                                      radius:
                                          MediaQuery.of(context).size.height *
                                              0.032,
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ),
                                )
                              : (data.data()['isActive'] &&
                                      !data.data()['uplodedStory'])
                                  ? Stack(children: <Widget>[
                                      CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                data.data()['UserimageUrl']),
                                        radius:
                                            MediaQuery.of(context).size.height *
                                                0.038,
                                        backgroundColor: Colors.grey[300],
                                      ),
                                      Positioned(
                                        top: 38,
                                        left: 45,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 8,
                                          child: CircleAvatar(
                                            radius: 6,
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ])
                                  : CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              data.data()['UserimageUrl']),
                                      radius:
                                          MediaQuery.of(context).size.height *
                                              0.038,
                                      backgroundColor: Colors.grey[300],
                                    ),
                          title: Row(
                            children: [
                              Text(
                                data.data()['userName'].split(' ')[0],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                data.data()['userName'].split(' ')[1] ?? "",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 1),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.5,
                                  minWidth: 30,
                                ),
                                child: Text(
                                  chatListSnapshot.data.documents[0]
                                      ['lastMessage'],
                                  style: TextStyle(fontSize: 15),
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(chatListSnapshot.data.documents[0]
                                  ['timestamp']),
                            ],
                          ),
                        ),
                      );
                    });
              }).toList());
        });
  }
}
