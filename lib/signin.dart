import 'package:flutter/material.dart';

void main() {
  runApp(EcoBeeApp());
}

class EcoBeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignIn(),
    );
  }
}

class SignIn extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Arc with Logo
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
                  top: 50,
                  left: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    child: ClipOval(
                      child: Image.asset(
                        'images/ecobee_logo.png',
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'SIGN IN',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Login to continue with your EcoBee account",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter your phone number",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),

                  // Phone Number Field
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic for sending OTP
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE59C15),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Send OTP", style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Enter your OTP",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),

                  // OTP Field
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "OTP",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic for sign in
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE59C15),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Sign In", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
