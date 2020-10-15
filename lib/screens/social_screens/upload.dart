import 'dart:io';
import 'package:geocoding/geocoding.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/user.dart';
import './home.dart';
import '../../widgets/social/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  final captionController = TextEditingController();
  final locationController = TextEditingController();
  File _pickedImage;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleTakingImage() async {
    Navigator.pop(context);
    final _picker = ImagePicker();
    final image = await _picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    final File fileCamera = File(image.path);

    setState(() {
      if (fileCamera != null) {
        _pickedImage = fileCamera;
      }
    });
  }

  handleChooseImage() async {
    Navigator.pop(context);
    final _picker = ImagePicker();
    final image = await _picker.getImage(source: ImageSource.gallery);
    final File fileGallery = File(image.path);
    setState(() {
      if (fileGallery != null) {
        _pickedImage = fileGallery;
      }
    });
  }

  selectImage(BuildContext parentContext) {
    return showCupertinoDialog(
      context: parentContext,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Create Post'),
        content: Text('Upload a Photo...'),
        actions: [
          FlatButton.icon(
              onPressed: handleTakingImage,
              icon: Icon(Icons.camera),
              label: Text('Camera')),
          FlatButton.icon(
              onPressed: handleChooseImage,
              icon: Icon(Icons.photo_library),
              label: Text('Gallery')),
          FlatButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.cancel),
              label: Text('Cancel')),
        ],
      ),
    );
  }

  buildSplashScreen() {
    return Container(
      color: Colors.lightBlue[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'images/upload.svg',
            height: 260,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton.icon(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => selectImage(context),
              icon: Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: Colors.deepOrangeAccent,
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      _pickedImage = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final imageFile = Im.decodeImage(_pickedImage.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg ')
      ..writeAsBytesSync(
        Im.encodeJpg(imageFile, quality: 95),
      );
    setState(() {
      _pickedImage = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    final uploadTask = storageRef.child('post_$postId.jpg').putFile(imageFile);
    final storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String mediaUrl, String location, String caption}) {
    postRef.doc(widget.currentUser.id).collection('userPosts').doc(postId).set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
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
    await compressImage();
    String mediaUrl = await uploadImage(_pickedImage);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      caption: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      _pickedImage = null;
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
          onPressed: clearImage,
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
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(_pickedImage),
                  )),
                ),
              ),
            ),
          ),
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
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write a Caption...',
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
                  hintText: 'Where was this photo taken?',
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
    final position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    final placemark = placemarks[0];

    String formattedAdress =
        '${placemark.thoroughfare},${placemark.subThoroughfare},${placemark.locality},${placemark.subLocality},${placemark.country}';
    locationController.text = formattedAdress;
    print(formattedAdress);
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _pickedImage == null ? buildSplashScreen() : buildUploadForm();
  }
}
