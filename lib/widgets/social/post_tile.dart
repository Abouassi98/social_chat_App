import 'package:flutter/material.dart';
import '../../screens/social_screens/post_screen.dart';
import './custom_image.dart';
import './post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
          mediaUrl: post.mediaUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: post.mediaUrl == null
          ? Center(child: Text(post.caption))
          : cachedNetworkImage(post.mediaUrl),
    );
  }
}
