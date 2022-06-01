import 'package:busapp/data/route_data.dart';
import 'package:busapp/scaffold/appbar.dart';
import 'package:busapp/webview_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  ImageSlider({Key? key}) : super(key: key);

  @override
  _ImageSlider createState() => _ImageSlider();
}

class _ImageSlider extends State<ImageSlider> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: RouteData.imageList.length,
            itemBuilder: (context, itemIndex, pageViewIndex) {
              return Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: App(
                                    title: RouteData
                                        .imageList[itemIndex].linkTitle,
                                    header: Text(""),
                                    footer: Text(""),
                                  ),
                                  body: WebViewPage(
                                    url: RouteData
                                        .imageList[itemIndex].imageLink,
                                  ),
                                ),
                              ),
                            ),
                            child: RouteData.imageList[itemIndex].image,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: RouteData.imageList.map((silder) {
                              int index = RouteData.imageList.indexOf(silder);
                              return Container(
                                width: 10.0,
                                height: 10.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentPage == index
                                      ? const Color.fromRGBO(255, 255, 255, 1)
                                      : const Color.fromRGBO(0, 0, 0, 0.7),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
            options: CarouselOptions(
                autoPlay: true,
                viewportFraction: 1,
                enlargeCenterPage: true,
                onPageChanged: (index, reson) {
                  setState(() {
                    currentPage = index;
                  });
                }),
          ),
        ],
      ),
    );
  }
}
