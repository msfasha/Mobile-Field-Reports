import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ufr/services/auth.dart';
import 'package:ufr/services/database.dart';
import 'package:ufr/shared/modules.dart';
import 'package:ufr/shared/loading.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _error;
  bool _loading = false;

  // text field state
  String _email;
  String _password;
  String _personName;
  int _utilityId;

  @override
  void initState() {
    super.initState();
    // DatabaseService().utilities.then((foo)
    // {
    //   setState(() {
    //     //_utilList = foo;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.blue[400],
              elevation: 0.0,
              title: Text('Sign up'),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.person),
                  label: Text('Sign In'),
                  onPressed: () => widget.toggleView(),
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                         decoration: InputDecoration(
                  labelText: 'email',
                  hintText: 'Enter a valid email address',
                  hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),                       
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        setState(() => _email = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter a valid password',
                  hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey),
                ), 
                      obscureText: true,
                      validator: (val) => (val != null && val.length < 6)
                          ? 'Enter a password 6+ chars long'
                          : null,
                      onChanged: (val) {
                        setState(() => _password = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration: InputDecoration(
                  labelText: 'name',
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey),
                ), 
                      validator: (val) => (val != null && val.length < 6)
                          ? 'Enter a valid name'
                          : null,
                      onChanged: (val) {
                        setState(() => _personName = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    FutureBuilder<QuerySnapshot>(
                        future: DatabaseService().utilities,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const Center(
                              child: const Text('...'),
                            );
                          else {
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                labelText: 'Utility',
                                hintText: 'Select utility',
                                hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey)),
                                value: _utilityId,
                                  //isDense: true,
                                  onChanged: (value) {
                                    setState(() {
                                      _utilityId = int.parse(value.toString());
                                    });
                                  },
                                  items: snapshot.data.docs
                                      .map((document) => DropdownMenuItem(
                                          // value: document.data['utility_id'],
                                          // child: Text(document.data['plant_name']),
                                          value: document['utility_id'],
                                          child: Text(
                                              document['native_name'] ?? '')))
                                      .toList()),
                            );
                          }
                        }),
                    SizedBox(height: 20.0),
                    RaisedButton(
                        color: Colors.blue[400],
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: onPressRegister),
                    SizedBox(height: 12.0),
                    Text(
                      _error ?? '',
                      style: TextStyle(
                          color: Colors.red,
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
      if (_formKey.currentState.validate()) {
        setState(() => _loading = true);
        dynamic result = await _auth.registerWithEmailAndPassword(
            _email, _password, _utilityId, _personName);
        if (result == null) {
          setState(() {
            _loading = false;
            _error = 'Registration unsuccesful';
          });
        }
      }
    } on Exception catch (e) {
      String errMsg = 'Something went wrong';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errMsg = 'email already in use, try another email';
        }
        if (e.code == 'weak-password') {
          errMsg = 'password is weak, chose another password';
        }
        if (e.code == 'invalid-email') {
          errMsg = 'email address is invalid, enter a valid email address';
        }
      }

      setState(() {
        _loading = false;
        _error = errMsg;
      });
    }
  }
}
