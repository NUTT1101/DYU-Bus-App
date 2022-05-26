import 'package:busapp/data/route_data.dart';
import 'package:busapp/filter/filter.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';

import '../BusApp.dart';

class FilterLabel extends StatefulWidget {
  FilterLabel({
    Key? key,
    required this.totalLocationName,
    required this.index,
  }) : super(key: key);

  final List<String> totalLocationName;
  final int index;

  @override
  State<StatefulWidget> createState() {
    return _FilterLabel();
  }
}

class _FilterLabel extends State<FilterLabel> {
  @override
  Widget build(BuildContext context) {
    return ChipsChoice<int>.single(
      choiceStyle: const C2ChoiceStyle(
        labelStyle: TextStyle(fontSize: 17),
        borderColor: BusApp.mainColor,
        color: BusApp.mainColor,
        showCheckmark: false,
      ),
      choiceActiveStyle: const C2ChoiceStyle(
          labelStyle: TextStyle(fontSize: 17),
          borderColor: Colors.white,
          color: Color.fromRGBO(33, 150, 243, 1.0),
          brightness: Brightness.dark),
      wrapped: true,
      value: Filter.filterSelectedIndex[widget.index],
      onChanged: (val) => setState(() {
        if (val != Filter.filterSelectedIndex[widget.index]) {
          Filter.filterSelectedIndex[widget.index] = val;
          RouteData.filterController.add(0);
        } else if (Filter.filterSelectedIndex[widget.index] == val) {
          Filter.filterSelectedIndex[widget.index] = -1;
          RouteData.filterController.add(1);
        }
      }),
      choiceItems: C2Choice.listFrom<int, String>(
        source: widget.totalLocationName,
        value: (i, v) => i,
        label: (i, v) => v,
      ),
    );
  }
}
