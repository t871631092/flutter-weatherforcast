import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weatherforcast/ApiService.dart';
import 'package:weatherforcast/loginPage.dart';
import 'package:weatherforcast/managePage.dart';
import 'package:weatherforcast/weatherPage.dart';
import 'dart:ui';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

//weatherforcast
//write by kqq@papaz.me

void main() {
  // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前
  // MaterialApp组件会覆盖掉这个值。
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const Widget _home = HomePage();
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
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
  ValueNotifier<List<String>> _lenght = ValueNotifier([]);
  List<dynamic> wData = [];
  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _lenght.addListener(() {
      print("变更");
      ApiService.getNows(_lenght.value, (cb) {
        print(cb);
        if (cb.length > 0) {
          setState(() {
            print('全部天气' + cb.toString());
            wData = cb;
          });
        }
      });
    });
    ApiService.getCity().then((value) {
      if (value != null) {
        setState(() {
          _lenght.value = value;
        });
      }
      if (value == null) {
        _lenght.value = ['长沙', '北京'];
      }
      getlocation();
      autoUpdate();
    });
  }

  void autoUpdate() {
    Timer(Duration(hours: 1), () {
      ApiService.getNows(_lenght.value, (cb) {
        print(cb);
        if (cb.length > 0) {
          setState(() {
            print('全部天气' + cb.toString());
            wData = cb;
          });
        }
        autoUpdate();
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void getlocation() async {
    print("getlocation");
    String str;
    await ApiService.getLocation().then((value) {
      str = '${value.latitude}:${value.longitude}';
      print("getlocation1" + str);
    });
    ApiService.p(str, (List<dynamic> callback) {
      print("获取当前城市" + callback.toString());
      if (callback.length != 0) {
        if (_lenght.value != null &&
            _lenght.value.contains(callback[0]['location']['name'])) {
          return;
        } else {
          setState(() {
            _lenght.value.insert(0, callback[0]['location']['name']);
            wData.insert(0, callback[0]);
            curPage = 0;
            setState(() {
              _controller.previousPage(
                  duration: Duration(seconds: 1), curve: Curves.easeIn);
            });
            ApiService.saveCity(_lenght.value);
          });
        }
      }
    });
  }

  void _add(str) => setState(() {
        if (_lenght.value.contains(str) || str == '') {
          return;
        }
        _lenght.value.add(str);
        ApiService.saveCity(_lenght.value);
        ApiService.getNows(_lenght.value, (cb) {
          print(cb);
          if (cb.length > 0) {
            setState(() {
              print('全部天气' + cb.toString());
              wData = cb;
            });
          }
          _controller.jumpToPage(_lenght.value.length);
        });
      });

  void _remove(String name) => setState(() {
        if (_lenght.value.length > 1) {
          _lenght.value.removeWhere((element) => element == name);
          curPage = _lenght.value.length;
          ApiService.saveCity(_lenght.value);
          wData.removeWhere((element) => element['location']['name'] == name);
        }
      });
  void _test(String string) => setState(() {
        wData.forEach((element) {
          if (element['location']['name'] == string) {
            ApiService.p(string, (result) {
              print("789");
              if (result != false) {
                setState(() {
                  element['now'] = result[0]['now'];
                  element['daily'] = result[0]['daily'];
                  element['suggestion'] = result[0]['suggestion'];
                });
                print(result);
              }
            });
          }
        });
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        // appBar: PreferredSize(
        //   preferredSize:
        //       Size.fromHeight(MediaQueryData.fromWindow(window).padding.top),
        //   child: SafeArea(
        //     top: true,
        //     child: Offstage(),
        //   ),
        // ),
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
              tileMode:
                  TileMode.repeated, // repeats the gradient over the canvas
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
                  for (var i in wData)
                    WeatherPage(
                        key: Key(i['location']['name']),
                        location: i['location']['name'],
                        daily: i['daily'],
                        suggestion: i['suggestion'],
                        now: i['now'],
                        refresh: _test),
                  ManagePage(this._add, this._remove, this._lenght.value),
                  LoginPage()
                ],
              ),
              Positioned(
                  bottom: 20,
                  child: PageViewDotIndicator(
                    currentItem: curPage,
                    count: wData.length + 2,
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
        ),
      );
}
