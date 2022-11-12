import 'dart:convert';

// import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:lecbooks/resetpasspage.dart';
import 'package:mailer/mailer.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:mailer/smtp_server.dart';
import 'package:otp/otp.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

import 'globals.dart';

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({Key? key}) : super(key: key);

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final _formKey = GlobalKey<FormState>();
  bool isotpsent = false;
  int sendcounter = 0;

  OtpFieldController otpController = OtpFieldController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sendcounter = 0;
  }

  String? code;
  String myuser = 'kevinrajput7777@gmail.com';
  String mypass = 'dqgtnpwkncilfvdu';
  int? id;
  Future sendPressed() async {
    if (_formKey.currentState!.validate()) {
      var url = Uri.parse(host + "/api/users?filters[email][\$eq]=$_email");
      http.Response getresponse = await http.get(url);
      var userdata = jsonDecode(getresponse.body);
      if (userdata.isNotEmpty) {
        id = userdata[0]['id'];
        setState(() {
          code = OTP.generateTOTPCodeString(
              'JBSWY3DPEHPK3PXP', DateTime.now().millisecondsSinceEpoch);
          isotpsent = true;
          sendcounter++;
        });
        final smtpServer = gmail(myuser, mypass);
        final message = Message()
          ..from = Address(myuser, 'Maharshi')
          ..recipients.add(_email)
          ..subject = 'Forgot password'
          ..html = "<h1>$code</h1>\n<p>OTP</p>";

        try {
          final sendReport = await send(message, smtpServer);
          print('Message sent: ' + sendReport.toString());
        } on MailerException catch (e) {
          print('Message not sent.');
          for (var p in e.problems) {
            print('Problem: ${p.code}: ${p.msg}');
          }
        }
      } else {
        errorSnackBar(context, 'This email is not synced with any account');
      }
    }
  }

  String? _email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.01,
        ),
        color: Colors.white,
        child: Column(
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
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
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                    ),
                    onChanged: (value) {
                      _email = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      fillColor: Color(0xFF0D47A1),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (sendcounter == 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, right: 50),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.35,
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
                        onTap: () => sendPressed(),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Send',
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
            if (sendcounter > 0)
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(top: 40, right: 50),
              //       child: Container(
              //         height: 50,
              //         decoration: BoxDecoration(
              //           boxShadow: [
              //             BoxShadow(
              //               blurRadius:
              //                   10.0, // has the effect of softening the shadow
              //               spreadRadius:
              //                   1.0, // has the effect of extending the shadow
              //               offset: Offset(
              //                 5.0, // horizontal, move right 10
              //                 5.0, // vertical, move down 10
              //               ),
              //             ),
              //           ],
              //           color: Colors.white,
              //           borderRadius: BorderRadius.circular(30),
              //         ),
              //         child: ArgonTimerButton(
              //           height: 50,
              //           width: MediaQuery.of(context).size.width * 0.45,
              //           initialTimer: 30,
              //           minWidth: MediaQuery.of(context).size.width * 0.45,
              //           highlightColor: Colors.transparent,
              //           highlightElevation: 0,
              //           roundLoadingShape: false,
              //           splashColor: Colors.transparent,
              //           onTap: (startTimer, btnState) {
              //             if (btnState == ButtonState.Idle) {
              //               startTimer(30);
              //               sendPressed();
              //               print('ok');
              //             }
              //           },
              //           // initialTimer: 10,
              //           child: Text(
              //             sendcounter == 0 ? "Send" : "Resend",
              //             style: TextStyle(
              //                 color: Color(0xFF0D47A1),
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.w700),
              //           ),
              //           loader: (timeLeft) {
              //             return Text(
              //               "Resend | $timeLeft",
              //               style: TextStyle(
              //                   color: Colors.grey[500],
              //                   fontSize: 18,
              //                   fontWeight: FontWeight.w700),
              //             );
              //           },
              //           borderRadius: 5.0,
              //           color: Colors.transparent,
              //           elevation: 0,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            if (isotpsent)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50, left: 50),
                    child: Text(
                      'Enter OTP :',
                      style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 50, left: 50, right: 50),
                    child: OTPTextField(
                      length: 6,
                      controller: otpController,
                      width: MediaQuery.of(context).size.width,
                      fieldWidth: (MediaQuery.of(context).size.width - 150) / 6,
                      style: TextStyle(fontSize: 17),
                      textFieldAlignment: MainAxisAlignment.spaceAround,
                      fieldStyle: FieldStyle.underline,
                      onChanged: (pin) {},
                      onCompleted: (pin) {
                        print("Completed: " + pin);
                        if (pin != code) {
                          otpController.clear();
                          errorSnackBar(context, 'Entered OTP is incorrect.');
                        }
                        if (pin == code) {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => ResetPass(
                                        id: id,
                                      )));
                        }
                      },
                    ),
                  ),
                ],
              ),
          ],
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
          'Forgot Password',
          style: TextStyle(color: colorAnimated.color, fontSize: 22),
        ),
      ),
    ),
  );
}
