import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService();
  static dynamic p(str, data) async {
    if (str == 'here') {
      await ApiService.getLocation()
          .then((value) => str = '${value.latitude}:${value.longitude}');
    }
    print(str);
    var result;
    await http
        .get(Uri.parse(
            'https://api.seniverse.com/v3/weather/now.json?key=SPFqkJQtu37wAi0wV&location=$str'))
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
            'https://api.seniverse.com/v3/weather/daily.json?key=SPFqkJQtu37wAi0wV&location=$str&language=zh-Hans&unit=c&start=0&days=5'))
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
            'https://api.seniverse.com/v3/life/suggestion.json?key=SPFqkJQtu37wAi0wV&location=$str&language=zh-Hans'))
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
    print(result);
    data([result]);
  }

  static void getNows(List<dynamic> locations, callback) async {
    //实况
    List<http.Response> list = await Future.wait(locations.map((e) {
      return http.get(Uri.parse(
          'https://api.seniverse.com/v3/weather/now.json?key=SPFqkJQtu37wAi0wV&location=$e'));
    }));
    //预报
    List<http.Response> list1 = await Future.wait(locations.map((e) {
      return http.get(Uri.parse(
          'https://api.seniverse.com/v3/weather/daily.json?key=SPFqkJQtu37wAi0wV&location=$e&language=zh-Hans&unit=c&start=0&days=5'));
    }));
    //生活
    List<http.Response> list2 = await Future.wait(locations.map((e) {
      return http.get(Uri.parse(
          'https://api.seniverse.com/v3/life/suggestion.json?key=SPFqkJQtu37wAi0wV&location=$e&language=zh-Hans'));
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
        results.add(el);
      }
    });
    callback(results);
  }

  static void searchLocation(String location, callback) async {
    http.Response result = await http.get(Uri.parse(
        'https://api.seniverse.com/v3/location/search.json?key=SPFqkJQtu37wAi0wV&q=$location'));
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
  }

  static Future<List<String>> getCity() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getStringList('citys');
  }
}
