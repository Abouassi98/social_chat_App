import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class userImage extends StatefulWidget {
  final void Function(File previewImage) imagePickfn;
  userImage(this.imagePickfn);
  @override
  _userImageState createState() => _userImageState();
}

class _userImageState extends State<userImage> {
  File pickedImage;
  void _pickImage() async {
    final fileImage = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 30, maxWidth: 150);
        if(fileImage==null){
          return ;
        }
    setState(() {
      pickedImage = File(fileImage.path);
    });
    widget.imagePickfn(File(fileImage.path));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(overflow: Overflow.visible,
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.black12,
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: pickedImage != null
                ? FileImage(pickedImage)
                : AssetImage('images/profile.jpg'),
            radius: 40,
          ),
        ),
        Positioned(top: 55,left: 55,
          child: IconButton(
              onPressed: _pickImage,
              icon: Icon(Icons.camera_alt, color: Colors.pink)),
        ),
      ],
    );
  }
}
