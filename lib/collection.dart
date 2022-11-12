import 'dart:convert';

import 'package:appbar_animated/appbar_animated.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecbooks/checkmark.dart';
import 'package:lecbooks/loadingbookcard.dart';
import 'package:lecbooks/searchdelegateforcollection.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'bookcard.dart';
import 'classes.dart';
import 'globals.dart';

class MyCollection extends StatefulWidget {
  const MyCollection({Key? key}) : super(key: key);

  @override
  State<MyCollection> createState() => _MyCollectionState();
}

class _MyCollectionState extends State<MyCollection> {
  void initState() {
    super.initState();
    setcollection().then((_) {
      if (collection.isNotEmpty) {
        _iscollectionempty = true;
      }
    });
  }

  List<Book> collection = [];
  bool _iscollectionempty = false;
  bool _isloading = true;
  Future setcollection() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');

    var url = Uri.parse(host +
        '/api/users?filters[username][\$eq]=$username&populate[books][populate]=*');
    http.Response response = await http.get(url);

    var data = jsonDecode(response.body);
    if (!this.mounted) return;

    setState(() {
      for (var element in data[0]['books']) {
        collection.add(Book(
          id: element['id'],
          authorname: element['author']['name'],
          price: (element['price'])!.toDouble(),
          publishdate: element['publishdate'].split('-')[2] +
              '/' +
              element['publishdate'].split('-')[1] +
              '/' +
              element['publishdate'].split('-')[0],
          category: element['category'],
          pdfurl: element['fullpdf'][0]['url'],
          demopdfurl: element['demopdf'][0]['url'],
          coverpageurl: element['coverpage'][0]['url'],
          title: element['title'],
          subtitle: element['subtitle'],
          institute: element['institute']['name'],
          subject: element['subject']['name'],
          ratings: element['ratings'],
          sem: element['sem']['Semester'].toString(),
        ));
      }
      _isloading = false;
    });
  }

  Future<void> _refresh() async {
    collection.clear();
    setState(() {
      _isloading = true;
    });
    await setcollection();
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldLayoutBuilder(
      backgroundColorAppBar:
          ColorBuilder(Colors.grey.shade200, Color(0xFF0D47A1)),
      textColorAppBar: const ColorBuilder(Color(0xFF0D47A1), Colors.white),
      appBarBuilder: _appBar,
      child: CustomRefreshIndicator(
        onRefresh: _refresh,
        builder: (BuildContext context, Widget child,
            IndicatorController controller) {
          return Loader(
              key: UniqueKey(),
              context: context,
              child: child,
              controller: controller);
        },
        offsetToArmed: 150,
        child: SingleChildScrollView(
          child: Stack(children: [
            Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1,
                ),
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                color: Colors.white,
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: _isloading
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey.shade200,
                                highlightColor: Colors.white,
                                enabled: true,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        _isloading ? 5 : collection.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0, left: 20, right: 20),
                                        child: Container(
                                          child: _isloading
                                              ? LoadingBookCard()
                                              : BookCard(
                                                  book: collection[index],
                                                ),
                                        ),
                                      );
                                    }))
                            : (collection.length != 0
                                ? ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: collection.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 7.0, left: 10, right: 10),
                                        child: Container(
                                          child: BookCard(
                                            book: collection[index],
                                          ),
                                        ),
                                      );
                                    })
                                : Center(
                                    child: Container(
                                        child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        'You have not added any books to your collection',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    )),
                                  ))))),
          ]),
        ),
      ),
    );
  }
}

Widget _appBar(BuildContext context, ColorAnimated colorAnimated) {
  return AppBar(
    backgroundColor: colorAnimated.background,
    elevation: 0,
    automaticallyImplyLeading: false,
    title: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Text(
          'My collection',
          style: GoogleFonts.nunito(
              textStyle: TextStyle(
                  color: colorAnimated.color,
                  fontSize: 23,
                  fontWeight: FontWeight.w900)),
        ),
      ),
    ),
    actions: [
      IconButton(
        onPressed: () {
          showSearch(
              context: context, delegate: CustomSearchDelegateForCollection());
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
