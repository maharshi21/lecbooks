import 'dart:convert';
import 'dart:ui';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:appbar_animated/appbar_animated.dart';
import 'package:flutter/material.dart';
import 'package:lecbooks/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes.dart';
import 'globals.dart';
import 'package:search_choices/search_choices.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getallinst();
    getuser().then((_) => getallcourse()).then((_) => getallsem());
  }

  TextEditingController _usernamecontroller = TextEditingController();

  bool editusername = false;
  bool editinstitute = false;
  bool editcourse = false;
  bool editsem = false;

  User user = User();
  List<Institute> allinst = [];
  List<DropdownMenuItem<String>> allinstname = [];
  List<DropdownMenuItem<String>> allcourse = [];
  List<DropdownMenuItem<String>> allsem = [];

  Future getallinst() async {
    if (!this.mounted) return;
    var url = Uri.parse(host + '/api/institutes');
    http.Response response = await http.get(url);

    var data = jsonDecode(response.body);
    setState(() {
      for (var element in data['data']) {
        allinst.add(Institute(
            name: element['attributes']['name'],
            fullname: element['attributes']['fullform']));
        allinstname.add(DropdownMenuItem(
            value: element['attributes']['fullform'] +
                '(' +
                element['attributes']['name'] +
                ')',
            child: Text(element['attributes']['fullform'] +
                '(' +
                element['attributes']['name'] +
                ')')));
      }
    });
  }

  Future getallcourse() async {
    if (user.institute == null) return;
    var instsort = (user.institute)!.split('(')[0];
    print(instsort);
    var url = Uri.parse(
        host + '/api/institutes?filters[fullform][\$eq]=$instsort&populate=*');
    http.Response response = await http.get(url);

    var data = jsonDecode(response.body);
    if (!this.mounted) return;
    setState(() {
      for (var element in data['data'][0]['attributes']['courses']['data']) {
        if (element['attributes']['branch'] != null)
          allcourse.add(DropdownMenuItem(
            child: Text(element['attributes']['fullform'] +
                '(' +
                element['attributes']['branch'] +
                ')'),
            value: (element['attributes']['fullform'] +
                '(' +
                element['attributes']['branch'] +
                ')'),
          ));
        else
          allcourse.add(DropdownMenuItem(
            child: Text(element['attributes']['fullform'] +
                '(' +
                element['attributes']['name'] +
                ')'),
            value: (element['attributes']['fullform'] +
                '(' +
                element['attributes']['name'] +
                ')'),
          ));
      }
    });
  }

  Future getallsem() async {
    if (!this.mounted) return;

    if (user.institute == null) return;
    if (user.course == null) return;
    print(user.course);
    var coursesort = (user.course)!.split('(')[0];
    var url = Uri.parse(
        host + '/api/courses?filters[fullform][\$eq]=$coursesort&populate=*');
    http.Response response = await http.get(url);

    var data = jsonDecode(response.body);
    setState(() {
      for (var element in data['data'][0]['attributes']['sems']['data']) {
        allsem.add(DropdownMenuItem(
          child: Text(element['attributes']['Semester'].toString()),
          value: element['attributes']['Semester'].toString(),
        ));
      }
    });
  }

  Future setinst() async {
    if (!this.mounted) return;

    var id = user.id;
    if (user.institute == null) {
      var url = Uri.parse(host + '/api/users/$id');
      http.Response response = await http.put(url,
          headers: headers,
          body: jsonEncode({'institute': [], 'course': [], 'sem': []}));
      return;
    }
    var instsort = (user.institute)!.split('(')[0];
    var url2 =
        Uri.parse(host + '/api/institutes?filters[fullform][\$eq]=$instsort');
    http.Response response2 = await http.get(url2);
    Map responseMap2 = jsonDecode(response2.body);
    var instid = responseMap2['data'][0]['id'];

    var url = Uri.parse(host + '/api/users/$id');
    http.Response response = await http.put(url,
        headers: headers,
        body: jsonEncode({
          'institute': [instid]
        }));
    Map responseMap = jsonDecode(response.body);
  }

  Future setcourse() async {
    if (!this.mounted) return;

    if (user.institute == null)
      return errorSnackBar(context, 'please select a institute.');
    var id = user.id;
    if (user.course == null) {
      var url = Uri.parse(host + '/api/users/$id');
      http.Response response = await http.put(url,
          headers: headers, body: jsonEncode({'course': [], 'sem': []}));
      return;
    }
    var coursesort = (user.course)!.split('(')[0];
    var url2 =
        Uri.parse(host + '/api/courses?filters[fullform][\$eq]=$coursesort');
    http.Response response2 = await http.get(url2);
    Map responseMap2 = jsonDecode(response2.body);
    var courseid = responseMap2['data'][0]['id'];

    var url = Uri.parse(host + '/api/users/$id');
    http.Response response = await http.put(url,
        headers: headers,
        body: jsonEncode({
          'course': [courseid]
        }));
    Map responseMap = jsonDecode(response.body);
  }

  Future setsem() async {
    if (!this.mounted) return;

    if (user.institute == null)
      return errorSnackBar(context, 'please select a institute.');
    if (user.course == null) {
      return;
    }
    var id = user.id;
    if (user.sem == null) {
      var url = Uri.parse(host + '/api/users/$id');
      http.Response response =
          await http.put(url, headers: headers, body: jsonEncode({'sem': []}));
      return;
    }
    var sem = int.parse(user.sem!);

    var url2 = Uri.parse(host + '/api/sems?filters[Semester][\$eq]=$sem');
    http.Response response2 = await http.get(url2);
    Map responseMap2 = jsonDecode(response2.body);
    var semid = responseMap2['data'][0]['id'];

    var url = Uri.parse(host + '/api/users/$id');
    http.Response response = await http.put(url,
        headers: headers,
        body: jsonEncode({
          'sem': [semid]
        }));
    Map responseMap = jsonDecode(response.body);
  }

  Future getuser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');

    var url = Uri.parse(
        host + '/api/users?filters[username][\$eq]=$username&populate=*');
    http.Response response = await http.get(url);

    var data = jsonDecode(response.body);
    if (!this.mounted) return;
    setState(() {
      user.id = data[0]['id'];
      user.name = data[0]['username'];
      _usernamecontroller.text = user.name!;
      if (data[0]['institute'] != null)
        user.institute = data[0]['institute']['fullform'] +
            '(' +
            data[0]['institute']['name'] +
            ')';
      if (data[0]['course'] != null)
        user.course = data[0]['course']['fullform'] +
            '(' +
            data[0]['course']['branch'] +
            ')';

      if (data[0]['sem'] != null)
        user.sem = data[0]['sem']['Semester'].toString();
    });
  }

  Future setusername() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');
    var id = user.id;
    var url = Uri.parse(host + '/api/users/$id');
    http.Response response = await http.put(url,
        headers: headers, body: jsonEncode({'username': user.name}));
    Map responseMap = jsonDecode(response.body);

    if (response.statusCode != 200) {
      errorSnackBar(context, responseMap.values.last['message']);
      if (!this.mounted) return;

      setState(() {
        _usernamecontroller.text = username!;
      });
    } else {
      pref.setString('username', user.name!);
    }
  }

  Future setloggedout(id) async {
    var url = Uri.parse(host + '/api/users/$id');

    http.Response response = await http.put(url,
        headers: headers, body: jsonEncode({'isloggedin': false}));
    var data = jsonDecode(response.body);
  }

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
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.08,
                    ),
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height),
                    color: Colors.white,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 20.0, right: 20, left: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.perm_identity_rounded,
                                size: 50,
                                color: Color(0xFF0D47A1),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20),
                                  child: TextFormField(
                                    style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 25,
                                            color: Color(0xFF0D47A1),
                                            fontWeight: FontWeight.w800)),
                                    controller: _usernamecontroller,
                                    enabled: editusername,
                                    onChanged: (value) {
                                      user.name = value;
                                    },
                                    decoration: InputDecoration(
                                        disabledBorder: InputBorder.none),
                                  ),
                                ),
                              ),
                              if (editusername == false)
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      editusername = true;
                                    });
                                  },
                                ),
                              if (editusername == true)
                                IconButton(
                                  icon: Icon(Icons.check_sharp, size: 20),
                                  onPressed: () {
                                    setusername();
                                    setState(() {
                                      editusername = false;
                                    });
                                  },
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                            child: Center(
                                child: Container(
                              color: Color(0xFF0D47A1),
                              height: 1,
                            )),
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.24,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Institute',
                                        style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFF0D47A1),
                                              fontWeight: FontWeight.w700),
                                        )),
                                    Text(
                                      ':',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF0D47A1),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              if (editinstitute == false)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20),
                                    child: Text(
                                      user.institute != null
                                          ? user.institute!
                                          : 'add institute',
                                      style: GoogleFonts.asap(
                                          textStyle: TextStyle(fontSize: 18)),
                                    ),
                                  ),
                                ),
                              if (editinstitute == false)
                                IconButton(
                                  icon: Icon(
                                    user.institute != null
                                        ? Icons.edit
                                        : Icons.add_outlined,
                                    size: 15,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      editinstitute = true;
                                    });
                                  },
                                ),
                              if (editinstitute == true)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: SearchChoices.single(
                                    items: allinstname,
                                    value: user.institute,
                                    hint: "Select one",
                                    searchHint: "Select one",
                                    onChanged: (value) {
                                      setState(() {
                                        user.institute = value;
                                        allcourse.clear();
                                        allsem.clear();
                                        getallcourse();
                                        print(allcourse);
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                              if (editinstitute == true)
                                IconButton(
                                  icon: Icon(Icons.check_sharp, size: 20),
                                  onPressed: () {
                                    setinst();
                                    setState(() {
                                      user.course = null;
                                      user.sem = null;
                                      editinstitute = false;
                                    });
                                  },
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.24,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Course',
                                        style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFF0D47A1),
                                              fontWeight: FontWeight.w700),
                                        )),
                                    Text(
                                      ':',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF0D47A1),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              if (editcourse == false)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20),
                                    child: Text(
                                      user.course != null
                                          ? user.course!
                                          : 'add course',
                                      style: GoogleFonts.asap(
                                          textStyle: TextStyle(fontSize: 18)),
                                    ),
                                  ),
                                ),
                              if (editcourse == false)
                                IconButton(
                                  icon: Icon(
                                    user.course != null
                                        ? Icons.edit
                                        : Icons.add_outlined,
                                    size: 15,
                                  ),
                                  onPressed: () {
                                    if (user.institute == null)
                                      return errorSnackBar(context,
                                          'please select a institute.');
                                    if (allcourse.isEmpty) {
                                      return errorSnackBar(
                                          context, 'no course available.');
                                    }
                                    setState(() {
                                      editcourse = true;
                                    });
                                  },
                                ),
                              if (editcourse == true)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: SearchChoices.single(
                                    items: allcourse,
                                    value: user.course,
                                    hint: "Select one",
                                    searchHint: "Select one",
                                    onTap: () {
                                      if (allcourse.isEmpty) {
                                        return errorSnackBar(
                                            context, 'no course available.');
                                      }
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        user.course = value;
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                              if (editcourse == true)
                                IconButton(
                                  icon: Icon(Icons.check_sharp, size: 20),
                                  onPressed: () {
                                    setcourse();
                                    setState(() {
                                      user.sem = null;

                                      allsem.clear();
                                      getallsem();
                                      print('$allsem ok');
                                      editcourse = false;
                                    });
                                  },
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.24,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Semester',
                                        style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFF0D47A1),
                                              fontWeight: FontWeight.w700),
                                        )),
                                    Text(
                                      ':',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF0D47A1),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              if (editsem == false)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20),
                                    child: Text(
                                      user.sem != null
                                          ? user.sem!
                                          : 'add Semester',
                                      style: GoogleFonts.asap(
                                          textStyle: TextStyle(fontSize: 18)),
                                    ),
                                  ),
                                ),
                              if (editsem == false)
                                IconButton(
                                  icon: Icon(
                                    user.sem != null
                                        ? Icons.edit
                                        : Icons.add_outlined,
                                    size: 15,
                                  ),
                                  onPressed: () {
                                    if (user.institute == null)
                                      return errorSnackBar(context,
                                          'please select a institute.');

                                    if (user.course == null)
                                      return errorSnackBar(
                                          context, 'please select a course.');
                                    setState(() {
                                      editsem = true;
                                    });
                                  },
                                ),
                              if (editsem == true)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: SearchChoices.single(
                                    items: allsem,
                                    value: user.sem,
                                    hint: "Select one",
                                    searchHint: "Select one",
                                    onTap: () {
                                      if (allcourse.isEmpty) {
                                        return errorSnackBar(
                                            context, 'no course available.');
                                      }
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        user.sem = value;
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                              if (editsem == true)
                                IconButton(
                                  icon: Icon(Icons.check_sharp, size: 20),
                                  onPressed: () {
                                    setsem();
                                    setState(() {
                                      editsem = false;
                                    });
                                  },
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  color: Color(0xFF0D47A1),
                                  height: 1,
                                )),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 15),
                                    child: Text('Your Collection',
                                        style: GoogleFonts.asap(
                                          textStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(
                              child: Container(
                            color: Color(0xFF0D47A1),
                            height: 1,
                          )),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 15),
                                    child: Text('Your Saved books',
                                        style: GoogleFonts.asap(
                                          textStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(
                              child: Container(
                            color: Color(0xFF0D47A1),
                            height: 1,
                          )),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        extendBody: true,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 45,
                width: 130,
                margin: EdgeInsets.only(left: 20, right: 10, bottom: 15),
                child: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(0)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.transparent,
                      )),
                  onPressed: () async {
                    if (await confirm(
                      context,
                      title: const Text('Confirm',
                          style: TextStyle(color: Color(0xFF0D47A1))),
                      content: const Text('Would you like to LogOut?'),
                      textOK: const Text(
                        'Yes',
                        style: TextStyle(color: Color(0xFF0D47A1)),
                      ),
                      textCancel: const Text('No',
                          style: TextStyle(color: Color(0xFF0D47A1))),
                    )) {
                      await setloggedout(user.id);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('loggedin', false);
                      prefs.setString('username', '');
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => LoginPage()));
                    }
                    return;
                  },
                  child: Ink(
                    height: 43,
                    width: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: GradientColors.skyLine,
                        end: Alignment.centerLeft,
                        begin: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.logout_outlined,
                                    size: 25,
                                  ),
                                ),
                                Text('LogOut',
                                    style: GoogleFonts.asap(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 17),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
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
          child: Text(user.name != null ? 'Hi,  ' + user.name! : 'Hi,',
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                    color: colorAnimated.color,
                    fontSize: 23,
                    fontWeight: FontWeight.w800),
              )),
        ),
      ),
    );
  }
}
