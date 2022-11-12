import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:lecbooks/aftertransaction.dart';
import 'package:lecbooks/slidingbuttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aboutbookpage.dart';
import 'globals.dart';
import 'homepagetop.dart';
import 'package:lecbooks/signupPage.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'homePage.dart';
import 'isloggedin.dart';
import 'loginPage.dart';
import 'verifyemailpage.dart';

Future<void> main() async {
  runApp(RestorationScope(
    child: MyApp(),
    restorationId: 'root',
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // // This widget is the root of your application.
  Map<int, Color> color = {
    50: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
    100: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
    200: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
    300: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
    400: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
    500: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
    600: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
    700: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
    800: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
    900: Color.fromARGB(0xFF, 0x0D, 0x47, 0xA1),
  };
  // Timer? timer;
  // bool logout = false;
  // @override
  // void initState() {
  //   super.initState();
  //   timer = Timer.periodic(Duration(seconds: 1), (Timer t) => checkforlogout());
  // }

  // Future checkforlogout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   if (prefs.getBool('loggedin') != null &&
  //       prefs.getBool('loggedin') == true) {
  //     var username = (prefs.getString('username'));

  //     var url2 =
  //         Uri.parse(host + '/api/users?filters[username][\$eq]=$username');

  //     http.Response response2 = await http.get(url2);
  //     var user = jsonDecode(response2.body);
  //     setState(() {
  //       logout = user[0]['requestforlogout'];
  //     });
  //     if (logout) {
  //       if (ModalRoute.of(context) !=
  //           null) if (ModalRoute.of(context)!.settings.name != '/login') {
  //         prefs.setBool('loggedin', false);
  //         prefs.setString('username', '');
  //         await navService.pushNamed('/login');
  //         var id = user[0]['id'];
  //         var url = Uri.parse(host + '/api/users/$id');

  //         http.Response response = await http.put(url,
  //             headers: headers, body: jsonEncode({'requestforlogout': false}));
  //       }
  //     }
  //   }
  // }

  // @override
  // void dispose() {
  //   timer?.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: MaterialColor(0xFF0D47A1, color),
      ),
      home: Isloggedin (),
      navigatorKey: NavigationService.navigationKey,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/aftertrans':
            return MaterialPageRoute(
                builder: (_) => AfterTrans(
                      args: settings.arguments,
                    ));
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());

          default:
            return null;
        }
      },
    );
  }
}
