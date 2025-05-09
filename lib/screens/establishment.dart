import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';

class EstablishmentScreen extends StatefulWidget {
  const EstablishmentScreen({super.key});

  @override
  State<EstablishmentScreen> createState() => _EstablishmentScreenState();
}

class _EstablishmentScreenState extends State<EstablishmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Establishment'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              dologout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: ElevatedButton(
        onPressed: () => scanQr(context),
        child: Text('Scan Client QR code'),
      ),
    );
  }

  void dologout() async {
    await FirebaseAuth.instance.signOut();
  }

  void scanQr(BuildContext context) async {
    var qrResult = await FlutterBarcodeScanner.scanBarcode(
      '',
      'Cancel',
      true,
      ScanMode.DEFAULT,
    );
    print('QR Code Result: $qrResult');
  }
}
