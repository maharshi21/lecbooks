import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
// import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:lecbooks/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'classes.dart';

class Verifyemailpage extends StatefulWidget {
  final String email;
  const Verifyemailpage({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyemailpageState createState() => _VerifyemailpageState(this.email);
}

class _VerifyemailpageState extends State<Verifyemailpage>
    with WidgetsBindingObserver {
  @override
  final email;
  bool confirmed = false;

  _VerifyemailpageState(this.email);
  Future deluser() async {
    var url3 = Uri.parse(host + "/api/users?filters[email][\$eq]=$email");

    http.Response response = await http.get(url3);
    var user = jsonDecode(response.body);

    if (!confirmed) {
      var url3 = Uri.parse(host + "/api/users/$user[0]['id']");

      http.Response response = await http.delete(url3);
    }
  }

  Future setisloggedin(id) async {
    var url = Uri.parse(host + '/api/users/$id');

    http.Response response = await http.put(url,
        headers: headers, body: jsonEncode({'isloggedin': true}));
    var data = jsonDecode(response.body);
  }

  Future checkforemailverification() async {
    var url3 = Uri.parse(host + "/api/users?filters[email][\$eq]=$email");

    http.Response response = await http.get(url3);
    var user = jsonDecode(response.body);
    if (user[0]['confirmed']) {
      setState(() {
        confirmed = true;
      });
      await setisloggedin(user[0]['id']);
      SharedPreferences pre = await SharedPreferences.getInstance();
      pre.setString('username', user[0]['username']);
      pre.setBool('loggedin', true);
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => MyHomePage()));
      timer?.cancel();
    }
  }

  Future resend() async {
    var url3 = Uri.parse(host + "/api/auth/send-email-confirmation");

    http.Response response = await http.post(url3,
        headers: headers, body: jsonEncode({'email': email}));
    var data = jsonDecode(response.body);
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => checkforemailverification());
  }

  @override
  Future<void> dispose() async {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      if (!confirmed) deluser();
      print('ok');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
      ),
      color: Colors.white,
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 10),
            child: RotatedBox(
                quarterTurns: -1,
                child: Text(
                  'Email',
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 10),
            child: RotatedBox(
                quarterTurns: -1,
                child: Text(
                  'Verification',
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                )),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Container(
            child: Text(
              "You're almost there! We sent an emaii to $email.",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: Text(
              "Just click on the link in that email to complete your sign up.",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // Container(
        //   child: Text(
        //     "Still can't find the email?",
        //     style: TextStyle(fontSize: 20),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        // Padding(
        //   padding: const EdgeInsets.all(10.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Padding(
        //         padding: const EdgeInsets.only(top: 40),
        //         child: Container(
        //           height: 50,
        //           decoration: BoxDecoration(
        //             boxShadow: [
        //               BoxShadow(
        //                 blurRadius:
        //                     10.0, // has the effect of softening the shadow
        //                 spreadRadius:
        //                     1.0, // has the effect of extending the shadow
        //                 offset: Offset(
        //                   5.0, // horizontal, move right 10
        //                   5.0, // vertical, move down 10
        //                 ),
        //               ),
        //             ],
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(30),
        //           ),
        //           child: ArgonTimerButton(
        //             height: 50,
        //             width: MediaQuery.of(context).size.width * 0.45,
        //             initialTimer: 30,
        //             minWidth: MediaQuery.of(context).size.width * 0.45,
        //             highlightColor: Colors.transparent,
        //             highlightElevation: 0,
        //             roundLoadingShape: false,
        //             splashColor: Colors.transparent,
        //             onTap: (startTimer, btnState) {
        //               if (btnState == ButtonState.Idle) {
        //                 startTimer(30);
        //                 resend();
        //               }
        //             },
        //             child: Text(
        //               "Resend",
        //               style: TextStyle(
        //                   color: Color(0xFF0D47A1),
        //                   fontSize: 18,
        //                   fontWeight: FontWeight.w700),
        //             ),
        //             loader: (timeLeft) {
        //               return Text(
        //                 "Resend | $timeLeft",
        //                 style: TextStyle(
        //                     color: Colors.grey[500],
        //                     fontSize: 18,
        //                     fontWeight: FontWeight.w700),
        //               );
        //             },
        //             borderRadius: 5.0,
        //             color: Colors.transparent,
        //             elevation: 0,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ]),
    ));
  }
}
