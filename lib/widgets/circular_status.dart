import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CircularStatus extends StatelessWidget {
  const CircularStatus({super.key});

  @override
  Widget build(BuildContext context) {
    // Usando PieChart como anel com exemplo estático
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 4,
              centerSpaceRadius: 36,
              sections: [
                PieChartSectionData(value: 70, color: Colors.green.shade400, radius: 40, showTitle: false),
                PieChartSectionData(value: 30, color: Colors.grey.shade300, radius: 40, showTitle: false),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('R\$ 1.250', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Gastos', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}