import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherforcast/Model.dart';

class WeatherPage extends StatefulWidget {
  final String location;
  final dynamic now;
  final dynamic refresh;
  final dynamic daily;
  final dynamic suggestion;
  WeatherPage(
      {Key key,
      this.location,
      this.now,
      this.refresh,
      this.daily,
      this.suggestion})
      : super(key: key);

  @override
  _WeatherPage createState() => _WeatherPage();
}

class _WeatherPage extends State<WeatherPage> {
  bool isOK = true;
  WeatherData weatherData = new WeatherData();
  void initState() {
    print("initState");
    print(widget.now);
    super.initState();
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _scrollViewController.addListener(changeColor);
  }

  var _gradientColor2 = Colors.blue[600].withOpacity(0);
  ScrollController _scrollViewController;
  void changeColor() {
    if (_scrollViewController.offset == 0) {
      setState(() {
        _gradientColor2 = Colors.blue[600].withOpacity(0);
      });
    }
    // else if (_scrollViewController.offset <= 30) {
    //   setState(() {
    //     _gradientColor2 = Colors.blue[600].withOpacity(0.2);
    //   });
    // } else if (_scrollViewController.offset <= 100) {
    //   var opacity = _scrollViewController.offset / 100;
    //   setState(() {
    //     _gradientColor2 = Colors.blue[600].withOpacity(opacity);
    //   });
    // }
  }

  List<Widget> getDaily(data) {
    List<Widget> list = [];
    list.add(Container(
      height: 35,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
              flex: 1,
              child: Center(
                child: Text(''),
              )),
          Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '早上',
                  style: TextStyle(fontSize: 10),
                ),
              )),
          Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '晚间',
                  style: TextStyle(fontSize: 10),
                ),
              )),
          Expanded(
            flex: 1,
            child: Text(
              '降雨概率',
              style: TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '最高',
                  style: TextStyle(fontSize: 10),
                ),
              )),
          Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '最低',
                  style: TextStyle(fontSize: 10),
                ),
              )),
        ],
      ),
    ));
    list.add(
      Divider(
        height: 1.0,
        color: Colors.black,
      ),
    );
    for (var i in data) {
      list.add(Container(
        height: 45,
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                      '${new DateFormat('d').format(DateTime.parse(i['date']))}日'),
                )),
            Expanded(
                flex: 1,
                child: Image(
                    width: 25,
                    height: 25,
                    image: AssetImage(isOK
                        ? 'lib/assets/${i['code_day']}@2x.png'
                        : 'lib/assets/99@2x.png'))),
            // Expanded(
            //     flex: 1,
            //     child: Center(
            //       child: Text('${i['text_day']}'),
            //     )),
            Expanded(
                flex: 1,
                child: Image(
                    width: 25,
                    height: 25,
                    image: AssetImage(isOK
                        ? 'lib/assets/${i['code_night']}@2x.png'
                        : 'lib/assets/99@2x.png'))),
            // Expanded(
            //     flex: 1,
            //     child: Center(
            //       child: Text('${i['text_night']}'),
            //     )),
            Expanded(
              flex: 1,
              child: Text(i['precip'] == "" ? '' : '${i['precip']}%'),
            ),
            Expanded(
                flex: 1,
                child: Center(
                  child: Text('${i['high']}°'),
                )),
            Expanded(
                flex: 1,
                child: Center(
                  child: Text('${i['low']}°'),
                )),
          ],
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (isOK) {
      return DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: ListView(
            children: [
              Column(
                children: [
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Text(
                        isOK ? '${widget.now['text']}' : '',
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      )),
                      Padding(
                        padding: EdgeInsets.only(left: 30, top: 20, bottom: 15),
                        child: Center(
                            child: Text(
                          isOK ? '${widget.now['temperature']}°' : '',
                          style: TextStyle(fontSize: 40, color: Colors.white),
                        )),
                      )
                    ],
                  )),
                  Container(
                      padding: EdgeInsets.only(top: 0, bottom: 20),
                      child: Column(
                        children: getDaily(widget.daily),
                      )),
                  Divider(
                    height: 1.0,
                    color: Colors.black,
                  ),
                  Container(
                    height: 25,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                            child: Center(
                          child: Text("穿衣"),
                        )),
                        Expanded(
                            child: Center(
                          child: Text("紫外线强度"),
                        )),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                            child: Center(
                          child: Text(
                            "${widget.suggestion['dressing']['brief']}",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                        Expanded(
                            child: Center(
                          child: Text(
                            "${widget.suggestion['uv']['brief']}",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.black,
                  ),
                  Container(
                    height: 25,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                            child: Center(
                          child: Text("洗车"),
                        )),
                        Expanded(
                            child: Center(
                          child: Text("旅游"),
                        )),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                            child: Center(
                          child: Text(
                            "${widget.suggestion['car_washing']['brief']}",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                        Expanded(
                            child: Center(
                          child: Text(
                            "${widget.suggestion['travel']['brief']}",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.black,
                  ),
                  Container(
                    height: 25,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                            child: Center(
                          child: Text("感冒"),
                        )),
                        Expanded(
                            child: Center(
                          child: Text("运动"),
                        )),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                            child: Center(
                          child: Text(
                            "${widget.suggestion['flu']['brief']}",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                        Expanded(
                            child: Center(
                          child: Text(
                            "${widget.suggestion['sport']['brief']}",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.black,
                  ),
                  Container(
                    height: 30,
                    child: Center(
                      child: Text('天气数据由心知天气提供'),
                    ),
                  )
                ],
              )
            ],
          ));
    } else {
      return Container(
        child: Center(
          child: Text('暂无数据'),
        ),
      );
    }
  }
}
