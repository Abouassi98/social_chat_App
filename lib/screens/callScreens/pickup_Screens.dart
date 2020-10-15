import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/call.dart';
import 'package:chat/resources/call_Methods.dart';
import 'package:chat/screens/callScreens/call_screen.dart';
import 'package:chat/utils/permissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat/Constant/constant.dart';
import 'package:chat/models/logs.dart';
import 'package:chat/resources/log_repository.dart';

class PickupScreens extends StatefulWidget {
  Call call = Call();
  dynamic myId;

  PickupScreens({this.call, this.myId});

  @override
  _PickupScreensState createState() => _PickupScreensState();
}

class _PickupScreensState extends State<PickupScreens> {
  CallMethods callMethods = CallMethods();
  bool isCallMissed = true;
  Stream _stream;
  bool isLoading = false;
  @override
  void didChangeDependencies() {
    setState(() {
      isLoading = true;
      _stream = callCollection.doc(widget.myId).snapshots();
    });
    if (_stream == null) {
      return;
    } else {
      isLoading = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  addToLocalStorage({@required String callStatus}) {
    Log log = Log(
      callerName: widget.call.callerName,
      callerPhoto: widget.call.callerPic,
      reciverPhoto: widget.call.reciverPic,
      reciverName: widget.call.reciverName,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );

    LogRepository.addLogs(log);
  }

  @override
  void dispose() {
    if (isCallMissed) {
      addToLocalStorage(callStatus: 'missed');
    }
    super.dispose();
  }

//   void initState() {
//         isLoading = true;
//     setState(() {
//       _stream = callCollection.document(widget.myId).snapshots();
//     });
// isLoading = false;
//     // TODO: implement initState
//     super.initState();
//   }
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: Container(child: CircularProgressIndicator()))
          : StreamBuilder<dynamic>(
              stream: _stream,
              builder: (context, callSnapshot) {
                if (callSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (callSnapshot.connectionState == ConnectionState.none) {
                  return Center(
                      child: Text('فقدت الاتصال بالانترنت رستر الراوتر هههه'));
                }

                if (!callSnapshot.hasData && callSnapshot.data.data() == null) {
                  return Container();
                }
                Call call = Call.fromMap(callSnapshot.data.data());
                if (call.videoCall == null) {
                  return Center(child: CircularProgressIndicator());
                }
                print("call.videoCall=${call.videoCall}");
                if (call.videoCall) {
                  return Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
                      child: Column(
                        children: [
                          Text(
                            'Incoming Video Call...',
                            style: TextStyle(fontSize: 30),
                          ),
                          SizedBox(height: 50),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: CachedNetworkImage(
                              imageUrl: call.callerPic,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            call.callerName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 75),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    Icons.call_end,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    isCallMissed = false;
                                    addToLocalStorage(callStatus: "received");
                                    await callMethods.endCall(call: call);
                                  }),
                              SizedBox(width: 25),
                              IconButton(
                                  icon: Icon(
                                    Icons.call,
                                    color: Colors.green,
                                  ),
                                  onPressed: () async {
                                    isCallMissed = false;
                                    addToLocalStorage(callStatus: "received");
                                    await Permissions
                                            .cameraAndMicrophonePermissionsGranted()
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CallScreen(
                                                      call: call,
                                                      videoCall: true,
                                                    )),
                                          )
                                        : {};
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
                      child: Column(
                        children: [
                          Text(
                            'Incoming Voice Call...',
                            style: TextStyle(fontSize: 30),
                          ),
                          SizedBox(height: 50),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: CachedNetworkImage(
                              imageUrl: call.callerPic,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            call.callerName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 75),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    Icons.call_end,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    await callMethods.endCall(call: call);
                                  }),
                              SizedBox(width: 25),
                              IconButton(
                                  icon: Icon(
                                    Icons.call,
                                    color: Colors.green,
                                  ),
                                  onPressed: () async {
                                    await Permissions
                                            .cameraAndMicrophonePermissionsGranted()
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CallScreen(
                                                      call: call,
                                                      videoCall: false,
                                                    )),
                                          )
                                        : {};
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
    );
  }
}
