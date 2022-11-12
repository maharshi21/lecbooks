import 'dart:convert';
import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecbooks/checkmarkindictor.dart';
import 'package:lecbooks/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:transparent_image/transparent_image.dart';

import 'aboutbookpage.dart';
import 'classes.dart';
import 'globals.dart';

class ContRead extends StatefulWidget {
  const ContRead({Key? key}) : super(key: key);

  @override
  State<ContRead> createState() => ContReadState();
}

class ContReadState extends State<ContRead> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcontbooks();
  }

  void refresh() {
    setState(() {
      print('ok2');
      crbooks.clear();
      per.clear();
      getcontbooks();
      getper();
    });
  }

  List<Book> crbooks = [];
  List per = [];
  Future getper() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');
    setState(() {
      for (var element in crbooks) {
        print('ok');
        var persent =
            pref.getInt('lastreadpage' + element.title! + username!)! /
                pref.getInt('totalpage' + element.title! + username)!;
        per.add(persent);
        print(persent);
      }
    });
  }

  Future getcontbooks() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');
    var url = Uri.parse(host +
        '/api/continue-readings?populate[books][populate]=*&filters[users_permissions_user][username][\$eq]=$username');
    http.Response getresponse = await http.get(url);
    var data = jsonDecode(getresponse.body);
    print(data);
    if (data['data'].length != 0) {
      for (var element in data['data'][0]['attributes']['books']['data']) {
        setState(() {
          crbooks.add(Book(
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
        });
      }
      setState(() {
        for (var element in crbooks) {
          if (pref.getInt('lastreadpage' + element.title! + username!) !=
                  null &&
              pref.getInt('totalpage' + element.title! + username) != null) {
            var persent =
                pref.getInt('lastreadpage' + element.title! + username)! /
                    pref.getInt('totalpage' + element.title! + username)!;
            per.add(persent);
          } else {
            per.add(0);
          }
        }
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {});
    print('ok');
  }

  @override
  Widget build(BuildContext context) {
    return crbooks.length != 0
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Continue Reading :',
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                color: Color(0xFF0D47A1),
                                fontWeight: FontWeight.w900,
                                fontSize: 16),
                          )),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Container(
                    height: 230,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: crbooks.length,
                        itemBuilder: ((context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewPdf(
                                          book: crbooks[index],
                                          url: crbooks[index].pdfurl))).then(
                                (value) {
                                  refresh();
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                  child: Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      height: 150,
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: host +
                                              crbooks[index].coverpageurl!,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      )),
                                  // if (per[index] != 0)
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: LinearPercentIndicator(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          percent: per[index].toDouble(),
                                          progressColor: Color(0xFF0D47A1),
                                          barRadius: Radius.circular(10),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        crbooks[index].title!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.asap(
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18)),
                                      )
                                    ],
                                  )
                                ],
                              )),
                            ),
                          );
                        })),
                  ),
                )
              ],
            ),
          )
        : Container();
  }
}
