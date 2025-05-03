import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'localization.dart';
import 'unit.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  Unit? selectedUnit;
  Map<String, double> feedingSums = {};
  Map<String, double> productionSums = {};
  bool loading = false;

  void loadData() async {
    if (selectedUnit == null) return;
    setState(() {
      loading = true;
    });

    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    final feedingSnapshot =
        await FirebaseDatabase.instance
            .ref('history/${selectedUnit!.id}')
            .orderByChild('timestamp')
            .get();

    final productionSnapshot =
        await FirebaseDatabase.instance
            .ref('production/${selectedUnit!.id}')
            .get();

    Map<String, double> feeding = {};
    Map<String, double> production = {};

    if (feedingSnapshot.exists) {
      final values = feedingSnapshot.value as Map<dynamic, dynamic>?;
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
              feeding[monthKey] =
                  (feeding[monthKey] ?? 0) + (quantity as num).toDouble();
            }
          }
        }
      }
    }

    if (productionSnapshot.exists) {
      final values = productionSnapshot.value as Map<dynamic, dynamic>?;
      if (values != null) {
        for (var entry in values.entries) {
          final data = entry.value as Map<dynamic, dynamic>;
          final timestampStr = data['timestamp'];
          final quantity = data['quantity'];

          if (timestampStr != null && quantity != null) {
            DateTime date = DateTime.parse(timestampStr);
            if (date.isAfter(sixMonthsAgo)) {
              String monthKey = DateFormat(
                'MMM yyyy',
              ).format(DateTime(date.year, date.month));
              production[monthKey] =
                  (production[monthKey] ?? 0) + (quantity as num).toDouble();
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
      feedingSums = {
        for (var month in last6Months) month: feeding[month] ?? 0.0,
      };
      productionSums = {
        for (var month in last6Months) month: production[month] ?? 0.0,
      };
      loading = false;
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
            title: Text(localization.insights),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
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
                          feedingSums = {};
                          productionSums = {};
                        });
                        loadData();
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                Expanded(
                  child:
                      loading
                          ? const Center(child: CircularProgressIndicator())
                          : (feedingSums.isEmpty && productionSums.isEmpty)
                          ? Center(child: Text(localization.noDataAvailable))
                          : Column(
                            children: [
                              Expanded(child: buildRatioBarChart()),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        color: Colors.purple,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(localization.feedToProdRatio),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildRatioBarChart() {
    final months = feedingSums.keys.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${feedingSums[months[groupIndex]]?.toStringAsFixed(1)}ml / ${productionSums[months[groupIndex]]?.toStringAsFixed(1)}kg',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < months.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      months[index].split(' ')[0],
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
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(months.length, (index) {
          double feed = feedingSums[months[index]] ?? 0;
          double prod = productionSums[months[index]] ?? 0;
          double ratio = prod == 0 ? 0 : feed / prod;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: ratio, color: Colors.purple, width: 16),
            ],
          );
        }),
      ),
    );
  }
}
