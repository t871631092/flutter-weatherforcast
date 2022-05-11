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
                  right: 20.0, left: 20.0),
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
    int index = value.toInt();
    var item = widget.data[index];
    const isOK = true;

    Widget w = Flex(
      direction: Axis.vertical,
      children: [
        Text('${item['temperature']}°'),
        Image(
            width: 25,
            height: 25,
            image: AssetImage(isOK
                ? 'lib/assets/${item['code']}@2x.png'
                : 'lib/assets/99@2x.png')
        ),
        SizedBox(height: 10),
        Text('${item['text']} '),
      ],
    );

    return Container(
      child: w,
      height: 300,
    );
  }

  Widget topTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    var first = widget.data[0]['time'].substring(11,13);
    int index = value.toInt();
    var realHour = index + int.parse(first);
    realHour = realHour % 24;

    Widget t = Text(realHour.toString() + ':00', style: style);

    return Padding(padding: EdgeInsets.only(bottom: 4), child: t);
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
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 23,
              interval: 1,
              getTitlesWidget: topTitleWidgets,
          ),
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
      maxY: double.parse(widget.data.reduce((a, b) => int.parse(a['temperature']) > int.parse(b['temperature']) ? a : b)['temperature']) + 2,
      minY: double.parse(widget.data.reduce((a, b) => int.parse(a['temperature']) < int.parse(b['temperature']) ? a : b)['temperature']) - 2,
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