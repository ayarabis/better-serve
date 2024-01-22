import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../providers/auth_provider.dart';
import '/constants.dart';
import '/core/extenstions.dart';
import '/core/util.dart';
import 'terms_and_condition_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  bool _redirecting = false;

  String email = "";

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
                  width: 100,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Register",
                  style: TextStyle(fontSize: 50, color: Colors.white),
                ),
                const SizedBox(height: 18),
                Form(
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
                        // terms and conditions with button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              const Text(
                                "By signing up, you agree to our",
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                onPressed: () {
                                  pushHeroDialog(context,
                                      const TermsAndConditionPage(), true);
                                },
                                child: const Text("Terms and Conditions"),
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed:
                              _isLoading || email.isEmpty ? null : signUp,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('SIGN UP'),
                        ),
                        Row(
                          children: [
                            const Text("Already have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/login');
                              },
                              child: const Text("Login"),
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
    );
  }

  void signUp() async {
    showLoading(context);
    setState(() {
      _isLoading = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signUp(email).then((res) {
      res.fold((l) => context.showErrorSnackBar(message: l.message), (r) {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
        context.showErrorSnackBar(message: "Please check your email to verify");
      });
      setState(() {
        _isLoading = false;
      });
    });
  }
}
