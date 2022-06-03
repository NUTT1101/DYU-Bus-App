import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:busapp/BusApp.dart';
import 'package:busapp/data/model/bus_route.dart';
import 'package:busapp/data/model/stop.dart';
import 'package:busapp/data/model/stop_with_position.dart';
import 'package:busapp/data/model/time_table.dart';
import 'package:busapp/data/model/slider_bar_data.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class RouteData {
  static late List<String> allBusName;
  static late Map<String, List<Stop>> allRouteStops;
  static late Map<String, List<TimeTable>> totalTimeTables;
  static late List<BusRoute> busRoutes;
  static late Map<String, List<StopWithPosition>> busAndStopPosition;
  static late bool busAndStopPositionStatus;
  static late Map<String, Widget> rotueBarTimeTables;
  static late LocalStorage storage;
  static late LocalStorage searchLog;
  static late List<int> element;
  static late StreamController<int> favoriteController;
  static late StreamController<int> filterController;
  static late StreamController<int> historyController;
  static late List<SliderBarData> imageList;
  static late List<String> aboutInfo;
  static var allData;
  static late String ptxID;
  static late String ptxKey;
  static late String g;

  static Future<bool> init() async {
    allBusName = [];
    allRouteStops = {};
    totalTimeTables = {};
    busRoutes = [];
    busAndStopPosition = {};
    rotueBarTimeTables = {};
    element = [1, 2, 3];
    favoriteController = StreamController<int>.broadcast();
    filterController = StreamController<int>.broadcast();
    historyController = StreamController<int>.broadcast();
    imageList = [];
    aboutInfo = [];
    busAndStopPositionStatus = false;

    await _getPtx();
    allData = await getJsonFromURL(BusApp.busLink);

    var t1 = BusApp.getNow();
    await _buildAllBusName();
    await _buildTimeTables();
    await _buildAllStops();
    await _buildRoutes();
    await buildColumnAndRow();
    await _buildLocalStorage();
    await _buildAppData();
    _buildStopWithPosition();
    var t2 = BusApp.getNow();

    g = ((t2.toUtc().microsecondsSinceEpoch -
                t1.toUtc().microsecondsSinceEpoch) /
            1000000)
        .toStringAsFixed(2);

    print("build successful! $g second(s)");

    return true;
  }

  static _buildLocalStorage() {
    storage = LocalStorage("favorite");
    searchLog = LocalStorage("search_log");
  }

  static _getPtx() async {
    var ptx = await getJsonFromLocal("assets/data/bus/ptx.json");
    ptxID = ptx["id"];
    ptxKey = ptx["key"];
  }

  static _buildAppData() async {
    if (aboutInfo.isNotEmpty) {
      aboutInfo.clear();
    }

    if (imageList.isNotEmpty) {
      aboutInfo.clear();
    }

    var data = await getJsonFromURL(BusApp.imageLink);
    if (data != null) {
      data["about_info"].forEach((value) {
        aboutInfo.add(value);
      });

      data["content"].forEach((value) {
        String image = value["image"];
        String imageLink = value["link"];
        String linkTitle = value["title"];

        imageList.add(
          SliderBarData(
            Image.network(
              image,
              height: 350,
              fit: BoxFit.cover,
            ),
            imageLink,
            linkTitle,
          ),
        );
      });
    } else {
      aboutInfo.add("訊息加載失敗，因為無法與伺服器取得連線。");
      imageList.add(
        SliderBarData(
            Image.asset(
              "assets/loading_failed.jpg",
              height: 350,
              fit: BoxFit.cover,
            ),
            "https://github.com/NUTT1101/DYU-Bus-App/issues",
            "請回報開發者"),
      );
    }
  }

  static List<BusRoute> getFavoriteList() {
    List<BusRoute> favorite = [];

    for (var bus in RouteData.busRoutes) {
      if (RouteData.storage.getItem(bus.getRouteId) != null) {
        favorite.add(bus);
      }
    }

    return favorite;
  }

  static Map<String, String> _getSignature() {
    var appkeyEncode = utf8.encode(ptxKey);
    String xdate = DateFormat("EEE, dd MMM yyyy HH:mm:ss")
            .format(BusApp.getNow().toUtc()) +
        " GMT";

    var xdateEncode = utf8.encode("x-date: " + xdate);

    var hmacSha1 = Hmac(sha1, appkeyEncode);

    var signature = base64Encode(hmacSha1.convert(xdateEncode).bytes);

    var athorization = "hmac username=\"" +
        ptxID +
        "\", algorithm=\"hmac-sha1\", headers=\"x-date\", signature=\"" +
        signature +
        "\"";

    return {"Authorization": athorization, "x-date": xdate};
  }

  static Future<dynamic> getJsonFromURL(String url,
      {Map<String, String>? headers}) async {
    var httpClient = http.Client();
    try {
      var response = await httpClient.get(Uri.parse(url), headers: headers);
      var utf8Decode = json.decode(utf8.decode(response.bodyBytes));
      return utf8Decode;
    } catch (e) {
      print(e);
    } finally {
      httpClient.close();
    }
  }

  static Future<dynamic> getJsonFromLocal(String path) async {
    var data = await rootBundle.loadString(path);
    var jsonData = json.decode(data);
    return jsonData;
  }

  static Future<void> _buildAllBusName() async {
    if (allBusName.isNotEmpty) {
      allBusName.clear();
    }

    allData.forEach((element) {
      if (!allBusName.contains(element["name"]["Zh"])) {
        allBusName.add(element["name"]["Zh"]);
      }
      allBusName.sort();
    });
  }

  static Future<void> _buildAllStops() async {
    await Future.forEach(allData, (allBus) async {
      allBus as Map<String, dynamic>;
      String url = allBus["url"]["first_time_table"];
      String routeID = _getRealRouteID(allBus["key"], url);
      dynamic stops;

      if (url.contains("http://www.ylbus.com.tw/")) {
        stops = await getJsonFromURL(url);

        if (stops[0]["Timetables"].isEmpty || stops[0]["Timetables"] == null) {
          allRouteStops[routeID] = [];
        } else {
          stops[0]["Timetables"].forEach((timeTable) {
            List<Stop> allStops = [];

            timeTable["StopTimes"].forEach(
              (stop) {
                String stopID = stop["StopID"];
                Map<String, String> stopName = {
                  "zh_tw": stop["StopName"]["Zh_tw"],
                  "en": stop["StopName"]["En"],
                };

                allStops.add(Stop(
                  id: stopID,
                  stopName: stopName,
                  routeID: routeID,
                ));
              },
            );

            allRouteStops[routeID] = allStops;
          });
        }
      } else {
        url = allBus["url"]["est_time"];
        stops = await getJsonFromURL(url, headers: _getSignature());

        if (stops.toString() == "{message: API rate limit exceeded}") {
          return;
        }

        List<Stop> allStops = [];
        if (stops == null || stops.isEmpty) {
          allRouteStops[routeID] = [];
        } else {
          stops.forEach((stop) {
            Map<String, String> stopName = {
              "zh_tw": stop["StopName"]["Zh_tw"],
              "en": stop["StopName"]["En"],
            };

            Stop buildStop = Stop(
              id: "",
              stopName: stopName,
              routeID: routeID,
            );

            allStops.add(buildStop);
          });
          allRouteStops[routeID] = allStops;
        }
      }
    });
  }

  static Future<void> _buildTimeTables() async {
    await Future.forEach(allData, (allBus) async {
      allBus as Map<String, dynamic>;
      String url = allBus["url"]["first_time_table"];
      List<TimeTable> allTimeTables = [];
      var routeTimeTables = await getJsonFromURL(url);

      if (url.contains("http://www.ylbus.com.tw/")) {
        String routeName = routeTimeTables[0]["RouteUID"];

        var timeTables = routeTimeTables[0]["Timetables"];

        if (timeTables.isEmpty || timeTables == null) {
          totalTimeTables[routeName] = [];
        } else {
          timeTables.forEach((timeTable) {
            List<bool> serviceDay = [];

            timeTable["ServiceDay"].forEach((key, value) {
              serviceDay.add(value == 1);
            });

            timeTable["StopTimes"].forEach((stopTime) {
              String arrTime = stopTime["ArrivalTime"];
              String depTime = stopTime["DepartureTime"];

              allTimeTables.add(TimeTable(
                serviceDay: serviceDay,
                arrivalTime: arrTime,
                departureTime: depTime,
              ));
            });

            totalTimeTables[routeName] = allTimeTables;
          });
        }
      } else {
        String routeID =
            url.split("/")[url.split("/").length - 1].replaceAll(".json", "");

        if (routeTimeTables.isEmpty || routeTimeTables == null) {
          totalTimeTables[routeID] = [];
        } else {
          routeTimeTables.forEach((timeTable) {
            List<bool> serviceDay = [];

            timeTable["ServiceDay"].forEach((key, value) {
              serviceDay.add(value == 1);
            });

            String arrTime = timeTable["Middle_Station"][0]["ArrivalTime"];

            allTimeTables.add(TimeTable(
              serviceDay: serviceDay,
              arrivalTime: arrTime,
              departureTime: "0",
            ));
          });

          totalTimeTables[routeID] = allTimeTables;
        }
      }
    });
  }

  static String _getRealRouteID(String id, String url) {
    if (url.contains("http://www.ylbus.com.tw/")) {
      return url.split("/")[url.split("/").length - 1].replaceAll(".json", "");
    } else {
      return id.split("_")[1];
    }
  }

  static Future<void> _buildRoutes() async {
    if (busRoutes.isNotEmpty) {
      busRoutes.clear();
    }

    await Future.forEach(allData, (data) {
      data as Map<String, dynamic>;

      String url = data["url"]["first_time_table"];
      String routeID = _getRealRouteID(data["key"], url);

      Map<String, String> routeName = {
        "zh_tw": data["name"]["Zh"],
        "en": data["name"]["Zh"],
      };

      Map<String, String> subtitle = {
        "zh_tw": data["sub_title"]["Zh"],
        "en": data["sub_title"]["En"],
      };

      int direction = data["direction"];

      String timeTableID =
          url.split("/")[url.split("/").length - 1].replaceAll(".json", "");

      bool provider = data["provider"] == 1;

      String ticket = data["url"]["ticket"];

      busRoutes.add(
        BusRoute(
          id: routeID,
          routeName: routeName,
          subtitle: subtitle,
          direction: direction,
          timeTables: totalTimeTables[timeTableID]!,
          stops: allRouteStops[routeID]!,
          provider: provider,
          ticket: ticket,
        ),
      );
    });
  }

  static getArriveTime(String time) {
    List<String> splitTime = time.split(":");
    int hour = int.parse(splitTime[0]);
    int mins = int.parse(splitTime[1]);
    int random = Random().nextInt(element.length - 1);
    mins += element[random];
    if (mins >= 60) {
      hour += mins ~/ 60;
      mins %= 60;
    }

    return (hour < 10 ? "0" + hour.toString() : hour.toString()) +
        ":" +
        (mins < 10 ? "0" + mins.toString() : mins.toString());
  }

  static int getTimeFormat(String timeStringFormat) {
    if (!timeStringFormat.contains(":")) return 0;

    var time = timeStringFormat.split(":");
    int hour = int.parse(time[0]);
    int min = int.parse(time[1]);

    return (hour * 3600 + min * 60);
  }

  static getTimeTable(BusRoute bus, int weekday) {
    List<DataColumn> dataColumns = [];

    for (var stop in bus.getStops) {
      String stopName = stop.getStopName["zh_tw"]!;
      dataColumns.add(
        DataColumn(
          label: Text(
            stopName,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    if (bus.getProvider && bus.getDirection == 0) {
      dataColumns = dataColumns.reversed.toList();
    }

    List<DataRow> rows = [];
    List<DataCell> cells = [];

    if (bus.getProvider) {
      for (var timeTable in bus.getTimeTables) {
        if (timeTable.getServiceDay[weekday]) {
          cells.add(DataCell(Text(timeTable.getArrivalTime)));
          String time = timeTable.getArrivalTime;

          while (cells.length < bus.getStops.length) {
            time = RouteData.getArriveTime(time);
            cells.add(DataCell(Text(time)));
          }
        }

        if (cells.length % bus.getStops.length == 0 && cells.isNotEmpty) {
          rows.add(DataRow(cells: cells.toList()));
          cells.clear();
        }
      }
    } else {
      for (var timeTable in bus.getTimeTables) {
        if (timeTable.getServiceDay[weekday]) {
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

        if (cells.length % bus.getStops.length == 0 && cells.isNotEmpty) {
          rows.add(DataRow(cells: cells.toList()));
          cells.clear();
        }
      }
    }

    return dataColumns.isNotEmpty
        ? DataTable(columns: dataColumns, rows: rows)
        : const Center(
            child: Text(
              BusApp.notToday,
              style: TextStyle(fontSize: 23),
            ),
          );
  }

  static buildColumnAndRow() async {
    await Future.forEach(busRoutes, (bus) {
      bus as BusRoute;

      var table = getTimeTable(bus, BusApp.getWeekday());

      rotueBarTimeTables[bus.getRouteId + bus.getSubtitle["zh_tw"]!] = table;
    });
  }

  static _buildStopWithPosition() async {
    await Future.forEach(allData, (allBus) async {
      allBus as Map<String, dynamic>;
      String url = allBus["url"]["stop_pos"];

      dynamic stopPosition;
      if (url.contains("http://www.ylbus.com.tw/")) {
        stopPosition = await getJsonFromURL(url);
      } else {
        stopPosition = await getJsonFromURL(url, headers: _getSignature());
      }

      if (stopPosition.toString() == "{message: API rate limit exceeded}") {
        return;
      }

      String idURL = allBus["url"]["first_time_table"];
      String routeID = _getRealRouteID(allBus["key"], idURL);

      stopPosition.forEach((busStop) {
        List<StopWithPosition> allStops = [];

        busStop["Stops"].forEach((stop) {
          String stopID = stop["StopID"];
          Map<String, String> stopName = {
            "zh_tw": stop["StopName"]["Zh_tw"],
            "en": stop["StopName"]["En"],
          };
          List<double> position = [
            stop["StopPosition"]["PositionLat"],
            stop["StopPosition"]["PositionLon"]
          ];

          allStops.add(
            StopWithPosition(
              id: stopID,
              stopName: stopName,
              position: position,
              routeID: routeID,
            ),
          );
        });

        for (var bus in busRoutes) {
          if (bus.getRouteId == routeID) {
            busAndStopPosition[bus.getRouteId + bus.getSubtitle["zh_tw"]!] =
                allStops;
          }
        }
      });
    });
    busAndStopPositionStatus = true;
  }
}
