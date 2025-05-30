import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'automation.dart';
import 'feeding_history.dart';
import 'insights.dart';
import 'localization.dart';
import 'production.dart';
import 'unit.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
        // Listen to user's data from Firebase Realtime Database
      stream:
          FirebaseDatabase.instance
              .ref('users/${FirebaseAuth.instance.currentUser?.uid}')
              .onValue,
      builder: (context, snapshot) {
         // Show loading while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Show error if there's an issue with the stream
        if (snapshot.hasError) {
          return const Center(child: Text(Localization.errorLoadingData));
        }
        // Show message if user data is not found
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text(Localization.noUserDataAvailable));
        }
        // Get user data from database
        final userData =
            snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

        // Set language based on user's preference
        Localization localization = englishLocalization;
        if (userData?['language'] == 'Sinhala') {
          localization = sinhalaLocalization;
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: const Color(0xFFE59C15),
            title: Text(
              localization.dashboard,
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('images/profile.jpg'),
                ),
              ),
            ],
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message with user’s name
                Text(
                  '${localization.welcome}, ${userData?['fullName'] ?? 'User'}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Language Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: localization.selectYourLanguage,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Sinhala',
                      child: Text(localization.sinhala),
                    ),
                    DropdownMenuItem(
                      value: 'English',
                      child: Text(localization.english),
                    ),
                  ],
                  onChanged: (value) {
                    // Update language selection in the database
                    FirebaseDatabase.instance
                        .ref('users/${FirebaseAuth.instance.currentUser?.uid}')
                        .update({'language': value});
                  },
                ),

                const SizedBox(height: 20),
                  // StreamBuilder to listen for user's bee units
                StreamBuilder<DatabaseEvent>(
                  stream:
                      FirebaseDatabase.instance
                          .ref('units')
                          .orderByChild('owner')
                          .equalTo(FirebaseAuth.instance.currentUser?.uid)
                          .onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(height: 40);
                    }
                      // Parse unit data
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
                     // Show status box for units
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: units.isEmpty ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          units.isEmpty
                              ? '${localization.noUnitsFound}. ${localization.pleaseAddUnits}'
                              : '${localization.units}: ${units.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                 // Grid of dashboard feature cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      // Card: Automation
                      dashboardCard(
                        label: localization.automation,
                        image: 'images/automation.jpg',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AutomationScreen(),
                            ),
                          );
                        },
                      ),
                      // Card: Feeding History
                      dashboardCard(
                        label: localization.feedingHistory,
                        image: 'images/feeding_history.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedingHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      // Card: Units
                      dashboardCard(
                        label: localization.units,
                        image: 'images/units.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HoneyUnitListScreen(),
                            ),
                          );
                        },
                      ),
                      // Card: Production
                      dashboardCard(
                        label: localization.production,
                        image: 'images/production.jpg',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductionScreen(),
                            ),
                          );
                        },
                      ),
                      // Card: Insights
                      dashboardCard(
                        label: localization.insights,
                        image: 'images/insights.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InsightsScreen(),
                            ),
                          );
                        },
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

  // Helper widget to create each dashboard card
  Widget dashboardCard({
    required String label,
    required String image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image for the card
            Image.asset(image, height: 60, width: 60, fit: BoxFit.contain),
            const SizedBox(height: 10),
            // Text label for the card
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
