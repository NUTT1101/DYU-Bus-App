import 'package:busapp/data/filter_data.dart';
import 'package:busapp/data/model/bus_route.dart';
import 'package:busapp/data/route_data.dart';
import 'package:flutter/material.dart';

import '../BusApp.dart';
import '../route_bar.dart';
import '../filter/filter.dart';

class AllRoutes extends StatefulWidget {
  AllRoutes({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AllRoute();
  }
}

class _AllRoute extends State<AllRoutes> {
  late List<BusRoute> _bus;
  late int _fullLength;
  @override
  void initState() {
    super.initState();
    _bus = RouteData.busRoutes;
    _fullLength = RouteData.busRoutes.length;

    RouteData.filterController.stream.listen((event) {
      if (mounted) {
        setState(() {
          List<List<String>> filterData = FilterData.getFilterData();
          List<String> locationData = filterData[0];
          List<String> routeData = filterData[1];
          int locationIndex = Filter.filterSelectedIndex[0];
          int routeIndex = Filter.filterSelectedIndex[1];

          List<BusRoute> tmpBus = [];

          for (int i = 0; i < locationData.length; i++) {
            if (locationData[i].contains("站")) {
              locationData[i] = locationData[i].replaceAll("站", "");
            }
          }

          if (locationIndex == -1 && routeIndex == -1) {
            _bus = RouteData.busRoutes;
            return;
          }

          if (locationIndex != -1) {
            for (var element in RouteData.busRoutes) {
              for (var e2 in element.getStops) {
                if (e2.getStopName["zh_tw"]!
                    .contains(locationData[locationIndex])) {
                  if (!(element.getRouteName["zh_tw"]!.contains("6700") &&
                      locationData[locationIndex] == "彰化")) {
                    tmpBus.add(element);
                  }

                  break;
                }
              }
            }
          }

          if (routeIndex != -1) {
            if (tmpBus.isEmpty) {
              for (var element in RouteData.busRoutes) {
                if (element.getRouteName["zh_tw"]!
                    .contains(routeData[routeIndex])) {
                  tmpBus.add(element);
                }
              }
            } else {
              for (var element in RouteData.busRoutes) {
                if (element.getRouteName["zh_tw"]!
                    .contains(routeData[routeIndex])) {
                  for (var l in tmpBus.toList()) {
                    if (!l.getRouteName["zh_tw"]!
                        .contains(routeData[routeIndex])) {
                      tmpBus.remove(l);
                    }
                  }
                }
              }
            }
          }

          _bus = tmpBus;
        });
      }
    });
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
                  const Text(BusApp.allRoutes, style: TextStyle(fontSize: 22)),
                  InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Filter(
                          totalLocationName: FilterData.getFilterData(),
                        );
                      },
                    ),
                    child: Image.asset(
                      "assets/image/2.png",
                      color: _bus.length != _fullLength
                          ? Color.fromRGBO(33, 150, 243, 1.0)
                          : Colors.black,
                      width: 32,
                      height: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.67,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _bus.length,
                  itemBuilder: (context, index) => RouteBar(
                    busRoute: _bus[index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
