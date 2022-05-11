import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:weatherforcast/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherforcast/editPasswordPage.dart';


class profilePage extends StatefulWidget {
  profilePage({Key key}) : super(key: key);

  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人'),
        brightness: Brightness.dark,
      ),
      body: new SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30,),
              _buildAvatar(),
              SizedBox(height: 15,),
              _buildUsername(),
              SizedBox(
                height: 60,
              ),
              _buildEditPasswordButton(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return new CircleAvatar(
      backgroundImage: AssetImage('lib/assets/defaultUserAvatar.png'),
      radius: 60.0,
    );
  }

  Widget _buildUsername() {
    var username = 'username';
    _getUsername().then((value) {
      if (value != null) {
        username = value;
      }
    });
    return Text(
      username,
      style: TextStyle(
        fontSize: 35,
      )
    );
  }

  Widget _buildEditPasswordButton() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor:
          MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
        ),
        child: Text(
          '编辑密码',
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return editPasswordPage();
            }),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor:
          MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
        ),
        child: Text(
          '登出',
        ),
        onPressed: () {
          ApiService.logout();
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<String> _getUsername() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('nickname');
  }

}
