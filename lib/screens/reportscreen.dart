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
    return  Scaffold(
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      backgroundColor: const Color(0xFFF7F8F9),
      body: Column(
          children: <Widget>[
            SizedBox(
            height: 200,
              child: Row( 
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 250,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF1F4F9)), 
                      color: Colors.white
                    ),
                    child: const Center(
                      child: Text('Solicitações Pendentes'),
                    ),
                  ),

                  Container(
                    width: 250,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF1F4F9)),
                      color: Colors.white
                    ),
                    child: const  Center(
                      child: Text('Movimentações hoje:')
                    ),
                  ),

                    Container(
                    width: 250,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF1F4F9)),
                      color: Colors.white
                    ),
                    child: const  Center(
                      child: Text('Itens críticos'),
                    ),
                  ),

                ],
           
              ),
            ),
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
      );
  }
}