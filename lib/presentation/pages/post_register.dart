import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '/core/util.dart';

class PostRegisterPage extends StatefulWidget {
  const PostRegisterPage({super.key});

  @override
  State<PostRegisterPage> createState() => _PostRegisterPageState();
}

class _PostRegisterPageState extends State<PostRegisterPage> {
  final bool _isLoading = false;

  String _firstName = "";
  String _lastName = "";

  final AuthProvider authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
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
                  "Welcome",
                  style: TextStyle(fontSize: 50, color: Colors.white),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Just a few more steps to complete your profile",
                    style: TextStyle(fontSize: 20, color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          readOnly: _isLoading,
                          onChanged: (value) {
                            setState(() {
                              _firstName = value;
                            });
                          },
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "This field is required";
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
                            hintText: "Firstname",
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: _isLoading,
                          onChanged: (value) {
                            setState(() {
                              _lastName = value;
                            });
                          },
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "This field is required";
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
                            hintText: "Lastname",
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                authProvider.signOut().then((_) {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, "/login", (route) => false);
                                });
                              },
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Sing Out'),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: FilledButton(
                                onPressed: _isLoading ||
                                        _firstName.isEmpty ||
                                        _lastName.isEmpty
                                    ? null
                                    : saveProfile,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Continue'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void saveProfile() {
    showLoading(context);
    authProvider.completeProfile(_firstName, _lastName).then((res) {
      Navigator.pop(context);
      res.fold((l) => null, (r) {
        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      });
    });
  }
}
