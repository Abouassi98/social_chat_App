import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../models/user.dart';
import './edit_profile.dart';
import './followers_screen.dart';
import './following_screen.dart';
import './home.dart';
import '../../widgets/social/header.dart';
import '../../widgets/social/post.dart';
import '../../widgets/social/post_tile.dart';
import '../../widgets/social/progress.dart';
import 'package:firebase_auth/firebase_auth.dart' as myUser;

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  String postToggle = 'grid';
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];
  final _auth = myUser.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length - 1;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapShot = await postRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapShot.docs.length;
      posts = snapShot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  buildButton({String label, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.61,
          height: 27,
          child: Text(
            label,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // if we are viewing our own profile we should show 'Edit profile Button '
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        label: 'Edit Profile',
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        label: 'Unfollow',
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        label: 'Follow',
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    //remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // make authenticated user follow another user and update Their followers collection
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    // put that user in the authenticated user following collection and update authenticated user's following collection
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    // add activity feed item for that user to notify about new follower
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': 'follow',
      'ownerId': widget.profileId,
      'userName': currentUser.username,
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': timestamp,
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapShot.data);
          var cuUser = _auth.currentUser;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      backgroundImage: user.photoUrl != null
                          ? CachedNetworkImageProvider(user.photoUrl)
                          : AssetImage('images/person-icon.png'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildCountColumn('Posts', postCount),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FollowersScreen(
                                        profileId: widget.profileId),
                                  ),
                                ),
                                child: buildCountColumn(
                                    'Followers', followerCount),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FollowingScreen(
                                        profileId: widget.profileId),
                                  ),
                                ),
                                child: buildCountColumn(
                                    'Following', followingCount),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildProfileButton(),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    user.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    '',
                  ),
                ),
              ],
            ),
          );
        });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'images/no_content.svg',
              height: 260,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'No Posts yet ...',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postToggle == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postToggle == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostView(String postToggle) {
    setState(() {
      this.postToggle = postToggle;
    });
  }

  buildTogglePost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.grid_on,
            color: postToggle == 'grid' ? Colors.blue : Colors.grey,
          ),
          onPressed: () => setPostView('grid'),
        ),
        IconButton(
          icon: Icon(
            Icons.view_list,
            color: postToggle == 'list' ? Colors.blue : Colors.grey,
          ),
          onPressed: () => setPostView('list'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, titleText: 'Profile'),
        body: ListView(
          children: [
            buildProfileHeader(),
            Divider(),
            buildTogglePost(),
            Divider(
              height: 0.0,
            ),
            buildProfilePosts(),
          ],
        ));
  }
}
