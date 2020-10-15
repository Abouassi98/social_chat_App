import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/chat.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import '../provider/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:chat/Constant/constant.dart';
import '../models/user_form.dart' as userForm;

class SearchUsers extends StatelessWidget {
  final List<userForm.User> userList;
  final String query;
  SearchUsers(this.userList, this.query);
  @override
  Widget build(BuildContext context) {
    final List<userForm.User> suggteionList = query.isEmpty
        ? []
        : userList != null
            ? userList.where((userForm.User user) {
                String getUserName = user.userName.toLowerCase();
                String _query = query.toLowerCase();
                String getEmail = user.email.toLowerCase();
                bool matchUserName = getUserName.contains(_query);
                bool matchemail = getEmail.contains(_query);
                return (matchUserName || matchemail);
              }).toList()
            : [];

    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: suggteionList.length,
        itemBuilder: ((context, i) {
          userForm.User searchedUser = userForm.User(
            email: suggteionList[i].email,
            firstName: suggteionList[i].firstName,
            imageUrl: suggteionList[i].imageUrl,
            userId: suggteionList[i].userId,
            userName: suggteionList[i].userName,
          );
          return GestureDetector(
            onTap: () {
              String chatId = Provider.of<Photos>(context, listen: false)
                  .makeChatRoomId(suggteionList[i].userId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => chat_screen(
                      isActive: false,
                      chatId: chatId,
                      myId: Photos.myID,
                      firstname: searchedUser.userName.split(' ')[0],
                      image: searchedUser.imageUrl,
                      idTo: searchedUser.userId,
                      reciver: searchedUser),
                ),
              );
            },
            child: ListTile(
              isThreeLine: false,
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  searchedUser.imageUrl,
                ),
                radius: MediaQuery.of(context).size.height * 0.038,
                backgroundColor: Colors.grey[300],
              ),
              title: Text(
                searchedUser.userName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                searchedUser.email,
                style: TextStyle(fontSize: 15),
                maxLines: 1,
              ),
            ),
          );
        }));
  }
}
