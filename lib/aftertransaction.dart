import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:lecbooks/aboutbookpage.dart';
import 'package:lecbooks/collection.dart';
import 'package:lecbooks/isloggedin.dart';
import 'package:lecbooks/pdfviewer.dart';

import 'classes.dart';
import 'globals.dart';

class Arguments {
  final String title_bar;
  final String text_message;

  Arguments(this.title_bar, this.text_message);
}

class AfterTrans extends StatefulWidget {
  final args;

  const AfterTrans({Key? key, this.args}) : super(key: key);

  @override
  State<AfterTrans> createState() => AfterTransState(this.args);
}

class AfterTransState extends State<AfterTrans> {
  final args;

  AfterTransState(this.args);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bookid = args['bookid'];
    status = args['status'];

    getbook();
  }

  var bookid;
  var status;
  Book? book;
  Future getbook() async {
    var url = Uri.parse(host + '/api/books/$bookid?populate=*');

    http.Response response = await http.get(url);

    setState(() {
      var data = jsonDecode(response.body);
      var element = data['data'];
      book = Book(
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
        demopdfurl: element['attributes']['demopdf']['data'][0]['attributes']
            ['url'],
        coverpageurl: element['attributes']['coverpage']['data'][0]
            ['attributes']['url'],
        title: element['attributes']['title'],
        subtitle: element['attributes']['subtitle'],
        institute: element['attributes']['institute']['data']['attributes']
            ['name'],
        subject: element['attributes']['subject']['data']['attributes']['name'],
        ratings: element['attributes']['ratings'],
        sem: element['attributes']['sem']['data']['attributes']['Semester']
            .toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Row(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 10),
                child: RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      status == 'Approved' ? 'Congratulations' : 'Oops!',
                      style: TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                    )),
              )
            ]),
            Padding(
              padding: const EdgeInsets.only(top: 80.0, bottom: 20),
              child: Text(
                status == 'Approved'
                    ? 'Book added to your collection!'
                    : 'Purchase is failed!',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 2),
                  height: 45,
                  width: 180,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(0)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.transparent,
                        )),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyCollection()));
                    },
                    child: Ink(
                      height: 43,
                      width: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: GradientColors.skyLine,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Go to your collection',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 2),
                  height: 45,
                  width: 180,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(0)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.transparent,
                        )),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutBookPage(
                                    book: book!,
                                  )));
                    },
                    child: Ink(
                      height: 43,
                      width: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: GradientColors.skyLine,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Read Book',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
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
