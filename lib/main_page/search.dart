import 'package:busapp/BusApp.dart';
import 'package:busapp/data/route_data.dart';
import 'package:busapp/main_page/nearby_stop.dart';
import 'package:busapp/scaffold/appbar.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  SearchBar({required this.searchSuggestion, Key? key}) : super(key: key);

  final String searchSuggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => null,
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: TextField(
                onSubmitted: ((value) {
                  if (value.isNotEmpty) {
                    value = value.trim();
                    List<dynamic> history =
                        RouteData.searchLog.getItem("log") == null
                            ? []
                            : RouteData.searchLog.getItem("log");

                    if (history.length == 0) {
                      history.add(value);
                    } else if (history[0] != value) {
                      if (history.length < 10) {
                        history.insert(0, value);
                      } else {
                        history.removeLast();
                        history.insert(0, value);
                      }
                    }

                    RouteData.searchLog.setItem("log", history);

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
                  }
                }),
                decoration:
                    InputDecoration.collapsed(hintText: searchSuggestion),
                textAlign: TextAlign.left,
                cursorColor: const Color(0xff92b8ff),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
