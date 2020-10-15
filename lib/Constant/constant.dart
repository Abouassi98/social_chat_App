import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference userCollection =
    FirebaseFirestore.instance.collection('users');

final CollectionReference chatCollection =
    FirebaseFirestore.instance.collection('chat');

final CollectionReference callCollection =
    FirebaseFirestore.instance.collection('call');
