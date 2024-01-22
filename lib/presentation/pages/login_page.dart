import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../providers/auth_provider.dart';
import '/constants.dart';
import '/core/extenstions.dart';
import '/core/util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  bool confirmOtp = false;

  final _loginKey = GlobalKey<FormState>();
  String email = "";
  String token = "";

  late AuthProvider authProvider;

  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: context.screenSize.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xff45a7f5), Color(0xff2095f3)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Image.asset(
                    "assets/images/logo.png",
                    width: 200,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  AnimatedCrossFade(
                    crossFadeState: confirmOtp
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 100),
                    firstChild: Form(
                      key: _loginKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              enabled: !_isLoading,
                              // controller: TextEditingController(text: email),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                setState(() {
                                  email = value;
                                });
                              },
                              validator: (value) {
                                if (value != null) {
                                  return EmailValidator.validate(value)
                                      ? null
                                      : "Please input a valid email address";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                filled: true,
                                errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(color: Colors.red)),
                                prefixIconConstraints:
                                    BoxConstraints(minWidth: 23, maxHeight: 23),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(
                                    Icons.email,
                                  ),
                                ),
                                hintText: "Email Address",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('/reset-password');
                                    },
                                    child: const Text("Forgot password?"),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton(
                              onPressed:
                                  _isLoading || email.isEmpty ? null : sendOtp,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('LOGIN'),
                            ),
                            Row(
                              children: [
                                const Text("Don't have an account?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed('/register');
                                  },
                                  child: const Text("Sign Up"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    secondChild: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(12),
                            color: _isLoading ? Colors.grey.shade300 : null,
                            child: TextFormField(
                              enabled: !_isLoading,
                              obscureText: true,
                              onChanged: (value) {
                                setState(() {
                                  token = value;
                                });
                              },
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  prefixIconConstraints: BoxConstraints(
                                      minWidth: 23, maxHeight: 23),
                                  prefixIcon: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(
                                      Icons.password,
                                    ),
                                  ),
                                  hintText: "Input OTP"),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    token = "";
                                    confirmOtp = false;
                                  });
                                },
                                child: const Text("Cancel"),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _isLoading || token.isEmpty
                                      ? null
                                      : signIn,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('CONFIRM'),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/register');
                                },
                                child: const Text("Sign Up"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void sendOtp() async {
    if (!_loginKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    await authProvider.sendOtp(email);
    setState(() {
      _isLoading = false;
      confirmOtp = true;
    });
  }

  void signIn() async {
    showLoading(context);
    setState(() {
      _isLoading = true;
    });
    authProvider.login(email, token).then((res) {
      res.fold(
          (error) => context.showErrorSnackBar(
              message: "Login Failed: ${error.message}"),
          (r) async {});
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    });
  }
}
