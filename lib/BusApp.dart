import 'package:flutter/material.dart';

class BusApp {
  static const String busLink =
      "http://www.ylbus.com.tw/bus_app_ylbus/route.json";
  static const String imageLink = "https://nutt1101.github.io/data/image.json";
  static int currentPage = 0; // default page is 0 (main page)
  static const double nearbyDistance = 1.0;
  static int initWeekday = getWeekday();
  static String year = getNow().year.toString();
  static const String appName = "GO大葉";
  static const String mainPage = "首頁";
  static const String dynamicRoutes = "到站資訊";
  static const String allRoutes = "全班次表";
  static const String history = "歷史紀錄";
  static const String favorite = "我的收藏";
  static const String searchSuggestion = "現在想要去哪裡呢？";
  static const Color mainColor = Color(0xff202125);
  static Color splashColor = Colors.blue.withAlpha(30);
  static const String acceptButton = "確定";
  static const String helpButtonTitle = "關於此應用程式";
  static const String filterTitle = "篩選班次";
  static const String location = "地點";
  static const String routes = "路線";
  static const String coming = "\n進站";
  static const String loading = "資料讀取中, 請稍候...";
  static const String error = "發生錯誤！請回報至開發人員！";
  static const String noStop = "此站不停";
  static const String ticket = "票價";
  static const String notToday = "當日無行駛";
  static const String nearbyStop = "附近的站點";
  static const String kilometer = " 公里";
  static const String stopName = "附近站牌: ";
  static const String straightDistance = "直線距離: ";
  static const String comeTime = "到站時間: ";
  static const String dec = "目的地: ";
  static const String noFavorite = "尚無任何收藏";
  static const String noHistory = "尚無任何搜尋紀錄";

  static const List<String> day = [
    "星期日",
    "星期一",
    "星期二",
    "星期三",
    "星期四",
    "星期五",
    "星期六"
  ];

  static DateTime getNow() {
    return DateTime.now();
  }

  static int getWeekday() {
    return getNow().weekday == 7 ? 0 : DateTime.now().weekday;
  }
}
