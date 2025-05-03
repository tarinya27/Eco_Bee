import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dashboard.dart';
import 'localization.dart';
import 'unit.dart';

// Feeding History Screen
class FeedingHistoryScreen extends StatefulWidget {
  const FeedingHistoryScreen({super.key});

  @override
  State<FeedingHistoryScreen> createState() => _FeedingHistoryScreenState();
}

class _FeedingHistoryScreenState extends State<FeedingHistoryScreen> {
  Unit? selectedUnit;
  Map<String, double> monthlySums = {};
  bool loadingHistory = false;

  void loadHistory() async {
    if (selectedUnit == null) return;
    setState(() {
      loadingHistory = true;
    });

    final snapshot =
        await FirebaseDatabase.instance
            .ref('history/${selectedUnit!.id}')
            .orderByChild('timestamp')
            .get();

    Map<String, double> sums = {};
    DateTime now = DateTime.now();
    DateTime sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    if (snapshot.exists) {
      final Map<dynamic, dynamic>? values =
          snapshot.value as Map<dynamic, dynamic>?;
      if (values != null) {
        for (var entry in values.entries) {
          final data = entry.value as Map<dynamic, dynamic>;
          final timestamp = data['timestamp'];
          final quantity = data['quantity'];

          if (timestamp != null && quantity != null) {
            DateTime date = DateTime.fromMillisecondsSinceEpoch(
              (timestamp as num).toInt() * 1000,
            );
            if (date.isAfter(sixMonthsAgo)) {
              String monthKey = DateFormat(
                'MMM yyyy',
              ).format(DateTime(date.year, date.month));
              sums[monthKey] =
                  (sums[monthKey] ?? 0) + (quantity as num).toDouble();
            }
          }
        }
      }
    }

    List<String> last6Months = List.generate(6, (i) {
      DateTime d = DateTime(now.year, now.month - (5 - i));
      return DateFormat('MMM yyyy').format(d);
    });

    setState(() {
      monthlySums = {for (var month in last6Months) month: sums[month] ?? 0.0};
      loadingHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance
              .ref('users/${FirebaseAuth.instance.currentUser?.uid}')
              .onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text(Localization.errorLoadingData));
        }
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text(Localization.noUserDataAvailable));
        }
        final userData =
            snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

        Localization localization = englishLocalization;
        if (userData?['language'] == 'Sinhala') {
          localization = sinhalaLocalization;
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFE59C15),
            title: Text(localization.feedingHistory),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder(
                  stream:
                      FirebaseDatabase.instance
                          .ref('units')
                          .orderByChild('owner')
                          .equalTo(FirebaseAuth.instance.currentUser?.uid)
                          .onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final unitsData =
                        snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                    final List<Unit> units =
                        unitsData != null
                            ? unitsData.entries
                                .map(
                                  (entry) => Unit(
                                    id: entry.key,
                                    nickname: entry.value['nickname'],
                                    beeSpecies: entry.value['beeSpecies'],
                                    numFrames: entry.value['numFrames'],
                                    hiveSize: entry.value['hiveSize'],
                                    province: entry.value['province'],
                                    district: entry.value['district'],
                                  ),
                                )
                                .toList()
                            : [];
                    if (units.isEmpty) {
                      return Center(
                        child: Text(
                          localization.noUnitsFound,
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }
                    return DropdownButtonFormField<Unit>(
                      decoration: InputDecoration(
                        labelText: localization.selectTheUnit,
                      ),
                      value: selectedUnit,
                      items:
                          units
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit.nickname),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value;
                          monthlySums = {};
                        });
                        loadHistory();
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                Expanded(
                  child:
                      loadingHistory
                          ? const Center(child: CircularProgressIndicator())
                          : monthlySums.isEmpty
                          ? Center(
                            child: Text(
                              localization.noDataAvailable,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : buildBarChart(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildBarChart() {
    final spots = monthlySums.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (monthlySums.values.reduce((a, b) => a > b ? a : b)) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(2)}ml',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, meta) {
                final index = value.toInt();
                if (index < spots.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      spots[index].key.split(' ')[0],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${value.toInt()}ml',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 50,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(spots.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: spots[index].value,
                color: const Color(0xff02d39a),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}
