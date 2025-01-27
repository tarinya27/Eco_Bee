import 'package:bee_feeder_ui/automation.dart';
import 'package:bee_feeder_ui/feeding_history.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
      routes: {
        '/automation': (context) => AutomationScreen(),
        '/feeding-history': (context) => FeedingHistoryScreen(),
      },
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? _selectedLanguage; // Variable to store the selected language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE59C15),
        title: const Text('DASHBOARD', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: const [
          // Add profile picture in the AppBar
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('images/profile.jpg'), // Profile picture
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Text
            const Text(
              'Hello, Tarinya!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Language Dropdown Selector
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Your Language',
                border: OutlineInputBorder(),
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

            // Display card with buttons only after a language is selected
            if (_selectedLanguage != null) ...[
              const SizedBox(height: 20), // Spacing between elements

              // Container with buttons inside one card
              Container(
                height: 250, // Increased card height
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(231, 237, 232, 232),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Automation Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AutomationScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                        backgroundColor: const Color(0xFFE59C15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        children: [
                          Image.asset('images/automation.jpg', height: 50, width: 50),
                          const SizedBox(width: 10),
                          const Text(
                            'Automation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),

                    // Feeding History Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FeedingHistoryScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                        backgroundColor: const Color(0xFFE59C15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        children: [
                          Image.asset('images/feeding_history.png', height: 50, width: 50),
                          const SizedBox(width: 10),
                          const Text(
                            'Feeding History',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
