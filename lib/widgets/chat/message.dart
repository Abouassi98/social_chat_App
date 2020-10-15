import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './message_Bubble.dart';
import 'package:chat/provider/chat_provider.dart';
import 'dart:io';

class Message extends StatelessWidget {
  bool isActive;

  String chatId;
  Stream stream;
  ScrollController _listScrollController = ScrollController();
  String idTo;
  Message({this.isActive, this.chatId, this.stream, this.idTo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (ctx, chatSnapShot) {
          if (chatSnapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (chatSnapShot.connectionState == ConnectionState.none) {
            return Center(
                child: Text('فقدت الاتصال بالانترنت رستر الراوتر هههه'));
          }
          final chatDocs = chatSnapShot.data.documents;
          for (var data in chatDocs) {
            if (data['idFrom'] != Photos.myID && data['isSeen'] == false) {
              FirebaseFirestore.instance
                  .runTransaction((Transaction myTransaction) async {
                //final user = await FirebaseAuth.instance.currentUser();
                final userData = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(Photos.myID)
                    .get();
                myTransaction.update(data.reference, {
                  'isSeen': true,
                  'imageSeen': userData.data()['UserimageUrl']
                });
              });
            }
          }
          List<bool> seenOrNot = [];
          for (int i = 0; i < chatDocs.length; i++) {
            seenOrNot.add(chatDocs[i]['isSeen']);
          }
          print(
              'lengthOfelementoutofSeenList is\t${seenOrNot.indexWhere((element) => element)}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _listScrollController.animateTo(
              _listScrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          });

          return ListView.builder(
            controller: _listScrollController,
            reverse: true,
            itemCount: chatDocs.length,
            itemBuilder: (ctx, i) {
              int hours = 0;
              int minutes = 0;
              double seconds = 0;
              if (chatDocs[i]['typeMessage'] == 'record') {
                List<String> durations =
                    (chatDocs[i]['duration'] as String).split(':');

                hours = int.parse(durations[durations.length - 3]);

                minutes = int.parse(durations[durations.length - 2]);

                seconds = double.parse(durations[2]);
              }
              var duration = Duration(
                hours: hours,
                minutes: minutes,
                seconds: seconds.round(),
              );
              print(duration);

              return message_Bubble(
                isActive: isActive,
                // userName: chatDocs[i]['userName'],
                imageUrl: chatDocs[i]['imageUrl'],
                imageSeen: chatDocs[i]['imageSeen'],
                isMe: chatDocs[i]['idFrom'] == Photos.myID,
                typeMessage: chatDocs[i]['typeMessage'],
                key: ValueKey(chatDocs[i].documentID),
                message: chatDocs[i]['content'],
                isSeen: chatDocs[i]['isSeen'],
                chatId: chatId,
                index: i,
                chatDocs: chatDocs,
                idTo: idTo,
                deletedMessage:
                    chatDocs[i]['content'] == 'This message is removed',
                duration: duration,
                lengthOfSeenOrNot: seenOrNot.indexWhere((element) => element),
              );
            },
          );
        });
  }
}
