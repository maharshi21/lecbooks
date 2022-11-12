import 'dart:ffi';
import 'dart:math';

import 'package:filter_list/filter_list.dart';

import 'package:appbar_animated/appbar_animated.dart';
import 'package:flutter/material.dart';
import 'package:lecbooks/globals.dart';
import 'package:lecbooks/homePage.dart';
import 'package:shimmer/shimmer.dart';
import 'classes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lecbooks/bookcard.dart';

import 'loadingbookcard.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key, required this.id}) : super(key: key);
  final id;
  @override
  State<CoursePage> createState() => _CoursePageState(id);
}

var course;

class _CoursePageState extends State<CoursePage> {
  final id;
  _CoursePageState(this.id);

  Future getcourse(id) async {
    var url = Uri.parse(host + '/api/courses/$id?populate=*');

    http.Response response = await http.get(url);
    setState(() {
      var coursedata = jsonDecode(response.body);

      course = coursedata['data']['attributes'];
      if (course != null) {
        for (var element in course['subjects']['data']) {
          subjects.add(Subject(name: element['attributes']['name']));
        }
        for (var element in course['sems']['data']) {
          sems.add(Sem(number: (element['attributes']['Semester']).toString()));
        }
        for (var element in course['institutes']['data']) {
          institutes.add(Institute(name: element['attributes']['name']));
        }
      }
    });
  }

