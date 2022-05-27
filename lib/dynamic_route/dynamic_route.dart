import 'dart:async';

import 'package:busapp/BusApp.dart';
import 'package:busapp/data/route_data.dart';

import 'package:busapp/route_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DynamicRoute extends StatefulWidget {
  DynamicRoute({Key? key}) : super(key: key);

  @override
  _DynamicRoute createState() => _DynamicRoute();
}

class _DynamicRoute extends State<DynamicRoute> {
  late DateTime _now;
  late String _time;
  late String _date;
  late List<RouteBar> _comingSoon;

  @override
  void initState() {
    super.initState();
    _now = BusApp.getNow();
    _time = _getTime(_now);
    _date = _getDate(_now);
    _comingSoon = [];

    Timer.periodic(const Duration(seconds: 1), (timer) {
      _now = BusApp.getNow();
      setState(() {
        _time = _getTime(_now);
        _comingSoon = _updateComingSoonBus();
      });
    });
  }

  List<RouteBar> _updateComingSoonBus() {
    int now = _now.hour * 3600 + _now.minute * 60;
    List<RouteBar> routeBarList = [];

    for (var bus in RouteData.busRoutes) {
      var table = RouteData
          .rotueBarTimeTables[bus.getRouteId + bus.getSubtitle["zh_tw"]!];

      if (table is! DataTable) continue;

      int? index;
      for (var column in table.columns) {
        Text lable = column.label as Text;

        if (lable.data!.contains("大葉") || lable.data!.contains("管院")) {
          index = table.columns.indexOf(column);
          break;
        }
      }

      if (index == null) {
        continue;
      }

      if (table.columns.last == table.columns[index]) continue;

      for (var row in table.rows) {
        String arrTimeStringFormat = (row.cells[index].child as Text).data!;
        int arrTimeFormat = RouteData.getTimeFormat(arrTimeStringFormat);

        if (!(arrTimeFormat > now && now > (arrTimeFormat - 3600))) {
          continue;
        }

        bool comingSoon = arrTimeFormat > now && now > (arrTimeFormat - 600);

        RouteBar routeBar = RouteBar(
          busRoute: bus,
          arriveTime: arrTimeStringFormat,
          comingSoon: comingSoon,
        );

        routeBarList.add(routeBar);
      }
    }

    routeBarList.sort(((a, b) {
      return a.arriveTime!.compareTo(b.arriveTime!);
    }));

    return routeBarList.sublist(
        0, routeBarList.length >= 6 ? 5 : routeBarList.length);
  }

  String _getTime(DateTime time) {
    return DateFormat("HH:mm:ss").format(time);
  }

  String _getDate(DateTime now) {
    String month = now.month.toString();
    String day = now.day.toString();
    return month + "/" + day + BusApp.day[BusApp.getWeekday()];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        BusApp.dynamicRoutes,
                        style: TextStyle(fontSize: 22),
                      ),
                      Text(
                        "大葉管院站",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _date,
                        style: const TextStyle(fontSize: 22),
                      ),
                      Text(
                        _time,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.67,
                child: _comingSoon.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: _comingSoon.length,
                        itemBuilder: (context, index) => _comingSoon[index])
                    : Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                            ),
                            Text(
                              "目前已無任何班次",
                              style: TextStyle(fontSize: 23),
                            )
                          ],
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
