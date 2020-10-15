import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../screens/social_screens/activity_feed.dart';
import '../../screens/social_screens/comments.dart';
import '../../screens/social_screens/home.dart';
import '../../widgets/social/custom_image.dart';
import '../../widgets/social/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.caption,
    this.mediaUrl,
    this.likes,
  });
  factory Post.fromDocument(DocumentSnapshot doc) {
    var getDocs = doc.data();
    return Post(
      postId: doc.data()['postId'],
      ownerId: getDocs['ownerId'],
      username: getDocs['username'],
      location: getDocs['location'],
      caption: getDocs['caption'],
      mediaUrl: getDocs['mediaUrl'],
      likes: getDocs['likes'],
    );
  }
  int getLikeCount(likes) {
    // if no likes , return likes == 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the value is equal to true ,add a like;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        caption: this.caption,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;

  int likeCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.caption,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapShot) {
        if (!snapShot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapShot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.photoUrl != null
                ? CachedNetworkImageProvider(user.photoUrl)
                : AssetImage('assets/images/person-icon.png'),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user?.displayName,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => handleDeletePost(context),
                )
              : Text(''),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showCupertinoDialog(
        context: parentContext,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Remove this post?'),
            actions: [
              FlatButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                label: Text(
                  'Delete',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              FlatButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.cancel,
                  color: Colors.blue,
                ),
                label: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          );
        });
  }

  // to delete a post ,ownerId  and currentuserId must be equal
  deletePost() async {
    //delete post data
    postRef.doc(ownerId).collection('userPosts').doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //delete uploaded image from storage reference
    storageRef.child('post_$postId.jpg').delete();
    //then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete all comments
    QuerySnapshot commentSnapshot =
        await commentsRef.doc(postId).collection('comments').get();
    commentSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLike() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    //add notification to postOwner activity feed only if made by other users
    bool isNotPostOwner = currentUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection('feedItems').doc(postId).set({
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': mediaUrl,
        'timestamp': timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection('feedItems')
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLike,
      child: Stack(
        alignment: Alignment.center,
        children: [
          mediaUrl == null
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.99,
                  padding: EdgeInsets.only(top: 10.0),
                  margin: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: ListTile(
                    title: Text(
                      caption,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                )
              : cachedNetworkImage(mediaUrl),
          showHeart
              ? Animator(
                  duration: Duration(
                    milliseconds: 300,
                  ),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, anim, child) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.white70,
                    ),
                  ),
                )
              : Text(''),

          // showHeart
          //     ? Icon(
          //         Icons.favorite,
          //         size: 80,
          //         color: Colors.red,
          //       )
          //     : Text(''),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40, left: 10)),
            GestureDetector(
              onTap: handleLike,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: !isLiked ? Colors.grey : Colors.red,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
            ),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
              child: Icon(
                Icons.chat_bubble,
                size: 28,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                '$likeCount likes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 10, bottom: 5),
              child: mediaUrl == null
                  ? Text('')
                  : Text(
                      '$username  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            Expanded(
              child: mediaUrl == null ? Text('') : Text(caption),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}

showComments(
  BuildContext context, {
  String postId,
  String ownerId,
  String mediaUrl,
}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
