import 'dart:convert';

import 'package:appbar_animated/appbar_animated.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:lecbooks/globals.dart';
import 'package:lecbooks/payment.dart';
import 'package:lecbooks/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'classes.dart';

class AboutBookPage extends StatefulWidget {
  final book;

  const AboutBookPage({Key? key, required Book this.book}) : super(key: key);

  @override
  State<AboutBookPage> createState() => _AboutBookPageState(this.book);
}

class _AboutBookPageState extends State<AboutBookPage> {
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _page = 0;
  _AboutBookPageState(Book this.book);
  final Book book;
  var coverpageurl;
  bool issaved = false;
  bool isbelongsto = false;
  @override
  void initState() {
    super.initState();
    checkifsaved();
    isbookbelongstouser();
  }

  Future isbookbelongstouser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');
    var url = Uri.parse(host +
        '/api/users?populate[books][populate]=*&filters[username][\$eq]=$username');
    http.Response response = await http.get(url);
    var data = jsonDecode(response.body);
    print(data);
    var id = book.id;
    for (var element in data[0]['books']) {
      if (element['id'] == id) {
        if (this.mounted)
          setState(() {
            isbelongsto = true;
          });
        break;
      }
    }
  }

  Future checkifsaved() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');
    var id = book.id;
    List ids = [];
    var url2 = Uri.parse(host +
        '/api/saveds?populate[books][populate]=*&filters[users_permissions_user][username][\$eq]=$username');
    http.Response response2 = await http.get(url2);
    var saveddata = jsonDecode(response2.body);
    if (saveddata['data'].isNotEmpty) {
      for (var element in saveddata['data'][0]['attributes']['books']['data']) {
        if (element['id'] == id) {
          setState(() {
            issaved = true;
          });
          break;
        }
      }
    }
  }

  Future removefromsaved() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');

    var id = book.id;
    List ids = [];
    var url2 = Uri.parse(host +
        '/api/saveds?populate[books][populate]=*&filters[users_permissions_user][username][\$eq]=$username');
    http.Response getresponse = await http.get(url2);
    var data = jsonDecode(getresponse.body);
    var savedid = data['data'][0]['id'];
    var url = Uri.parse(host + '/api/saveds/$savedid');

    http.Response response2 = await http.get(url2);
    var saveddata = jsonDecode(response2.body);
    for (var element in saveddata['data'][0]['attributes']['books']['data']) {
      ids.add(element['id']);
    }
    ids.remove(id);
    http.Response response = await http.put(url,
        headers: headers,
        body: jsonEncode({
          'data': {'books': ids}
        }));

    if (response.statusCode != 200) {
      var data = jsonDecode(response.body);

      errorSnackBar(context, data.values.last['message']);
    } else {
      setState(() {
        issaved = false;
      });
    }
  }

  Future addtosaved() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');
    var url = Uri.parse(host +
        '/api/saveds?filters[users_permissions_user][username][\$eq]=$username');
    http.Response getresponse = await http.get(url);
    var data = jsonDecode(getresponse.body);
    print(data);
    var id = book.id;
    List ids = [];
    if (data['data'].isNotEmpty) {
      var savedid = data['data'][0]['id'];
      var url = Uri.parse(host + '/api/saveds/$savedid');
      var url2 = Uri.parse(host +
          '/api/saveds?populate[books][populate]=*&filters[users_permissions_user][username][\$eq]=$username');

      http.Response response2 = await http.get(url2);
      var saveddata = jsonDecode(response2.body);
      for (var element in saveddata['data'][0]['attributes']['books']['data']) {
        ids.add(element['id']);
      }
      ids.add(id);
      http.Response response = await http.put(url,
          headers: headers,
          body: jsonEncode({
            'data': {'books': ids}
          }));

      if (response.statusCode != 200) {
        var data = jsonDecode(response.body);

        errorSnackBar(context, data.values.last['message']);
      } else {
        setState(() {
          issaved = true;
        });
      }
    } else {
      ids.add(id);
      var url = Uri.parse(host + '/api/saveds');
      var url2 =
          Uri.parse(host + '/api/users?filters[username][\$eq]=$username');
      http.Response response2 = await http.get(url2);

      var data2 = jsonDecode(response2.body);
      var userid = data2[0]['id'];

      http.Response response = await http.post(url,
          headers: headers,
          body: jsonEncode({
            'data': {
              'books': ids,
              'users_permissions_user': [userid]
            }
          }));

      if (response.statusCode != 200) {
        var data = jsonDecode(response.body);

        errorSnackBar(context, data.values.last['message']);
      } else {
        setState(() {
          issaved = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ScaffoldLayoutBuilder(
          backgroundColorAppBar:
              ColorBuilder(Colors.grey.shade200, Color(0xFF0D47A1)),
          textColorAppBar: const ColorBuilder(Color(0xFF0D47A1), Colors.white),
          appBarBuilder: _appBar,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  color: Colors.grey[200],
                  height: MediaQuery.of(context).size.height,
                ),
                if (book.coverpageurl != null)
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.13,
                    ),
                    color: Colors.grey[200],
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: host + book.coverpageurl!,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.30,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.43,
                  ),
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.57),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 8.0, bottom: 8, right: 50, left: 50),
                        child: Text(
                          book.title!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 23,
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 8.0, bottom: 8, right: 80, left: 80),
                        child: Text(
                          'By ' + book.authorname!,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (book.ratings != null)
                        RatingBarIndicator(
                          rating: book.ratings!,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Publish Date:' + book.publishdate!,
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 20, right: 20, bottom: 50),
                        child: Container(
                          child: SingleChildScrollView(
                            child: Text(
                              book.subtitle!,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 15,
                                letterSpacing: 1.2,
                                wordSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        extendBody: true,
        bottomNavigationBar: isbelongsto
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width * 0.7,
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(0)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.transparent,
                          )),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewPdf(
                                      url: book.pdfurl,
                                      book: book,
                                    )));
                      },
                      child: Ink(
                        height: 43,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: GradientColors.skyLine,
                            end: Alignment.centerLeft,
                            begin: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.read_more,
                                      size: 25,
                                    ),
                                  ),
                                  Text(
                                    'Read',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width * 0.42,
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(0)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.transparent,
                          )),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewPdf(
                                      url: book.demopdfurl,
                                      book: book,
                                    )));
                      },
                      child: Ink(
                        height: 43,
                        width: MediaQuery.of(context).size.width * 0.42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: GradientColors.skyLine,
                            end: Alignment.centerLeft,
                            begin: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 25,
                                    ),
                                  ),
                                  Text(
                                    'Preview',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    height: 45,
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(0)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.transparent,
                          )),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Paywith(
                                      book: book,
                                    )));
                      },
                      child: Ink(
                        height: 43,
                        width: MediaQuery.of(context).size.width * 0.42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: GradientColors.skyLine,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Buy',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20),
                            ),
                            Text(
                              '\u{20B9}' + book.price.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ));
  }

  Widget _appBar(BuildContext context, ColorAnimated colorAnimated) {
    return AppBar(
        backgroundColor: colorAnimated.background,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          book.title!,
          style: TextStyle(
            color: colorAnimated.color,
          ),
        ),
        leading: InkWell(
          onTap: (() => Navigator.pop(context)),
          child: Container(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorAnimated.color,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: issaved
                ? InkWell(
                    onTap: (() => removefromsaved()),
                    child: Icon(
                      Icons.bookmark_added,
                      color: colorAnimated.color,
                    ),
                  )
                : InkWell(
                    onTap: (() => addtosaved()),
                    child: Icon(
                      Icons.bookmark_add_outlined,
                      color: colorAnimated.color,
                    ),
                  ),
          ),
        ]);
  }
}
