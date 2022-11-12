import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lecbooks/forgotpasspage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lecbooks/homePage.dart';
import 'package:lecbooks/signupPage.dart';

import 'package:loading_overlay/loading_overlay.dart';
import 'package:page_transition/page_transition.dart';

import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'auth_services.dart';
import 'globals.dart';
import 'verifyemailpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  bool isalreadyloggedin = false;
  String _email = '';
  String _password = '';
  bool _isloading = false;

  Future checkalreadyloggedin(id) async {
    var url2 = Uri.parse(host + '/api/users/$id');

    http.Response response2 = await http.get(url2);
    var user = jsonDecode(response2.body);
    setState(() {
      isalreadyloggedin = user['isloggedin'];
    });
  }

  Future logoutfromotherdevices(id) async {
    var url = Uri.parse(host + '/api/users/$id');

    http.Response response = await http.put(url,
        headers: headers, body: jsonEncode({'requestforlogout': true}));
  }

  Future setisloggedin(id) async {
    var url = Uri.parse(host + '/api/users/$id');

    http.Response response = await http.put(url,
        headers: headers, body: jsonEncode({'isloggedin': true}));
    var data = jsonDecode(response.body);
  }

  loginPressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isloading = true;
        context.loaderOverlay.visible;
      });
      var url = Uri.parse(host + '/api/auth/local');

      http.Response response = await http.post(url,
          headers: headers,
          body: jsonEncode({
            'identifier': _email,
            'password': _password,
          }));
      Map responseMap = jsonDecode(response.body);

      if (response.statusCode != 200) {
        setState(() {
          _isloading = false;
        });
        if (responseMap.values.last['message'] ==
            'Your account email is not confirmed') {
          var url3 = Uri.parse(host +
              "/api/users?filters[\$or][0][email][\$eq]=$_email&filters[\$or][1][username][\$eq]=$_email");

          http.Response user = await http.get(url3);
          var usermap = jsonDecode(user.body);
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => Verifyemailpage(
                        email: usermap[0]['email'],
                      )));
        } else {
          errorSnackBar(context, responseMap.values.last['message']);
        }
      } else {
        setState(() {
          _isloading = false;
        });
        if (responseMap['user']['confirmed'] == true) {
          await checkalreadyloggedin(responseMap['user']['id']);
          if (isalreadyloggedin) {
            if (await confirm(
              context,
              title: const Text('Confirm',
                  style: TextStyle(color: Color(0xFF0D47A1))),
              content: const Text(
                  'Login from multiple device at a time is not allowed!would you like to logout from all other divices?'),
              textOK: const Text(
                'Yes',
                style: TextStyle(color: Color(0xFF0D47A1)),
              ),
              textCancel:
                  const Text('No', style: TextStyle(color: Color(0xFF0D47A1))),
            )) {
              logoutfromotherdevices(responseMap['user']['id']);
            }
          }
          setisloggedin(responseMap['user']['id']);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('loggedin', true);
          prefs.setString('username', responseMap['user']['username']);
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => MyHomePage()));
        } else {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => Verifyemailpage(
                        email: _email,
                      )));
        }
      }
    }
  }

  bool _showpass = false;
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isloading,
      progressIndicator: SpinKitThreeBounce(color: Color(0xFF0D47A1)),
      child: Scaffold(
          body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, Colors.white]),
          ),
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 60, left: 10),
                      child: RotatedBox(
                          quarterTurns: -1,
                          child: Text('Sign in',
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                ),
                              ))),
                    )
                  ]),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 50, left: 50, right: 50),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        style: GoogleFonts.asap(
                            textStyle: TextStyle(
                          color: Color(0xFF0D47A1),
                        )),
                        onChanged: (value) {
                          _email = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          fillColor: Color(0xFF0D47A1),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 23, maxHeight: 20),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              FontAwesome5.user,
                              size: 18,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          labelText: 'Identifier (Email or Username)',
                          labelStyle: TextStyle(
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 50, left: 50, right: 50),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        style: GoogleFonts.asap(
                            textStyle: TextStyle(
                          color: Color(0xFF0D47A1),
                        )),
                        onChanged: (value) {
                          _password = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        obscureText: !_showpass,
                        decoration: InputDecoration(
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 23, maxHeight: 20),
                          prefixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Entypo.key,
                                size: 20,
                                color: Color(0xFF0D47A1),
                              )),
                          suffixIcon: IconButton(
                            icon: Icon(
                              !_showpass
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                              color: Color(0xFF0D47A1),
                            ),
                            onPressed: () {
                              if (!_showpass) {
                                setState(() {
                                  _showpass = true;
                                });
                              } else {
                                setState(() {
                                  _showpass = false;
                                });
                              }
                            },
                          ),
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
                    padding:
                        const EdgeInsets.only(top: 30, left: 50, right: 50),
                    child: Container(
                      alignment: Alignment.topRight,
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassPage()));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.asap(
                              textStyle: TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontWeight: FontWeight.w700)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 40, right: 50, left: 200),
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
                        onTap: () => loginPressed(),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Sign In',
                                style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                )),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF0D47A1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 50),
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                            'New user?',
                            style: GoogleFonts.asap(
                                textStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF0D47A1),
                            )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        duration: Duration(milliseconds: 500),
                                        type: PageTransitionType
                                            .leftToRightWithFade,
                                        child: SignupPage()));
                              },
                              child: Text(
                                'Sign up',
                                style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF0D47A1),
                                        fontWeight: FontWeight.w700)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
