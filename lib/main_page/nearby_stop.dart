import 'dart:async';

import 'package:busapp/BusApp.dart';
import 'package:busapp/bus_route_page.dart';
import 'package:busapp/data/model/bus_route.dart';
import 'package:busapp/data/model/stop.dart';
import 'package:busapp/data/model/stop_with_position.dart';
import 'package:busapp/data/position.dart';
import 'package:busapp/data/route_data.dart';
import 'package:busapp/loading.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class NearbyStop extends StatefulWidget {
  NearbyStop({Key? key, required this.searchValue}) : super(key: key);

  String searchValue;

  @override
  State<NearbyStop> createState() => _NearbyStop();
}

class _NearbyStop extends State<NearbyStop> {
  late String search;
  Position? position;
  late bool gpsEnable;
  late bool hasPermission;
  late bool hasLongPermission;
  late final Stream<int> positionStream;
  late String message;
  late List<NearbyWidget> nearbyStops;
  /**
   * 0 -> nearbyStops is empty
   * 1 -> no found
   */
  int? searchStatus;

  @override
  void initState() {
    super.initState();

    search = widget.searchValue;
    valueFilter();

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

          for (;;) {
            if (RouteData.busAndStopPositionStatus) {
              break;
            }
            await Future<void>.delayed(const Duration(seconds: 1));
          }

          getNearbyStops();
          streamController.add(1);

          await streamController.close();
        },
      );
      return streamController.stream;
    })();
  }

  void valueFilter() {
    search = search.trim();
    if (search.contains("站")) {
      search = search.replaceAll("站", "");
    }

    if (search == "大葉") {
      search = "大葉大學";
    }
  }

  getNearbyStops() {
    if (position == null) {
      searchStatus = 0;
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
      StopWithPosition? contain;

      late List<StopWithPosition> stopWithPosition;

      if (RouteData
              .busAndStopPosition[bus.getRouteId + bus.getSubtitle["zh_tw"]!] !=
          null) {
        stopWithPosition = RouteData
            .busAndStopPosition[bus.getRouteId + bus.getSubtitle["zh_tw"]!]!;
      } else {
        continue;
      }

      stopWithPosition = (bus.getDirection == 0 && bus.getProvider)
          ? stopWithPosition.reversed.toList()
          : stopWithPosition;

      for (var stop in stopWithPosition) {
        if (stop.getStopName["zh_tw"]!.contains(search) ||
            (stop.getStopName["zh_tw"]!.contains("管院") &&
                search.contains("大葉大學"))) {
          if (!(search == "彰化" && stop.getStopName["zh_tw"]!.contains("高鐵"))) {
            contain = stop;
          }
        }
      }

      if (contain != null) {
        for (var stop in stopWithPosition) {
          List<double> stopPosition = stop.getPosition;

          double distance = BusAppPosition.calculateDistance(
            stopPosition[0],
            stopPosition[1],
            position!.latitude,
            position!.longitude,
          );

          distance = double.parse(distance.toStringAsFixed(1));

          if (distance < BusApp.nearbyDistance) {
            searchStatus = 1;
            List<StopWithPosition> stops = stopWithPosition;

            if (stops.indexOf(stop) < stops.indexOf(contain)) {
              var table = RouteData.rotueBarTimeTables[
                  bus.getRouteId + bus.getSubtitle["zh_tw"]!];

              if (table is! DataTable) continue;

              int index = stops.indexOf(stop);

              if (table.columns.last == table.columns[index]) continue;

              for (var row in table.rows) {
                String arrTimeStringFormat =
                    (row.cells[index].child as Text).data!;
                int arrTimeFormat =
                    RouteData.getTimeFormat(arrTimeStringFormat);

                if (!(arrTimeFormat > now && now > (arrTimeFormat - 3600))) {
                  continue;
                }

                bool repeat = false;
                for (var nstop in nearbyStops) {
                  if (nstop.bus == bus) {
                    repeat = !repeat;
                  }
                }

                if (!repeat) {
                  nearbyStops.add(
                    NearbyWidget(
                      bus: bus,
                      stopName: stop.getStopName["zh_tw"]!,
                      decStopName: contain.getStopName["zh_tw"]!,
                      distance: distance,
                      arrTime: arrTimeStringFormat,
                    ),
                  );
                }
              }
            }
          }
        }
      }
    }

    if (nearbyStops.isEmpty && searchStatus == null) {
      searchStatus = 0;
      return;
    }

    nearbyStops.sort(
      ((a, b) {
        return (a.distance > b.distance ? 1 : -1);
      }),
    );
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

  Widget getEmptyReason(String searchValue) {
    switch (searchStatus) {
      case 0:
        return Text(
          "您周圍 ${BusApp.nearbyDistance} 公里內找不到目的地為 \"$searchValue\" 的途經公車。",
          style: TextStyle(
            fontSize: 20,
          ),
        );
      case 1:
        return Text(
          "此時間點沒有公車會經過 \" $searchValue \"",
          style: TextStyle(
            fontSize: 20,
          ),
        );
    }
    return Text("發生未知的錯誤，請回報給開發人員。");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: positionStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (snapshot.hasData) {
          return (nearbyStops.isEmpty
              ? Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    child: getEmptyReason(widget.searchValue),
                  ),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.85,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "搜尋 \"${widget.searchValue}\" 的結果如下 :",
                            style: TextStyle(fontSize: 20),
                          ),
                          ...nearbyStops
                        ],
                      ),
                    ),
                  ),
                ));
        } else {
          return Center(
            child: LoadingWidget(
              text: "GPS資訊取得中...",
            ),
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
    required this.decStopName,
    required this.distance,
    required this.arrTime,
  }) : super(key: key);

  final BusRoute bus;
  final String stopName;
  final String decStopName;
  final double distance;
  final String arrTime;

  @override
  State<NearbyWidget> createState() => _NearbyWidgetState();
}

class _NearbyWidgetState extends State<NearbyWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Card(
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
            padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                          "${widget.distance}" +
                          BusApp.kilometer),
                      Text(BusApp.comeTime + widget.arrTime),
                      Text(BusApp.dec + widget.decStopName),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
