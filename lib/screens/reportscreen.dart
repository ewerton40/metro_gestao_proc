import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';


class ReportScreen extends StatefulWidget{
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();

}

class _ReportScreenState extends State<ReportScreen>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(

                      )
                    ]
                  )
                ),
                BarChart(
                  BarChartData(
                    barGroups: [
                      BarChartGroupData(
                        x:0,
                        barRods: [
                          BarChartRodData(
                            toY: 0
                            )
                        ]
                      )
                    ]
                  )
                ),
                LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: [

                        ]
                      )
                    ]
                  )
                )
              ],
            )

          ] 
      ),
      ),
    );
  }
}