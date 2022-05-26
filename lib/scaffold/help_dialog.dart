import 'package:busapp/BusApp.dart';
import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  HelpDialog({Key? key}) : super(key: key);

  List<Widget> _getContent() {
    switch (BusApp.currentPage) {
      case 0:
        return [
          Text("標題欄："),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(Icons.info),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  "此App版權說明及介紹",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(Icons.help),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  "此頁面按鈕及功能說明",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          Divider(),
          Text("內容欄："),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(Icons.photo),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  "圖片輪播",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(Icons.search),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  "輸入目的地，會以您當前位置尋找附近的站牌以及顯示公車到站牌的時間",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(Icons.favorite),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  "收藏的公車路線",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(Icons.history),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  "搜尋過的目的地",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ];
      case 1:
        return [
          Text("內容欄："),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "此頁會顯示現在時間，以及顯示各公車到 大葉管院站 的預估時間，並且在到站前十分鐘會以紅色粗體字顯示時間，點擊車次可以進入查詢車次相關資訊。",
                  style: TextStyle(fontSize: 13.5),
                ),
              ),
            ],
          ),
        ];
      case 2:
        return [
          Text("內容欄："),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Image.asset(
                "assets/image/2.png",
                color: Colors.black,
                width: 32,
                height: 32,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  "以路線或經過地點的條件篩選車次，若是選取狀態，圖示會以藍色狀態顯示。",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "此頁可查詢大葉相關公車的全時刻表、票價，以及可將路線加入收藏。",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ];
    }
    return [Center()];
  }

  _getTitle() {
    switch (BusApp.currentPage) {
      case 0:
        return Text("首頁 - 頁面說明");
      case 1:
        return Text("到站資訊 - 頁面說明");
      case 2:
        return Text("全班次表 - 頁面說明");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _getTitle(),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.maxFinite,
        child: ListView(
          children: _getContent(),
        ),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(BusApp.mainColor),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(BusApp.acceptButton),
        ),
      ],
    );
  }
}
