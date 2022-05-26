import 'package:busapp/data/model/bus_route.dart';

import 'package:busapp/data/route_data.dart';
import 'package:busapp/route_bar.dart';
import 'package:busapp/scaffold/appbar.dart';
import 'package:flutter/material.dart';

import '../BusApp.dart';

class Favorite extends StatefulWidget {
  Favorite(
      {required this.title,
      this.icon = const Icon(Icons.favorite),
      this.fontSize = 15.0,
      Key? key})
      : super(key: key);

  final Icon icon;
  final String title;
  final double fontSize;

  @override
  State<StatefulWidget> createState() {
    return _Favorite();
  }
}

class _Favorite extends State<Favorite> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: App(
              title: BusApp.favorite,
              header: Text(""),
              footer: Text(""),
            ),
            body: FavoritePage(),
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
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.icon,
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FavoritePage extends StatefulWidget {
  FavoritePage({
    Key? key,
  }) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<RouteBar> _list = [];

  List<RouteBar> _getFavoriteRoutes() {
    List<BusRoute> favorite = RouteData.getFavoriteList();

    List<RouteBar> routeBars = [];
    for (var f in favorite) {
      routeBars.add(RouteBar(
        busRoute: f,
      ));
    }

    return routeBars;
  }

  @override
  void initState() {
    super.initState();
    _list = _getFavoriteRoutes();
    RouteData.favoriteController.stream.listen((event) {
      if (mounted) {
        setState(() {
          _list = _getFavoriteRoutes();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            children: _list.isEmpty
                ? [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.36,
                    ),
                    Text(
                      BusApp.noFavorite,
                      style: TextStyle(fontSize: 23),
                    )
                  ]
                : _list,
          ),
        ),
      ),
    );
  }
}
