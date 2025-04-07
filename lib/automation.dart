import 'package:new_bee/dashboard.dart';
import 'package:flutter/material.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  _AutomationScreenState createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  String? selectedBeeSpecies;
  String? selectedApiaryName;
  String? selectedApiaryLocation;
  String? selectedHive;
  bool hasNotifications = true; // Simulating notifications
  double progress = 0.0; // Progress percentage for the rectangle (0 to 1)
  String? validationMessage; // Validation message

  final List<String> notifications = [
    "Notification 1: Colombo hive 1 feeder is empty",
    "Notification 2: Galle hive 2 automation started",
    "Notification 3: automation finished",
  ];

  final Map<String, List<String>> apiaryData = {
    'Western': ['Colombo', 'Gampaha', 'Kalutara'],
    'Southern': ['Galle', 'Matara', 'Hambantota'],
    'North-western': ['Kurunegala', 'Puttalam', 'Negombo'],
    'Sabaragamuwa': ['Ratnapura', 'Kegalle'],
    'Central': ['Kandy', 'Nuwara Eliya', 'Matale'],
    'UVA': ['Badulla', 'Moneragala'],
    'North-central': ['Anuradhapura', 'Polonnaruwa'],
    'Northern': ['Jaffna', 'Mannar', 'Kilinochchi']
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE59C15),
        title: const Text('AUTOMATION'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Dashboard()));
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.notification_important),
                            title: Text(notifications[index]),
                          );
                        },
                      );
                    },
                  );
                  setState(() {
                    hasNotifications = false; // Clear notifications
                  });
                },
              ),
              if (hasNotifications)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Your Bee Species'),
              value: selectedBeeSpecies,
              items: ['Apis mellifera', 'Apis cerana']
                  .map((species) => DropdownMenuItem(
                        value: species,
                        child: Text(species),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedBeeSpecies = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select the Apiary Name'),
              value: selectedApiaryName,
              items: apiaryData.keys
                  .map((apiary) => DropdownMenuItem(
                        value: apiary,
                        child: Text(apiary),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedApiaryName = value;
                  selectedApiaryLocation = null; // Reset location when name changes
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select the Apiary Location'),
              value: selectedApiaryLocation,
              items: selectedApiaryName != null
                  ? apiaryData[selectedApiaryName]!
                      .map((location) => DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ))
                      .toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  selectedApiaryLocation = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select the Hive'),
              value: selectedHive,
              items: ['Hive 1', 'Hive 2']
                  .map((hive) => DropdownMenuItem(
                        value: hive,
                        child: Text(hive),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedHive = value;
                });
              },
            ),
            const SizedBox(height: 32),
            if (validationMessage != null)
              Center(
                child: Text(
                  validationMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
            Center(
              child: ElevatedButton(
                onPressed: (selectedBeeSpecies != null &&
                        selectedApiaryName != null &&
                        selectedApiaryLocation != null &&
                        selectedHive != null)
                    ? () {
                        setState(() {
                          validationMessage = null; // Clear validation message
                        });
                        startAutomation(); // Start the automation process
                      }
                    : () {
                        setState(() {
                          validationMessage = "Please select all fields";
                        });
                      },
                child: const Text('Automation On'),
              ),
            ),
            const SizedBox(height: 32),
            if (progress > 0)
              Center(
                child: Column(
                  children: [
                    Text('${(progress * 100).toInt()}% Complete'),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Container(
                          width: 150, // Make the rectangle wider
                          height: 300, // Make the rectangle taller
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color.fromARGB(207, 0, 0, 0)), // Darker border
                            borderRadius: BorderRadius.circular(8), // Slightly rounded rectangle
                          ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(seconds: 1),
                                height: progress * 300, // Height based on progress
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8), // Keep corners consistent
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: -30,
                          top: (1 - progress) * 300 - 10, // Dynamic position of the percentage
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (progress >= 1.0)
                      const Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(
                              'Finished :)',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE59C15)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Feeder is full',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromARGB(218, 18, 17, 17)),
                            ),
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
  }

  void startAutomation() {
    // Simulate automation process with delays
    setState(() {
      progress = 0.01; // Initial progress
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        progress = 0.2; // 20% progress
      });
    });
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        progress = 0.5; // 50% progress
      });
    });
    Future.delayed(const Duration(seconds: 6), () {
      setState(() {
        progress = 1.0; // 100% progress
      });
    });
  }
}

