import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
  });
  factory User.fromDocument(DocumentSnapshot doc) {
    Map getDoc = doc.data();

    return User(
      id: getDoc['userId'],
      email: getDoc['email'],
      username: getDoc['firstName'],
      photoUrl: getDoc['UserimageUrl'],
      displayName: getDoc['userName'],
      bio: getDoc['bio'],
    );
  }
}
