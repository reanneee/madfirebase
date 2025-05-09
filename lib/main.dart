import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_trace/screens/client.dart';
import 'package:contact_trace/screens/establishment.dart';
import 'package:contact_trace/screens/home.dart';
import 'package:contact_trace/screens/register_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TraceApp());
}

class TraceApp extends StatelessWidget {
  const TraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            var uid = snapshot.data?.uid ?? '';
            print(uid);
            return FutureBuilder(
              future:
                  FirebaseFirestore.instance.collection('users').doc(uid).get(),
              builder: (context, docSnapshot) {
                if (docSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                var data = docSnapshot.data;
                if (data != null) {
                  return ClientScreen(uid: uid);
                } else {
                  return EstablishmentScreen();
                }
              },
            );
          }
          return HomeScreen(); //no user data
        },
      ),
    );
  }
}
