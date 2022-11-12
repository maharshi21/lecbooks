import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lecbooks/coursepage.dart';
import 'package:lecbooks/globals.dart';
import 'package:lecbooks/searchdelegateforcourse.dart';
import 'package:shimmer/shimmer.dart';

class ExplorebyCoursesfront extends StatefulWidget {
  const ExplorebyCoursesfront({Key? key}) : super(key: key);

  @override
  State<ExplorebyCoursesfront> createState() => _ExplorebyCoursesfrontState();
}

class _ExplorebyCoursesfrontState extends State<ExplorebyCoursesfront> {
  List courses = [];
  int present = 3;
  bool _isloading = true;
  List<Widget> loadingwidgetcourses = [];
  @override
  void initState() {
    super.initState();
    getcourses();
  }

  void setloadingwidget() {
    for (var i = 0; i < 3; i++) {
      List<Widget> rowcategory = [];

      for (var j = 0; j < 3; j++) {
        rowcategory.add(Container(child: loadingcoursecard()));
      }
      loadingwidgetcourses.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: rowcategory,
      ));
    }
  }

  Future getcourses() async {
    setloadingwidget();
    var url = Uri.parse(host + '/api/courses/');

    http.Response response = await http.get(url);
    var fetchData = jsonDecode(response.body);
    setState(() {
      for (var course in fetchData['data']) {
        courses.add(course);
      }
      _isloading = false;
      for (var i = 0; i < courses.length / 3; i++) {
        List<Widget> rowcategory = [];

        for (var j = 0; j < 3 && (i * 3 + j) < courses.length; j++) {
          rowcategory.add(Container(child: coursecard(courses, i * 3 + j)));
        }
        widgetcourses.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rowcategory,
        ));
      }
    });
  }

  Widget coursecard(List courses, int index) {
    return Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CoursePage(
                          id: courses[index]['id'],
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
                        courses[index]['attributes']['name'],
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
                      courses[index]['attributes']['fullform'],
                      style: GoogleFonts.asap(
                          textStyle: TextStyle(color: Colors.white)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (courses[index]['attributes']['branch'] != null)
                    Container(
                      child: Text(
                        courses[index]['attributes']['branch'],
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                ],
              )),
        ));
  }

  Widget loadingcoursecard() {
    return Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
          width: 120,
        ));
  }

  List<Widget> widgetcourses = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Explore by Courses :',
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ),
              ),
              IconButton(
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: CustomSearchDelegateForCourse());
                  },
                  icon: Icon(
                    Icons.search,
                    color: Color(0xFF0D47A1),
                  ))
            ],
          ),
          Container(
            height: 360,
            child: _isloading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    enabled: true,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: loadingwidgetcourses.length,
                        itemBuilder: (context, index) {
                          return loadingwidgetcourses[index];
                        }))
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widgetcourses.length,
                    itemBuilder: (context, index) {
                      return widgetcourses.isNotEmpty
                          ? widgetcourses[index]
                          : Container();
                    }),
          ),
        ],
      ),
    );
  }
}
