import 'package:provider/provider.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/authenticate/register.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:ufr/shared/modules.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  String _message = '';
  TextEditingController _emailController = new TextEditingController();

  bool _loading = false;

  // text field state
  String _email = '';
  String _password = '';

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);

    //This case happens when we sign in using a valid firebase user but the user is not activated by the sys admin
    //We set the variables in here (in build method), yet they stick since the wrapper reopens the signin screen without chaning state
    if (user != null && user.userStatus == false) {
      _emailController.text = user.email;
      _message = "User not activated, call system support";
      _loading = false;
      AuthService.signOut();
    }

    return _loading == true
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue[400],
              elevation: 0.0,
              //title: Text('Sign In', style: TextStyle(fontSize: 16)),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.person, color: Colors.white),
                  label: Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Register()));
                  },
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
                      controller: _emailController,
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
                      _message,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void asyncLogin() async {
    OperationResult or = OperationResult();
    if (_formKey.currentState.validate()) {
      setState(() => _loading = true);

      //After successfull login, this screen will be replaced by home screen by wrapper
      or = await AuthService.signInWithEmailAndPassword(_email, _password);
    }

    if (or.operationCode == OperationResultCodeEnum.Error) {
      setState(() {
        _message = or.message;
        _loading = false;
      });
    }
  }
}
