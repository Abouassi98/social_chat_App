import 'package:chat/widgets/chat/message_Bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat/Constant/constant.dart';
import 'package:chat/provider/chat_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './message.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:chat/utils/universal_variables.dart';
import '../../utils/permissions.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart' as sysPath;

class new_message extends StatefulWidget {
  String chatId;
  String idTo;
  String timer = DateTime.now().millisecondsSinceEpoch.toString();
  new_message({this.chatId, this.timer, this.idTo});
  @override
  _new_messageState createState() => _new_messageState();
}

class _new_messageState extends State<new_message> {
  FlutterAudioRecorder record;
  String timeofNow = DateTime.now().millisecondsSinceEpoch.toString();
  ImageSource camera = ImageSource.camera;
  ImageSource gallery = ImageSource.gallery;
  dynamic photo;
  FocusNode textFieldFoucs = FocusNode();
  File pickedImage;
  bool showEmojiPicker = false;
  bool isWriting = false;
  bool isRecording = false;
  bool isUploading = false;
  final _controller = TextEditingController();

  void _sendTextMessage(String text) async {
    Photos.fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(Photos.myID)
        .get();
    try {
      chatCollection
          .doc(widget.chatId)
          .collection(widget.chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set(
        {
          'content': !isWriting ? '👍' : enterdMessage,
          'typeMessage': 'text',
          'CreatedAt': Timestamp.now(),
          'idFrom': userData.data()['userId'],
          'idTo': widget.idTo,
          'userName': userData.data()['userName'],
          'imageUrl': userData.data()['UserimageUrl'],
          'imageSeen': null,
          'isSeen': false,
        },
      );
      Provider.of<Photos>(context, listen: false).updateChatRequestField(
          Photos.myID, !isWriting ? '👍' : enterdMessage, widget.idTo, context);

      Provider.of<Photos>(context, listen: false).updateChatRequestField(
          widget.idTo, !isWriting ? '👍' : enterdMessage, widget.idTo, context);
    } catch (e) {
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          });
    }
    setState(() {
      isWriting = false;
    });
    _controller.clear();
  }

  Future<void> _saveUserImageToFirebaseStorage(ImageSource chooseSurce) async {
    final fileImage = await ImagePicker().getImage(
      source: chooseSurce,
    );
    if (fileImage == null) {
      return;
    }
    setState(() {
      pickedImage = File(fileImage.path);
    });

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(Photos.myID)
        .get();
    try {
      FirebaseFirestore.instance
          .collection('chat')
          .doc(widget.chatId)
          .collection(widget.chatId)
          .doc(timeofNow)
          .set(
        {
          'content': null,
          'typeMessage': 'photo',
          'CreatedAt': Timestamp.now(),
          'idFrom': userData.data()['userId'],
          'idTo': widget.idTo,
          'userName': userData.data()['userName'],
          'imageUrl': userData.data()['UserimageUrl'],
          'imageSeen': null,
          'isSeen': false,
        },
      );
      Provider.of<Photos>(context, listen: false).updateChatRequestField(
          Photos.myID, 'You sent a photo', widget.idTo, context);

      Provider.of<Photos>(context, listen: false).updateChatRequestField(
          widget.idTo, 'You received a photo', widget.idTo, context);
    } catch (e) {
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          });
    }
    return await Provider.of<Photos>(context, listen: false)
        .uploadchatPicture(pickedImage)
        .then((value) => value != null
            ? setState(() {
                photo = value;
                print('photo=$photo');
                FirebaseFirestore.instance
                    .collection('chat')
                    .doc(widget.chatId)
                    .collection(widget.chatId)
                    .doc(timeofNow)
                    .update({
                  'content': photo,
                });
              })
            : Fluttertoast.showToast(
                msg: 'الصوره فيها حاجه غلط لو وشك غيهر بحاجه عدله '));
  }

  showKeyboard() => textFieldFoucs.requestFocus();
  hideKeyboard() => textFieldFoucs.unfocus();
  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: Colors.white54,
      indicatorColor: UniversalVariables.blackColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });
        _controller.text = _controller.text + emoji.emoji;
        enterdMessage = _controller.text;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  void _uploadRecordMessage() async {
    print('canceled');

    setState(() {
      isRecording = !isRecording;

      isUploading = true;
    });
    var recording = await record.stop();
    print(recording.path);
    print(recording.duration);
    print(recording.extension);
    var recordDuration = recording.duration;

    var url = await Provider.of<Photos>(context, listen: false)
        .uploadchatRecord(File(recording.path));
    print(url);
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(Photos.myID)
        .get();
    try {
      await chatCollection
          .doc(widget.chatId)
          .collection(widget.chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set(
        {
          'content': url,
          'typeMessage': 'record',
          'CreatedAt': Timestamp.now(),
          'idFrom': userData.data()['userId'],
          'idTo': widget.idTo,
          'userName': userData.data()['userName'],
          'imageUrl': userData.data()['UserimageUrl'],
          'imageSeen': null,
          'isSeen': false,
          'duration': recording.duration.toString(),
        },
      );
      setState(() {
        isUploading = false;
      });
    } catch (error) {
      setState(() {
        isUploading = false;
      });
    }
  }

  // int numLines = 0;
  var enterdMessage = '';
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () async {
      var path = await sysPath.getApplicationDocumentsDirectory();
      var file = File('${path.path}.m4a');
      print(file.path);
      print(Photos.myID);
      var isExists = await file.exists();
      if (isExists) {
        print('exists');
        file.delete();
      }

      record = FlutterAudioRecorder(path.path, audioFormat: AudioFormat.AAC);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    return Column(children: [
      Card(
        elevation: 1,
        margin: EdgeInsets.only(top: 1),
        child: Container(
          width: double.infinity,
          height: null,
          margin: EdgeInsets.only(top: 9.0),
          padding: const EdgeInsets.only(top: 6, bottom: 5),
          child: Row(children: <Widget>[
            if (!isWriting)
              IconButton(
                  icon: Icon(
                    Icons.my_location,
                    color: Colors.blue,
                  ),
                  onPressed: () {}),
            if (!isWriting)
              IconButton(
                icon: Icon(
                  Icons.photo_camera,
                  color: Colors.blue,
                ),
                onPressed: () => _saveUserImageToFirebaseStorage(camera),
              ),
            if (!isWriting)
              IconButton(
                  icon: Icon(
                    Icons.photo,
                    color: Colors.blue,
                  ),
                  onPressed: () => _saveUserImageToFirebaseStorage(gallery)),
            if (!isWriting)
              GestureDetector(
                onLongPress: isUploading
                    ? null
                    : () async {
                        await Permissions.microphonePermissionGranted();
                        await record.initialized;
                        var hasPermission =
                            await FlutterAudioRecorder.hasPermissions;

                        print('linkStart');

                        if (hasPermission) {
                          print('yes i has');

                          await record.start().then(
                                (value) => setState(() {
                                  isRecording = !isRecording;
                                }),
                              );
                        }
                      },
                onLongPressEnd: (details) => _uploadRecordMessage(),
                child: Icon(
                  Icons.keyboard_voice,
                  color: isRecording ? Colors.red : Colors.blue,
                ),
              ),
            if (isWriting)
              IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.blue,
                  ),
                  onPressed: () {}),
            Flexible(
              child: Container(
                constraints: _controller.text.length > 50
                    ? BoxConstraints.expand(height: 90)
                    : BoxConstraints.expand(height: 35),
                // height: 35,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(32)),
                child: Stack(alignment: Alignment.centerRight, children: [
                  TextFormField(
                    onTap: () => hideEmojiContainer(),
                    minLines: 1,
                    focusNode: textFieldFoucs,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    cursorColor: Colors.blue,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.sentences,
                    enableSuggestions: true,
                    controller: _controller,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: 'Aa',
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(32.0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        gapPadding: 2,
                        borderSide:
                            BorderSide(color: Colors.grey[300], width: 1.0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(32.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        gapPadding: 1,
                        borderSide:
                            BorderSide(color: Colors.grey[300], width: 2.0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(32.0),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      (value.length > 0 && value.trim() != "")
                          ? setWritingTo(true)
                          : setWritingTo(false);
                      setState(() {
                        enterdMessage = value;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.face,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      if (!showEmojiPicker) {
                        showEmojiContainer();
                        hideKeyboard();
                      } else {
                        showKeyboard();
                        hideEmojiContainer();
                      }
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                ]),
              ),
            ),
            IconButton(
                icon: (!isWriting)
                    ? Icon(
                        Icons.thumb_up,
                        color: Colors.blue,
                      )
                    : Icon(
                        Icons.send,
                        color: Colors.blue,
                      ),
                onPressed: () => _sendTextMessage(_controller.text))
          ]),
        ),
      ),
      showEmojiPicker
          ? Container(
              child: emojiContainer(),
            )
          : Container(),
    ]);
  }
}
