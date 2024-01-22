import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '/domain/models/role.dart';
import '/presentation/providers/role_provider.dart';
import '/presentation/widgets/common/dialog_pane.dart';

class RoleFormDialog extends StatefulWidget {
  final Role? role;
  const RoleFormDialog({this.role, super.key});

  @override
  State<RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends State<RoleFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  final _formKey = GlobalKey<FormState>();

  final permissions = {
    'default': true,
    'manage_inventory': false,
    'manage_users': false,
    'reporting': false,
  };

  @override
  void initState() {
    _nameController = TextEditingController();
    _descController = TextEditingController();

    Role? role = widget.role;
    if (role != null) {
      _nameController.text = role.name;
      _descController.text = role.description;

      for (var p in role.permissions) {
        permissions[p] = true;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Role? role = widget.role;
    return Consumer<RoleProvider>(builder: (context, roleProvider, _) {
      return DialogPane(
        tag: "addon_${role == null ? "new" : role.id}",
        width: 400,
        header: role == null
            ? const Row(
                children: [
                  Icon(Icons.add),
                  Text(
                    "Create New Role",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              )
            : const Row(
                children: [
                  Icon(Icons.edit),
                  Text(
                    "Edit Role",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
        builder: (context, toggleLoadding) {
          return Container(
            padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      icon: Icon(Icons.text_fields_sharp),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required!';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      icon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Row(
                    children: [
                      Icon(MdiIcons.formatListCheckbox),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Permissions",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  CheckboxListTile(
                      title: const Text("Default"),
                      value: true,
                      enabled: false,
                      onChanged: (v) {}),
                  CheckboxListTile(
                      title: const Text("Manage Inventory"),
                      value: permissions['manage_inventory'],
                      onChanged: (v) {
                        setState(() {
                          permissions['manage_inventory'] = v ?? false;
                        });
                      }),
                  CheckboxListTile(
                      title: const Text("Manage Roles and Users"),
                      value: permissions['manage_users'],
                      onChanged: (v) {
                        setState(() {
                          permissions['manage_users'] = v ?? false;
                        });
                      }),
                  CheckboxListTile(
                      title: const Text("Reporting"),
                      value: permissions['reporting'],
                      onChanged: (v) {
                        setState(() {
                          permissions['reporting'] = v ?? false;
                        });
                      })
                ],
              ),
            ),
          );
        },
        footerBuilder: (context, toggleLoadding) {
          return Row(children: [
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
                  String name = _nameController.text;
                  String desc = _descController.text;
                  toggleLoadding();
                  final permissions0 =
                      permissions.filter((value) => value).keys.toList();
                  if (role != null) {
                    roleProvider
                        .updateRole(role, name, desc, permissions0)
                        .then((value) {
                      Navigator.of(context).pop();
                    });
                  } else {
                    roleProvider
                        .saveRole(name, desc, permissions0)
                        .then((value) {
                      Navigator.of(context).pop();
                    });
                  }
                },
                child: const Icon(Icons.check),
              ),
            )
          ]);
        },
      );
    });
  }
}
