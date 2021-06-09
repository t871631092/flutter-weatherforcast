import 'package:flutter/material.dart';
import 'package:weatherforcast/ApiService.dart';

class ManagePage extends StatefulWidget {
  final _add;
  final _remove;
  final _list;
  final _setCurrent;
  ManagePage(
      this._add, this._remove, List<dynamic> this._list, this._setCurrent);
  @override
  _ManagePage createState() => _ManagePage();
}

class _ManagePage extends State<ManagePage> {
  List<Widget> citylist = [];

  @override
  void initState() {
    super.initState();
    // ApiService.getNows(widget._list, (cb) {
    //   print(cb);
    // });
    // Future.delayed(Duration(milliseconds: 200)).then((e) {
    //   setState(() {
    //     citylist = getWidget();
    //   });
    // });
  }

  List<dynamic> search_list = [];
  String cityname = "";
  void inputcity(String str) {
    setState(() {
      print(str);
      cityname = str;
    });
    ApiService.searchLocation(str, (cb) {
      setState(() {
        search_list = cb;
      });
    });
  }

  TextEditingController tc1 = new TextEditingController();
  void add(dynamic item) {
    widget._add(item['name']);
    setState(() {
      cityname = "";
      tc1.value = TextEditingValue.empty;
      tc1.clear();
    });
  }

  void delete(dynamic item) {
    setState(() {
      widget._remove(item);
    });
  }

  List<Widget> getWidget() {
    if (cityname == "") {
      return [
        Expanded(
            child: RefreshIndicator(
                child: ListView.builder(
                    itemCount: widget._list.length,
                    itemExtent: 50.0, //强制高度为50.0
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text("${widget._list[index]}"),
                        onTap: widget._setCurrent(index),
                        trailing: TextButton(
                          child: Text("删除"),
                          onPressed: () {
                            delete(widget._list[index]);
                          },
                        ),
                      );
                    }),
                onRefresh: () async {
                  print("123");
                }))
      ];
    } else {
      return [
        for (var item in search_list)
          Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                height: 80,
                child: Center(
                  child: Text('${item['name']}', textAlign: TextAlign.center),
                ),
              )),
              Expanded(
                child: TextButton(
                  child: Text("添加"),
                  onPressed: () {
                    print('add0');
                    add(item);
                  },
                ),
              ),
            ],
          )
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("城市管理"),
      ),
      //backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            margin: EdgeInsets.all(8),
            height: 45,
            child: Center(
              child: TextField(
                controller: tc1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '城市名',
                  suffix: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                  ),
                ),
                onChanged: inputcity,
              ),
            ),
          ),
          for (var item in citylist) item,
          Container(
            padding: EdgeInsets.all(3),
            height: 23,
            child: Text(
              "天气数据由心知天气提供",
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
