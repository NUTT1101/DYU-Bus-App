import 'package:busapp/BusApp.dart';
import 'package:busapp/loading.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: BusApp.mainColor,
      splashColor: BusApp.splashColor,
    ),
    home: LoadingPage(title: "Loading"),
    debugShowCheckedModeBanner: false,
  ));
}
