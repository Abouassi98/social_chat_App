import 'dart:io';
import 'package:chat/screens/social_screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../provider/chat_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  static const routedname = '/Profile';
  final User user;
  Profile({this.user});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _emailKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  var _editName = false;
  var _editEMAIL = false;
  var _editPassword = false;
  var passwordSecure = false;
  var newPasswordSecure = false;
  var confirmPasswordSecure = false;
  var _isUploading = false;

  User _currentUser;
  SharedPreferences prefs;
  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordChecker = TextEditingController();

  var password = false;
  var _auth = FirebaseAuth.instance;

  void _pickImage() async {
    final fileImage = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 30, maxWidth: 150);
    if (fileImage == null) {
      return;
    }

    final imageFile = File(fileImage.path);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Alert!!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              imageFile,
              height: 100,
              width: 100,
            ),
            SizedBox(
              height: 10,
            ),
            Text('Are You sure?'),
          ],
        ),
        actions: [
          FlatButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() {
                _isUploading = true;
              });

              var imageUrl = await Provider.of<Photos>(context, listen: false)
                  .uploadPicture(imageFile, 'userImage', _currentUser.uid);

              await _currentUser.updateProfile(photoURL: imageUrl);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUser.uid)
                  .update({
                'UserimageUrl': imageUrl,
              });
              setState(() {
                _isUploading = false;
              });
            },
            child: Text('Yes'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  Future<void> showCheckerDialog() async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You Need To Enter Your Password',
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              controller: passwordChecker,
              decoration: InputDecoration(
                labelText: 'Enter Your Password',
              ),
            ),
          ],
        ),
        actions: [
          RaisedButton(
            onPressed: () {
              if (passwordChecker.text.trim().isEmpty) {
                return;
              }
              FocusScope.of(ctx).unfocus();

              if (prefs.getString('password') == passwordChecker.text.trim()) {
                password = true;
              } else {
                Fluttertoast.showToast(msg: 'Wrong Password!!');
              }
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
          SizedBox(width: 15),
          RaisedButton(
            onPressed: () {
              FocusScope.of(ctx).unfocus();
              Navigator.of(ctx).pop();
              return false;
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _myUser() async {
    prefs = await SharedPreferences.getInstance();
  }

  String get passwordStars {
    var name = prefs.get('password');
    var star = '';

    for (int i = 0; i < name.length; i++) {
      star = '$star*';
    }
    return star;
  }

  List<Widget> buildListTile(
      IconData icon, String title, String titleData, Function onPressed,
      {IconData icons = Icons.edit}) {
    return [
      ListTile(
        leading: Icon(icon),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(titleData),
          ],
        ),
        trailing: IconButton(
          icon: Icon(icons),
          onPressed: onPressed,
        ),
      ),
      SizedBox(height: 10)
    ];
  }

  save(String feature) async {
    FocusScope.of(context).unfocus();
    if (prefs.containsKey('user') && feature == 'email') {
      await showCheckerDialog();
      if (password == false) {
        return;
      }
    }

    try {
      if (feature == 'password') {
        var validate = _passwordKey.currentState.validate();

        if (!validate) {
          return;
        }
      }
      final cred = EmailAuthProvider.credential(
        email: _currentUser.email,
        password: prefs.getString('password'),
      );
      await _currentUser.reauthenticateWithCredential(cred);
      //check whether we wanna edit email or password...
      if (feature == 'password') {
        await _currentUser.updatePassword(passwordController.text).then(
          (value) async {
            await prefs.setString('password', passwordController.text);
            print('yes');
          },
        );

        setState(() {
          _editPassword = !_editPassword;
        });
      } else if (feature == 'email') {
        if (!_emailKey.currentState.validate()) {
          return;
        }
        await _currentUser.updateEmail(emailController.text);

        FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser.uid)
            .update({
          'email': emailController.text,
        });
        setState(() {
          _editEMAIL = !_editEMAIL;
        });
      }

      Fluttertoast.showToast(
          msg: feature == 'password'
              ? 'Password Changed Successfully'
              : 'Email Changed Successfully');
    } on PlatformException catch (error) {
      String message = 'something wrong occured';
      if (error.message != null) {
        print(error.message);
        message = error.message;
        Fluttertoast.showToast(msg: message);
      }
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  @override
  void initState() {
    _currentUser = _auth.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
      ),
      body: FutureBuilder(
        future: _myUser(),
        builder: (ctx, snapShot) => snapShot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Stack(
                          overflow: Overflow.visible,
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.black12,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    NetworkImage(_currentUser.photoURL),
                                radius: 40,
                              ),
                            ),
                            Positioned(
                              top: 55,
                              left: 55,
                              child: IconButton(
                                onPressed: _pickImage,
                                icon:
                                    Icon(Icons.camera_alt, color: Colors.pink),
                              ),
                            ),
                            if (_isUploading)
                              Positioned(
                                top: 25,
                                left: 25,
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (_editName)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (v) {
                                    setState(() {});
                                  },
                                  controller: userController,
                                  decoration: InputDecoration(
                                    labelText: 'User Name',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.check),
                                onPressed: userController.text.trim().isEmpty
                                    ? null
                                    : () async {
                                        FocusScope.of(context).unfocus();
                                        if (prefs.containsKey('user')) {
                                          print(prefs.getString('user'));
                                          await showCheckerDialog();
                                          if (password == false) {
                                            return;
                                          }
                                        }
                                        try {
                                          userController.text;
                                          await _currentUser.updateProfile(
                                              displayName: userController.text);
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(_currentUser.uid)
                                              .update(
                                            {
                                              'userName': userController.text,
                                            },
                                          );

                                          await prefs.setString(
                                              'user', _currentUser.displayName);
                                        } on PlatformException catch (error) {
                                          String message =
                                              'something wrong occured';
                                          if (error.message != null) {
                                            print(error.message);
                                            message = error.message;
                                            Fluttertoast.showToast(
                                                msg: message);
                                          }
                                        } catch (error) {
                                          Fluttertoast.showToast(
                                            msg: error.toString(),
                                          );
                                        }

                                        setState(() {
                                          _editName = !_editName;
                                        });
                                      },
                              ),
                              IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _editName = !_editName;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      if (!_editName)
                        ...buildListTile(
                          Icons.contacts,
                          'User Name',
                          _currentUser.displayName,
                          () {
                            setState(() {
                              _editName = !_editName;
                            });
                          },
                        ),
                      if (_editEMAIL)
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          width: double.infinity,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Form(
                                  key: _emailKey,
                                  child: TextFormField(
                                    onChanged: (v) {
                                      setState(() {});
                                    },
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email Address',
                                    ),
                                    validator: (value) {
                                      if (!value.contains('@') &&
                                          !value.contains('.com')) {
                                        return 'Enter a valid Email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: emailController.text.trim().isEmpty
                                      ? null
                                      : () => save('email')),
                              IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _editEMAIL = !_editEMAIL;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      if (!_editEMAIL)
                        ...buildListTile(
                          Icons.email,
                          'Email Address',
                          _currentUser.email,
                          prefs.containsKey('userName')
                              ? null
                              : () {
                                  setState(() {
                                    _editEMAIL = !_editEMAIL;
                                  });
                                },
                          icons:
                              prefs.containsKey('userName') ? null : Icons.edit,
                        ),
                      if (!_editPassword && !prefs.containsKey('userName'))
                        ...buildListTile(
                          Icons.security,
                          'Password',
                          passwordStars,
                          () {
                            setState(() {
                              _editPassword = !_editPassword;
                            });
                          },
                        ),
                      if (_editPassword && !prefs.containsKey('userName'))
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          width: double.infinity,
                          child: Form(
                            key: _passwordKey,
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: TextFormField(
                                    validator: (value) {
                                      if (value.trim().isEmpty) {
                                        return 'Enter your current password';
                                      }
                                      if (value.trim() !=
                                          prefs.getString('password')) {
                                        return 'Wrong Password!! try again!';
                                      }
                                      return null;
                                    },
                                    obscureText: !passwordSecure,
                                    decoration: InputDecoration(
                                      labelText: 'Current Password',
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(passwordSecure
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(
                                        () {
                                          passwordSecure = !passwordSecure;
                                        },
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  title: TextFormField(
                                    validator: (value) {
                                      if (value.trim().isEmpty) {
                                        return 'Enter Your New Password';
                                      }
                                      if (value.length < 6) {
                                        return 'Your Password is very short';
                                      }
                                      return null;
                                    },
                                    controller: passwordController,
                                    obscureText: !newPasswordSecure,
                                    decoration: InputDecoration(
                                      labelText: 'New Password',
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(newPasswordSecure
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        newPasswordSecure = !newPasswordSecure;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  title: TextFormField(
                                    validator: (value) {
                                      if (value.trim().isEmpty) {
                                        return 'Confirm your password';
                                      }
                                      if (passwordController.text !=
                                          value.trim()) {
                                        return 'password didn\'t match';
                                      }
                                      return null;
                                    },
                                    obscureText: !confirmPasswordSecure,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm New Password',
                                    ),
                                  ),
                                  trailing: IconButton(
                                      icon: Icon(confirmPasswordSecure
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          confirmPasswordSecure =
                                              !confirmPasswordSecure;
                                        });
                                      }),
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                      onPressed: () => save('password'),
                                      child: Text('Save'),
                                    ),
                                    SizedBox(width: 15),
                                    RaisedButton(
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          _editPassword = !_editPassword;
                                        });
                                      },
                                      child: Text('Cancel'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
