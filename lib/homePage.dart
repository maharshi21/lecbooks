import 'package:flutter/material.dart';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:lecbooks/collection.dart';
import 'package:lecbooks/explorenotesbycourses.dart';
import 'package:lecbooks/homepagetop.dart';
import 'package:lecbooks/homepagewidget.dart';
import 'package:lecbooks/loginPage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:lecbooks/mybottomnavbar.dart';
import 'package:lecbooks/saved.dart';
import 'package:lecbooks/searchdelegate.dart';
import 'package:lecbooks/userpage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with RouteAware, RestorationMixin {
  void didPop() {
    super.didPop();
    setState(() {});
  }

  List<Widget> pages = [Home(), MyCollection(), Saved(), UserPage()];

  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          index: 0,
          height: 60.0,
          items: <Widget>[
            Icon(
              Icons.home_outlined,
              size: 30,
              color: Color(0xFF0D47A1),
            ),
            Icon(
              Icons.collections_bookmark_outlined,
              size: 30,
              color: Color(0xFF0D47A1),
            ),
            Icon(
              Icons.bookmark_border_outlined,
              size: 30,
              color: Color(0xFF0D47A1),
            ),
            Icon(
              Icons.perm_identity,
              size: 30,
              color: Color(0xFF0D47A1),
            ),
          ],
          color: Colors.grey.shade100,
          buttonBackgroundColor: Colors.grey.shade100,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true,
        ),
        extendBody: true,
        body: pages[_page]);
  }

  @override
  // TODO: implement restorationId
  String? get restorationId => 'homepage';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // TODO: implement restoreState
  }
}
