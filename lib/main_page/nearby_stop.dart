import 'dart:async';

import 'package:busapp/BusApp.dart';
import 'package:busapp/bus_route_page.dart';
import 'package:busapp/data/model/bus_route.dart';
import 'package:busapp/data/model/stop.dart';
import 'package:busapp/data/position.dart';
import 'package:busapp/data/route_data.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class NearbyStop extends StatefulWidget {
  NearbyStop({Key? key, required this.searchValue}) : super(key: key) {
    searchValue = searchValue.trim();
    if (searchValue.contains("站")) {
      searchValue = searchValue.replaceAll("站", "");
    }
  }

  String searchValue;

  @override
  State<NearbyStop> createState() => _NearbyStop();
}

class _NearbyStop extends State<NearbyStop> {
  Position? position;
  late bool gpsEnable;
  late bool hasPermission;
  late bool hasLongPermission;
  late final Stream<int> positionStream;
  late String message;
  late List<NearbyWidget> nearbyStops;

  @override
  void initState() {
    super.initState();

    message = "";
    nearbyStops = [];

    positionStream = (() {
      late final StreamController<int> streamController;
      streamController = StreamController<int>(
        onListen: () async {
          try {
            gpsEnable = true;
            hasPermission = true;
            hasLongPermission = true;
            position = await BusAppPosition.getPosition();
          } catch (e) {
            switch (e) {
              case "Location services are disabled.":
                gpsEnable = false;
                break;
              case "Location permissions are denied":
                hasPermission = false;
                break;
              case "Location permissions are permanently denied, we cannot request permissions.":
                hasLongPermission = false;
                break;
            }
          }
          streamController.add(1);

          getNearbyStops();

          await streamController.close();
        },
      );
      return streamController.stream;
    })();
  }

  getNearbyStops() {
    if (position == null) {
      return [
        Center(
          child: Text(
            _getContent(),
          ),
        )
      ];
    }

    int now = BusApp.getNow().hour * 3600 + BusApp.getNow().minute * 60;
    for (var bus in RouteData.busRoutes) {
      Stop? contain;
      for (var stop in bus.getStops) {
        if (stop.getStopName["zh_tw"]!.contains(widget.searchValue) ||
            (stop.getStopName["zh_tw"]!.contains("管院") &&
                widget.searchValue.contains("大葉大學"))) {
          contain = stop;
          break;
        }
      }

      if (contain != null) {
        for (var stop in bus.getStops) {
          List<double> stopPosition = stop.getPosition;

          double distance = BusAppPosition.calculateDistance(
            stopPosition[0],
            stopPosition[1],
            position!.latitude,
            position!.longitude,
          );

          distance = double.parse(distance.toStringAsFixed(1));

          if (distance < 1.5) {
            if (bus.getStops.indexOf(stop) < bus.getStops.indexOf(contain)) {
              var table = RouteData.rotueBarTimeTables[
                  bus.getRouteId + bus.getSubtitle["zh_tw"]!];

              if (table is! DataTable) continue;

              int index = bus.getStops.indexOf(stop);

              if (table.columns.last == table.columns[index]) continue;

              for (var row in table.rows) {
                String arrTimeStringFormat =
                    (row.cells[index].child as Text).data!;
                int arrTimeFormat =
                    RouteData.getTimeFormat(arrTimeStringFormat);

                if (!(arrTimeFormat > now && now > (arrTimeFormat - 3600))) {
                  continue;
                }

                NearbyWidget nearbyWidget = NearbyWidget(
                  bus: bus,
                  stopName: stop.getStopName["zh_tw"]!,
                  distance: distance,
                  arrTime: arrTimeStringFormat,
                );

                nearbyStops.add(nearbyWidget);
              }
            }
          }
        }
      }
    }

    nearbyStops.sort(((a, b) {
      return (a.distance > b.distance ? 1 : 0);
    }));
  }

  String _getContent() {
    if (!gpsEnable) {
      return "GPS定位未開啟，請開啟您的GPS定位才能使用此功能。";
    }

    if (!hasPermission) {
      return "請開啟GPS定位權限才能使用此功能。";
    }

    if (!hasLongPermission) {
      return "GPS訪問權限被設置為關閉，故無法要求GPS定位。";
    }

    return "位置取得時發生未知錯誤，請聯絡開發者。";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: positionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child: Column(
                  children: nearbyStops.isEmpty
                      ? [
                          SizedBox(
                            height: 300,
                          ),
                          Center(
                            child: Text(
                              "您周圍 1.5 公里無公車會經過的站牌。",
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          )
                        ]
                      : nearbyStops,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Container(
              child: Text("none"),
            );

          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 300,
                  ),
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 25,
                  ),
                  Text("GPS資訊取得中..."),
                ],
              ),
            );

          case ConnectionState.active:
            return Container(
              child: Text("active"),
            );
          case ConnectionState.done:
            return Container(
              child: Text("done"),
            );
        }
      },
    );
  }
}

class NearbyWidget extends StatefulWidget {
  const NearbyWidget({
    Key? key,
    required this.bus,
    required this.stopName,
    required this.distance,
    required this.arrTime,
  }) : super(key: key);

  final BusRoute bus;
  final String stopName;
  final double distance;
  final String arrTime;

  @override
  State<NearbyWidget> createState() => _NearbyWidgetState();
}

class _NearbyWidgetState extends State<NearbyWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: BusApp.mainColor,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusRoutePage(
              thisPageBusRoute: widget.bus,
            ),
          ),
        ),
        splashColor: BusApp.splashColor,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.bus.getRouteName["zh_tw"]!,
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      widget.bus.getSubtitle["zh_tw"]!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(BusApp.stopName + widget.stopName),
                    Text(BusApp.straightDistance +
                        widget.distance.toString() +
                        BusApp.kilometer),
                    Text(BusApp.comeTime + widget.arrTime + BusApp.kilometer),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
