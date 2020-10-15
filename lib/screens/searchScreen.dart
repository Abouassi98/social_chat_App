import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../utils/universal_variables.dart';
import '../models/user_form.dart' as loggedUser;
import '../Constant/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/search.dart';

class SearchScreen extends StatefulWidget {
  static const routedname = '/SearchScreen';
  SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  loggedUser.User user = loggedUser.User();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<loggedUser.User>> fetchAllUser(User currentUser) async {
    List<loggedUser.User> userList = List<loggedUser.User>();
    QuerySnapshot querySnapShot = await userCollection.get();
    for (int i = 0; i < querySnapShot.docs.length; i++) {
      if (querySnapShot.docs[i].id != currentUser.uid) {
        userList.add(loggedUser.User.fromMap(querySnapShot.docs[i].data()));
      }
    }
    return userList;
  }

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    user.getCurrentUser().then((User currentUser) {
      fetchAllUser(currentUser).then((List<loggedUser.User> list) {
        setState(() {
          userList = list;
        });
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  List<loggedUser.User> userList;
  String query = "";
  TextEditingController _searchController = TextEditingController();
  searchAppBar(BuildContext context) {
    return GradientAppBar(
      gradient: LinearGradient(colors: [
        UniversalVariables.gradientColorStart,
        UniversalVariables.gradientColorEnd,
      ]),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.search,
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                query = val;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 35,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _searchController.clear());
                },
              ),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
                color: Color(0x88ffffff),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SearchUsers(userList, query),
      ),
    );
  }
}
