import 'package:busapp/BusApp.dart';
import 'package:busapp/data/route_data.dart';
import 'package:flutter/material.dart';

class PageInfoDialog extends StatelessWidget {
  const PageInfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        BusApp.helpButtonTitle,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: RouteData.aboutInfo.length,
          itemBuilder: ((context, index) => Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                RouteData.aboutInfo[index],
              ))),
        ),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.black)),
          onPressed: () => Navigator.pop(context),
          child: const Text(BusApp.acceptButton),
        ),
      ],
    );
  }
}
