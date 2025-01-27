import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUserToFirestore() async {
    if (selectedApiaries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one apiary.")),
      );
      return;
    }

    try {
      await _firestore.collection('users').add({
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'password': password, // In production, ensure you hash the password
        'apiaries': selectedApiaries,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User registered successfully!")),
      );
      Navigator.pushNamed(context, '/signIn');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error registering user: $e")),
      );
    }
  }

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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Number
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onSaved: (value) {
                        phoneNumber = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone Number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Full Name
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onSaved: (value) {
                        fullName = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Password
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onSaved: (value) {
                        password = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Dropdowns for Apiary and Location
                    // (Existing code for Apiary Name, Location, and Hives here)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            registerUserToFirestore();
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
}
