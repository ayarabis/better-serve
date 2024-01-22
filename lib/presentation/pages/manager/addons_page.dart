import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/addon_provider.dart';
import '../../widgets/addons/addon_card.dart';
import '../../widgets/addons/addon_delete_dialog.dart';
import '../../widgets/addons/addon_form_dialog.dart';
import '../../widgets/addons/addons_empty_view.dart';
import '/constants.dart';
import '/core/util.dart';
import '/domain/models/addon.dart';
import '/presentation/widgets/common/button.dart';

class AddonsPage extends StatefulWidget {
  const AddonsPage({super.key});

  @override
  State<AddonsPage> createState() => _AddonsPageState();
}

class _AddonsPageState extends State<AddonsPage> {
  List<Addon> selected = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Consumer<AddonProvider>(builder: (context, addonProvider, _) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: AnimatedCrossFade(
              firstChild: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${addonProvider.addons.length} Addons",
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (addonProvider.addons.isNotEmpty)
                          const Row(
                            children: [
                              Icon(
                                Icons.info,
                                size: 14,
                              ),
                              Text(" Tap and hold item to start selection"),
                            ],
                          )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  PrimaryButton(
                    onPressed: () {
                      pushHeroDialog(primaryContext, const AddonFormDialog());
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
                          Icons.inventory,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${selected.length}/${addonProvider.addons.length} Selected",
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
                        selected.clear();
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
                          return AddonDeleteDialog(selected, () {
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
          ),
          const Divider(
            height: 1,
          ),
          const SizedBox(
            height: 5,
          ),
          Expanded(
            child: addonProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                      left: 10,
                      right: 10,
                    ),
                    width: double.infinity,
                    child: addonProvider.addons.isNotEmpty
                        ? Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (Addon addon in addonProvider.addons)
                                AddonCard(
                                  key: ObjectKey(
                                      "${addon.id}_${selected.contains(addon)}"),
                                  addon,
                                  isActive: selected.contains(addon),
                                  onSelectionChanged: (bool long) {
                                    setState(() {
                                      selected.add(addon);
                                    });
                                  },
                                  onTap: () {
                                    bool isActive = selected.contains(addon);
                                    if (selected.isNotEmpty) {
                                      setState(() {
                                        if (isActive) {
                                          selected.remove(addon);
                                          isActive = false;
                                        } else {
                                          selected.add(addon);
                                          isActive = true;
                                        }
                                      });
                                    } else {
                                      pushHeroDialog(primaryContext,
                                          AddonFormDialog(addon: addon));
                                    }
                                    return isActive;
                                  },
                                )
                            ],
                          )
                        : const AddonsEmptyView(),
                  ),
          )
        ],
      );
    });
  }
}
