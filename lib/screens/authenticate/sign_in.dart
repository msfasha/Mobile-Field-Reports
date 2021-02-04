import 'package:firebase_auth/firebase_auth.dart';
import 'package:ufr/services/firebase.dart';
import 'package:ufr/shared/loading.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();

  String _error = '';
  bool _loading = false;

  // text field state
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue[400],
              elevation: 0.0,
              title: Text('Sign in'),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.person),
                  label: Text('Register'),
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
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'email',
                        hintText: 'Enter your email address',
                        hintStyle:
                            TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      validator: (val) => (val != null && val.isEmpty)
                          ? 'Enter a valid email address'
                          : null,
                      onChanged: (val) {
                        setState(() => _email = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        hintStyle:
                            TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      validator: (val) => (val != null && val.length < 6)
                          ? 'Enter a password 6+ chars long'
                          : null,
                      onChanged: (val) {
                        setState(() => _password = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                        color: Colors.blue[400],
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: asyncLogin),
                    SizedBox(height: 12.0),
                    Text(
                      _error ?? '',
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void asyncLogin() async {
    try {
      if (_formKey.currentState.validate()) {
        setState(() => _loading = true);
        dynamic result =
            await AuthService.signInWithEmailAndPassword(_email, _password);
        //if the user is not null, then the stream in main an wrapper
        //will be updated and therefore home screen will be displayed
        if (result == null) {
          setState(() {
            _loading = false;
            _error = 'Could not sign in with those credentials';
          });
        }
      }
    } on Exception catch (e) {
       String errMsg = e.toString();
      if (e is FirebaseAuthException) {          
        if (e.code == 'invalid-email') {
          errMsg = 'email address is invalid, enter a valid email address';
        }
        if (e.code == 'user-not-found') {
          errMsg = 'User not found';
        }
        if (e.code == 'wrong-password') {
          errMsg = 'Incorrect credentials';
        }
      }

      setState(() {
        _loading = false;
        _error = errMsg;
      });   
    }
  }
}
