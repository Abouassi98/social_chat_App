import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './activity_feed.dart';
import './home.dart';
import '../../widgets/social/header.dart';
import '../../widgets/social/post.dart';
import '../../widgets/social/progress.dart';

class PostScreen extends StatefulWidget {
  final String userId;
  final String postId;
  final String mediaUrl;

  PostScreen({
    this.userId,
    this.postId,
    this.mediaUrl,
  });

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String postId;
  Post post = Post();
  var data;

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.userId)
          .collection('userPosts')
          .doc(widget.postId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress();
        }
        if (snapshot.connectionState == ConnectionState.done ||
            snapshot.data != null && widget.postId != null) {
          data = snapshot.data;
          print(snapshot);
          print(widget.userId);

          post = Post.fromDocument(data);

          return Center(
            child: Scaffold(
              appBar: header(context, titleText: post?.caption),
              body: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  )
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: Text('error'),
          );
        }
      },
    );
  }
}
