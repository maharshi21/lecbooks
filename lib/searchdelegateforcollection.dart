import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:lecbooks/bookcard.dart';
import 'package:lecbooks/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes.dart';

class CustomSearchDelegateForCollection extends SearchDelegate {
// Demo list to show querying

  Future<List<Book>> getbooks(String? query) async {
    List<Book> collection = [];
    List<Book> results = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var username = pref.getString('username');

    var url = Uri.parse(host +
        '/api/users?filters[username][\$eq]=$username&populate[books][populate]=*');
    http.Response response = await http.get(url);

    var data = jsonDecode(response.body);
    for (var element in data[0]['books']) {
      collection.add(Book(
        id: element['id'],
        authorname: element['author']['name'],
        price: (element['price'])!.toDouble(),
        publishdate: element['publishdate'].split('-')[2] +
            '/' +
            element['publishdate'].split('-')[1] +
            '/' +
            element['publishdate'].split('-')[0],
        category: element['category'],
        pdfurl: element['fullpdf'][0]['url'],
        demopdfurl: element['demopdf'][0]['url'],
        coverpageurl: element['coverpage'][0]['url'],
        title: element['title'],
        subtitle: element['subtitle'],
        institute: element['institute']['name'],
        subject: element['subject']['name'],
        ratings: element['ratings'],
        sem: element['sem']['Semester'].toString(),
      ));
    }
    if (query != null) {
      results = collection
          .where((element) =>
              element.title!.toLowerCase().contains((query.toLowerCase())))
          .toList();
      return results;
    } else {
      return collection;
    }
  }

  @override
  // TODO: implement searchFieldStyle
  TextStyle? get searchFieldStyle => TextStyle(color: Color(0xFF0D47A1));
// first overwrite to
// clear the search text
  @override
  // TODO: implement searchFieldLabel
  String? get searchFieldLabel => 'Search in your collection';
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
