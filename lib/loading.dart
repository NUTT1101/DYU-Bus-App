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
        controller.close();
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
                  body: Center(child: LoadingWidget()),
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

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key, this.space = 25}) : super(key: key);

  final double space;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: BusApp.mainColor,
        ),
        SizedBox(
          height: space,
        ),
        Text(BusApp.loading)
      ],
    );
  }
}
