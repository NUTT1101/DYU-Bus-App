import 'package:busapp/scaffold/help_dialog.dart';
import 'package:busapp/scaffold/page_info_dialog.dart';
import 'package:flutter/material.dart';

import '../BusApp.dart';

class App extends StatelessWidget implements PreferredSizeWidget {
  App({
    Key? key,
    this.title,
    this.header,
    this.footer,
  }) : super(key: key);

  final String? title;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: header ??
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return PageInfoDialog();
              },
            ),
            child: const Icon(Icons.info),
          ),
      centerTitle: true,
      title: Text(title == null ? BusApp.appName : title!),
      backgroundColor: BusApp.mainColor,
      actions: [
        footer ??
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return HelpDialog();
                },
              ),
              child: const Icon(Icons.help),
            ),
        const SizedBox(width: 10)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
