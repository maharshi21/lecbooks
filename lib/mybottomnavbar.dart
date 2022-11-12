import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:lecbooks/homePage.dart';
import 'package:lecbooks/isloggedin.dart';
import 'package:lecbooks/saved.dart';

class Bottomnavbar extends StatefulWidget {
  final index;
  const Bottomnavbar({Key? key, required this.index}) : super(key: key);

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: widget.index,
      height: 60.0,
      items: <Widget>[
        Icon(
          Icons.library_add_outlined,
          size: 30,
          color: Color(0xFF0D47A1),
        ),
        Icon(
          Icons.list,
          size: 30,
          color: Color(0xFF0D47A1),
        ),
        Icon(
          Icons.home_outlined,
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
      color: Colors.white,
      buttonBackgroundColor: Colors.white,
      backgroundColor: Color(0xFF0D47A1),
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 600),
      onTap: (index) {
        setState(() {
          switch (index) {
            case 3:
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => Saved()));
              break;
            case 2:
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => MyHomePage()));
              break;
            default:
          }
        });
      },
      letIndexChange: (index) => true,
    );
  }
}
