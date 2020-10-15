import 'package:flutter/material.dart';
import '../provider/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/Constant/constant.dart';
import '../screens/FullPhoto.dart';
//import 'package:flutter_instagram_stories/flutter_instagram_stories.dart';
import 'package:meta/meta.dart';

enum MediaType { image, video }

class story_photos extends StatelessWidget {
  final Stream stream;
  // final MediaType media;
  String imageStory;
  // final Duration duration;

  story_photos(this.stream, this.imageStory);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (ctx, contactSnapshot) {
          if (contactSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (contactSnapshot.connectionState == ConnectionState.none) {
            return Center(
                child: Text('فقدت الاتصال بالانترنت رستر الراوتر هههه'));
          }
          final snapShot = contactSnapshot.data.documents;

          for (var data in snapShot) {
            if (data.data()['userId'] == Photos.myID && imageStory != null) {
              FirebaseFirestore.instance
                  .runTransaction((Transaction myTransaction) async {
                myTransaction.update(data.reference, {
                  'StoryPhoto': imageStory,
                  'uplodedStory': true,
                });
              });
            }
          }
          return ListView(
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: snapShot.map((data) {
                if (data.data()['userId'] == Photos.myID) return Container();
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(Photos.myID)
                        .collection('Messages')
                        .where('chatWith', isEqualTo: data.data()['userId'])
                        .snapshots(),
                    builder: (ctx, storySnapShot) {
                      if (storySnapShot.data == null) {
                        return Container();
                      } else if (storySnapShot.data.documents.length == 0) {
                        return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(9, 4, 8, 0),
                        child: Column(
                          children: <Widget>[
                            Flexible(
                              child: data.data()['uplodedStory']
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FullPhoto(
                                                      url: data
                                                          .data()['StoryPhoto'],
                                                    )));
                                      },
                                      child: CircleAvatar(
                                        radius:
                                            MediaQuery.of(context).size.height *
                                                0.038,
                                        backgroundColor: Colors.blue,
                                        child: CircleAvatar(
                                          backgroundImage: data
                                                  .data()['uplodedStory']
                                              ? CachedNetworkImageProvider(
                                                  data.data()['StoryPhoto'])
                                              : CachedNetworkImageProvider(
                                                  data.data()['UserimageUrl']),
                                          radius: MediaQuery.of(context)
                                                  .size
                                                  .height *
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
                                                CachedNetworkImageProvider(data
                                                    .data()['UserimageUrl']),
                                            radius: MediaQuery.of(context)
                                                    .size
                                                    .height *
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
                                          radius: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.038,
                                          backgroundColor: Colors.grey[300],
                                        ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              data.data()['userName'].split(' ')[0],
                              style: TextStyle(fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      );
                    });
              }).toList());
        });
  }
}
