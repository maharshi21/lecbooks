import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:lecbooks/bookcard.dart';
import 'package:lecbooks/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes.dart';

class CustomSearchDelegateForSaved extends SearchDelegate {
// Demo list to show querying

  Future<List<Book>> getbooks(String? query) async {
    List<Book> saved = [];
    List<Book> results = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');
    print(username);
    var url = Uri.parse(host +
        '/api/saveds?populate[books][populate]=*&filters[users_permissions_user][username][\$eq]=$username');
    http.Response response = await http.get(url);

    var saveddata = jsonDecode(response.body);
    print(saveddata);
    for (var element in saveddata['data'][0]['attributes']['books']['data']) {
      saved.add(Book(
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
      ));
    }
    if (query != null) {
      results = saved
          .where((element) =>
              element.title!.toLowerCase().contains((query.toLowerCase())))
          .toList();
      return results;
    } else {
      return saved;
    }
  }

  @override
  // TODO: implement searchFieldStyle
  TextStyle? get searchFieldStyle => TextStyle(color: Color(0xFF0D47A1));
// first overwrite to
// clear the search text
  @override
  // TODO: implement searchFieldLabel
  String? get searchFieldLabel => 'Search in saved books';
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
    return FutureBuilder<List<Book>>(
        future: getbooks(query),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Book>? data = snapshot.data;
          return ListView.builder(
              itemCount: data?.length,
              itemBuilder: (context, index) {
                return BookCard(book: data![index]);
              });
        });
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty)
      return FutureBuilder<List<Book>>(
          future: getbooks(query),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            List<Book>? data = snapshot.data;
            if (data?.length == 0) {
              return Center(
                child: Text('No Books available for the search.'),
              );
            }
            return ListView.builder(
                itemCount: data?.length,
                itemBuilder: (context, index) {
                  return BookCard(book: data![index]);
                });
          });
    else
      return Container();
  }
}
