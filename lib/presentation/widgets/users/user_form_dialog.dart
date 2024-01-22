import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Left, Right;
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../providers/auth_provider.dart';
import '../common/dialog_pane.dart';
import '/domain/models/profile.dart';
import '/domain/models/role.dart';
import '/presentation/providers/role_provider.dart';
import '/presentation/providers/user_provider.dart';
import '/presentation/widgets/avatar_picker.dart';

class UserFormDialog extends StatefulWidget {
  final Profile? profile;
  const UserFormDialog({super.key, this.profile});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();

  final UserProvider userProvider = UserProvider();

  File? avatarImg;
  Role? role;

  @override
  void initState() {
    Profile? profile = widget.profile;
    if (profile != null) {
      _emailController.text = profile.email;
      _fNameController.text = profile.firstName;
      _lNameController.text = profile.lastName;
      role = profile.role;
    }

    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Profile? profile = widget.profile;
    String avatarUrl = profile?.avatarUrl ?? "";
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, child) {
        final List<Map<String, dynamic>> roleSelect = [
          for (Role r in roleProvider.roles)
            {
              'value': r.name,
              'label': r.name,
            }
        ];
        return DialogPane(
          tag: profile == null ? "add_user" : "edit_user_${profile.id}",
          width: 400,
          scrollable: true,
          header: Padding(
            padding: const EdgeInsets.all(5),
            child: profile == null
                ? const Row(
                    children: [
                      Icon(Icons.add),
                      Text(
                        "Add User",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  )
                : const Row(
                    children: [
                      Icon(Icons.edit),
                      Text(
                        "Edit User",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
          ),
          builder: (context, toggleLoadding) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          AvatarPicker(
                            value: avatarImg != null
                                ? Left(avatarImg!)
                                : avatarUrl.isNotEmpty
                                    ? Right(avatarUrl)
                                    : null,
                            radius: 50,
                            onTap: () {
                              FilePicker.platform.pickFiles().then(
                                (filePickerResult) async {
                                  if (filePickerResult != null) {
                                    var pickedFile = File(filePickerResult
                                        .files.single.path
                                        .toString());
                                    setState(() {
                                      avatarImg = pickedFile;
                                    });
                                  }
                                },
                              );
                            },
                          ),
                          TextFormField(
                            enabled: profile == null,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            style: TextStyle(
                              color:
                                  profile == null ? Colors.black : Colors.grey,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a email';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _fNameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a first name';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _lNameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a last name';
                              }
                              return null;
                            },
                          ),
                          SelectFormField(
                            type: SelectFormFieldType.dropdown,
                            labelText: 'Role',
                            items: roleSelect,
                            initialValue: profile?.role.name,
                            onChanged: (val) {
                              setState(() {
                                role = roleProvider.roles
                                    .firstWhere((e) => e.name == val);
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select user role';
                              }
                              return null;
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          footerBuilder: (context, toggleLoadding) {
            return Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    toggleLoadding();
                    final profile0 = Profile(
                        id: profile?.id,
                        email: _emailController.text,
                        firstName: _fNameController.text,
                        lastName: _lNameController.text,
                        avatarUrl: profile?.avatarUrl,
                        tenantId: tenantId!,
                        role: role!);
                    userProvider.saveUser(profile0, avatarImg).then((res) {
                      Navigator.of(context).pop();
                    });
                  },
                  child: const Icon(Icons.check),
                ))
              ],
            );
          },
        );
      },
    );
  }
}
