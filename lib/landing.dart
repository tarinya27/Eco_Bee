import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'login.dart';
import 'signup.dart';

Widget landing() {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text('Error occurred!'));
      } else if (snapshot.hasData) {
        return StreamBuilder<DatabaseEvent>(
          stream:
              FirebaseDatabase.instance
                  .ref('users/${FirebaseAuth.instance.currentUser?.uid}')
                  .onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            } else {
              final userData =
                  snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
              if (userData == null) {
                return Signup();
              } else {
                return Dashboard();
              }
            }
          },
        );
      } else {
        return Login();
      }
    },
  );
}
