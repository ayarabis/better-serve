import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/addon_provider.dart';
import '../../providers/setting_provider.dart';
import '../common/dialog_pane.dart';
import '/domain/models/addon.dart';

class AddonForm extends StatefulWidget {
  final List<Addon>? selected;
  final Function(List<Addon>? result) onComplete;
  const AddonForm(
      {super.key, required this.selected, required this.onComplete});

  @override
  State<AddonForm> createState() => _AddonFormState();
}

class _AddonFormState extends State<AddonForm> {
  List<Addon> selectedAddons = List.empty(growable: true);
  final SettingProvider settingProvider = SettingProvider();
  @override
  void initState() {
    if (widget.selected != null) {
      selectedAddons = widget.selected!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "_",
      width: 500,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.add),
                SizedBox(
                  width: 5,
                ),
                Text("Select Addon")
              ],
            ),
            const Divider(),
            Consumer<AddonProvider>(builder: (context, addonProvider, child) {
              if (addonProvider.addons.isNotEmpty) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (Addon addon in addonProvider.addons)
                      Card(
                        clipBehavior: Clip.hardEdge,
                        elevation: 3,
                        margin: EdgeInsets.zero,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              int index = selectedAddons
                                  .indexWhere((e) => e.id == addon.id);
                              if (index != -1) {
                                selectedAddons.removeAt(index);
                              } else {
                                selectedAddons.add(addon);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            constraints: const BoxConstraints(
                              maxWidth: 110,
                              maxHeight: 110,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CachedNetworkImage(
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Container(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: settingProvider.logo),
                                      ),
                                    ),
                                  ),
                                  imageUrl: addon.imgUrl,
                                  errorWidget: (context, url, error) {
                                    return const Icon(
                                      Icons.error,
                                      size: 30,
                                    );
                                  },
                                  fit: BoxFit.fill,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black,
                                            Colors.transparent
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: Text(
                                        addon.name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black,
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        "₱${addon.price}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                if (selectedAddons.firstWhereOrNull(
                                      (e) => e.id == addon.id,
                                    ) !=
                                    null)
                                  Container(
                                    color: settingProvider.primaryColor
                                        .withAlpha(100),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.check,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      )
                  ],
                );
              }
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: addonProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text("No addons available"),
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedAddons.isNotEmpty
                    ? "${selectedAddons.length} Selected"
                    : ""),
                FilledButton(
                  onPressed: () {
                    widget.onComplete(selectedAddons);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.check),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Ok",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
