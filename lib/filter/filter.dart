import 'package:busapp/BusApp.dart';
import 'package:busapp/filter/filter_label.dart';
import 'package:flutter/material.dart';

class Filter extends StatefulWidget {
  Filter({Key? key, required this.totalLocationName}) : super(key: key);

  final List<List<String>> totalLocationName;

  static List<int> filterSelectedIndex = [-1, -1];

  @override
  State<StatefulWidget> createState() {
    return _Filter();
  }
}

class _Filter extends State<Filter> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Title(
          color: BusApp.mainColor,
          child: const Text(
            BusApp.filterTitle,
            style: TextStyle(fontSize: 25),
          )),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        width: double.maxFinite,
        child: ListView(
          children: [
            const Text(
              BusApp.location,
              style: TextStyle(color: Colors.black54),
            ),
            FilterLabel(
              totalLocationName: widget.totalLocationName[0],
              index: 0,
            ),
            const Text(BusApp.routes, style: TextStyle(color: Colors.black54)),
            FilterLabel(
              totalLocationName: widget.totalLocationName[1],
              index: 1,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(BusApp.mainColor),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(BusApp.acceptButton),
        )
      ],
    );
  }
}
