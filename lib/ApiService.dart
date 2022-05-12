import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherforcast/model/User.dart';

class ApiService {
  static String key = "S6pTS6PlJWjLCRroi"; //"SxytzgbMmIFfKL3Ck";
  ApiService();
  static dynamic p(str, data) async {
    if (str == 'here') {
      await ApiService.getLocation()
          .then((value) => str = '${value.latitude}:${value.longitude}');
    }
    var result;
    await http
        .get(Uri.parse(
            'https://api.seniverse.com/v3/weather/now.json?key=$key&location=$str'))
        .then((value) {
      print(value);
      if (value.statusCode == 200) {
        print("123");
        result = JSON.jsonDecode(value.body)['results'][0];
      } else {
        data(false);
        return false;
      }
    }).catchError((onError) {
      print("error");
    });
    await http
        .get(Uri.parse(
            'https://api.seniverse.com/v3/weather/daily.json?key=$key&location=$str&language=zh-Hans&unit=c&start=0&days=7'))
        .then((value) {
      if (value.statusCode == 200) {
        result['daily'] = JSON.jsonDecode(value.body)['results'][0]['daily'];
      } else {
        data(false);
        return false;
      }
    }).catchError((onError) {
      print("error");
    });
    await http
        .get(Uri.parse(
            'https://api.seniverse.com/v3/life/suggestion.json?key=$key&location=$str&language=zh-Hans'))
        .then((value) {
      if (value.statusCode == 200) {
        result['suggestion'] =
            JSON.jsonDecode(value.body)['results'][0]['suggestion'];
      } else {
        data(false);
        return false;
      }
    }).catchError((onError) {
      print("error");
    });
    await http
        .get(Uri.parse(
            'https://api.seniverse.com/v3/weather/hourly.json?key=$key&location=$str&language=zh-Hans&unit=c&start=0&hours=24'))
        .then((value) {
      if (value.statusCode == 200) {
        result['hourly'] = JSON.jsonDecode(value.body)['results'][0]['hourly'];
      } else {
        data(false);
        return false;
      }
    }).catchError((onError) {
      print("error");
    });
    data([result]);
  }

  static void getNows(List<dynamic> locations, callback) async {
    //实况
    List<http.Response> list = await Future.wait(locations.map((e) {
      return http.get(Uri.parse(
          'https://api.seniverse.com/v3/weather/now.json?key=$key&location=$e'));
    }));
    //预报
    List<http.Response> list1 = await Future.wait(locations.map((e) {
      return http.get(Uri.parse(
          'https://api.seniverse.com/v3/weather/daily.json?key=$key&location=$e&language=zh-Hans&unit=c&start=0&days=7'));
    }));
    //生活
    List<http.Response> list2 = await Future.wait(locations.map((e) {
      return http.get(Uri.parse(
          'https://api.seniverse.com/v3/life/suggestion.json?key=$key&location=$e&language=zh-Hans'));
    }));
    // 24 hours
    List<http.Response> list3 = await Future.wait(locations.map((e) {
      return http.get(Uri.parse(
          'https://api.seniverse.com/v3/weather/hourly.json?key=$key&location=$e&language=zh-Hans&unit=c&start=0&hours=24'));
    }));
    List<dynamic> results = [];
    print(list);
    list.forEach((element) {
      if (element.statusCode == 200) {
        var el = JSON.jsonDecode(element.body)['results'][0];
        list1.forEach((element1) {
          if (element1.statusCode == 200) {
            var el1 = JSON.jsonDecode(element1.body)['results'][0];
            if (element.statusCode == 200 &&
                el1['location']['name'] == el['location']['name']) {
              el['daily'] = el1['daily'];
            }
          }
        });
        list2.forEach((element2) {
          if (element2.statusCode == 200) {
            var el2 = JSON.jsonDecode(element2.body)['results'][0];
            if (element.statusCode == 200 &&
                el2['location']['name'] == el['location']['name']) {
              el['suggestion'] = el2['suggestion'];
            }
          }
        });
        list3.forEach((element3) {
          if (element3.statusCode == 200) {
            var el3 = JSON.jsonDecode(element3.body)['results'][0];
            if (element.statusCode == 200 &&
                el3['location']['name'] == el['location']['name']) {
              el['hourly'] = el3['hourly'];
            }
          }
        });
        results.add(el);
      }
    });
    callback(results);
  }

