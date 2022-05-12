import 'package:event_bus/event_bus.dart';

class User {
  bool islogin;
  User(this.islogin);
}

class Global {
  static EventBus eventBus = EventBus();
}
