import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String baseURL = "http://192.168.1.7:1337/api/"; //emulator localhost
const Map<String, String> headers = {"Content-Type": "application/json"};

errorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Text(text),
    duration: const Duration(seconds: 2),
  ));
}

const String host = 'http://192.168.1.7:1337';