  static void searchLocation(String location, callback) async {
    http.Response result = await http.get(Uri.parse(
        'https://api.seniverse.com/v3/location/search.json?key=$key&q=$location'));
    if (result.statusCode == 200) {
      callback(JSON.jsonDecode(result.body)['results']);
    } else {
      callback([]);
    }
  }

  static Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static void saveCity(strs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('citys', strs);
    ApiService.saveaddress();
  }

  static Future<List<String>> getCity() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('cookie')) {
      await ApiService.islogin();
      return sharedPreferences.getStringList('citys');
    } else {
      return sharedPreferences.getStringList('citys');
    }
  }

  static void login(username, password, context) async {
    await http.post(Uri.parse('http://192.168.199.140:8088/account/login'),
        body: {'username': username, 'password': password}).then((value) async {
      if (value.statusCode == 200) {
        if (value.headers['set-cookie'] != null) {
          var result = JSON.jsonDecode(value.body);
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString('cookie', value.headers['set-cookie']);
          if ((result['data']['locations'] as List).isNotEmpty) {
            sharedPreferences.setStringList(
                'citys', result['data']['locations']);
          }
          sharedPreferences.setString('nickname', result['data']['nickname']);
          print('login成功');
          Global.eventBus.fire(User(true));
          Navigator.pop(context, true);
        }
      } else {
        return false;
      }
    }).catchError((onError) {
      print("error");
    });
  }

  static Future<List<String>> islogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = '';
    if (sharedPreferences.containsKey('cookie')) {
      token = sharedPreferences.getString('cookie');
    }
    await http.get(Uri.parse('http://192.168.199.140:8088/account/islogin'),
        headers: {'Cookie': token}).then((value) async {
      if (value.statusCode == 200) {
        var result = JSON.jsonDecode(value.body);
        print(result['data']['locations']);
        if (result['success']) {
          sharedPreferences.setStringList('citys', result['data']['locations']);
          sharedPreferences.setString('nickname', result['data']['nickname']);
        } else {
          sharedPreferences.remove('cookie');
          sharedPreferences.remove('nickname');
        }
        return result['data']['locations'];
      } else {
        return [];
      }
    }).catchError((onError) {
      print("error");
      return [];
    });
  }

  static void logout() async {
    print("api.logout()");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = '';
    if (sharedPreferences.containsKey('cookie')) {
      token = sharedPreferences.getString('cookie');
    }
    await http.get(Uri.parse('http://192.168.199.140:8088/account/logout'),
        headers: {'Cookie': token}).then((value) async {
      if (value.statusCode == 200) {
        var result = JSON.jsonDecode(value.body);
        if (result['success']) {
          sharedPreferences.remove('cookie');
          sharedPreferences.remove('nickname');
          print('登出成功');
          print(sharedPreferences.containsKey('nickname'));
          print(sharedPreferences.containsKey('cookie'));
          Global.eventBus.fire(User(false));
          print('登出成功end');
        } else {}
      } else {
        return false;
      }
    }).catchError((onError) {
      print("logout error");
    });
  }

  static void register(content, username, password, nickname, email) async {
    print(username + password + nickname + email);
    await http.post(Uri.parse('http://192.168.199.140:8088/account/register'),
        body: {
          'username': username,
          'password': password,
          'email': email,
          'nickname': nickname
        }).then((value) async {
      if (value.statusCode == 200) {
        if (JSON.jsonDecode(value.body)['success']) {
          Navigator.pop(content);
        } else {}
      } else {}
    }).catchError((onError) {
      print("error");
    });
  }

  static void saveaddress() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = '';
    if (sharedPreferences.containsKey('cookie')) {
      token = sharedPreferences.getString('cookie');
    }
    var a = sharedPreferences.get('citys');
    var city = '';
    (a as List).forEach((e) {
      if (city == '') {
        city = e;
      } else {
        city += ",";
        city += e;
      }
    });
    await http.post(
        Uri.parse('http://192.168.199.140:8088/account/saveaddress'),
        body: {'locations': city},
        headers: {'Cookie': token}).then((value) async {
      if (value.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }).catchError((onError) {
      print("error");
    });
  }
}
