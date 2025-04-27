import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_trace/screens/login.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RegisterEstablishmentScreen extends StatefulWidget {
  RegisterEstablishmentScreen({super.key});

  @override
  State<RegisterEstablishmentScreen> createState() =>
      _RegisterEstablishmentScreenState();
}

class _RegisterEstablishmentScreenState
    extends State<RegisterEstablishmentScreen> {
  final formKey = GlobalKey<FormState>();
  final fnCtrl = TextEditingController();
  final lnCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final businessCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as Establishment'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            alignment: Alignment.bottomCenter,
            opacity: 0.5,
          ),
        ),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Text(
                'To register as a client, please enter the needed information.',
              ),

              TextFormField(
                decoration: setTextDecoration('First name'),
                controller: fnCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                },
              ),
              const Gap(4),
              TextFormField(
                decoration: setTextDecoration('Last name'),
                controller: lnCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                },
              ),

              const Gap(4),
              TextFormField(
                decoration: setTextDecoration('Business Name'),
                controller: businessCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                },
              ),
              const Gap(4),
              TextFormField(
                decoration: setTextDecoration('Address'),
                controller: addressCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                },
              ),
              Divider(),
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
              TextFormField(
                decoration: setTextDecoration(
                  'Confirm Password',
                  isPasswordField: true,
                ),
                controller: confirmPassCtrl,
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
              Gap(16),
              ElevatedButton(onPressed: doRegister, child: Text('Register')),
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

  void doRegister() {
    //valdiate form
    if (!formKey.currentState!.validate()) {
      return;
    }
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Are you sure?',
      confirmBtnText: 'YES',
      cancelBtnText: 'No',
      onConfirmBtnTap: () {
        //dismiss the dialog
        Navigator.of(context).pop();
        //call the actual registration
        RegisterEstablishment();
      },
    );
  }

  void RegisterEstablishment() async {
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Please wait',
        text: 'Registering your account',
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text,
            password: passwordCtrl.text,
          );
      print(userCredential.user?.uid);

      await FirebaseFirestore.instance
          .collection('establishments')
          .doc(userCredential.user!.uid)
          .set({
            'firstname': fnCtrl.text,
            'lastname': lnCtrl.text,
            'email': emailCtrl.text,
            'business': businessCtrl.text,
            'address': addressCtrl.text,
          });
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => LoginScreen()));
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'User Registration',
        text: 'You account has been registered. You can now login',
      );
    } on FirebaseAuthException catch (ex) {
      print(ex.code);
      print(ex.message);
      if (ex.code == 'weak-password') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: ex.message,
        );
      }
    }
  }
}
