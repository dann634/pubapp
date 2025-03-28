import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../classes/Drink.dart';

class UnitsGraph extends StatelessWidget {

  // Sample data - replace with your actual data
  final List<Drink> drinkList;
  List<PersonData> peopleData = List.empty(growable: true);
  final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.purple, Colors.yellow, Colors.orange, Colors.pink, Colors.teal];

  UnitsGraph({super.key, required this.drinkList}) {
    //Create peopleData
    Map<String, double> total = {};

    for(int i = drinkList.length - 1; i >= 0; i--) {
      Drink drink = drinkList[i];
      if(total.containsKey(drink.username)) {
        total[drink.username] = total[drink.username]! + double.parse(drink.units);

        for(int j = 0; j < peopleData.length; j++) {
          PersonData personData = peopleData[j];
          if(personData.name == drink.username) {

            DateTime dateTime = DateFormat("EEE, dd MMM HH:mm").parseUtc(drink.time);

            personData.addPoint(FlSpot(dateTime.millisecondsSinceEpoch.toDouble(), total[drink.username] ?? 0.0));
            break;
          }
        }

      } else {
        total[drink.username] = double.parse(drink.units);

        //Get Color
        Color color = Colors.white60;
        if(peopleData.length < colors.length) {
          color = colors[peopleData.length];
        }

        PersonData personData = PersonData(name: drink.username, color: color);

        DateTime dateTime = DateFormat("EEE, dd MMM HH:mm").parseUtc(drink.time);

        personData.addPoint(FlSpot(dateTime.millisecondsSinceEpoch.toDouble(), total[drink.username] ?? 0.0));

        peopleData.add(personData);
      }

    }
  }

  // Convert numeric x-value to time representation
  String xValueToTime(double value) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    // return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  double _calculateFirstHalfHourBeforeFirstPoint(int firstPointMillis) {
    final firstDate = DateTime.fromMillisecondsSinceEpoch(firstPointMillis);

    // Round down to nearest 30 minute interval
    final minutes = firstDate.minute;
    final roundedMinutes = minutes < 30 ? 0 : 30;

    return DateTime(
      firstDate.year,
      firstDate.month,
      firstDate.day,
      firstDate.hour,
      roundedMinutes,
      0,
    ).millisecondsSinceEpoch.toDouble();
  }

  double _calculateFirstHalfHourAfterLastPoint(int lastPointMillis) {
    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastPointMillis);

    // Round up to next 30 minute interval
    final minutes = lastDate.minute;
    final roundedMinutes = minutes < 30 ? 30 : 0;
    final roundedHour = minutes < 30 ? lastDate.hour : lastDate.hour + 1;

    return DateTime(
      lastDate.year,
      lastDate.month,
      lastDate.day,
      roundedHour,
      roundedMinutes,
      0,
    ).millisecondsSinceEpoch.toDouble();
  }

  @override
  Widget build(BuildContext context) {

    int firstMillis = 0;
    int lastMillis = 0;
    if(drinkList.isNotEmpty) {
      final time = drinkList[drinkList.length - 1].time;
      DateTime dateTime = DateFormat("EEE, dd MMM HH:mm").parseUtc(time);
      firstMillis = dateTime.millisecondsSinceEpoch;


      final lastTime = drinkList[0].time;
      DateTime dateTime1 = DateFormat("EEE, dd MMM HH:mm").parseUtc(lastTime);
      lastMillis = dateTime1.millisecondsSinceEpoch;
    }


    return Column(
      children: [
        // Legend
        buildLegend(),
        const SizedBox(height: 10),
        // Graph
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, verticalInterval: 60*30*1000),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 60*30*1000,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(xValueToTime(value), style: TextStyle(fontSize: 12),),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(1));
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                minY: 0,
                maxY: 40,
                minX: _calculateFirstHalfHourBeforeFirstPoint(firstMillis),
                maxX: _calculateFirstHalfHourAfterLastPoint(lastMillis),
                lineBarsData: peopleData.map((person) {
                  return LineChartBarData(
                    spots: person.points,
                    isCurved: false,
                    color: person.color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: person.color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  );
                }).toList(),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBorder: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${peopleData[spot.barIndex].name}\n'
                              'Value: ${spot.y.toStringAsFixed(2)}\n'
                              'Time: ${xValueToTime(spot.x)}',
                          TextStyle(
                            color: peopleData[spot.barIndex].color,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: peopleData.map((person) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: person.color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              person.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

}

class PersonData {
  final String name;
  final Color color;
  List<FlSpot> points = List.empty(growable: true);

  PersonData({
    required this.name,
    required this.color,
  });

  void addPoint(FlSpot spot) {

    for(int i = 0; i < points.length; i++) {
      FlSpot flSpot = points[i];
      if(flSpot.x == spot.x) {
        points.remove(flSpot);
        break;
      }
    }

    points.add(spot);
  }
}