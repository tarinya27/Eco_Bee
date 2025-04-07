import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String? selectedApiary;
  String? selectedLocation;
  int? selectedHives;
  List<String> apiaryLocations = [];
  List<int> hiveOptions = [1, 2, 3];
  List<Map<String, dynamic>> selectedApiaries = [];

  Map<String, List<String>> apiaryLocationMap = {
    'Western': ['Colombo', 'Gampaha', 'Kalutara'],
    'Southern': ['Galle', 'Matara', 'Hambantota'],
    'North-western': ['Kurunegala', 'Puttalam', 'Negombo'],
    'Sabaragamuwa': ['Ratnapura', 'Kegalle'],
    'Central': ['Kandy', 'Nuwara Eliya', 'Matale'],
    'UVA': ['Badulla', 'Moneragala'],
    'North-central': ['Anuradhapura', 'Polonnaruwa'],
    'Northern': ['Jaffna', 'Mannar', 'Kilinochchi']
  };

  final _formKey = GlobalKey<FormState>();
  String phoneNumber = '';
  String fullName = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Section with Half Circle
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE59C15),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(350),
                      bottomRight: Radius.circular(350),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.black,
                        child: ClipOval(
                          child: Image.asset(
                            'images/ecobee_logo.png',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'SIGN UP',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text("Already have an account? Sign In", style: TextStyle(fontSize: 12)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Number
                    buildTextField("Phone Number", onSaved: (val) => phoneNumber = val),
                    const SizedBox(height: 15),

                    // Full Name
                    buildTextField("Full Name", onSaved: (val) => fullName = val),
                    const SizedBox(height: 15),

                    // Password
                    buildTextField("Password", obscureText: true, onSaved: (val) => password = val),
                    const SizedBox(height: 15),

                    // Apiary Province Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedApiary,
                      hint: const Text("Apiary Name (Which Province)"),
                      decoration: buildDropdownDecoration(),
                      items: apiaryLocationMap.keys
                          .map((province) => DropdownMenuItem(
                                value: province,
                                child: Text(province),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedApiary = value;
                          apiaryLocations = apiaryLocationMap[value] ?? [];
                          selectedLocation = null;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Apiary Location Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedLocation,
                      hint: const Text("Select Apiary Location"),
                      decoration: buildDropdownDecoration(),
                      items: apiaryLocations
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Number of Hives Dropdown
                    DropdownButtonFormField<int>(
                      value: selectedHives,
                      hint: const Text("Select No.of Hives"),
                      decoration: buildDropdownDecoration(),
                      items: hiveOptions
                          .map((hive) => DropdownMenuItem(
                                value: hive,
                                child: Text(hive.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedHives = value;
                        });
                      },
                    ),
                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();

                            // You can handle UI-only logic here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Form submitted (UI only).")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFE59C15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration buildDropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget buildTextField(String label,
      {bool obscureText = false, required void Function(String) onSaved}) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onSaved: (value) => onSaved(value ?? ''),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}
