import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:lecbooks/bookcard.dart';
import 'package:lecbooks/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes.dart';
import 'coursepage.dart';

class CustomSearchDelegateForCourse extends SearchDelegate {
// Demo list to show querying

  Future<List> getcourses(String? query) async {
    List courses = [];
    List results = [];
    var url = Uri.parse(host + '/api/courses/');

    http.Response response = await http.get(url);
    var fetchData = jsonDecode(response.body);
    for (var course in fetchData['data']) {
      courses.add(course);
    }
    if (query != null) {
      results = courses
          .where((element) => element['attributes']['fullform']
              .toLowerCase()
              .contains((query.toLowerCase())))
          .toList();
      return results;
    } else {
      return courses;
    }
  }

  Widget coursecard(course, context) {
    return Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CoursePage(
                          id: course['id'],
                        )));
          },
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Colors.blue.shade700],
                  end: Alignment.centerLeft,
                  begin: Alignment.centerRight,
                ),
                color: Color(0xFF0D47A1),
              ),
              height: 120,
              width: MediaQuery.of(context).size.width * 0.30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        course['attributes']['name'],
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  Container(
                    child: Text(
                      course['attributes']['fullform'],
                      style: GoogleFonts.asap(
                          textStyle: TextStyle(color: Colors.white)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (course['attributes']['branch'] != null)
                    Container(
                      child: Text(
                        course['attributes']['branch'],
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                ],
              )),
        ));
  }

  @override
  // TODO: implement searchFieldStyle
  TextStyle? get searchFieldStyle => TextStyle(color: Color(0xFF0D47A1));
// first overwrite to
// clear the search text
  @override
  // TODO: implement searchFieldLabel
  String? get searchFieldLabel => 'Search by full name of course';
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(
          Icons.clear,
          color: Color(0xFF0D47A1),
        ),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(
        Icons.arrow_back_ios,
        color: Color(0xFF0D47A1),
      ),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(80.0),
      child: FutureBuilder<List>(
          future: getcourses(query),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            List? data = snapshot.data;
            List? widgetcourses = [];
            if (data!.isNotEmpty) {
              for (var i = 0; i < data.length / 3; i++) {
                List<Widget> rowcategory = [];

                for (var j = 0; j < 3 && (i * 3 + j) < data.length; j++) {
                  rowcategory.add(
                      Container(child: coursecard(data[i * 3 + j], context)));
                }
                widgetcourses.add(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: rowcategory,
                ));
              }
            }
            return ListView.builder(
                itemCount: widgetcourses.length,
                itemBuilder: (context, index) {
                  return widgetcourses[index];
                });
          }),
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty)
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: FutureBuilder<List>(
            future: getcourses(query),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              List? data = snapshot.data;
              List? widgetcourses = [];
              if (data!.isNotEmpty) {
                for (var i = 0; i < data.length / 3; i++) {
                  List<Widget> rowcategory = [];

                  for (var j = 0; j < 3 && (i * 3 + j) < data.length; j++) {
                    rowcategory.add(
                        Container(child: coursecard(data[i * 3 + j], context)));
                  }
                  widgetcourses.add(Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: rowcategory,
                  ));
                }
              }
              return ListView.builder(
                  itemCount: widgetcourses.length,
                  itemBuilder: (context, index) {
                    return widgetcourses[index];
                  });
            }),
      );
    else
      return Container();
  }
}
