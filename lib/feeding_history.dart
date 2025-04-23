import 'package:flutter/material.dart';

import 'dashboard.dart';

// Feeding History Screen
class FeedingHistoryScreen extends StatefulWidget {
  const FeedingHistoryScreen({super.key});

  @override
  State<FeedingHistoryScreen> createState() => _FeedingHistoryScreenState();
}

class _FeedingHistoryScreenState extends State<FeedingHistoryScreen> {
  String selectedApiaryName = 'Western';
  String selectedLocation = 'Colombo';
  String selectedHive = 'Hive 1';

  final Map<String, List<String>> apiaryData = {
    'Western': ['Colombo', 'Gampaha', 'Kalutara'],
    'Southern': ['Galle', 'Matara', 'Hambantota'],
    'North-western': ['Kurunegala', 'Puttalam', 'Negombo'],
    'Sabaragamuwa': ['Ratnapura', 'Kegalle'],
    'Central': ['Kandy', 'Nuwara Eliya', 'Matale'],
    'UVA': ['Badulla', 'Moneragala'],
    'North-central': ['Anuradhapura', 'Polonnaruwa'],
    'Northern': ['Jaffna', 'Mannar', 'Kilinochchi'],
  };

  List<String> get locations => apiaryData[selectedApiaryName] ?? [];
  final List<String> hives = ['Hive 1', 'Hive 2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE59C15),
        title: const Text('FEEDING HISTORY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to Dashboard on back arrow press
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
            DropdownButtonFormField<String>(
              value: selectedApiaryName,
              items:
                  apiaryData.keys
                      .map(
                        (apiaryName) => DropdownMenuItem(
                          value: apiaryName,
                          child: Text(apiaryName),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedApiaryName = value!;
                  selectedLocation = apiaryData[selectedApiaryName]!.first;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select the apiary name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedLocation,
              items:
                  locations
                      .map(
                        (location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select the apiary location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedHive,
              items:
                  hives
                      .map(
                        (hive) =>
                            DropdownMenuItem(value: hive, child: Text(hive)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedHive = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select the Hive',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            const Expanded(
              child: Center(
                child: Text(
                  "Bar Chart Placeholder",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
