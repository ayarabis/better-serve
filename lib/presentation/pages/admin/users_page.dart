import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/setting_provider.dart';
import '../../widgets/users/user_delete_dialog.dart';
import '../../widgets/users/user_form_dialog.dart';
import '/constants.dart';
import '/core/util.dart';
import '/domain/models/profile.dart';
import '/presentation/providers/user_provider.dart';
import '/presentation/widgets/common/button.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, _) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "(${userProvider.users.length}) Users",
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                PrimaryButton(
                  onPressed: () {
                    pushHeroDialog(primaryContext, const UserFormDialog());
                  },
                  icon: const Icon(Icons.add),
                  text: "Add",
                )
              ],
            ),
            const Divider(
              height: 5,
            ),
            Expanded(
              child: userProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : userProvider.users.isNotEmpty
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
                                    DataColumn2(
                                        label: Text(''), size: ColumnSize.S),
                                    DataColumn(
                                      label: Text('Email'),
                                    ),
                                    DataColumn(
                                      label: Text('First Name'),
                                    ),
                                    DataColumn(
                                      label: Text('Last Name'),
                                    ),
                                    DataColumn(
                                      label: Text('Role'),
                                    ),
                                    DataColumn(
                                      label: Text(""),
                                    ),
                                  ],
                                  rows: [
                                    for (Profile user in userProvider.users)
                                      DataRow(
                                        cells: [
                                          DataCell(
                                            user.avatarUrl != null
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: ClipOval(
                                                      child: CachedNetworkImage(
                                                        width: 50,
                                                        height: 50,
                                                        imageUrl:
                                                            user.avatarUrl!,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        SettingProvider()
                                                            .primaryColor,
                                                    child: const ClipOval(
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          DataCell(Text(user.email)),
                                          DataCell(Text(user.firstName)),
                                          DataCell(Text(user.lastName)),
                                          DataCell(Text(user.role.name)),
                                          DataCell(Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Hero(
                                                tag: "edit_user_${user.id}",
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: IconButton(
                                                    splashRadius: 20,
                                                    onPressed: () {
                                                      pushHeroDialog(
                                                        primaryContext,
                                                        UserFormDialog(
                                                          profile: user,
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Hero(
                                                tag: "delete_user_${user.id}",
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: IconButton(
                                                    splashRadius: 20,
                                                    onPressed: user.id ==
                                                            currentUser?.id
                                                        ? null
                                                        : () {
                                                            pushHeroDialog(
                                                              primaryContext,
                                                              UserDeleteDialog(
                                                                profile: user,
                                                              ),
                                                              true,
                                                            );
                                                          },
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: user.id ==
                                                              currentUser?.id
                                                          ? Colors.redAccent
                                                              .shade100
                                                          : Colors.redAccent,
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
                              MdiIcons.accountMultiplePlus,
                              size: 200,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "Tap '+ Add' button to add user",
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
