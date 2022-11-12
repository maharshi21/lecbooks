import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:lecbooks/logopage.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'homePage.dart';
import 'loginPage.dart';

class Isloggedin extends StatefulWidget {
  const Isloggedin({Key? key}) : super(key: key);

  @override
  State<Isloggedin> createState() => IsloggedinState();
}

class IsloggedinState extends State<Isloggedin> {
  Widget home = LogoPage();
  bool isalreadyloggedin = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gethome();
  }

  Future checkalreadyloggedin(username) async {
    var url2 = Uri.parse(host + '/api/users?filters[username][\$eq]=$username');

    http.Response response2 = await http.get(url2);
    var user = jsonDecode(response2.body);
    setState(() {
      isalreadyloggedin = user[0]['isloggedin'];
    });
  }

  Future gethome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('loggedin') != null &&
        prefs.getBool('loggedin') == true) {
      await checkalreadyloggedin(prefs.getString('username'));
      if (isalreadyloggedin)
        setState(() {
          navService.pushNamed('/login');
          print(prefs.getBool('loggedin'));
        });
      else
        setState(() {
          home = MyHomePage();
        });
    } else {
      setState(() {
        home = LoginPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return home;
  }
}
