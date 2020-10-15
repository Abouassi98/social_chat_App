import 'package:flutter/material.dart';
import 'package:chat/resources/log_repository.dart';
import 'package:chat/models/logs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/widgets/quiet_box.dart';
import 'package:chat/utils/call_Utils.dart';

class LogListContainer extends StatefulWidget {
  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  
    getIcon(String callStatus) {
      Icon _icon;
      double _iconSize = 15;

      switch (callStatus) {
        case "dialled":
          _icon = Icon(
            Icons.call_made,
            size: _iconSize,
            color: Colors.green,
          );
          break;

        case "missed":
          _icon = Icon(
            Icons.call_missed,
            color: Colors.red,
            size: _iconSize,
          );
          break;

        default:
          _icon = Icon(
            Icons.call_received,
            size: _iconSize,
            color: Colors.grey,
          );
          break;
      }

      return Container(
        margin: EdgeInsets.only(right: 5),
        child: _icon,
      );
    }

    @override
    Widget build(BuildContext context) {
      return FutureBuilder<dynamic>(
        future: LogRepository.getLogs(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            List<dynamic> logList = snapshot.data;

            if (logList.isNotEmpty) {
              return ListView.builder(
                itemCount: logList.length,
                itemBuilder: (context, i) {
                  Log _log = logList[i];
                  bool hasDialled = _log.callStatus == "dialled";

                  return ListTile(
                    leading: CircleAvatar(
                      radius: MediaQuery.of(context).size.height * 0.038,
                      child: CachedNetworkImage(
                        imageUrl:
                            hasDialled ? _log.reciverPhoto : _log.callerPhoto,
                      ),
                    ),
                    onLongPress: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Delete this Log?"),
                        content:
                            Text("Are you sure you wish to delete this log?"),
                        actions: [
                          FlatButton(
                            child: Text("YES"),
                            onPressed: () async {
                              Navigator.maybePop(context);
                              await LogRepository.deleteLogs(i);
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                          FlatButton(
                            child: Text("NO"),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      hasDialled ? _log.reciverName : _log.callerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    trailing: getIcon(_log.callStatus),
                    subtitle: Text(
                      CallUtils.formatDateString(_log.timestamp),
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              );
            }
            return QuietBox(
              heading: "This is where all your call logs are listed",
              subtitle: "Calling people all over the world with just one click",
            );
          }

          return QuietBox(
            heading: "This is where all your call logs are listed",
            subtitle: "Calling people all over the world with just one click",
          );
        },
      );
    }
  
}
