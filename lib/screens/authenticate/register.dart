import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ufr/screens/home/wrapper.dart';
import 'package:ufr/shared/modules.dart';
import 'package:ufr/shared/loading.dart';
import 'package:flutter/material.dart';

import '../../shared/aws_authentication_service.dart';
import '../../shared/aws_data_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  String? _error;
  String? _message;
  bool _loading = false;

  // text field state
  String? _email;
  String? _password;
  String? _confirmPassword;
  String? _personName;
  String? _phoneNumber;
  String? _agencyId;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              //title: Text('New user', style: TextStyle(fontSize: 16)),
              actions: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: const Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                  //register widget is opened out of wrapper, meaning that wrapper won't get any notifications
                  //about the registration process, therefore when we click on sign in link, we reactivate the wrapper widget
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Wrapper())),
                ),
              ],
            ),
            body: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'email',
                        hintText: 'Enter a valid email address',
                      ),
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        setState(() => _email = val);
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter a valid password',
                      ),
                      obscureText: true,
                      validator: (val) {
                        if (val!.length < 6) {
                          return 'Enter a password 6+ chars long';
                        } else if (_confirmPassword != null &&
                            _confirmPassword!.length >= 6 &&
                            _confirmPassword != _password) {
                          return 'Passwords does not match';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (val) {
                        setState(() => _password = val);
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                      ),
                      obscureText: true,
                      validator: (val) {
                        if (val!.length < 6) {
                          return 'Enter a password 6+ chars long';
                        } else if (_password != null &&
                            _password!.length >= 6 &&
                            _confirmPassword != _password) {
                          return 'Passwords does not match';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (val) {
                        setState(() => _confirmPassword = val);
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'name',
                        hintText: 'Enter your name',
                      ),
                      validator: (val) => (val != null && val.length < 6)
                          ? 'Enter a valid name'
                          : null,
                      onChanged: (val) {
                        setState(() => _personName = val);
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'phone number',
                        hintText: 'Enter phone number',
                      ),
                      validator: (val) => (val != null && val.length < 10)
                          ? 'Enter a valid phone number'
                          : null,
                      onChanged: (val) {
                        setState(() => _phoneNumber = val);
                      },
                    ),
                    const SizedBox(height: 10.0),
                    FutureBuilder<QuerySnapshot>(
                        future: DataService.agencies,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text('...'),
                            );
                          } else {
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'agency',
                                    hintText: 'Select agency',
                                  ),
                                  value: _agencyId,
                                  validator: (val) => (val == null)
                                      ? 'Select Agency/Utility'
                                      : null,
                                  //isDense: true,
                                  onChanged: (value) {
                                    setState(() {
                                      //_agencyId = int.parse(value.toString());
                                      _agencyId = value;
                                    });
                                  },
                                  items: snapshot.data!.docs
                                      .map((document) => DropdownMenuItem(
                                          // value: document.data['agency_id'],
                                          // child: Text(document.data['plant_name']),
                                          value: document.id,
                                          //value: document['agency_id'],
                                          child: Text(document['name'] ?? '')))
                                      .toList()),
                            );
                          }
                        }),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                        onPressed: onPressRegister,
                        child: const Text(
                          'Register',
                        )),
                    const SizedBox(height: 12.0),
                    Text(
                      _error ?? '',
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _message ?? '',
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          );
  }

  void onPressRegister() async {
    try {
      if (_formKey.currentState!.validate()) return;

      setState(() => _loading = true);
      await AuthenticationService.registerWithEmailAndPassword(
          _email!, _password!, _agencyId!, _personName!, _phoneNumber!);

      setState(() {
        _loading = false;
        _message = 'User was created successfully, '
            'call system support to activate your user then login using the Sign In screen';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }
}
