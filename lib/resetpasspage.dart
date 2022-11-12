import 'package:appbar_animated/appbar_animated.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lecbooks/loginPage.dart';

import 'globals.dart';

class ResetPass extends StatefulWidget {
  final id;

  const ResetPass({Key? key, required this.id}) : super(key: key);

  @override
  State<ResetPass> createState() => _ResetPassState(this.id);
}

class _ResetPassState extends State<ResetPass> {
  final _formKey = GlobalKey<FormState>();
  String? pass;
  String? cpass;

  final id;

  _ResetPassState(this.id);
  Future resetPressed() async {
    if (_formKey.currentState!.validate()) {
      var url2 = Uri.parse(host + "/api/users/$id");

      http.Response postresponse = await http.put(url2,
          headers: headers, body: jsonEncode({'password': pass}));
      Map responseMap = jsonDecode(postresponse.body);

      if (postresponse.statusCode != 200) {
        errorSnackBar(context, responseMap.values.last['message']);
      } else {
        print(responseMap);
        Navigator.push(
            context, new MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.01,
        ),
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 10),
                      child: RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            'Forgot',
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
                            'Password',
                            style: TextStyle(
                              color: Color(0xFF0D47A1),
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                            ),
                          )),
                    ),
                  ]),
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                    ),
                    onChanged: (value) {
                      pass = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      } else if (value.length < 6) {
                        return 'password is too short';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      fillColor: Color(0xFF0D47A1),
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                    ),
                    onChanged: (value) {
                      cpass = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      } else if (value != pass) {
                        return 'password and confirm password are not same';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      fillColor: Color(0xFF0D47A1),
                      labelText: 'Confim Password',
                      labelStyle: TextStyle(
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, right: 50, left: 200),
                child: Container(
                  alignment: Alignment.bottomRight,
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius:
                            10.0, // has the effect of softening the shadow
                        spreadRadius:
                            1.0, // has the effect of extending the shadow
                        offset: Offset(
                          5.0, // horizontal, move right 10
                          5.0, // vertical, move down 10
                        ),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: InkWell(
                    onTap: () => resetPressed(),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Reset',
                            style: TextStyle(
                              color: Color(0xFF0D47A1),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _appBar(BuildContext context, ColorAnimated colorAnimated) {
  return AppBar(
    backgroundColor: colorAnimated.background,
    elevation: 0,
    title: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Text(
          'Reset Password',
          style: TextStyle(color: colorAnimated.color, fontSize: 22),
        ),
      ),
    ),
  );
}
