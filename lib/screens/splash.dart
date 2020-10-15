import 'package:flutter/material.dart';

class Splash extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: Text('Loading...'),
      ),
    );
  }
}