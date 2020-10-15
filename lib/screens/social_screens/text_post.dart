import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import './home.dart';
import 'package:geocoding/geocoding.dart';
import '../../widgets/social/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class TextPost extends StatefulWidget {
  final User currentUser;

  const TextPost({this.currentUser});
  @override
  _TextPostState createState() => _TextPostState();
}

class _TextPostState extends State<TextPost> {
    bool isLood = false;
  final captionController = TextEditingController();
  final locationController = TextEditingController();
  bool isUploading = false;
  String postId = Uuid().v4();

  createPostInFirestore({String location, String caption}) {
    postRef.doc(widget.currentUser.id).collection('userPosts').doc(postId).set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': null,
      'caption': caption,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    await createPostInFirestore(
      location: locationController.text,
      caption: captionController.text,
    );

    captionController.clear();
    locationController.clear();

    setState(() {
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: 'Signatra',
            fontSize: 35,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : Text(''),
          Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.currentUser.photoUrl != null
                  ? CachedNetworkImageProvider(widget.currentUser.photoUrl)
                  : AssetImage('assets/images/person-icon.png'),
            ),
            title: Container(
              width: 250,
              child: TextField(
                keyboardType: TextInputType.multiline,
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write a Post...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Where did this happen ?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                'Use current location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.blue,
            ),
          )
        ],
      ),
    );
  }

  getUserLocation() async {
    try {
      setState(() {
        isLood = true;
      });
    final position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    final placemark = placemarks[0];

    String formattedAdress =
        '${placemark.thoroughfare},${placemark.subThoroughfare},${placemark.locality},${placemark.subLocality},${placemark.country}';
    locationController.text = formattedAdress;
          setState(() {
        isLood = false;
      });
    print(formattedAdress);
  }catch (error) {
      print(error);
    }
  }
  @override
  Widget build(BuildContext context) {
    return buildUploadForm();
  }
}
