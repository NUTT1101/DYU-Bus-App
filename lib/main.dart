import 'package:busapp/loading.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    home: LoadingPage(title: "Loading"),
    debugShowCheckedModeBanner: false,
  ));
}
