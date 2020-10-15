import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/contacts.dart';
import '../widgets/story.dart';
import '../widgets/search.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Constant/constant.dart';
import '../widgets/auth/auth_google.dart';
import '../widgets/AppBar.dart';
import 'dart:io';
import './searchScreen.dart';

class ContactsScreen extends StatefulWidget {
  static const routedname = '/ContactsScreen';
  String myID;
  String myName;
  ContactsScreen({this.myID, this.myName});
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  // Future _logout() async {
  //   await FirebaseAuth.instance.signOut();
  // }
  AuthGoogle _auth = AuthGoogle();

  File pickedImage;
  var image;
  Stream stream;
  dynamic imageStory;

  void initState() {
    setState(() {
      stream = userCollection.snapshots();
    });
    // TODO: implement initState
    super.initState();
  }

  var futurePhoto;
  bool _isInit = true;
  bool _loadSpinner = true;

  // Future<void> downloadPhoto() async {
  //   final _future = await FirebaseAuth.instance
  //       .currentUser(); //can't use widget.myID cuz the func is called early abut it
  //   await Provider.of<Photos>(context, listen: false)
  //       .downloadPicture(_future.uid)
  //       .then((result) => setState(() {
  //             result != null
  //                 ? setState(() {
  //                     // print('result=$result');
  //                     image = result;

  //                     //  print('image=$image');
  //                     //   Fluttertoast.showToast(msg: 'بحبك يا ولا ');
  //                   })
  //                 : Fluttertoast.showToast(
  //                     msg: 'الصوره فيها حاجه غلط لو وشك غيره بحاجه عدله ');
  //           }));
  // }

  // void didChangeDependencies() async {
  //   if (_isInit) {
  //     // TODO: implement didChangeDependencies
  //     setState(() {
  //       _loadSpinner = true;
  //     });
  //     await downloadPhoto();
  //   }
  //   _isInit = false;
  //   setState(() {
  //     _loadSpinner = false;
  //   });
  //   super.didChangeDependencies();
  //   //print('MyId2=${widget.myID}');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: AppBenaburr(stream),
        ),
      ),
      body: SingleChildScrollView(
        primary: false,
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 14, right: 14),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25)),
                  width: MediaQuery.of(context).size.width - 40,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      textAlign: TextAlign.left,
                      autofocus: false,
                      onTap: () => Navigator.of(context)
                          .pushNamed(SearchScreen.routedname),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: "Search By E-mail",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Column(
              children: <Widget>[
                Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    width: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(13, 5, 0, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius:
                                    MediaQuery.of(context).size.height * 0.035,
                                backgroundColor: Colors.grey[300],
                                child: IconButton(
                                  onPressed: () async {
                                    final imageFile = await ImagePicker()
                                        .getImage(source: ImageSource.gallery);
                                    if (imageFile == null) {
                                      return;
                                    }
                                    setState(() {
                                      pickedImage = File(imageFile.path);
                                    });
                                    return await Provider.of<Photos>(context,
                                            listen: false)
                                        .uploadstoryPicture(pickedImage)
                                        .then((value) => setState(() {
                                              imageStory = value;
                                              print('imageStory=$imageStory');
                                            }));
                                  },
                                  icon: Icon(Icons.add),
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text('Your Story',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 9,
                        ),
                        story_photos(stream, imageStory),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                ContactsWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
