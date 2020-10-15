import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import './home.dart';
import './search.dart';
import './text_post.dart';
import '../../widgets/social/header.dart';
import '../../widgets/social/post.dart';
import '../../widgets/social/progress.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList = [];
  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView.builder(
        itemBuilder: (context, index) => posts[index],
        itemCount: posts.length,
      );
    }
  }

  buildUsersToFollow() {
    return StreamBuilder(
        stream: usersRef
            .orderBy('timestamp', descending: true)
            .limit(30)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> userResults = [];
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocument(doc);
            final bool isAuthUser = currentUser.id == user.id;
            final bool isFollowingUser = followingList.contains(user.id);
            //remove current user from recommended list
            if (isAuthUser) {
              return;
            } else if (isFollowingUser) {
              return;
            } else {
              UserResult userResult = UserResult(user);
              userResults.add(userResult);
            }
          });
          return Container(
            color: Colors.lightBlueAccent,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Users to Follow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: userResults,
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        title: Text(
          'Blazigram',
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            fontFamily: 'Signatra',
            color: Colors.black,
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TextPost(
                  currentUser: currentUser,
                ),
              ),
            ),
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            borderSide: BorderSide.none,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
