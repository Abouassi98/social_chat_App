// import 'package:flutter/material.dart';
// import './auth/auth_google.dart';
// import 'package:shimmer/shimmer.dart';
// class google_SignIn extends StatelessWidget {
//   Auth auth = Auth();
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.pink,
//       highlightColor: Colors.blueAccent,
//           child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
//         child: OutlineButton(
//           splashColor: Colors.grey,
//           onPressed: () => auth.signUp(context),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
//           highlightElevation: 0,
//           borderSide: BorderSide(color: Colors.grey[400]),
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Expanded(
//                   child: Image(
//                     image: AssetImage('images/google_logo.png'),
//                     height: 24,
//                   ),
//                 ),
//                 SizedBox(width: 12.0),
//                 Text(
//                   'Sign in with Google',
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: Colors.grey,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
