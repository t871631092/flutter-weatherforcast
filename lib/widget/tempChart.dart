import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class tempChart extends StatefulWidget {
  final dynamic data;

  const tempChart(
  {
    Key key, this.data
  }
  ): super(key: key);

  @override
  _tempChartState createState() => _tempChartState();
}

class _tempChartState extends State<tempChart> {
  List<Color> gradientColors = [
    const Color(0xffeebc06),
    const Color(0xffef063b),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 8,
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
                // color: Color(0xff232d37)
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 18.0, left: 12.0, top: 24, bottom: 12),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    var first = widget.data[0]['time'].substring(11,13);
    int index = value.toInt();
    var realHour = index + int.parse(first);
    realHour = realHour % 24;
    index = index % 24;
    var item = widget.data[index];
    const isOK = true;
    print(item);

    Widget w = Flex(
      direction: Axis.vertical,
      children: [
        Text(realHour.toString(), style: style),
        Text('${item['temperature']}°'),
        Image(
            width: 25,
            height: 25,
            image: AssetImage(isOK
                ? 'lib/assets/${item['code']}@2x.png'
                : 'lib/assets/99@2x.png')
        ),
        Text('${item['text']} '),
      ],
    );

    return Container(
      child: w,
      height: 300,
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 23,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: false,
      ),
      minX: 0,
      maxX: 25,
      minY: 5,
      maxY: 22,
      lineBarsData: [
        LineChartBarData(
          spots: _buildFlSpot(widget.data),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildFlSpot(data) {
    List<FlSpot> result = [];
    int count = 0;
    for (var item in data) {
      var timeStr = '${item['time'].toString().substring(11, 13)}';
      double x = count.toDouble();
      double y = double.parse(item['temperature']);
      result.add(FlSpot(x, y));
      count += 1;
    }
    return result;
  }
}