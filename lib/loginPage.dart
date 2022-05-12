import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:weatherforcast/ApiService.dart';
import 'package:weatherforcast/RegisterPage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //TextEditingController可以使用 text 属性指定初始值
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _username = '', _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登陆'),
        brightness: Brightness.dark,
      ),
      body: new SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // _getRoundImage('images/logo.png', 100.0),
              SizedBox(
                height: 60,
              ),
              _getUsernameInput(),
              _getPasswordInput(),
              SizedBox(
                height: 10,
              ),
              _getLoginButton(), _getRegisterButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getUsernameInput() {
    return _getInputTextField(
      TextInputType.number,
      controller: _usernameController,
      decoration: InputDecoration(
        hintText: "输入用户名",
        icon: Icon(
          Icons.mobile_friendly_rounded,
          size: 20.0,
        ),
        border: InputBorder.none,
        //使用 GestureDetector 实现手势识别
        suffixIcon: GestureDetector(
          child: Offstage(
            child: Icon(Icons.clear),
            offstage: _username == '',
          ),
          //点击清除文本框内容
          onTap: () {
            this.setState(() {
              _username = '';
              _usernameController.clear();
            });
          },
        ),
      ),
      //使用 onChanged 完成双向绑定
      onChanged: (value) {
        this.setState(() {
          _username = value;
        });
      },
    );
  }

  Widget _getPasswordInput() {
    return _getInputTextField(
      TextInputType.text,
      obscureText: true,
      controller: _passwordController,
      decoration: InputDecoration(
        hintText: "输入密码",
        icon: Icon(
          Icons.lock_open,
          size: 20.0,
        ),
        suffixIcon: GestureDetector(
          child: Offstage(
            child: Icon(Icons.clear),
            offstage: _password == '',
          ),
          onTap: () {
            this.setState(() {
              _password = '';
              _passwordController.clear();
            });
          },
        ),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        this.setState(() {
          _password = value;
        });
      },
    );
  }

  Widget _getRoundImage(String imageName, double size) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
      ),
      child: Image.asset(
        imageName,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget _getLoginButton() {
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
          '登陆',
        ),
        onPressed: () {
          ApiService.login(_username.trim(), _password.trim(), context);
        },
      ),
    );
  }

  Widget _getRegisterButton() {
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
          '注册',
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return RegisterPage();
            }),
          );
        },
      ),
    );
  }

  Widget _getInputTextField(
    TextInputType keyboardType, {
    FocusNode focusNode,
    controller: TextEditingController,
    onChanged: Function,
    InputDecoration decoration,
    bool obscureText = false,
    height = 50.0,
  }) {
    return Container(
      height: height,
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextField(
            keyboardType: keyboardType,
            focusNode: focusNode,
            obscureText: obscureText,
            controller: controller,
            decoration: decoration,
            onChanged: onChanged,
          ),
          Divider(
            height: 1.0,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
