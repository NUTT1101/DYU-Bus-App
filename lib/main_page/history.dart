import 'package:busapp/data/route_data.dart';
import 'package:busapp/main_page/nearby_stop.dart';
import 'package:busapp/scaffold/appbar.dart';
import 'package:flutter/material.dart';

import '../BusApp.dart';

class History extends StatelessWidget {
  const History(
      {required this.title,
      this.icon = const Icon(Icons.history),
      this.fontSize = 15.0,
      Key? key})
      : super(key: key);

  final Icon icon;
  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: App(
              title: BusApp.history,
              header: Text(""),
              footer: Text(""),
            ),
            body: SearchLogPage(
              history: RouteData.searchLog.getItem("log") == null
                  ? []
                  : RouteData.searchLog.getItem("log"),
            ),
          ),
        ),
      ),
      splashColor: BusApp.splashColor,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: fontSize),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SearchLogPage extends StatefulWidget {
  const SearchLogPage({Key? key, required this.history}) : super(key: key);

  final List<dynamic> history;

  @override
  State<StatefulWidget> createState() {
    return _SearchLogPage();
  }
}

class _SearchLogPage extends State<SearchLogPage> {
  @override
  void initState() {
    super.initState();

    RouteData.historyController.stream.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.history.isNotEmpty
        ? SingleChildScrollView(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child: Column(
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    for (var his in widget.history)
                      HistoryBar(value: his, index: widget.history.indexOf(his))
                  ],
                ),
              ),
            ),
          )
        : Center(
            child: Text(
              BusApp.noHistory,
              style: TextStyle(fontSize: 22),
            ),
          );
  }
}

class HistoryBar extends StatelessWidget {
  const HistoryBar({Key? key, required this.value, required this.index})
      : super(key: key);

  final String value;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: BusApp.mainColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        splashColor: BusApp.splashColor,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: App(
                  title: BusApp.nearbyStop,
                  header: Text(""),
                  footer: Text(""),
                ),
                body: NearbyStop(searchValue: value),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Icon(Icons.history),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(flex: 8, child: Text(value)),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    List<dynamic> hisotry = RouteData.searchLog.getItem("log");
                    hisotry.removeAt(index);
                    RouteData.searchLog.setItem("log", hisotry);
                    RouteData.historyController.add(1);
                  },
                  child: Icon(Icons.cancel_outlined),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
