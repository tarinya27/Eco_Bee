import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'automation.dart';
import 'feeding_history.dart';
import 'insights.dart';
import 'unit.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE59C15),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
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
            StreamBuilder<DatabaseEvent>(
              stream:
                  FirebaseDatabase.instance
                      .ref('users/${FirebaseAuth.instance.currentUser?.uid}')
                      .onValue,
              builder: (context, snapshot) {
                String name;
                if (!snapshot.hasData) {
                  name = 'User';
                } else {
                  final userData =
                      snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                  name = userData?['fullName'] ?? 'User';
                }

                return Text(
                  'Welcome, $name!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Language Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Your Language',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'Sinhala', child: Text('Sinhala')),
                DropdownMenuItem(value: 'English', child: Text('English')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
              },
            ),

            const SizedBox(height: 20),

            if (_selectedLanguage != null)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    dashboardCard(
                      label: 'Automation',
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
                    dashboardCard(
                      label: 'Feeding History',
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
                    dashboardCard(
                      label: 'Units',
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
                    dashboardCard(
                      label: 'Insights',
                      image: 'images/insights.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Insights(units: []),
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
  }

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
            Image.asset(image, height: 60, width: 60, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
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
