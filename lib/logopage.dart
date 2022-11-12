import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoPage extends StatelessWidget {
  const LogoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: Container(
            margin: EdgeInsets.only(left: 10, bottom: 0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF0D47A1),
                  blurRadius: 4.0, // has the effect of softening the shadow
                  spreadRadius: 1.5, // has the effect of extending the shadow
                  offset: Offset(
                    3.0, // horizontal, move right 10
                    4.0, // vertical, move down 10
                  ),
                ),
              ],
              color: Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 15, top: 5, bottom: 5),
              child: Text('LecBooks.',
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        backgroundColor: Color(0xFF0D47A1)),
                  )),
            )),
      ),
    );
  }
}
