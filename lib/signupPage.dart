import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lecbooks/globals.dart';
import 'package:lecbooks/loginPage.dart';
import 'package:lecbooks/verifyemailpage.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:page_transition/page_transition.dart';
import 'classes.dart';
import 'homePage.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  var url = Uri.parse(host + "/api/auth/local/register");
  var url2 = Uri.parse(host + "/api/members");
  var url3 = Uri.parse(host + "/api/auth/send-email-confirmation");

  User user = User();

  Future save() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });
      http.Response postresponse = await http.post(url,
          headers: headers,
          body: jsonEncode({
            'username': user.name,
            'email': user.email,
            'password': user.password,
            'confirmed': false
          }));
      Map responseMap = jsonDecode(postresponse.body);

      if (postresponse.statusCode != 200) {
        setState(() {
          _isloading = false;
        });
        errorSnackBar(context, responseMap.values.last['message']);
      } else {
        setState(() {
          _isloading = false;
        });

        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => Verifyemailpage(
                      email: user.email!,
                    )));
      }
    } else {}
  }

  bool _showpass = false;
  bool _showconpass = false;

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isloading,
      progressIndicator: SpinKitThreeBounce(color: Color(0xFF0D47A1)),
      child: Scaffold(
          body: Form(
        key: _formKey,
        child: Container(
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 10),
                      child: RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            'Sign up',
                            style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                    fontSize: 38,
                                    color: Color(0xFF0D47A1),
                                    fontWeight: FontWeight.w900)),
                          )),
                    )
                  ]),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 50, right: 50),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          } else if (value.length > 20) {
                            return 'text is too long';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          user.name = value;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[a-zA-Z0-9_]"))
                        ],
                        decoration: InputDecoration(
                          fillColor: Color(0xFF0D47A1),
                          labelText: 'User Name',
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
                          labelStyle: GoogleFonts.asap(
                              textStyle: TextStyle(
                            color: Color(0xFF0D47A1),
                          )),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 50, right: 50),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          } else if (!EmailValidator.validate(value)) {
                            return 'Please enter valid email';
                            // ignore: unrelated_type_equality_checks
                          }
                          return null;
                        },
                        onChanged: (value) {
                          user.email = value;
                        },
                        enableSuggestions: true,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 23, maxHeight: 20),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Entypo.mail,
                              size: 20,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          fillColor: Color(0xFF0D47A1),
                          labelText: 'Email',
                          labelStyle: GoogleFonts.asap(
                              textStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0D47A1),
                          )),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 50, right: 50),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          } else if (value.length < 6) {
                            return 'password is too short';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          user.password = value;
                        },
                        obscureText: !_showpass,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          fillColor: Color(0xFF0D47A1),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 23, maxHeight: 20),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Entypo.key,
                              size: 20,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
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
                          labelText: 'Password',
                          labelStyle: GoogleFonts.asap(
                              textStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0D47A1),
                          )),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 50, right: 50),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          } else if (value != user.password) {
                            return 'password and confirm password are not same';
                          }
                          return null;
                        },
                        obscureText: !_showconpass,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          fillColor: Color(0xFF0D47A1),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 23, maxHeight: 20),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.confirmation_num,
                              size: 18,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              !_showconpass
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                              color: Color(0xFF0D47A1),
                            ),
                            onPressed: () {
                              if (!_showconpass) {
                                setState(() {
                                  _showconpass = true;
                                });
                              } else {
                                setState(() {
                                  _showconpass = false;
                                });
                              }
                            },
                          ),
                          labelText: 'Confirm Password',
                          labelStyle: GoogleFonts.asap(
                              textStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0D47A1),
                          )),
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
                      child: ElevatedButton(
                        onPressed: () => save(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Sign up',
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      //color: Color(0xFF0D47A1),
                                      fontWeight: FontWeight.w900)),
                            ),
                            Icon(
                              Icons.arrow_forward,
                             // color: Color(0xFF0D47A1),
                            ),
                          ],
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
                            'Already a users?',
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
                                        child: LoginPage()));
                              },
                              child: Text(
                                'Sign In',
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
