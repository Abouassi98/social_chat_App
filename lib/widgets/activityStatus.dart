import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat/models/user_form.dart';
Firestore _firestore = Firestore.instance;
DatabaseReference _firebaseDatabse = FirebaseDatabase.instance.reference();
final User _user = User();
myActiveStatus() {
  int index = _user.email.indexOf("@");
  var userFirestoreRef = _firestore
      .collection('status')
      .document(_user.email.substring(0, index));
  var userDBRef = _firebaseDatabse
      .child('status')
      .child(_user.email.substring(0, index));

  var userIsOnlineFirestor = {
    'status': 'online',
    'lastChanged': FieldValue.serverTimestamp(),
  };
  var userIsOfflineFirestor = {
    'status': 'offline',
    'lastChanged': FieldValue.serverTimestamp(),
  };

  var userIsOnlineDb = {
    'status': 'online',
    'lastChanged': ServerValue.timestamp,
  };
  var userIsOfflineDB = {
    'status': 'offline',
    'lastChanged': ServerValue.timestamp,
  };

  _firebaseDatabse.child('.info').child('connected').onValue.listen((onData) {
    if (onData.snapshot.value == false) {
      userFirestoreRef.setData(userIsOfflineFirestor);
    }
    userDBRef.onDisconnect().update(userIsOfflineDB).then((onValue) async {
      await userDBRef.update(userIsOnlineDb).catchError((e) {
        print(e);
      });
      await userFirestoreRef.setData(userIsOnlineFirestor).catchError((e) {
        print(e);
      });
    });
  });
}

Future<String> getActiveStatus(String email) async {
  int index = email.indexOf('@');
  String status;
  await _firebaseDatabse
      .child('status')
      .child(email.substring(0, index))
      .once()
      .then((DataSnapshot snapshot) {
    Map<dynamic, dynamic> values = snapshot.value;
    status = values['status'];
    // print(values['status']);
  });
  return status;
}
