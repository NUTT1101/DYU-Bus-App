import 'package:busapp/BusApp.dart';
import 'package:busapp/bus_route_page.dart';
import 'package:busapp/data/model/bus_route.dart';

import 'package:flutter/material.dart';

class RouteBar extends StatelessWidget {
  RouteBar({
    Key? key,
    required this.busRoute,
    this.comingSoon,
    this.arriveTime,
  }) : super(key: key);

  final BusRoute busRoute;
  bool? comingSoon;
  String? arriveTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        border: Border.all(width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: BusApp.splashColor,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusRoutePage(
              thisPageBusRoute: busRoute,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Expanded(child: SizedBox()),
              Expanded(
                  flex: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        busRoute.getRouteName["zh_tw"]!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        busRoute.getSubtitle["zh_tw"]!,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  )),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: arriveTime == null ? 0 : 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    comingSoon == null || comingSoon == false
                        ? Text(
                            (arriveTime == null
                                ? ""
                                : arriveTime! + BusApp.coming),
                            style: const TextStyle(fontSize: 14),
                          )
                        : Text(
                            (arriveTime == null
                                ? ""
                                : arriveTime! + BusApp.coming),
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