  Future getbooks() async {
    var url =
        Uri.parse(host + '/api/books?populate=*&filters[course][id][\$eq]=$id');

    http.Response response = await http.get(url);

    setState(() {
      var data = jsonDecode(response.body);
 print(data);
      for (var element in data!['data']) {
        allBooks.add(Book(
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
          subject: element['attributes']['subject']['data']['attributes']
              ['name'],
          ratings: element['attributes']['ratings'],
          sem: element['attributes']['sem']['data']['attributes']['Semester']
              .toString(),
        ));
        _isloading = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getcourse(id);
    getbooks();
  }

  List<Subject> subjects = [];
  List<Sem> sems = [];
  List<Institute> institutes = [];
  List<Book> allBooks = [];
  List<Book> filteredBooks = [];

  List<Subject>? selectedSubjectsList = [];
  List<Sem>? selectedSemsList = [];
  List<Institute>? selectedInstitutesList = [];
  bool _isloading = true;
  void _openFilterInstituteDialog() async {
    await FilterListDialog.display<Institute>(
      context,
      hideSelectedTextCount: true,

      themeData: FilterListThemeData(context,
          headerTheme: HeaderThemeData(
              searchFieldIconColor: Color(0xFF0D47A1),
              headerTextStyle: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          controlButtonBarTheme: ControlButtonBarThemeData(context,
              controlButtonTheme: ControlButtonThemeData(
                  primaryButtonBackgroundColor: Color(0xFF0D47A1),
                  textStyle: TextStyle(color: Color(0xFF0D47A1))))),
      headlineText: 'Select Institute',
      height: 500,
      listData: institutes,
      selectedListData: selectedInstitutesList,
      choiceChipLabel: (item) => item!.name,
      validateSelectedItem: (list, val) => list!.contains(val),
      controlButtons: [ControlButtonType.All, ControlButtonType.Reset],
      onItemSearch: (inst, query) {
        /// When search query change in search bar then this method will be called
        ///
        /// Check if items contains query
        return inst.name!.toLowerCase().contains(query.toLowerCase());
      },

      onApplyButtonClick: (list) {
        setState(() {
          selectedInstitutesList = List.from(list!);
          filterbooks();
        });
        Navigator.pop(context);
      },

      /// uncomment below code to create custom choice chip
      choiceChipBuilder: (context, item, isSelected) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              color: isSelected! ? Color(0xFF0D47A1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                style: BorderStyle.solid,
                color: isSelected ? Color(0xFF0D47A1) : Colors.grey[700]!,
              )),
          child: Text(
            item.name,
            style:
                TextStyle(color: isSelected ? Colors.white : Colors.grey[700]),
          ),
        );
      },
    );
  }

  void _openFilterSemDialog() async {
    await FilterListDialog.display<Sem>(
      context,
      hideSelectedTextCount: true,

      themeData: FilterListThemeData(context,
          headerTheme: HeaderThemeData(
              searchFieldIconColor: Color(0xFF0D47A1),
              headerTextStyle: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          controlButtonBarTheme: ControlButtonBarThemeData(context,
              controlButtonTheme: ControlButtonThemeData(
                  primaryButtonBackgroundColor: Color(0xFF0D47A1),
                  textStyle: TextStyle(color: Color(0xFF0D47A1))))),
      headlineText: 'Select Semester',
      height: 500,
      listData: sems,
      selectedListData: selectedSemsList,
      choiceChipLabel: (item) => item!.number,
      validateSelectedItem: (list, val) => list!.contains(val),
      controlButtons: [ControlButtonType.All, ControlButtonType.Reset],
      onItemSearch: (sem, query) {
        /// When search query change in search bar then this method will be called
        ///
        /// Check if items contains query
        return sem.number!.toLowerCase().contains(query.toLowerCase());
      },

      onApplyButtonClick: (list) {
        setState(() {
          selectedSemsList = List.from(list!);

          filterbooks();
        });
        Navigator.pop(context);
      },

      /// uncomment below code to create custom choice chip
      choiceChipBuilder: (context, item, isSelected) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              color: isSelected! ? Color(0xFF0D47A1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Color(0xFF0D47A1) : Colors.grey[700]!,
              )),
          child: Text(
            item!.number,
            style:
                TextStyle(color: isSelected ? Colors.white : Colors.grey[700]),
          ),
        );
      },
    );
  }

  void _openFilterSubjectDialog() async {
    await FilterListDialog.display<Subject>(
      context,
      hideSelectedTextCount: true,

      themeData: FilterListThemeData(context,
          headerTheme: HeaderThemeData(
              searchFieldIconColor: Color(0xFF0D47A1),
              headerTextStyle: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          controlButtonBarTheme: ControlButtonBarThemeData(context,
              controlButtonTheme: ControlButtonThemeData(
                  primaryButtonBackgroundColor: Color(0xFF0D47A1),
                  textStyle: TextStyle(color: Color(0xFF0D47A1))))),
      headlineText: 'Select Subjects',
      height: 500,
      listData: subjects,
      selectedListData: selectedSubjectsList,
      choiceChipLabel: (item) => item!.name,
      validateSelectedItem: (list, val) => list!.contains(val),
      controlButtons: [ControlButtonType.All, ControlButtonType.Reset],
      onItemSearch: (subject, query) {
        /// When search query change in search bar then this method will be called
        ///
        /// Check if items contains query
        return subject.name!.toLowerCase().contains(query.toLowerCase());
      },

      onApplyButtonClick: (list) {
        setState(() {
          selectedSubjectsList = List.from(list!);
          filterbooks();
        });
        Navigator.pop(context);
      },

      /// uncomment below code to create custom choice chip
      choiceChipBuilder: (context, item, isSelected) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              color: isSelected! ? Color(0xFF0D47A1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Color(0xFF0D47A1) : Colors.grey[700]!,
              )),
          child: Text(
            item.name,
            style:
                TextStyle(color: isSelected ? Colors.white : Colors.grey[700]),
          ),
        );
      },
    );
  }

  Widget filterbooks() {
    List<Book> l1 = allBooks;
    List<Book> l2 = allBooks;
    List<Book> l3 = allBooks;

    if (selectedInstitutesList!.isNotEmpty)
      for (var inst in selectedInstitutesList!) {
        l1 = allBooks
            .where((element) => (element.institute == inst.name))
            .toList();
      }
    if (selectedSubjectsList!.isNotEmpty)
      for (var sub in selectedSubjectsList!) {
        l2 =
            allBooks.where((element) => (element.subject == sub.name)).toList();
      }
    if (selectedSemsList!.isNotEmpty)
      for (var sem in selectedSemsList!) {
        l3 = allBooks.where((element) => (element.sem == sem.number)).toList();
      }

    filteredBooks = l1
        .where((element) => (l2.contains(element) && l3.contains(element)))
        .toList();
    return Container(
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
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                      child: Container(child: LoadingBookCard()),
                    );
                  }))
          : ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 7.0, left: 10, right: 10),
                  child: Container(
                    child: BookCard(book: filteredBooks[index]),
                  ),
                );
              }),
    );
  }

  String dropdownvalue = 'Subjects';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaffoldLayoutBuilder(
        backgroundColorAppBar:
            const ColorBuilder(Colors.transparent, Color(0xFF0D47A1)),
        textColorAppBar: const ColorBuilder(Color(0xFF0D47A1), Colors.white),
        appBarBuilder: _appBar,
        child: SingleChildScrollView(
          child: Stack(children: [
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.13,
                ),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      color: Colors.grey[300],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            child: Text(
                              'Filter By :',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          TextButton(
                            onPressed: _openFilterSubjectDialog,
                            child: Row(
                              children: [
                                Text(
                                  "Subjects",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 18,
                                )
                              ],
                            ),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xFF0D47A1))),
                            // color: Colors.blue,
                          ),
                          TextButton(
                            onPressed: _openFilterSemDialog,
                            child: Row(
                              children: [
                                Text(
                                  "Semesters",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 18,
                                )
                              ],
                            ),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xFF0D47A1))),
                            // color: Colors.blue,
                          ),
                          TextButton(
                            onPressed: _openFilterInstituteDialog,
                            child: Row(
                              children: [
                                Text(
                                  "Institutes",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 18,
                                )
                              ],
                            ),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xFF0D47A1))),
                            // color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [filterbooks()],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context, ColorAnimated colorAnimated) {
    return AppBar(
      backgroundColor: colorAnimated.background,
      elevation: 0,
      title: Text(
        course != null ? course['name'] : 'loading...',
        style: TextStyle(
          color: colorAnimated.color,
        ),
      ),
      leading: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MyHomePage())).then((_) {
            setState(() {});
          });
        },
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colorAnimated.color,
        ),
      ),
    );
  }
}
