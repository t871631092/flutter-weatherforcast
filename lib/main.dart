import 'package:flutter/material.dart';
import 'package:weatherforcast/ApiService.dart';
import 'package:weatherforcast/managePage.dart';
import 'package:weatherforcast/weatherPage.dart';
import 'dart:ui';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const Widget _home = HomePage();
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: _home,
      );
}

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _controller;
  int curPage = 0;
  List<String> _lenght = [];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    setState(() {
      ApiService.getCity().then((value) {
        if (value != null) {
          _lenght = value;
        }
      });
      if (_lenght == null) {
        _lenght = ['长沙', '北京'];
      }
      getlocation();
      print(_lenght);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void getlocation() async {
    String str;
    await ApiService.getLocation()
        .then((value) => str = '${value.latitude}:${value.longitude}');
    ApiService.getNows([str], (List<dynamic> callback) {
      if (callback.length != 0) {
        if (_lenght != null &&
            _lenght.contains(callback[0]['location']['name'])) {
          return;
        } else {
          setState(() {
            _lenght.insert(0, callback[0]['location']['name']);
            curPage = 1;
            setState(() {
              _controller.previousPage(
                  duration: Duration(seconds: 1), curve: Curves.easeIn);
            });
            ApiService.saveCity(_lenght);
          });
        }
      }
    });
  }

  void _add(str) => setState(() {
        if (_lenght.contains(str) || str == '') {
          return;
        }
        _lenght.add(str);
        _controller.jumpToPage(_lenght.length);
        ApiService.saveCity(_lenght);
      });

  void _remove(String name) => setState(() {
        if (_lenght.length > 1) {
          _lenght.removeWhere((element) => element == name);
          curPage = _lenght.length;
          ApiService.saveCity(_lenght);
        }
      });

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQueryData.fromWindow(window).padding.top),
        child: SafeArea(
          top: true,
          child: Offstage(),
        ),
      )
      // actions: <Widget>[
      //   Padding(
      //     padding: const EdgeInsets.only(right: 20.0),
      //     child: IconButton(
      //       icon: const Icon(Icons.remove),
      //       onPressed: _remove,
      //     ),
      //   ),
      //   Padding(
      //     padding: const EdgeInsets.only(right: 20.0),
      //     child: IconButton(
      //       icon: const Icon(Icons.add),
      //       onPressed: _add,
      //     ),
      //   ),
      // ],
      ,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(
                1.5, 1.5), // 10% of the width, so there are ten blinds.
            colors: [
              const Color(0xFF41D8DD),
              const Color(0xFF6CACFF)
            ], // whitish to gray
            tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
        ),
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (page) {
                setState(() {
                  curPage = page;
                });
              },
              children: <Widget>[
                for (var i in _lenght)
                  WeatherPage(
                    key: Key(i),
                    location: i,
                  ),
                ManagePage(this._add, this._remove, this._lenght),
              ],
            ),
            Positioned(
                bottom: 10,
                child: PageViewDotIndicator(
                  currentItem: curPage,
                  count: _lenght.length + 1,
                  unselectedColor: Colors.black26,
                  selectedColor: Colors.blue,
                  duration: Duration(milliseconds: 200),
                ))
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 24),
            //   child:
            // ),
          ],
        ),
      ));
}
