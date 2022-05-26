import 'package:busapp/BusApp.dart';

import 'package:busapp/data/route_data.dart';

import 'package:busapp/scaffold/appbar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  Widget? _currentPage;
  int? _currentPageIndex;
  String? _weekday;

  _wantDayTimeTable() {
    if (_currentPageIndex! > 6) {
      _currentPageIndex = 0;
    } else if (_currentPageIndex! < 0) {
      _currentPageIndex = 6;
    }

    List<DataColumn> dataColumns = [];

    for (var stop in widget.thisPageBusRoute.getStops) {
      String stopName = stop.getStopName["zh_tw"]!;
      dataColumns.add(DataColumn(
          label: Text(
        stopName,
        style: const TextStyle(fontSize: 20),
      )));
    }

    if (widget.thisPageBusRoute.getProvider &&
        widget.thisPageBusRoute.getDirection == 0) {
      dataColumns = dataColumns.reversed.toList();
    }

    List<DataRow> rows = [];
    List<DataCell> cells = [];

    if (widget.thisPageBusRoute.getProvider) {
      for (var timeTable in widget.thisPageBusRoute.getTimeTables) {
        if (timeTable.getServiceDay[_currentPageIndex!]) {
          cells.add(DataCell(Text(timeTable.getArrivalTime)));
          String time = timeTable.getArrivalTime;

          while (cells.length < widget.thisPageBusRoute.getStops.length) {
            time = RouteData.getArriveTime(time);
            cells.add(DataCell(Text(time)));
          }
        }

        if (cells.length % widget.thisPageBusRoute.getStops.length == 0 &&
            cells.isNotEmpty) {
          rows.add(DataRow(cells: cells.toList()));
          cells.clear();
        }
      }
    } else {
      for (var timeTable in widget.thisPageBusRoute.getTimeTables) {
        if (timeTable.getServiceDay[_currentPageIndex!]) {
          cells.add(
            DataCell(
              Text(
                timeTable.getArrivalTime,
                style: TextStyle(
                    color: timeTable.getArrivalTime == BusApp.noStop
                        ? Colors.redAccent
                        : Colors.black),
              ),
            ),
          );
        }

        if (cells.length % widget.thisPageBusRoute.getStops.length == 0 &&
            cells.isNotEmpty) {
          rows.add(DataRow(cells: cells.toList()));
          cells.clear();
        }
      }
    }

    DataTable table = DataTable(columns: dataColumns, rows: rows);

    return table.rows.isEmpty
        ? const Center(
            child: Text(
              BusApp.notToday,
              style: TextStyle(fontSize: 23),
            ),
          )
        : table;
  }

  @override
  void initState() {
    super.initState();
    _currentPage = RouteData.rotueBarTimeTables[
        widget.thisPageBusRoute.getRouteId +
            widget.thisPageBusRoute.getSubtitle["zh_tw"]!];

    _currentPageIndex = BusApp.getWeekday();
    _weekday = BusApp.day[_currentPageIndex!];
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
                      _currentPageIndex = _currentPageIndex! - 1;
                      _currentPage = _wantDayTimeTable();
                      _weekday = BusApp.day[_currentPageIndex!];
                    });
                  },
                ),
                Text(
                  _weekday!,
                  style: TextStyle(fontSize: 25),
                ),
                GestureDetector(
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    size: 35,
                  ),
                  onTap: () {
                    setState(() {
                      _currentPageIndex = _currentPageIndex! + 1;
                      _currentPage = _wantDayTimeTable();
                      _weekday = BusApp.day[_currentPageIndex!];
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
                children: [_currentPage!],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  WebViewPage({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
