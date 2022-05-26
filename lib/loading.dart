import 'dart:async';

import 'package:busapp/BusApp.dart';
import 'package:busapp/data/route_data.dart';

import 'package:busapp/home.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  final Stream<bool> _stream = (() {
    late final StreamController<bool> controller;
    controller = StreamController<bool>(
      onListen: () async {
        bool result = await RouteData.init();
        controller.add(result);
      },
    );
    return controller.stream;
  })();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Home();
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  children: [Text(BusApp.error), Text("${snapshot.error}")],
                ),
              ),
            );
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                break;
              case ConnectionState.waiting:
                return Scaffold(
                  body: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: BusApp.mainColor,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(BusApp.loading)
                    ],
                  )),
                );
              case ConnectionState.active:
                break;
              case ConnectionState.done:
                break;
            }
          }
          return Scaffold(
            body: Center(
              child: Column(
                children: [Text(BusApp.error), Text("${snapshot.error}")],
              ),
            ),
          );
        });
  }
}
