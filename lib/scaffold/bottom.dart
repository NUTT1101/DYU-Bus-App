import 'package:busapp/BusApp.dart';
import 'package:flutter/material.dart';

class Bottom extends StatefulWidget {
  Bottom({required this.update, Key? key}) : super(key: key);
  final ValueChanged<int> update;

  @override
  _Bottom createState() => _Bottom();
}

class _Bottom extends State<Bottom> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      backgroundColor: BusApp.mainColor,
      unselectedItemColor: Colors.grey[500],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_filled,
          ),
          label: BusApp.mainPage,
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.timer), label: BusApp.dynamicRoutes),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.roundabout_left,
            ),
            label: BusApp.allRoutes),
      ],
      onTap: (index) {
        widget.update(index);
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
