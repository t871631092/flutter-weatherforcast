import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weatherforcast/ApiService.dart';
import 'package:weatherforcast/weatherPage.dart';
import 'dart:ui';

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
  int currdentData = 0;
  bool isok = false;
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
      setState(() {
        if (value != null) {
          setState(() {
            _lenght.value = value;
          });
        }
      });
      if (_lenght.value == null) {
        _lenght.value = ['长沙', '北京'];
      }
      setState(() {
        isok = true;
      });
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
    String str;
    await ApiService.getLocation()
        .then((value) => str = '${value.latitude}:${value.longitude}');
    ApiService.p(str, (List<dynamic> callback) {
      print("获取当前城市" + callback.toString());
      if (callback.length != 0) {
        if (_lenght.value != null &&
            _lenght.value.contains(callback[0]['location']['name'])) {
          return;
        } else {
          setState(() {
            _lenght.value.insert(0, callback[0]['location']['name']);
            curPage = 1;
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

  List<Widget> getWidget() {
    if (cityname == "") {
      return [
        Expanded(
            child: RefreshIndicator(
                child: ListView.builder(
                    itemCount: this._lenght.value.length,
                    itemExtent: 50.0, //强制高度为50.0
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text("${this._lenght.value[index]}"),
                        onTap: () {
                          setState(() {
                            currdentData = index;
                          });
                        },
                        trailing: TextButton(
                          child: Text("删除"),
                          onPressed: () {
                            delete(this._lenght.value[index]);
                          },
                        ),
                      );
                    }),
                onRefresh: () async {
                  print("123");
                }))
      ];
    } else {
      return [
        Expanded(
            child: ListView(
          children: [
            for (var item in search_list)
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    height: 80,
                    child: Center(
                      child:
                          Text('${item['name']}', textAlign: TextAlign.center),
                    ),
                  )),
                  Expanded(
                    child: TextButton(
                      child: Text("添加"),
                      onPressed: () {
                        print('add0');
                        add(item);
                      },
                    ),
                  ),
                ],
              )
          ],
        ))
      ];
    }
  }

  List<dynamic> search_list = [];
  String cityname = "";
  void inputcity(String str) {
    setState(() {
      print(str);
      cityname = str;
    });
    ApiService.searchLocation(str, (cb) {
      setState(() {
        search_list = cb;
      });
    });
  }

  TextEditingController tc1 = new TextEditingController();
  void add(dynamic item) {
    _add(item['name']);
    setState(() {
      cityname = "";
      tc1.value = TextEditingValue.empty;
      tc1.clear();
    });
  }

  void delete(dynamic item) {
    setState(() {
      _remove(item);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: wData.length > 0
            ? Text(wData[currdentData]['location']['name'])
            : Text('Loading'),
        backgroundColor: Color(0xFFA16BFE),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(
                1.5, 1.5), // 10% of the width, so there are ten blinds.
            colors: [
              const Color(0xFFA16BFE),
              const Color(0xFFBC3D2F)
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
                if (wData.length > 0)
                  WeatherPage(
                      key: Key(wData[currdentData]['location']['name']),
                      location: wData[currdentData]['location']['name'],
                      daily: wData[currdentData]['daily'],
                      suggestion: wData[currdentData]['suggestion'],
                      now: wData[currdentData]['now'],
                      refresh: _test),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Scaffold(
          appBar: AppBar(
            title: Text("城市"),
            backgroundColor: Color(0xFFA16BFE),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                margin: EdgeInsets.all(8),
                height: 45,
                child: Center(
                  child: TextField(
                    controller: tc1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '城市名',
                      suffix: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {},
                      ),
                    ),
                    onChanged: inputcity,
                  ),
                ),
              ),
              for (var item in getWidget()) item,
              Container(
                padding: EdgeInsets.all(3),
                height: 23,
                child: Text(
                  "天气数据由心知天气提供",
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ));
}
