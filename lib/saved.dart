import 'dart:convert';

import 'package:appbar_animated/appbar_animated.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecbooks/checkmark.dart';
import 'package:lecbooks/mybottomnavbar.dart';
import 'package:lecbooks/searchdelegateforsaved.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'bookcard.dart';
import 'classes.dart';
import 'globals.dart';
import 'package:http/http.dart' as http;

import 'loadingbookcard.dart';

class Saved extends StatefulWidget {
  const Saved({Key? key}) : super(key: key);

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  late User user;
  var data = 'ok';
  List<Book> savedbooks = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getsaved();
  }

  Future getsaved() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');
    var url = Uri.parse(host +
        '/api/saveds?populate[books][populate]=*&filters[users_permissions_user][username][\$eq]=$username');
    http.Response response = await http.get(url);
    if (!this.mounted) return;

    setState(() {
      var saveddata = jsonDecode(response.body);
      if (saveddata['data'].length != 0) {
        for (var element in saveddata['data'][0]['attributes']['books']
            ['data']) {
          savedbooks.add(Book(
            id: element['id'],
            authorname: element['attributes']['author']['data']['attributes']
                ['name'],
            price: (element['attributes']['price'])!.toDouble(),
            publishdate: element['attributes']['publishdate'].split('-')[2] +
                '/' +
                element['attributes']['publishdate'].split('-')[1] +
                '/' +
                element['attributes']['publishdate'].split('-')[0],
            category: element['attributes']['category'],
            pdfurl: element['attributes']['fullpdf']['data'][0]['attributes']
                ['url'],
            demopdfurl: element['attributes']['demopdf']['data'][0]
                ['attributes']['url'],
            coverpageurl: element['attributes']['coverpage']['data'][0]
                ['attributes']['url'],
            title: element['attributes']['title'],
            subtitle: element['attributes']['subtitle'],
            institute: element['attributes']['institute']['data']['attributes']
                ['name'],
            subject: element['attributes']['subject']['data']['attributes']
                ['name'],
            ratings: element['attributes']['ratings'],
            sem: element['attributes']['sem']['data']['attributes']['Semester']
                .toString(),
          ));
        }
        _isloading = false;
      }
    });
  }

  Future<void> _refresh() async {
    savedbooks.clear();

    await getsaved();
    setState(() {});
  }

  bool _isloading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaffoldLayoutBuilder(
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
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1,
                  ),
                  child: Container(
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
                                          _isloading ? 5 : savedbooks.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20.0, left: 20, right: 20),
                                          child: Container(
                                            child: _isloading
                                                ? LoadingBookCard()
                                                : BookCard(
                                                    book: savedbooks[index],
                                                  ),
                                          ),
                                        );
                                      }))
                              : (savedbooks.length != 0
                                  ? ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: savedbooks.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 7.0, left: 10, right: 10),
                                          child: Container(
                                            child: BookCard(
                                                book: savedbooks[index]),
                                          ),
                                        );
                                      })
                                  : Center(
                                      child: Container(
                                          child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                          'You have not added any books to saved',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      )),
                                    )),
                        ),
                      )),
                ),
              ),
            ]),
          ),
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
          'Saved',
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
              context: context, delegate: CustomSearchDelegateForSaved());
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
