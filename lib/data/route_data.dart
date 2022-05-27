import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:busapp/BusApp.dart';
import 'package:busapp/data/model/bus_route.dart';
import 'package:busapp/data/model/stop.dart';
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
  static late Map<String, Widget> rotueBarTimeTables;
  static late LocalStorage storage;
  static late LocalStorage searchLog;
  static late List<int> element;
  static late StreamController<int> favoriteController;
  static late StreamController<int> filterController;
  static late StreamController<int> historyController;
  static late List<SilderBarData> imageList;
  static late List<String> aboutInfo;
  static var allData;
  static late String ptxID;
  static late String ptxKey;

  static String link = "http://www.ylbus.com.tw/bus_app_ylbus/route.json";

  static Future<bool> init() async {
    allBusName = [];
    allRouteStops = {};
    totalTimeTables = {};
    busRoutes = [];
    rotueBarTimeTables = {};
    element = [1, 2, 3];
    favoriteController = StreamController<int>.broadcast();
    filterController = StreamController<int>.broadcast();
    historyController = StreamController<int>.broadcast();
    imageList = [];
    aboutInfo = [];

    await _getPtx();
    allData = await getJsonFromURL(link);

    await _buildAllBusName();
    await _buildAllStops(); // 這個跑最慢
    await _buildTimeTables();
    await _buildRoutes();
    await _buildColumnAndRow();
    await _buildLocalStorage();
    await _buildAppData();

    print("build successful!");
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
    var data = await getJsonFromURL("https://cnutt.me/d/slider/image.json");
    data["about_info"].forEach((value) {
      aboutInfo.add(value);
    });

    data["content"].forEach((value) {
      String image = value["image"];
      String imageLink = value["link"];
      String linkTitle = value["title"];

      SilderBarData silderBarData = SilderBarData(image, imageLink, linkTitle);
      imageList.add(silderBarData);
    });
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

      stopPosition.forEach((busStop) {
        String routeID = busStop["RouteID"];
        List<Stop> allStops = [];

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

          Stop buildStop = Stop(
            id: stopID,
            stopName: stopName,
            position: position,
            routeID: routeID,
          );

          allStops.add(buildStop);
        });

        allRouteStops[routeID] = allStops;
      });
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

        routeTimeTables[0]["Timetables"].forEach((timeTable) {
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
      } else {
        String routeID =
            url.split("/")[url.split("/").length - 1].replaceAll(".json", "");

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

      busRoutes.add(BusRoute(
        id: routeID,
        routeName: routeName,
        subtitle: subtitle,
        direction: direction,
        timeTables: totalTimeTables[timeTableID]!,
        stops: allRouteStops[routeID == "13" ? "0801" : routeID]!,
        provider: provider,
        ticket: ticket,
      ));
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

  static _buildColumnAndRow() async {
    await Future.forEach(busRoutes, (bus) {
      bus as BusRoute;

      var table = getTimeTable(bus, BusApp.getWeekday());

      rotueBarTimeTables[bus.getRouteId + bus.getSubtitle["zh_tw"]!] = table;
    });
  }
}
