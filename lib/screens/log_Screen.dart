import 'package:flutter/material.dart';
import 'package:chat/provider/chat_provider.dart';
import '../models/call.dart';
import 'package:chat/utils/universal_variables.dart';
import '../widgets/logs//floating_column.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/logs/log_list_container.dart';
import '../Constant/constant.dart';
import 'callScreens/pickup_Screens.dart';
import './searchScreen.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Photos.myID != null
        ? StreamBuilder<DocumentSnapshot>(
            stream: callCollection.doc(Photos.myID).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data() != null) {
                Call call = Call.fromMap(snapshot.data.data());
                if (!call.hasDialled &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!call.hasDialled) {
                  return (PickupScreens(
                    call: call,
                    myId: Photos.myID,
                  ));
                }
              }
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(SearchScreen.routedname),
                    ),
                  ],
                ),
                // floatingActionButton: FloatingColumn(),
                body: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: LogListContainer(),
                ),
              );
            })
        : Scaffold(
            body: Container(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
