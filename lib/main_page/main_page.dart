import 'package:busapp/BusApp.dart';

import 'package:busapp/main_page/favorite.dart';
import 'package:busapp/main_page/history.dart';
import 'package:busapp/main_page/image_slider.dart';
import 'package:busapp/main_page/search.dart';
import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 25),
              ImageSlider(),
              const SizedBox(height: 25),
              SearchBar(
                searchSuggestion: BusApp.searchSuggestion,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Expanded(child: Favorite(title: BusApp.favorite)),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: History(
                    title: BusApp.history,
                  ))
                ],
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
