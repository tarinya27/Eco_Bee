import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'unit.dart';

// Dummy feeding history for now
Map<String, List<Map<String, dynamic>>> mockFeedingHistory = {
  'U01': [
    {'time': '2024-12-01', 'points': 3},
    {'time': '2025-01-01', 'points': 4},
    {'time': '2025-02-01', 'points': 5},
  ],
  'U02': [
    {'time': '2025-01-01', 'points': 2},
    {'time': '2025-02-01', 'points': 3},
    {'time': '2025-03-01', 'points': 6},
  ],
};

class Insights extends StatefulWidget {
  final List<Units> units;

  Insights({required this.units});

  @override
  State<Insights> createState() => _InsightsState();
}

class _InsightsState extends State<Insights> {
  String? selectedUnitId;
  String? selectedUnitName;
  double selectedQuantity = 0;
  List<Map<String, dynamic>> selectedHistory = [];

  void _updateData() {
    if (selectedUnitId != null) {
      selectedQuantity =
          widget.units.firstWhere((unit) => unit.id == selectedUnitId).quantity;
      selectedHistory = mockFeedingHistory[selectedUnitId!] ?? [];
    }
  }

  // Navigate back to Dashboard
  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Dashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> unitIds = widget.units.map((e) => e.id).toList();
    List<String> unitNames = widget.units.map((e) => e.name).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE59C15),
        centerTitle: true,
        title: Text('Honey Units'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateToDashboard,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Unit ID'),
              value: selectedUnitId,
              isExpanded: true,
              items:
                  unitIds.map((id) {
                    return DropdownMenuItem(value: id, child: Text(id));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedUnitId = value;
                  _updateData();
                });
              },
            ),
            DropdownButton<String>(
              hint: Text('Select Unit Name'),
              value: selectedUnitName,
              isExpanded: true,
              items:
                  unitNames.map((name) {
                    return DropdownMenuItem(value: name, child: Text(name));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedUnitName = value;
                });
              },
            ),
            SizedBox(height: 20),
            if (selectedUnitId != null)
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: selectedQuantity + 2,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index < selectedHistory.length) {
                              return Text(
                                selectedHistory[index]['time']
                                    .toString()
                                    .substring(5),
                                style: TextStyle(fontSize: 10),
                              );
                            }
                            return Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups:
                        selectedHistory.asMap().entries.map((entry) {
                          int index = entry.key;
                          var data = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: (data['points'] as int).toDouble(),
                                width: 16,
                                color: Color(0xFFE59C15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
