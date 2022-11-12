import 'dart:convert';
import 'dart:ffi';

import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'package:http/http.dart' as http;
import 'package:lecbooks/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPdf extends StatefulWidget {
  final book;
  final url;
  const ViewPdf({Key? key, required this.book, required this.url})
      : super(key: key);

  @override
  State<ViewPdf> createState() => _ViewPdfState(this.book);
}

class _ViewPdfState extends State<ViewPdf> {
  late PdfViewerController _pdfViewerController;
  final book;
  _ViewPdfState(this.book);
  bool isdemo = false;
  @override
  initState() {
    // TODO: implement initState
    super.initState();
    securescreen();
    isdemopdf();
    _pdfViewerController = PdfViewerController();
    jumpto();
  }

  Future securescreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  void isdemopdf() {
    setState(() {
      if (book.demopdfurl == widget.url) isdemo = true;
    });
  }

  Future contread() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');
    var url = Uri.parse(host +
        '/api/continue-readings?filters[users_permissions_user][username][\$eq]=$username');
    http.Response getresponse = await http.get(url);
    var data = jsonDecode(getresponse.body);
    print(data);
    var id = book.id;
    List ids = [];
    if (data['data'].isNotEmpty) {
      var crid = data['data'][0]['id'];
      var url = Uri.parse(host + '/api/continue-readings/$crid');
      var url2 = Uri.parse(host +
          '/api/continue-readings?populate[books][populate]=*&filters[users_permissions_user][username][\$eq]=$username');

      http.Response response2 = await http.get(url2);
      var crdata = jsonDecode(response2.body);
      print(crdata);
      for (var element in crdata['data'][0]['attributes']['books']['data']) {
        ids.add(element['id']);
      }
      print(ids);

      if (!ids.contains(id)) {
        ids.insert(0, id);
        http.Response response = await http.put(url,
            headers: headers,
            body: jsonEncode({
              'data': {'books': ids}
            }));
        var data = jsonDecode(response.body);
        print(data);

        if (response.statusCode != 200) {
          var data = jsonDecode(response.body);

          errorSnackBar(context, data.values.last['message']);
        }
      } else {
        ids.remove(id);
        ids.insert(0, id);
        http.Response response = await http.put(url,
            headers: headers,
            body: jsonEncode({
              'data': {'books': ids}
            }));
        var data = jsonDecode(response.body);
        print(data);

        if (response.statusCode != 200) {
          var data = jsonDecode(response.body);

          errorSnackBar(context, data.values.last['message']);
        }
      }
    } else {
      ids.add(id);
      var url = Uri.parse(host + '/api/continue-readings');
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
      }
    }
  }

  Future jumpto() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var user = preferences.getString('username');
    var page = preferences.getInt('lastreadpage' + widget.book.title + user!);
    if (page != null) _pdfViewerController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0D47A1),
          elevation: 0,
          title: Text(
            widget.book.title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
            child: SfPdfViewer.network(
          host + widget.url,
          controller: _pdfViewerController,
          onPageChanged: (details) async {
            if (!details.isFirstPage) {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();

              var user = preferences.getString('username');

              preferences.setInt('totalpage' + widget.book.title + user!,
                  _pdfViewerController.pageCount);
              preferences.setInt('lastreadpage' + widget.book.title + user,
                  details.newPageNumber);
              contread();
            }
          },
        )));
  }
}
