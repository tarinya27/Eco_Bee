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

/// State class for FeedingHistoryScreen
class _FeedingHistoryScreenState extends State<FeedingHistoryScreen> {
  Unit? selectedUnit; // Currently selected bee unit
  Map<String, double> monthlySums = {}; // Stores sum of feeding quantities by month
  bool loadingHistory = false;
  
  /// Loads feeding history data from Firebase for the selected unit
  void loadHistory() async {
    if (selectedUnit == null) return; // Do nothing if no unit selected
    setState(() {
      loadingHistory = true; // Show loading spinner
    });
   
   //Get feeding history data from Firebase, sorted by timestamp
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

          // Filter data within  months
          if (timestamp != null && quantity != null) {
            DateTime date = DateTime.fromMillisecondsSinceEpoch(
              (timestamp as num).toInt() * 1000,
            );
            if (date.isAfter(sixMonthsAgo)) {
              String monthKey = DateFormat(
                'MMM yyyy',
              ).format(DateTime(date.year, date.month));
               // Sum feeding quantity for each month
              sums[monthKey] =
                  (sums[monthKey] ?? 0) + (quantity as num).toDouble();
            }
          }
        }
      }
    }
    
    //Generate keys for last 6 months to keep ordering consistent
    List<String> last6Months = List.generate(6, (i) {
      DateTime d = DateTime(now.year, now.month - (5 - i));
      return DateFormat('MMM yyyy').format(d);
    });
    
    //Update UI with fetched data
    setState(() {
      monthlySums = {for (var month in last6Months) month: sums[month] ?? 0.0};
      loadingHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to user data to get language preference and localization
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance
              .ref('users/${FirebaseAuth.instance.currentUser?.uid}')
              .onValue,
      builder: (context, snapshot) {
        // Show loading spinner while waiting for user data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Show error message if user data fails to load
        if (snapshot.hasError) {
          return const Center(child: Text(Localization.errorLoadingData));
        }
        // Show message if no user data found
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text(Localization.noUserDataAvailable));
        }
        final userData =
            snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

        // Set localization based on user's preferred language
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
                // Dropdown to select the bee unit for which feeding history is shown
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
                    // Parse units from database snapshot
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
                      // Show message if user has no units
                      return Center(
                        child: Text(
                          localization.noUnitsFound,
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }
                    // Dropdown for selecting a unit
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
                        loadHistory();// Load feeding history for selected unit
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Show loading spinner, no data message, or the feeding bar chart
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

  // Builds a bar chart to visualize monthly feeding quantities
  Widget buildBarChart() {
    final spots = monthlySums.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        // Set maximum y-axis value a bit higher than max feeding amount for padding
        maxY: (monthlySums.values.reduce((a, b) => a > b ? a : b)) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // Tooltip to show exact feeding amount when user taps a bar
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
              // Display month abbreviation on X axis labels
              getTitlesWidget: (double value, meta) {
                final index = value.toInt(); // Convert the floating value to integer index
                if (index < spots.length) { // Check if index is within the range of data points
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      //Bars are at whole number positions.
                      //convert the decimal position to an integer to label each bar correctly.
                      //display only the month abbreviation
                      spots[index].key.split(' ')[0],  
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                } else {
                  return const SizedBox.shrink(); // Return an empty widget if index is out of range (no title)
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // Show integer feeding amount labels on Y axis
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
        gridData: FlGridData(show: true), // Show grid lines for easier reading
        borderData: FlBorderData(show: false),  // No border around chart

        // Generate bars for each month with corresponding feeding quantity
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
