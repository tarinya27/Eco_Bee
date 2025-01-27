import 'package:flutter/material.dart';

void main() {
  runApp(EcoBeeApp());
}

class EcoBeeApp extends StatelessWidget {
  const EcoBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.jpg'), 
                fit: BoxFit.cover, 
              ),
            ),
          ),
          // Overlay Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 90, // Size of the circular logo
                  child: ClipOval(
                    child: Image.asset(
                      'images/ecobee_logo.png', 
                      fit: BoxFit.cover,
                      width: 180,
                      height: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 50), // Spacing between logo and buttons
                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    // Handle Sign Up action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE59C15), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Button size
                  ),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 22, 
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30), // spacing between buttons
                // Sign In Button
                ElevatedButton(
                  onPressed: () {
                    // Handle Sign In action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE59C15), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), 
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), 
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 22, 
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
