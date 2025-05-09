import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ClientScreen extends StatelessWidget {
  ClientScreen({super.key, required this.uid});

  final String uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Client'),
        actions: [
          IconButton(
            onPressed: () {
              dologout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: QrImageView(data: uid)),
    );
  }
}

void dologout() async {
  await FirebaseAuth.instance.signOut();
}
