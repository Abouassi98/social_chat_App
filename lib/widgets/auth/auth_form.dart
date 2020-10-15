import 'package:flutter/material.dart';
import 'package:chat/screens/auth.dart';
import '../User_image.dart';
import 'package:chat/widgets/google_SignIn.dart';
import 'dart:io';
import './auth_google.dart';

class auth_form extends StatefulWidget {
  auth_form(this.SubmitFn, this.isLoading);
  var isLoading;
  final void Function(
      String userName,
      String email,
      File image,
      String password,
      bool isLogin,
      String imageUrl,
      BuildContext ctx) SubmitFn;
  @override
  _auth_formState createState() => _auth_formState();
}

class _auth_formState extends State<auth_form> {
  final _formKey = GlobalKey<FormState>();
  var _controller = TextEditingController();
  var _isLogin = true;
  var user_Email = '';
  var user_Name = '';
  File userImageFile;
  var user_password = '';

  BuildContext ctx;
  String imageUrl;
  void pickedImage(File image) {
    setState(() {
      userImageFile = image;
    });
  }

  void _submit() {
    final isVaild = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (userImageFile == null && !_isLogin) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حط صورة معلش يعم',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    if (isVaild) {
      _formKey.currentState.save();
      widget.SubmitFn(user_Name.trim(), user_Email.trim(), userImageFile,
          user_password.trim(), _isLogin, imageUrl, ctx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isLogin) userImage(pickedImage),
                  if (!_isLogin)
                    TextFormField(
                      autocorrect: false,
                      textCapitalization: TextCapitalization.words,
                      enableSuggestions: true,
                      key: ValueKey('username'),
                      decoration: InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value.isEmpty || value.length < 3) {
                          return 'انت دمك خفيف اوي ، اجي اكتبلك اسمك يلا ';
                        }

                        if (!value.contains(' ')) {
                          return 'دخل اسمك كامل يلا';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        user_Name = value;
                      },
                    ),
                  TextFormField(
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      key: ValueKey('email'),
                      decoration: InputDecoration(labelText: 'Email address'),
                      validator: (value) {
                        if (value.isEmpty ||
                            !value.contains('@') ||
                            !value.endsWith('.com')) {
                          return 'دخل البريد عدل يلا وكل سنه وانت طيب يا حبيبي سلملي ع بابا ';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        user_Email = value;
                      }),
                  TextFormField(
                    key: ValueKey('password'),
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value.isEmpty || value.length < 6) {
                        return 'طول الباس حبه تاخد محبه ، معلش جاي عليك والله ، انت عامل ايه بقي ؟ ';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      user_password = value;
                    },
                    obscureText: true,
                    controller: _controller,
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('Confirm'),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                      ),
                      validator: (value) {
                        if (value != _controller.text) {
                          return 'دخل نفس الباس اللي مدخله مره بقي متبقاش لطخ ';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                  SizedBox(
                    height: 12,
                  ),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    RaisedButton(
                      child: Text(_isLogin ? 'Login ' : 'SignUp'),
                      onPressed: _submit,
                    ),
                  if (!widget.isLoading)
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin
                          ? 'Create new account'
                          : 'I already have account'),
                    ),
                  AuthGoogle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
