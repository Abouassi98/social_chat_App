import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/user.dart';
import './home.dart';
import './profile copy.dart';
import '../../widgets/social/header.dart';
import '../../widgets/social/progress.dart';

class FollowersScreen extends StatefulWidget {
  final String profileId;
  FollowersScreen({this.profileId});
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final String currentUserId = currentUser?.id;
  Future<QuerySnapshot> followingResults;
  List<String> followersList = [];
  var following;

  handleGetFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followersList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  handleGetUsers(id) {
    final user = usersRef.where('id', isEqualTo: id).get();
    setState(() {
      followingResults = user;
    });
  }

  @override
  void initState() {
    super.initState();
    handleGetUsers(following);
    handleGetFollowers();
  }

  buildNoContent() {
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Nothing here yet...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Signatra',
                fontWeight: FontWeight.w400,
                fontSize: 60,
              ),
            ),
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300 : 200,
            ),
          ],
        ),
      ),
    );
  }

  buildfollowersResults() {
    return FutureBuilder(
        future: followingResults,
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return circularProgress();
          }
          print(snapShot.data.docs);
          print(followersList);
          List<UserResult> searchResultss = [];
          snapShot.data.docs.forEach((doc) {
            User user = User.fromDocument(doc);
            final bool isAuthUser = currentUser.id == user.id;
            final bool isFollowingUser = followersList.contains(user.id);
            if (isAuthUser) {
              return;
            } else if (isFollowingUser) {
              UserResult searchResult = UserResult(user);
              searchResultss.add(searchResult);
            } else {
              return;
            }
          });
          return ListView(
            children: searchResultss,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Followers'),
      body:
          followingResults == null ? buildNoContent() : buildfollowersResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  const UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: user.photoUrl != null
                    ? CachedNetworkImageProvider(user.photoUrl)
                    : AssetImage('assets/images/person-icon.png'),
              ),
              title: Text(
                '${user?.displayName}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${user?.username}',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
