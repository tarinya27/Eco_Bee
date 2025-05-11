import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'signup.dart';
import 'welcome.dart';

Widget landing() {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
       // Show loading indicator while checking auth state
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text('Error occurred!'));
      } else if (snapshot.hasData) { 
        return StreamBuilder<DatabaseEvent>(
          // Listen to the database to fetch user profile data
          stream:
              FirebaseDatabase.instance
                  .ref('users/${FirebaseAuth.instance.currentUser?.uid}')
                  .onValue,
          builder: (context, snapshot) {
            // Show loading while fetching data
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              // Extract user data from the snapshot
              final userData =
                  snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

              // If no user profile exists in database, go to signup screen
              if (userData == null) {
                return Signup();
              } else {
                return Dashboard(); // User is authenticated and has profile data → show dashboard
              }
            }
          },
        );
      } else {
        return WelcomeScreen();
      }
    },
  );
}
