import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:ufr/screens/authenticate/wrapper.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/modules.dart';
import 'package:ufr/shared/loading.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  Register();

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  String _error;
  String _message;
  bool _loading = false;

  // text field state
  String _email;
  String _password;
  String _confirmPassword;
  String _personName;
  String _phoneNumber;
  String _organizationId;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            key: registerScafoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.blue[400],
              elevation: 0.0,
              //title: Text('New user', style: TextStyle(fontSize: 16)),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.person, color: Colors.white),
                  label: Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                  //register widget is opened out of wrapper, meaning that wrapper won't get any notifications
                  //about the registration process, therefore when we click on sign in link, we reactivate the wrapper widget
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Wrapper())),
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'email',
                        hintText: 'Enter a valid email address',
                        hintStyle:
                            TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        setState(() => _email = val);
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter a valid password',
                        hintStyle:
                            TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      obscureText: true,
                      validator: (val) {
                        String result;

                        if (val.length < 6) {
                          result = 'Enter a password 6+ chars long';
                        } else if (_confirmPassword != null &&
                            _confirmPassword.length >= 6) {
                          if (_confirmPassword != _password) {
                            return 'Passwords does not match';
                          }
                        }

                        return result;
                      },
                      onChanged: (val) {
                        setState(() => _password = val);
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        hintStyle:
                            TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      obscureText: true,
                      validator: (val) {
                        String result;

                        if (val.length < 6) {
                          result = 'Enter a password 6+ chars long';
                        } else if (_password != null && _password.length >= 6) {
                          if (_confirmPassword != _password) {
                            return 'Passwords does not match';
                          }
                        }

                        return result;
                      },
                      onChanged: (val) {
                        setState(() => _confirmPassword = val);
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'name',
                        hintText: 'Enter your name',
                        hintStyle:
                            TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      validator: (val) => (val != null && val.length < 6)
                          ? 'Enter a valid name'
                          : null,
                      onChanged: (val) {
                        setState(() => _personName = val);
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'phone number',
                        hintText: 'Enter phone number',
                        hintStyle:
                            TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      validator: (val) => (val != null && val.length < 10)
                          ? 'Enter a valid phone number'
                          : null,
                      onChanged: (val) {
                        setState(() => _phoneNumber = val);
                      },
                    ),
                    SizedBox(height: 10.0),
                    FutureBuilder<QuerySnapshot>(
                        future: DataService.organizations,
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
                                      labelText: 'Organization',
                                      hintText: 'Select organization',
                                      hintStyle: TextStyle(
                                          fontSize: 12.0, color: Colors.grey)),
                                  value: _organizationId,
                                  validator: (val) => (val == null)
                                      ? 'Select Organization/Utility'
                                      : null,
                                  //isDense: true,
                                  onChanged: (value) {
                                    setState(() {
                                      //_organizationId = int.parse(value.toString());
                                      _organizationId = value;
                                    });
                                  },
                                  items: snapshot.data.docs
                                      .map((document) => DropdownMenuItem(
                                          // value: document.data['organization_id'],
                                          // child: Text(document.data['plant_name']),
                                          value: document.id,
                                          //value: document['organization_id'],
                                          child: Text(document['name'] ?? '')))
                                      .toList()),
                            );
                          }
                        }),
                    SizedBox(height: 10.0),
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
                    ),
                    Text(
                      _message ?? '',
                      style: TextStyle(
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
    OperationResult or = OperationResult();
    if (_formKey.currentState.validate()) {
      setState(() => _loading = true);
      or = await AuthService.registerWithEmailAndPassword(
          _email, _password, _organizationId, _personName, _phoneNumber);
      if (or.operationCode == OperationResultCodeEnum.Success) {
        setState(() {
          _loading = false;
          _message = 'User was created successfully, ' +
              'call system support to activate your user then login using the Sign In screen';
        });
        AuthService.signOut();
      } else if (or.operationCode == OperationResultCodeEnum.Error) {
        setState(() {
          _loading = false;
          _error = or.message;
        });
      }
    }
  }
}
