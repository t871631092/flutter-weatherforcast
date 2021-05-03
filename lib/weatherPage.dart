import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weatherforcast/ApiService.dart';
import 'package:weatherforcast/Model.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  final location;
  WeatherPage({Key key, String this.location}) : super(key: key);

  @override
  _WeatherPage createState() => _WeatherPage();
}

class _WeatherPage extends State<WeatherPage> {
  bool isOK = false;
  WeatherData weatherData = new WeatherData();
  void initState() {
    super.initState();
    ApiService.p(widget.location, (result) {
      if (result != false) {
        setState(() {
          weatherData.data = result;
          isOK = true;
        });
        print(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isOK) {
      return RefreshIndicator(
          onRefresh: () async {
            ApiService.p(widget.location, (result) {
              if (result != false) {
                setState(() {
                  weatherData.data = result;
                  isOK = true;
                });
                print("refresh");
              }
            });
          },
          child: ListView(
            children: [
              Column(
                children: [
                  Container(
                    child: Center(
                      child: Text(isOK
                          ? '${new DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(weatherData.data['last_update']))}'
                          : ''),
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text(
                          isOK ? weatherData.data['location']['name'] : ''),
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text(isOK
                          ? '${weatherData.data['now']['temperature']}°'
                          : ''),
                    ),
                  ),
                  Offstage(
                    offstage: !isOK,
                    child: Container(
                      child: Center(
                          child: Image(
                              image: AssetImage(isOK
                                  ? 'lib/assets/${weatherData.data['now']['code']}@2x.png'
                                  : 'lib/assets/99@2x.png'))),
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text(
                          isOK ? '${weatherData.data['now']['text']}' : ''),
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
