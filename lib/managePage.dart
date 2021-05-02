import 'package:flutter/material.dart';
import 'package:weatherforcast/ApiService.dart';

class ManagePage extends StatefulWidget {
  final _add;
  final _remove;
  final _list;
  ManagePage(this._add, this._remove, List<dynamic> this._list);
  @override
  _ManagePage createState() => _ManagePage();
}

class _ManagePage extends State<ManagePage> {
  @override
  void initState() {
    super.initState();
    ApiService.getNows(widget._list, (cb) {
      print(cb);
    });
  }

  List<dynamic> search_list = [];
  String cityname = "";
  void inputcity(String str) {
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
      tc1.clear();
    });
  }

  void delete(dynamic item) {
    setState(() {
      widget._remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (search_list.length == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text("城市管理"),
        ),
        //backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: Center(
                child: TextField(
                  controller: tc1,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '城市名',
                  ),
                  onChanged: inputcity,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: widget._list.length,
                  itemExtent: 50.0, //强制高度为50.0
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text("${widget._list[index]}"),
                      trailing: TextButton(
                        child: Text("删除"),
                        onPressed: () {
                          delete(widget._list[index]);
                        },
                      ),
                    );
                  }),
            )
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("城市管理"),
        ),
        //backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '城市名',
                  ),
                  onChanged: inputcity,
                ),
              ),
            ),
            for (var item in search_list)
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    height: 80,
                    child: Center(
                      child:
                          Text('${item['name']}', textAlign: TextAlign.center),
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
          ],
        )),
      );
    }
  }
}
