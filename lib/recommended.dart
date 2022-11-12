import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecbooks/aboutbookpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

import 'classes.dart';
import 'globals.dart';

class Recommended extends StatefulWidget {
  const Recommended({Key? key}) : super(key: key);

  @override
  State<Recommended> createState() => _RecommendedState();
}

class _RecommendedState extends State<Recommended> {
  void initState() {
    super.initState();
    setdetails().then((_) => setrmndbooks());
  }

  List<Book> rmndbooks = [];
  bool isthereanycredentials = false;
  User user = User();
  int instid = 0;
  int courseid = 0;
  int semid = 0;
  Future setdetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');

    var url = Uri.parse(
        host + '/api/users?filters[username][\$eq]=$username&populate=*');
    http.Response response = await http.get(url);

    var data = jsonDecode(response.body);
    setState(() {
      user.id = data[0]['id'];
      user.name = data[0]['username'];
      if (data[0]['institute'] != null) instid = data[0]['institute']['id'];
      if (data[0]['course'] != null) courseid = data[0]['course']['id'];

      if (data[0]['sem'] != null) semid = data[0]['sem']['id'];
      if (semid != 0 || courseid != 0 || instid != 0)
        isthereanycredentials = true;
    });
  }

  Future setrmndbooks() async {
    if (semid != 0 && courseid != 0 && instid != 0) {
      var url = Uri.parse(host +
          '/api/books?filters[sem][id][\$eq]=$semid&filters[course][id][\$eq]=$courseid&filters[institute][id][\$eq]=$instid&populate=*');
      http.Response response = await http.get(url);
      var data = jsonDecode(response.body);

      print(data);
      setState(() {
        for (var element in data['data']) {
          rmndbooks.add(Book(
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
      });
    }

    if (semid == 0 && courseid != 0 && instid != 0) {
      var url = Uri.parse(host +
          '/api/books?filters[course][id][\$eq]=$courseid&filters[institute][id][\$eq]=$instid&populate=*');
      http.Response response = await http.get(url);
      var data = jsonDecode(response.body);

      print(data);
      setState(() {
        for (var element in data['data']) {
          rmndbooks.add(Book(
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
      });
    }

    if (semid == 0 && courseid == 0 && instid != 0) {
      var url = Uri.parse(
          host + '/api/books?filters[institute][id][\$eq]=$instid&populate=*');
      http.Response response = await http.get(url);
      var data = jsonDecode(response.body);

      print(data);
      setState(() {
        for (var element in data['data']) {
          rmndbooks.add(Book(
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
      });
    }
    if (semid == 0 && instid == 0 && courseid == 0) {}
  }

  @override
  Widget build(BuildContext context) {
    if (isthereanycredentials)
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Books as per your credentials :',
                    style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                height: 220,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: rmndbooks.length,
                    itemBuilder: ((context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AboutBookPage(
                                        book: rmndbooks[index],
                                      )));
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image:
                                          host + rmndbooks[index].coverpageurl!,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )),
                              Row(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: Center(
                                      child: Text(
                                        rmndbooks[index].title!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: GoogleFonts.asap(
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18)),
                                      ),
                                    ),
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
      );
    else
      return Container();
  }
}
