import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_trace/screens/client.dart';
import 'package:contact_trace/screens/establishment.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  bool hidePassword = true;
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_back.webp'),
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('To Login, please enter your email and password'),
              Gap(22),

              const Gap(4),
              TextFormField(
                decoration: setTextDecoration('Email address'),
                keyboardType: TextInputType.emailAddress,
                controller: emailCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                  if (!EmailValidator.validate(value)) {
                    return '*Invalid email';
                  }
                },
              ),
              const Gap(4),
              TextFormField(
                decoration: setTextDecoration(
                  'Password',
                  isPasswordField: true,
                ),
                controller: passwordCtrl,
                obscureText: hidePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                  if (passwordCtrl.text != value) {
                    return '*Passwords do not match.';
                  }
                },
              ),
              const Gap(4),

              ElevatedButton(onPressed: doLogin, child: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration setTextDecoration(
    String name, {
    bool isPasswordField = false,
  }) {
    return InputDecoration(
      border: OutlineInputBorder(),
      label: Text(name),
      suffixIcon:
          isPasswordField
              ? IconButton(
                onPressed: toggleShowPassword,
                icon: Icon(
                  hidePassword ? Icons.visibility : Icons.visibility_off,
                ),
              )
              : null,
    );
  }

  void toggleShowPassword() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void doLogin() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    QuickAlert.show(context: context, type: QuickAlertType.loading);

    try {
      var userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailCtrl.text,
            password: passwordCtrl.text,
          );
      String userId = userCredential.user?.uid ?? '';
      //access firestore
      final document =
          await FirebaseFirestore.instance
              .collection('establishments')
              .doc(userId)
              .get();

      var docData = document.data;
      Widget landingScreen;
      if (docData != null) {
        landingScreen = ClientScreen();
      } else {
        landingScreen = EstablishmentScreen();
      }
      ;
      print('document data: ${document.data()}');
      Navigator.of(context).pop();
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => landingScreen));
    } on FirebaseAuthException catch (ex) {
      Navigator.of(context).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'You have entered an incorrect email and password',
      );
    }
  }
}
