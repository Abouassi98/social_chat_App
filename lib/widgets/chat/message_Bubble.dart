import 'package:audioplayers/audioplayers.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/screens/FullPhoto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat/Constant/constant.dart';
import 'package:chat/provider/chat_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class message_Bubble extends StatefulWidget {
  final String message;
  final bool isMe;
  File fileImage;
  bool isActive;
  bool deletedMessage;
  final String imageUrl;
  //final String userName;
  final Key key;
  int index;
  String idTo;
  int lengthOfSeenOrNot;
  final String imageSeen;
  String chatId;
  bool isSeen;
  Duration duration;
  String typeMessage;
  dynamic chatDocs;
  message_Bubble(
      {this.message,
      this.fileImage,
      this.idTo,
      this.deletedMessage,
      this.chatDocs,
      this.isActive,
      this.isMe,
      this.imageUrl,
      this.imageSeen,
      this.chatId,
      this.typeMessage,
      this.duration,
      this.key,
      this.isSeen,
      this.index,
      this.lengthOfSeenOrNot});

  @override
  _message_BubbleState createState() => _message_BubbleState();
}

class _message_BubbleState extends State<message_Bubble> {
  var isHeart;
  var audioPlayer = AudioPlayer();
  double playerSeeker = 0;
  Duration playerDuration;
  bool isPlaying = false;
  int maxDuration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('fileImage=${widget.fileImage}');
  }

  deleteMessage() async {
    try {
      for (var data in widget.chatDocs) {
        if (data['idFrom'] == Photos.myID &&
            data['content'] == widget.message) {
          Firestore.instance.runTransaction((Transaction myTransaction) async {
            return await myTransaction.update(data.reference,
                {'content': 'This message is removed', 'typeMessage': 'Text'});
          });
        }
      }

      Provider.of<Photos>(context, listen: false).updateChatRequestField(
          Photos.myID, 'This message is removed', widget.idTo, context);
      Provider.of<Photos>(context, listen: false).updateChatRequestField(
          widget.idTo, 'This message is removed', widget.idTo, context);
      if (widget.typeMessage == 'photo') {
        await Provider.of<Photos>(context, listen: false)
            .deletePhoto(widget.imageUrl);
      }
      print('message=${widget.message}');
      Fluttertoast.showToast(msg: 'مسحتهالك يعم اي خدمه');
    } catch (error) {
      Fluttertoast.showToast(msg: 'مفيش حاجه اتمسحت مفيش عندك عدل ');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typeMessage == 'record') {
      print('due ${widget.duration}');
    }
    return Row(
        crossAxisAlignment:
            (!widget.isMe && widget.lengthOfSeenOrNot == widget.index)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: widget.isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: <Widget>[
                  if (!widget.isMe)
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                        ),
                        child: widget.isActive
                            ? Stack(
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: CachedNetworkImageProvider(
                                      widget.imageUrl,
                                    ),
                                  ),
                                  Positioned(
                                    top: 20,
                                    left: 20,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 7,
                                      child: CircleAvatar(
                                        radius: 5,
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.grey,
                                backgroundImage: CachedNetworkImageProvider(
                                  widget.imageUrl,
                                ),
                              ),
                      ),
                    ),
                  Flexible(
                    child: Container(
                      decoration: (widget.message == '👍' ||
                              widget.typeMessage == 'photo')
                          ? null
                          : widget.deletedMessage
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(35),
                                  ),
                                  border: Border.all(color: Colors.grey[300]),
                                )
                              : BoxDecoration(
                                  color: widget.isMe
                                      ? Colors.blue
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(35),
                                      topRight: Radius.circular(35),
                                      bottomLeft: !widget.isMe
                                          ? Radius.circular(0)
                                          : Radius.circular(35),
                                      bottomRight: widget.isMe
                                          ? Radius.circular(0)
                                          : Radius.circular(35)),
                                ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: (widget.typeMessage == 'photo')
                          ? GestureDetector(
                              onLongPress: () {
                                if (widget.isMe && !widget.deletedMessage) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('اخر كلام'),
                                      content:
                                          Text('عاوز تمسح الرسالة ديه يحب'),
                                      actions: [
                                        FlatButton(
                                          child: Text('No'),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('Yes'),
                                          onPressed: () {
                                            try {
                                              if (widget.typeMessage ==
                                                  'photo') {}
                                              deleteMessage();
                                              Navigator.of(ctx).pop();
                                            } catch (error) {
                                              return error;
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullPhoto(
                                      url: widget.message,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  child: widget.message != null
                                      ? CachedNetworkImage(
                                          imageUrl: widget.message,
                                        )
                                      : widget.fileImage != null
                                          ? Stack(
                                              children: <Widget>[
                                                Image.file(widget.fileImage,
                                                    fit: BoxFit.cover),
                                                Positioned(
                                                    top: 30,
                                                    child:
                                                        CircularProgressIndicator()),
                                              ],
                                              overflow: Overflow.visible,
                                            )
                                          : CircularProgressIndicator(),
                                ),
                              ),
                            )
                          : widget.typeMessage == 'record'
                              ? GestureDetector(
                                  onLongPress: () {
                                    if (widget.isMe && !widget.deletedMessage) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('اخر كلام'),
                                          content: Text(
                                              'عاوز تمسح الصوت الجميل ده يحب'),
                                          actions: [
                                            FlatButton(
                                              child: Text('No'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Yes'),
                                              onPressed: () {
                                                try {
                                                  if (widget.typeMessage ==
                                                      'photo') {}
                                                  deleteMessage();
                                                  Navigator.of(ctx).pop();
                                                } catch (error) {
                                                  return error;
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: widget.deletedMessage
                                      ? Text(
                                          widget.message,
                                          style: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 16),
                                          textAlign: widget.isMe
                                              ? TextAlign.end
                                              : TextAlign.start,
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          // TODO : Resume Record Button..
                                          children: [
                                            Slider.adaptive(
                                              activeColor: widget.isMe
                                                  ? Colors.white
                                                  : Colors.blue,
                                              inactiveColor: widget.isMe
                                                  ? Colors.grey
                                                  : Colors.blueGrey,
                                              min: 0.0,
                                              max: widget.duration.inSeconds
                                                  .toDouble(),
                                              value: playerSeeker,
                                              onChanged: (value) async {
                                                setState(() {
                                                  playerSeeker = value;
                                                });
                                                print(playerSeeker);

                                                if (audioPlayer.state ==
                                                        AudioPlayerState
                                                            .PLAYING ||
                                                    audioPlayer.state ==
                                                        AudioPlayerState
                                                            .PAUSED) {
                                                  await audioPlayer.seek(
                                                      Duration(
                                                          seconds: playerSeeker
                                                              .toInt()));
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow),
                                              onPressed: () {
                                                print(
                                                    'pppp${audioPlayer.state}');
                                                if (!isPlaying) {
                                                  if (audioPlayer.state ==
                                                      AudioPlayerState.PAUSED) {
                                                    audioPlayer.resume();
                                                  } else {
                                                    audioPlayer
                                                        .play(widget.message);

                                                    audioPlayer
                                                        .onAudioPositionChanged
                                                        .listen((event) {
                                                      if (event.inSeconds <=
                                                              0 &&
                                                          playerSeeker > 0) {
                                                        setState(() {
                                                          event = Duration(
                                                              seconds:
                                                                  playerSeeker
                                                                      .round());
                                                        });
                                                      }
                                                      setState(() {
                                                        playerSeeker = event
                                                            .inSeconds
                                                            .toDouble();
                                                      });
                                                    }).onError((error) {
                                                      setState(() {
                                                        playerSeeker = 0.0;
                                                        playerDuration =
                                                            Duration(
                                                                seconds: 0);
                                                      });
                                                    });
                                                    audioPlayer
                                                        .onPlayerStateChanged
                                                        .listen((event) {
                                                      if (audioPlayer.state ==
                                                          AudioPlayerState
                                                              .STOPPED) {
                                                        print('srop');
                                                        setState(() {
                                                          playerSeeker =
                                                              playerDuration
                                                                  .inSeconds
                                                                  .toDouble();
                                                        });
                                                      } else if (audioPlayer
                                                              .state ==
                                                          AudioPlayerState
                                                              .COMPLETED) {
                                                        print('com');
                                                        setState(() {});

                                                        setState(() {
                                                          playerSeeker = 0;
                                                          isPlaying = false;
                                                        });
                                                        print(isPlaying);
                                                      }
                                                    });
                                                  }
                                                } else if (isPlaying) {
                                                  audioPlayer.pause();
                                                }
                                                setState(() {
                                                  isPlaying = !isPlaying;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                )
                              : GestureDetector(
                                  onLongPress: () {
                                    if (widget.isMe && !widget.deletedMessage) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('اخر كلام'),
                                          content:
                                              Text('عاوز تمسح الرسالة ديه يحب'),
                                          actions: [
                                            FlatButton(
                                              child: Text('No'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Yes'),
                                              onPressed: () {
                                                try {
                                                  if (widget.typeMessage ==
                                                      'photo') {}
                                                  deleteMessage();
                                                  Navigator.of(ctx).pop();
                                                } catch (error) {
                                                  return error;
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    widget.message,
                                    style: widget.deletedMessage
                                        ? TextStyle(
                                            color: Colors.black45, fontSize: 16)
                                        : TextStyle(
                                            color: widget.isMe
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16),
                                    textAlign: widget.isMe
                                        ? TextAlign.end
                                        : TextAlign.start,
                                  ),
                                ),
                    ),
                  ),
                  if (widget.isMe &&
                      widget.isSeen &&
                      widget.index == widget.lengthOfSeenOrNot)
                    CircleAvatar(
                      radius: 10,
                      backgroundImage:
                          CachedNetworkImageProvider(widget.imageSeen),
                    ),
                  if (widget.isMe && !widget.isSeen)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        minRadius: 1,
                        backgroundColor: Colors.grey[400],
                        child: Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ]),
          ),
          if (!widget.isMe && widget.index == widget.lengthOfSeenOrNot)
            Container(
              margin: EdgeInsets.all(8),
              child: CircleAvatar(
                radius: 10,
                backgroundImage: CachedNetworkImageProvider(widget.imageUrl),
              ),
            ),
        ]);
  }
}
