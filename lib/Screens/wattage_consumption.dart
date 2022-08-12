import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mr_power_manager_client/Screens/pc_manager.dart';
import 'package:mr_power_manager_client/Utils/size_adjustaments.dart';
import 'package:mr_power_manager_client/Widgets/large_command_shape.dart';

class WattageConsumptionChart extends StatefulWidget {



  const WattageConsumptionChart({Key? key, required this.unit,required this.each
    ,required this.spots,})
      : super(key: key);
  final List<FlSpot> spots;
  final String unit;
  final int each;

  @override
  WattageConsumptionChartState createState() => WattageConsumptionChartState();
}

class WattageConsumptionChartState extends State<WattageConsumptionChart> {
  static final intervals = [60,60,60];
  var gradientColors = [
    [
      const Color(0xff23b6e6),
      const Color(0xff02d39a),
    ],
    [
      const Color(0xffF08130),
      const Color(0xffF08ACF),
    ],
    [
      const Color(0xff1CB86B),
      const Color(0xffEDEA3E),
    ]
  ];

  static int currentIndex = 0;
  static bool loading = false;

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.32,
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
                color: Color(0xff232d37)),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 18.0, left: 12.0, top: 42, bottom: 12),
              child: Stack(
                children: [
                  Opacity(
                    opacity: WattageConsumptionChartState.loading?0.16:1,
                    child: LineChart(
                      data(),
                      swapAnimationDuration: const Duration(milliseconds: 20),
                    ),
                  ),
                  WattageConsumptionChartState.loading?
                  Center(
                    child: Container(
                      decoration:  BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(22)),
                          color: Colors.black.withOpacity(0.46)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              strokeWidth: 6,
                              color: Colors.blue,
                            ),
                            SizedBox.fromSize(size: const Size(0,16),),
                            Text('Loading...',style: GoogleFonts.lato(fontSize: 16),)
                          ],
                        ),
                      ),
                    ),
                  ):Container(),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 60,
              height: 34,
              child: TextButton(
                onPressed: ()=>resolutionOnTap(0),
                child: Text(
                  '24h',
                  style: TextStyle(
                      fontSize: 14,
                      color: currentIndex != 0
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 34,
              child: TextButton(
                onPressed: ()=>resolutionOnTap(1),
                child: Text(
                  '4h',
                  style: TextStyle(
                      fontSize: 14,
                      color: currentIndex != 1
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 34,
              child: TextButton(
                onPressed: ()=>resolutionOnTap(2),
                child: Row(
                  children: [
                    currentIndex==2?
                    Icon(Icons.circle,color: currentIndex != 2
                        ? Colors.lightGreen.withOpacity(0.5)
                        : Colors.lightGreenAccent,size: adjustSizeHorizontally(context, 10),):Container(),
                    SizedBox(width: adjustSizeHorizontally(context, 4),),
                    Text(
                      'Live',
                      style: TextStyle(
                          fontSize: 14,
                          color: currentIndex != 2
                              ? Colors.lightGreen.withOpacity(0.5)
                              : Colors.lightGreenAccent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, Duration duration) {
    var now = DateTime.now();
    var formatter =
        duration.inMinutes > 60 ? DateFormat('HH:mm') : DateFormat('HH:mm:ss');
    var split = Duration(seconds: duration.inSeconds ~/ intervals[currentIndex]);

    var style = TextStyle(
      color: const Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: duration.inMinutes > 60 ? 16 : 13,
    );
    Widget text;
    switch (value.toInt()) {
      case 8:
        text = Text(formatter.format(now.subtract(split * 40)), style: style);
        break;
      case 24:
        text = Text(formatter.format(now.subtract(split * 24)), style: style);
        break;
      case 40:
        text = Text(formatter.format(now.subtract(split * 8)), style: style);
        break;
        default:
        text = Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  Widget bottomTitleWidgets24h(double value, TitleMeta meta) {
    return bottomTitleWidgets(value, meta, const Duration(days: 1));
  }

  Widget bottomTitleWidgets4h(double value, TitleMeta meta) {
    return bottomTitleWidgets(value, meta, const Duration(hours: 4));
  }

  Widget bottomTitleWidgets1m(double value, TitleMeta meta) {
    return bottomTitleWidgets(value, meta, const Duration(minutes: 1));
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    var style = GoogleFonts.lato(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 11 / MediaQuery.of(context).textScaleFactor,
    );
    if(value%widget.each==0){
      return Text('${value.toInt()}${widget.unit}', style: style, textAlign: TextAlign.left);
    }
    return Container();
  }

  LineChartData data() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 25,
        verticalInterval: intervals[currentIndex] / (currentIndex==0?16:currentIndex==1?12:20),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 1,
            getTitlesWidget: currentIndex==0?bottomTitleWidgets24h:
            currentIndex==1?bottomTitleWidgets4h:bottomTitleWidgets1m,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: intervals[currentIndex].toDouble(),
      minY: 0,
      maxY: widget.unit=='W'?getMax() * 1.5:100,
      lineBarsData: [
        LineChartBarData(
          spots: widget.spots,
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors[currentIndex],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors[currentIndex]
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

  getMax() {
    double max=0;
    for(var spot in widget.spots){
        max=spot.y>max?spot.y:max;
    }
    return max;
  }


  void resolutionOnTap(int index) {
    setState(() {
      if(currentIndex!=index) {
        Future.delayed(const Duration(milliseconds: 70),() {
          LargeCommandShape.pcManager?.setState(() {
            currentIndex = index;
          });
        });

        loading=true;
        Future.delayed(const Duration(milliseconds: 350),() {
          setState(() {
            loading = false;
          });
        });
      }
    });

  }
}
