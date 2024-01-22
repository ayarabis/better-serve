import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../widgets/roles/role_form_dialog.dart';
import '/constants.dart';
import '/core/util.dart';
import '/domain/models/role.dart';
import '/presentation/providers/role_provider.dart';
import '/presentation/widgets/common/button.dart';
import '/presentation/widgets/roles/role_delete_dialog.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(builder: (context, roleProvider, _) {
      final selected = roleProvider.roles.where((e) => e.selected).toList();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            AnimatedCrossFade(
              firstChild: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          MdiIcons.badgeAccount,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${roleProvider.roles.length} Roles",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  PrimaryButton(
                    onPressed: () {
                      pushHeroDialog(primaryContext, const RoleFormDialog());
                    },
                    icon: const Icon(Icons.add),
                    text: 'Add',
                  )
                ],
              ),
              secondChild: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          MdiIcons.badgeAccount,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${selected.length}/${roleProvider.roles.length} Selected",
                          style: const TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (var e in roleProvider.roles) {
                          e.selected = false;
                        }
                      });
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.redAccent),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return RoleDeleteDialog(selected, () {
                            setState(() {
                              selected.clear();
                            });
                          });
                        },
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.white,
                        ),
                        Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  )
                ],
              ),
              crossFadeState: selected.isEmpty
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 100),
            ),
            const Divider(
              height: 5,
            ),
            Expanded(
              child: roleProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : roleProvider.roles.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: DataTable(
                                  columnSpacing: 12,
                                  horizontalMargin: 12,
                                  columns: const [
                                    DataColumn(
                                      label: Text(''),
                                    ),
                                    DataColumn(
                                      label: Text('Name'),
                                    ),
                                    DataColumn(
                                      label: Text('Description'),
                                    ),
                                    DataColumn(
                                      label: Text('Permissions'),
                                    ),
                                    DataColumn(
                                      label: Text(""),
                                    ),
                                  ],
                                  rows: [
                                    for (Role role in roleProvider.roles)
                                      DataRow(
                                        cells: [
                                          DataCell(
                                            Checkbox(
                                              value: role.selected,
                                              onChanged: role.isManage
                                                  ? (v) {
                                                      setState(() {
                                                        role.selected = v!;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                          ),
                                          DataCell(Text(role.name)),
                                          DataCell(Text(role.description)),
                                          DataCell(Row(
                                            children: [
                                              for (String p in role.permissions)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Chip(
                                                    label: Text(p),
                                                    padding: EdgeInsets.zero,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  ),
                                                )
                                            ],
                                          )),
                                          DataCell(Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Hero(
                                                tag: "edit_role_${role.id}",
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: IconButton(
                                                    splashRadius: 20,
                                                    color: Colors.blue,
                                                    disabledColor: Colors.grey,
                                                    onPressed: role.isManage
                                                        ? () {
                                                            pushHeroDialog(
                                                              primaryContext,
                                                              RoleFormDialog(
                                                                role: role,
                                                              ),
                                                            );
                                                          }
                                                        : null,
                                                    icon: const Icon(
                                                      Icons.edit,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Hero(
                                                tag: "delete_role_${role.id}",
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: IconButton(
                                                    splashRadius: 20,
                                                    color: Colors.redAccent,
                                                    disabledColor: Colors.grey,
                                                    onPressed: role.isManage
                                                        ? () {
                                                            pushHeroDialog(
                                                              primaryContext,
                                                              RoleDeleteDialog(
                                                                  [role],
                                                                  () {}),
                                                              true,
                                                            );
                                                          }
                                                        : null,
                                                    icon: const Icon(
                                                      Icons.delete,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              MdiIcons.badgeAccount,
                              size: 200,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "Tap '+ Add' button to add role",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            )
                          ],
                        ),
            )
          ],
        ),
      );
    });
  }
}
