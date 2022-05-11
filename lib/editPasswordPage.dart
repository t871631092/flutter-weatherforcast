import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:weatherforcast/ApiService.dart';
import 'package:weatherforcast/RegisterPage.dart';

class editPasswordPage extends StatefulWidget {
  editPasswordPage({Key key}) : super(key: key);

  @override
  _editPasswordPageState createState() => _editPasswordPageState();
}

class _editPasswordPageState extends State<editPasswordPage> {
  //TextEditingController可以使用 text 属性指定初始值
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _oldPasswordController = TextEditingController();
  String _password = '', _oldPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更改密码'),
        brightness: Brightness.dark,
      ),
      body: new SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              _getOldPasswordInput(),
              _getNewPasswordInput(),
              SizedBox(
                height: 10,
              ),
              _buildSubmitButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNewPasswordInput() {
    return _getInputTextField(
      TextInputType.text,
      obscureText: true,
      controller: _passwordController,
      decoration: InputDecoration(
        hintText: "输入新密码",
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

  Widget _getOldPasswordInput() {
    return _getInputTextField(
      TextInputType.text,
      obscureText: true,
      controller: _oldPasswordController,
      decoration: InputDecoration(
        hintText: "输入旧密码",
        icon: Icon(
          Icons.lock_open,
          size: 20.0,
        ),
        suffixIcon: GestureDetector(
          child: Offstage(
            child: Icon(Icons.clear),
            offstage: _oldPassword == '',
          ),
          onTap: () {
            this.setState(() {
              _oldPassword = '';
              _oldPasswordController.clear();
            });
          },
        ),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        this.setState(() {
          _oldPassword = value;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
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
          '提交',
        ),
        onPressed: () {
          _doSumit();
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

  void _doSumit() {
    if (_isPasswordValid(_password, _oldPassword)) {
      // TODO: Edit Password API
      print("TODO: Edit Password API");
      // ApiService.editPassword(_password, _oldPassword);
    } else {
      print("TODO: Password is not valid");
    }
  }

  bool _isPasswordValid(String pass, String oldPass) {
    return pass != oldPass && pass.length >= 4;
  }
}
