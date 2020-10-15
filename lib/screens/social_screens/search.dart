import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/user.dart';
import './activity_feed.dart';
import './home.dart';
import '../../widgets/social/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController _controller = TextEditingController();
  Future<QuerySnapshot> searchResults;

  handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      final users =
          usersRef.where('userName', isGreaterThanOrEqualTo: query).get();
      setState(() {
        searchResults = users;
      });
    }
  }

  AppBar buildSearchBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search for a user...',
          filled: true,
          prefixIcon: Icon(
            Icons.supervisor_account,
            size: 28,
          ),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
              }),
        ),
        
        onChanged: handleSearch,
      ),
    );
  }

  buildNoContent() {
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Signatra',
                fontWeight: FontWeight.w400,
                fontSize: 60,
              ),
            ),
            SvgPicture.asset(
              'images/search.svg',
              height: orientation == Orientation.portrait ? 300 : 200,
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        future: searchResults,
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchResultss = [];
          snapShot.data.docs.forEach((doc) {
            User user = User.fromDocument(doc);
            final bool isAuthUser = currentUser.id == user.id;
            if (isAuthUser) {
              return;
            }
            UserResult searchResult = UserResult(user);
            searchResultss.add(searchResult);
          });
          return ListView(
            children: searchResultss,
          );
        });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      appBar: buildSearchBar(),
      body: searchResults == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  const UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightBlue[200],
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
               user.username == null ? '':user.username,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
        user.displayName == null ? '' : user.displayName,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
