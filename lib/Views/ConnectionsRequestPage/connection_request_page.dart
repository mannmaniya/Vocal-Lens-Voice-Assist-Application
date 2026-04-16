import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/user_controller.dart';

class ConnectionRequestPage extends StatefulWidget {
  const ConnectionRequestPage({super.key});

  @override
  _ConnectionRequestPageState createState() => _ConnectionRequestPageState();
}

class _ConnectionRequestPageState extends State<ConnectionRequestPage> {
  @override
  void initState() {
    super.initState();
    // Fetch connection requests when the page is loaded
    Future.microtask(() => Provider.of<UserController>(context, listen: false)
        .fetchConnectionRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Flexify.back(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey.shade900,
        title: Text(tr('connection_requests')),
      ),
      body: Consumer<UserController>(
        builder: (context, userController, child) {
          if (userController.receivedRequests.isEmpty) {
            return Center(
              child: Text(
                tr('no_connection_requests'),
                style: TextStyle(color: Colors.white54, fontSize: 16.sp),
              ),
            );
          }

          return ListView.builder(
            itemCount: userController.receivedRequests.length,
            itemBuilder: (context, index) {
              String senderUid = userController.receivedRequests[index]['from'];

              return FutureBuilder<String>(
                future: userController.getUserName(senderUid),
                builder: (context, snapshot) {
                  String username = snapshot.data ?? tr('unknown_user');

                  return Card(
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    color: Colors.blueGrey.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(username[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(username,
                          style: const TextStyle(color: Colors.white)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check,
                                color: Colors.greenAccent),
                            onPressed: () async {
                              await userController.acceptRequest(senderUid);
                              Fluttertoast.showToast(
                                  msg: tr('request_accepted'));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.redAccent),
                            onPressed: () async {
                              await userController.rejectRequest(senderUid);
                              Fluttertoast.showToast(
                                msg: tr(
                                  'request_declined',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }
}
