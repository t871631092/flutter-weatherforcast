class AppPage {
  List<dynamic> locations;
  List<dynamic> states;
  AppPage() {
    this.locations = [];
    this.states = [];
  }
  updateState() {
    for (var item in this.states) {
      print(this.states);
      item();
    }
  }
}

class WeatherData {
  Map<dynamic, dynamic> data;
  WeatherData() {
    this.data = {'name': ''};
  }
  get isEmpty => data.isEmpty;
}
