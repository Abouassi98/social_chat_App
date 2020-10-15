import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './profile.dart';
import './contacts.dart';
import '../provider/chat_provider.dart';
import 'package:chat/Constant/constant.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import './log_Screen.dart';
import 'package:chat/resources/log_repository.dart';

class TabScreen extends StatefulWidget {
  static const routedname = '/Tab_Screen';

  @override
  _TabScreenState createState() => _TabScreenState();
}

FirebaseFirestore cloud = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class _TabScreenState extends State<TabScreen> with WidgetsBindingObserver {
  String myID;
  String myName;
  List<Map<String, Object>> pages;

  bool isInit = false;
  int _selectedPage = 0;
  selectedPage(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  setisActive() async {
    print('id1=${Photos.myID}');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Photos.myID)
        .update({'isActive': true});
  }

  setunActive() async {
    print('id2=${Photos.myID}');
    await userCollection.doc(Photos.myID).update({'isActive': false});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      setisActive();
    } else {
      setunActive();
    }
  }

  @override
  void didChangeDependencies() async {
    setState(() {
      isInit = true;
    });
    await Provider.of<Photos>(context, listen: false)
        .getCurrentUserId(myID, myName);
    print("mya7aId=${Photos.myID}");
    LogRepository.init(
      isHive: true,
      dbName: Photos.myID,
    );

    setState(() {
      isInit = false;
    });
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void initState() {
    pages = [
      {
        'page': ContactsScreen(
          myID: myID,
          myName: myName,
        ),
      },
      {'page': Profile()},
      {
        'page': LogScreen(),
      },
    ];

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedPage]['page'],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedPage,
        onTap: selectedPage,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat',

            // backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),

            label: 'My Profile',

            // backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Call',

            // backgroundColor: Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }
}
