import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

circularProgress() {
  return Container(
    padding: EdgeInsets.only(top:10),
    alignment: Alignment.center,
    child: CupertinoActivityIndicator(
      animating: true,
    ),
  );
}

linearProgress() {
  return Container(
    padding:EdgeInsets.only(bottom:10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blue),
    )
  );
}
