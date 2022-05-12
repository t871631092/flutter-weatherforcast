import 'dart:async';

import 'package:flutter/material.dart';
import 'package:via_logger/logger.dart';
import 'package:weatherforcast/ApiService.dart';
import 'package:weatherforcast/loginPage.dart';
import 'package:weatherforcast/model/User.dart';
import 'package:weatherforcast/profilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagePage extends StatefulWidget {
  final _add;
  final _remove;
  final _list;
  final _set;
  ManagePage(this._set, this._add, this._remove, List<dynamic> this._list);
  @override
  _ManagePage createState() => _ManagePage();
}

class _ManagePage extends State<ManagePage> {
  Widget _LoginButton;
  Widget list;

  @override
  void initState() {
    super.initState();
    list = getWidget();
    ApiService.getNows(widget._list, (cb) {
      Logger.info(cb);
    });
    ApiService.islogin();
    _LoginButton = _buildBarButton(false);
    checkIsLogin();
    Global.eventBus.on<User>().listen((event) {
      Logger.info('event.islogin');
      Logger.info(event.islogin);
      widget._set();
      setState(() {
        _LoginButton = _buildBarButton(event.islogin);
        list = getWidget();
      });
    });
  }

  List<dynamic> search_list = [];
  String cityname = "";
  Timer timer;
  void inputcity(String str) {
    setState(() {
      Logger.info(str);
      cityname = str;
      list = getWidget();
    });
    if (timer != null && timer.isActive) {
      timer.cancel();
    }
    if (str.isNotEmpty) {
      timer = Timer(Duration(milliseconds: 500), () {
        Logger.info('search' + str);
        ApiService.searchLocation(str, (cb) {
          setState(() {
            search_list = cb;
            Logger.info(cb);
            list = getWidget();
          });
        });
      });
    }
  }

  TextEditingController tc1 = new TextEditingController();
  void add(dynamic item) {
    widget._add(item['name']);
    setState(() {
      cityname = "";
      list = getWidget();
      tc1.value = TextEditingValue.empty;
      tc1.clear();
    });
  }

  void delete(dynamic item) {
    setState(() {
      widget._remove(item);
    });
  }

  Widget getWidget() {
    if (cityname == "") {
      return Expanded(
          child: RefreshIndicator(
              child: ListView.builder(
                  itemCount: widget._list.length,
                  itemExtent: 50.0, //强制高度为50.0
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text("${widget._list[index]}"),
                      trailing: TextButton(
                        child: Text("删除"),
                        onPressed: () {
                          delete(widget._list[index]);
                        },
                      ),
                    );
                  }),
              onRefresh: () async {
                Logger.info("123");
              }));
    } else {
      return Expanded(
          child: ListView(
        children: [
          for (var item in search_list)
            Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                  height: 80,
                  child: Center(
                    child: Text('${item['name']}', textAlign: TextAlign.center),
                  ),
                )),
                Expanded(
                  child: TextButton(
                    child: Text("添加"),
                    onPressed: () {
                      Logger.info('add0');
                      add(item);
                    },
                  ),
                ),
              ],
            )
        ],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("城市管理"),
        actions: <Widget>[
          _LoginButton,
        ],
      ),
      //backgroundColor: Colors.transparent,
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
          list,
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
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   if (cityname == "") {
  //     return Scaffold(
  //       appBar: AppBar(
  //         title: Text("城市管理"),
  //         actions: <Widget>[
  //           _LoginButton,
  //         ],
  //       ),
  //       body: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Container(
  //             key: Key("tc1"),
  //             color: Colors.white,
  //             margin: EdgeInsets.all(8),
  //             height: 45,
  //             child: Center(
  //               child: TextField(
  //                 controller: tc1,
  //                 decoration: InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   labelText: '城市名',
  //                   suffix: IconButton(
  //                     icon: Icon(Icons.search),
  //                     onPressed: () {},
  //                   ),
  //                 ),
  //                 onChanged: inputcity,
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //               child: RefreshIndicator(
  //                   child: ListView.builder(
  //                       itemCount: widget._list.length,
  //                       itemExtent: 50.0, //强制高度为50.0
  //                       itemBuilder: (BuildContext context, int index) {
  //                         return ListTile(
  //                           title: Text("${widget._list[index]}"),
  //                           trailing: TextButton(
  //                             child: Text("删除"),
  //                             onPressed: () {
  //                               delete(widget._list[index]);
  //                             },
  //                           ),
  //                         );
  //                       }),
  //                   onRefresh: () async {
  //                     Logger.info("123");
  //                   })),
  //           Container(
  //             padding: EdgeInsets.all(3),
  //             height: 23,
  //             child: Text(
  //               "天气数据由心知天气提供",
  //               style: TextStyle(fontSize: 11),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     return Scaffold(
  //       appBar: AppBar(
  //         title: Text("城市管理"),
  //       ),
  //       //backgroundColor: Colors.transparent,
  //       body: SingleChildScrollView(
  //           child: Column(
  //         children: [
  //           Container(
  //             key: Key("tc1"),
  //             color: Colors.white,
  //             margin: EdgeInsets.all(8),
  //             height: 45,
  //             child: Center(
  //               child: TextField(
  //                 decoration: InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   labelText: '城市名',
  //                   suffix: IconButton(
  //                     icon: Icon(Icons.search),
  //                     onPressed: () {},
  //                   ),
  //                 ),
  //                 onChanged: inputcity,
  //               ),
  //             ),
  //           ),
  //           for (var item in search_list)
  //             Row(
  //               children: <Widget>[
  //                 Expanded(
  //                     child: Container(
  //                   height: 80,
  //                   child: Center(
  //                     child:
  //                         Text('${item['name']}', textAlign: TextAlign.center),
  //                   ),
  //                 )),
  //                 Expanded(
  //                   child: TextButton(
  //                     child: Text("添加"),
  //                     onPressed: () {
  //                       Logger.info('add0');
  //                       add(item);
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             )
  //         ],
  //       )),
  //     );
  //   }
  // }

  Widget _buildBarButton(isLogin) {
    if (isLogin) {
      return ElevatedButton(
        child: Text("用户"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return profilePage();
            }),
          );
        },
      );
    } else {
      return ElevatedButton(
        child: Text("登陆"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return LoginPage();
            }),
          );
        },
      );
    }
  }

  Future<void> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Logger.info('checkIsLogin');
    Logger.info(prefs.containsKey('cookie'));
    _LoginButton = _buildBarButton(prefs.containsKey('cookie'));
  }
}
