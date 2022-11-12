import 'package:page_transition/page_transition.dart';
import 'package:rive/rive.dart';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecbooks/checkmark.dart';
import 'package:lecbooks/checkmarkindictor.dart';
import 'package:lecbooks/continuereading.dart';
import 'package:lecbooks/recommended.dart';
import 'package:lecbooks/searchdelegate.dart';
import 'explorenotesbycourses.dart';
import 'homepagetop.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {}

  Future<void> _onRefresh() async {
    setState(() {});
  }

  void callback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldLayoutBuilder(
      backgroundColorAppBar:
          ColorBuilder(Colors.grey.shade200, Color(0xFF0D47A1)),
      textColorAppBar: const ColorBuilder(Color(0xFF0D47A1), Colors.white),
      appBarBuilder: _appBar,
      child: CustomRefreshIndicator(
        onRefresh: _onRefresh,
        builder: (
          BuildContext context,
          Widget child,
          IndicatorController controller,
        ) {
          return Loader(context: context, child: child, controller: controller);
        },
        offsetToArmed: 150,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
                child: Container(
                  color: Colors.grey[200],
                ),
              ),
              Container(
                color: Colors.grey.shade200,
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.15,
                ),
                child: Homepagetop(),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.40,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    ContRead(),
                    Recommended(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: ExplorebyCoursesfront(),
                    ),
                  ],
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
    automaticallyImplyLeading: false,
    backgroundColor: colorAnimated.background,
    elevation: 0,
    title: Container(
        margin: EdgeInsets.only(left: 30, bottom: 0),
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
    actions: [
      IconButton(
        onPressed: () {
          showSearch(context: context, delegate: CustomSearchDelegate());
        },
        icon: Icon(
          Icons.search,
          size: 25,
          color: colorAnimated.color,
        ),
      ),
    ],
  );
}
