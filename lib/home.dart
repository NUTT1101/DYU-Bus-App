import 'package:busapp/BusApp.dart';

import 'package:busapp/scaffold/appbar.dart';
import 'package:busapp/main_page/main_page.dart';
import 'package:busapp/scaffold/bottom.dart';
import 'package:flutter/material.dart';

import 'all_routes/all_routes.dart';
import 'dynamic_route/dynamic_route.dart';

class Home extends StatefulWidget {
  Home({Key? key, this.initPage = 0}) : super(key: key);
  final int initPage;

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  @override
  void initState() {
    super.initState();
    BusApp.currentPage = widget.initPage;
  }

  void update(int index) {
    setState(() => BusApp.currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: App(),
      body: IndexedStack(
        index: BusApp.currentPage,
        children: [Body(), DynamicRoute(), AllRoutes()],
      ),
      bottomNavigationBar: Bottom(
        update: update,
      ),
    );
  }
}
