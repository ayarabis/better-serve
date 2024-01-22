import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/setting_provider.dart';
import '../widgets/common/custom_dialog.dart';
import '../widgets/common/dialog_pane.dart';
import '../widgets/common/flip_dialog.dart';
import '../widgets/settings/custom_color_picker.dart';
import '../widgets/settings/general_setting.dart';
import '../widgets/settings/shop_setting.dart';
import '/core/util.dart';
import '/domain/models/attribute.dart';
import '/domain/models/variation.dart';
import '/presentation/widgets/common/button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  Variation? editingVariation;
  Attribute? editingAttribute;

  bool showConfirmExit = false;

  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(
      builder: (context, settingProvider, child) {
        final primaryColor = settingProvider.primaryColor;
        return PopScope(
          canPop: !settingProvider.isDirty,
          onPopInvoked: (_) async {
            if (settingProvider.isDirty) {
              setState(() {
                showConfirmExit = true;
              });
            }
          },
          child: FlipDialog(
            frontBuilder: (context, flip) {
              return Stack(
                children: [
                  DialogPane(
                    tag: "settings",
                    width: 600,
                    builder: (context, toggleLoadding) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 5, top: 5, right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.settings),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Settings"),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Divider(
                              height: 2,
                            ),
                            TabBar(
                                controller: _controller,
                                indicatorColor: primaryColor,
                                tabs: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "General",
                                      style: TextStyle(color: primaryColor),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Shop",
                                      style: TextStyle(color: primaryColor),
                                    ),
                                  )
                                ]),
                            SizedBox(
                              height: 400,
                              width: 600,
                              child: TabBarView(
                                  controller: _controller,
                                  children: [
                                    GeneralSetting(onFlip: flip),
                                    const ShopSetting()
                                  ]),
                            ),
                          ],
                        ),
                      );
                    },
                    footerBuilder: (context, toggleLoadding) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              if (settingProvider.isDirty) {
                                setState(() {
                                  showConfirmExit = true;
                                });
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text("Close"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          PrimaryButton(
                            onPressed: !settingProvider.isDirty
                                ? null
                                : () {
                                    toggleLoadding();
                                    settingProvider.save().then((res) {
                                      toggleLoadding();
                                      res.fold((l) {
                                        showToast(context,
                                            child: Text("Error: ${l.message}"));
                                      }, (r) {
                                        showToast(context,
                                            child:
                                                const Text("Settings updated"));
                                      });
                                    });
                                  },
                            icon: const Icon(
                              Icons.save,
                              size: 20,
                            ),
                            text: "Save",
                          )
                        ],
                      );
                    },
                  ),
                  if (showConfirmExit)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black.withAlpha(100),
                        child: CustomDialog(
                          title: "Discard changes?",
                          content:
                              "changes will be discarded if you continue without saving.",
                          positiveBtnText: "Yes",
                          negativeBtnText: "Cancel",
                          type: DialogType.warning,
                          onNegative: () {
                            setState(() {
                              showConfirmExit = false;
                            });
                          },
                          onPositive: () {
                            settingProvider.loadSettings();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
            backBuilder: (context, flip) {
              return CustomColorPicker(primaryColor, (Color pickedColor) {
                settingProvider.setPrimaryColor(pickedColor);
                flip();
              });
            },
          ),
        );
      },
    );
  }
}
