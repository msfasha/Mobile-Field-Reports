import 'package:provider/provider.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/authenticate/register.dart';
import 'package:ufr/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:ufr/shared/modules.dart';

import '../../shared/aws_authentication_service.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  String _message = '';
  final TextEditingController _emailController = TextEditingController();

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
    final user = Provider.of<UserProfile?>(context);

    //This case happens when we sign in using a valid firebase user
    //but the user is not activated by the sys admin
    //we set the variables in here (in the build method)
    //yet they stick since the wrapper reopens the signin screen without changing state
    if (user != null && user.userStatus == false) {
      _emailController.text = user.email;
      _message = "User not activated, call system support";
      _loading = false;

      AuthenticationService.signOut();
    }

    return _loading == true
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              //title: Text('Sign In', style: TextStyle(fontSize: 16)),
              actions: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Register()));
                  },
                ),
              ],
            ),
            body: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'email',
                        hintText: 'Enter your email address',
                      ),
                      validator: (val) => (val != null && val.isEmpty)
                          ? 'Enter a valid email address'
                          : null,
                      onChanged: (val) {
                        setState(() => _email = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                      ),
                      validator: (val) => (val != null && val.length < 6)
                          ? 'Enter a password 6+ chars long'
                          : null,
                      onChanged: (val) {
                        setState(() => _password = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                        onPressed: asyncLogin,
                        child: const Text(
                          'Sign In',
                        )),
                    const SizedBox(height: 12.0),
                    Text(
                      _message,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void asyncLogin() async {
    OperationResult or = OperationResult();
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      //After successfull login, this screen will be replaced by home screen by wrapper
      or = await AuthenticationService.signInWithEmailAndPassword(
          _email, _password);
    }

    if (or.operationCode == OperationResultCodeEnum.error) {
      setState(() {
        _message = or.message!;
        _loading = false;
      });
    }
  }
}
