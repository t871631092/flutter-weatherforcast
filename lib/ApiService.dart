import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:via_logger/logger.dart';
import 'package:weatherforcast/model/User.dart';

class ApiService {
  static String key = "SiDxi55cEAsRaAJYR"; //"SxytzgbMmIFfKL3Ck";
  static String host = "http://192.168.199.140:8088";
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
      Logger.info(value);
      if (value.statusCode == 200) {
        Logger.info("123");
        result = JSON.jsonDecode(value.body)['results'][0];
      } else {
        return false;
      }
    }).catchError((onError) {
      Logger.info("error");
    });
    await http
        .get(Uri.parse(
            'https://api.seniverse.com/v3/weather/daily.json?key=$key&location=$str&language=zh-Hans&unit=c&start=0&days=7'))
        .then((value) {
      if (value.statusCode == 200) {
        result['daily'] = JSON.jsonDecode(value.body)['results'][0]['daily'];
      } else {
        return false;
      }
    }).catchError((onError) {
      Logger.info("error");
    });
    await http
        .get(Uri.parse(
            'https://api.seniverse.com/v3/life/suggestion.json?key=$key&location=$str&language=zh-Hans'))
        .then((value) {
      if (value.statusCode == 200) {
        result['suggestion'] =
            JSON.jsonDecode(value.body)['results'][0]['suggestion'];
      } else {
        return false;
      }
    }).catchError((onError) {
      Logger.info("error");
    });
    await http
        .get(Uri.parse(
            'https://api.seniverse.com/v3/weather/hourly.json?key=$key&location=$str&language=zh-Hans&unit=c&start=0&hours=24'))
        .then((value) {
      if (value.statusCode == 200) {
        result['hourly'] = JSON.jsonDecode(value.body)['results'][0]['hourly'];
      } else {
        return false;
      }
    }).catchError((onError) {
      Logger.info("error");
    });
    if (result == null) {
    } else {
      data([result]);
    }
  }

  static void getNows(List<dynamic> locations, callback) async {
    //??????
    List<http.Response> list = await Future.wait(locations.map((e) {
      return http.get(Uri.parse(
          'https://api.seniverse.com/v3/weather/now.json?key=$key&location=$e'));
    }));
    //??????
    List<http.Response> list1 = await Future.wait(locations.map((e) {
      return http.get(Uri.parse(
          'https://api.seniverse.com/v3/weather/daily.json?key=$key&location=$e&language=zh-Hans&unit=c&start=0&days=7'));
    }));
    //??????
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
    Logger.info(list);
    list.forEach((element) {
      if (element.statusCode == 200) {
        var el = JSON.jsonDecode(element.body)['results'][0];
        if (list1 != null) {
          list1.forEach((element1) {
            if (element1.statusCode == 200) {
              var el1 = JSON.jsonDecode(element1.body)['results'][0];
              if (element.statusCode == 200 &&
                  el1['location']['name'] == el['location']['name']) {
                el['daily'] = el1['daily'];
              }
            }
          });
        }
        if (list2 != null) {
          list2.forEach((element2) {
            if (element2.statusCode == 200) {
              var el2 = JSON.jsonDecode(element2.body)['results'][0];
              if (element.statusCode == 200 &&
                  el2['location']['name'] == el['location']['name']) {
                el['suggestion'] = el2['suggestion'];
              }
            }
          });
        }
        if (list3 != null) {
          list3.forEach((element3) {
            if (element3.statusCode == 200) {
              var el3 = JSON.jsonDecode(element3.body)['results'][0];
              if (element.statusCode == 200 &&
                  el3['location']['name'] == el['location']['name']) {
                el['hourly'] = el3['hourly'];
              }
            }
          });
        }
        results.add(el);
      }
    });
    callback(results);
  }

  static void searchLocation(String location, callback) async {
    Logger.info(location);
    await http
        .get(Uri.parse(
            'https://api.seniverse.com/v3/location/search.json?key=$key&q=${location.trim()}'))
        .then((result) {
      if (result.statusCode == 200) {
        callback(JSON.jsonDecode(result.body)['results']);
      } else {
        callback([]);
      }
    });
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

  static void login(String username, String password, context) async {
    if (username.isEmpty) {
      Fluttertoast.showToast(
          msg: '??????????????????',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (password.isEmpty) {
      Fluttertoast.showToast(
          msg: '???????????????',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    await http.post(Uri.parse('$host/account/login'),
        body: {'username': username, 'password': password}).then((value) async {
      if (value.statusCode == 200) {
        if (value.headers['set-cookie'] != null) {
          var result = JSON.jsonDecode(value.body);
          Logger.info(result['data']);
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString('cookie', value.headers['set-cookie']);
          if ((result['data']['locations'] as List).isNotEmpty) {
            sharedPreferences.setStringList(
                'citys', (result['data']['locations'].cast<String>()));
          }
          sharedPreferences.setString('nickname', result['data']['nickname']);
          Logger.info('login??????');
          Global.eventBus.fire(User(true));
          Navigator.pop(context, true);
        } else {
          Fluttertoast.showToast(
              msg: JSON.jsonDecode(value.body)['msg'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        return false;
      }
    }).catchError((onError) {
      Logger.info("error login");
    });
  }

  static Future<bool> islogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = '';
    if (sharedPreferences.containsKey('cookie')) {
      token = sharedPreferences.getString('cookie');
    }
    await http.get(Uri.parse('$host/account/islogin'),
        headers: {'Cookie': token}).then((value) async {
      if (value.statusCode == 200) {
        var result = JSON.jsonDecode(value.body);
        Logger.info(result['data']['locations']);
        if (result['success']) {
          if ((result['data']['locations'] as List).isNotEmpty) {
            sharedPreferences.setStringList(
                'citys', (result['data']['locations'].cast<String>()));
          }
          sharedPreferences.setString('nickname', result['data']['nickname']);
          return true;
        } else {
          sharedPreferences.remove('cookie');
          sharedPreferences.remove('nickname');
          Fluttertoast.showToast(
              msg: JSON.jsonDecode(value.body)['msg'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    }).catchError((onError) {
      Logger.info("error islogin");
      Logger.info(onError);
      return false;
    });
    return false;
  }

  static void logout() async {
    Logger.info("api.logout()");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = '';
    if (sharedPreferences.containsKey('cookie')) {
      token = sharedPreferences.getString('cookie');
    }
    await http.get(Uri.parse('$host/account/logout'),
        headers: {'Cookie': token}).then((value) async {
      if (value.statusCode == 200) {
        var result = JSON.jsonDecode(value.body);
        if (result['success']) {
          sharedPreferences.remove('cookie');
          sharedPreferences.remove('nickname');
          Logger.info('????????????');
          Logger.info(sharedPreferences.containsKey('nickname'));
          Logger.info(sharedPreferences.containsKey('cookie'));
          Global.eventBus.fire(User(false));
          Logger.info('????????????end');
        } else {
          Fluttertoast.showToast(
              msg: JSON.jsonDecode(value.body)['msg'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        return false;
      }
    }).catchError((onError) {
      Logger.info("logout error");
    });
  }

  static void register(content, String username, String password,
      String nickname, String email, String verify) async {
    Logger.info(username + password + nickname + email + verify);
    if (username.isEmpty) {
      Fluttertoast.showToast(
          msg: '??????????????????',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (password.isEmpty) {
      Fluttertoast.showToast(
          msg: '???????????????',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (nickname.isEmpty) {
      Fluttertoast.showToast(
          msg: '??????????????????',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (email.isEmpty) {
      Fluttertoast.showToast(
          msg: '???????????????',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (verify.isEmpty) {
      Fluttertoast.showToast(
          msg: '??????????????????',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    await http.post(Uri.parse('$host/account/register'), body: {
      'username': username,
      'password': password,
      'email': email,
      'nickname': nickname,
      'verify': verify
    }).then((value) async {
      if (value.statusCode == 200) {
        if (JSON.jsonDecode(value.body)['success']) {
          Fluttertoast.showToast(
              msg: JSON.jsonDecode(value.body)['msg'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.pop(content);
        } else {
          Fluttertoast.showToast(
              msg: JSON.jsonDecode(value.body)['msg'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {}
    }).catchError((onError) {
      Logger.info("error");
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
    await http.post(Uri.parse('$host/account/saveaddress'),
        body: {'locations': city},
        headers: {'Cookie': token}).then((value) async {
      if (value.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }).catchError((onError) {
      Logger.info("error");
    });
  }

  static void changepw(content, old, pw) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = '';
    if (sharedPreferences.containsKey('cookie')) {
      token = sharedPreferences.getString('cookie');
    }
    await http.post(Uri.parse('$host/account/changepassword'),
        body: {'old': old, 'pw': pw},
        headers: {'Cookie': token}).then((value) async {
      if (value.statusCode == 200) {
        if (JSON.jsonDecode(value.body)['success']) {
          Navigator.pop(content);
        } else {
          Fluttertoast.showToast(
              msg: JSON.jsonDecode(value.body)['msg'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {}
    }).catchError((onError) {
      Logger.info("error");
    });
  }

  static void sendEmail(String email) async {
    if (email.isEmpty) {
      Fluttertoast.showToast(
          msg: '???????????????',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    await http.post(Uri.parse('$host/account/sendemail'),
        body: {'email': email}).then((value) async {
      if (value.statusCode == 200) {
        Fluttertoast.showToast(
            msg: JSON.jsonDecode(value.body)['msg'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {}
    }).catchError((onError) {
      Logger.info("error");
    });
  }
}
