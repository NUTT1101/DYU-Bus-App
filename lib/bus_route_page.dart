import 'dart:async';
import 'dart:ffi';

import 'package:busapp/BusApp.dart';

import 'package:busapp/data/route_data.dart';
import 'package:busapp/loading.dart';

import 'package:busapp/scaffold/appbar.dart';
import 'package:busapp/webview_page.dart';
import 'package:flutter/material.dart';

import 'data/model/bus_route.dart';

class BusRoutePage extends StatefulWidget {
  BusRoutePage({
    Key? key,
    required this.thisPageBusRoute,
  }) : super(key: key);

  final BusRoute thisPageBusRoute;

  @override
  State<BusRoutePage> createState() => _BusRoutePageState();
}

class _BusRoutePageState extends State<BusRoutePage> {
  late Widget _currentPage;
  late int _weekdayIndex;
  late String _weekday;

  _checkWeekday() {
    if (_weekdayIndex > 6) {
      _weekdayIndex = 0;
    } else if (_weekdayIndex < 0) {
      _weekdayIndex = 6;
    }
  }

  @override
  void initState() {
    super.initState();
    _weekdayIndex = BusApp.getWeekday();
    _weekday = BusApp.day[_weekdayIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: App(
        header: GestureDetector(
          child: Icon(
            RouteData.storage.getItem(widget.thisPageBusRoute.getRouteId) ==
                    null
                ? Icons.favorite_border
                : Icons.favorite,
            color: Colors.redAccent,
          ),
          onTap: () {
            setState(() {
              if (RouteData.storage
                      .getItem(widget.thisPageBusRoute.getRouteId) !=
                  null) {
                RouteData.storage
                    .setItem(widget.thisPageBusRoute.getRouteId, null);
              } else {
                RouteData.storage
                    .setItem(widget.thisPageBusRoute.getRouteId, true);
              }
              RouteData.favoriteController.add(1);
            });
          },
        ),
        title: widget.thisPageBusRoute.getRouteName["zh_tw"],
        footer: GestureDetector(
          child: const Icon(
            Icons.attach_money,
            color: Colors.amberAccent,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: App(
                    title: widget.thisPageBusRoute.getRouteName["zh_tw"]! +
                        BusApp.ticket,
                    header: Text(""),
                    footer: Text("")),
                body: WebViewPage(
                  url: widget.thisPageBusRoute.getTicket,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: const Icon(Icons.keyboard_arrow_left, size: 35),
                  onTap: () {
                    setState(() {
                      _weekdayIndex = _weekdayIndex - 1;
                      _checkWeekday();
                      _currentPage = RouteData.getTimeTable(
                          widget.thisPageBusRoute, _weekdayIndex);
                      _weekday = BusApp.day[_weekdayIndex];
                    });
                  },
                ),
                Text(
                  _weekday,
                  style: TextStyle(fontSize: 25),
                ),
                GestureDetector(
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    size: 35,
                  ),
                  onTap: () {
                    setState(() {
                      _weekdayIndex = _weekdayIndex + 1;
                      _checkWeekday();
                      _currentPage = RouteData.getTimeTable(
                          widget.thisPageBusRoute, _weekdayIndex);
                      _weekday = BusApp.day[_weekdayIndex];
                    });
                  },
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  StreamBuilder(
                    // immediately invoked function expression. It is so cool!
                    stream: ((int weekday) {
                      late final StreamController<int> controller;
                      controller = StreamController<int>(
                        onListen: () async {
                          _currentPage = RouteData.getTimeTable(
                              widget.thisPageBusRoute, _weekdayIndex);
                          controller.add(1);
                          await controller.close();
                        },
                      );
                      return controller.stream;
                    }(_weekdayIndex)),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        return _currentPage;
                      }

                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Text("none");
                        case ConnectionState.waiting:
                          return LoadingWidget();
                        case ConnectionState.active:
                          return Text("active");
                        case ConnectionState.done:
                          return Text("done");
                      }
                    }),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
