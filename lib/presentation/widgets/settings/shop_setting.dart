import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/setting_provider.dart';
import '/constants.dart';
import '../../../core/config/settings.dart';

class ShopSetting extends StatefulWidget {
  const ShopSetting({super.key});

  @override
  State<ShopSetting> createState() => _ShopSettingState();
}

class _ShopSettingState extends State<ShopSetting> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(builder: (context, settingProvider, _) {
      return SingleChildScrollView(
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Product Card",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const Divider(),
              InkWell(
                onTap: () {
                  final currentValue =
                      settings.valueOf<bool>(Settings.shopShowItemPrice) ??
                          false;
                  settingProvider.setValue(
                      Settings.shopShowItemPrice, !currentValue);
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: settings.valueOf(Settings.shopShowItemPrice),
                      onChanged: (val) {
                        settingProvider.setValue(
                            Settings.shopShowItemPrice, val);
                      },
                    ),
                    const Text("Show Price"),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  final currentValue =
                      settings.valueOf<bool>(Settings.shopShowQuickView) ??
                          false;
                  settingProvider.setValue(
                      Settings.shopShowQuickView, !currentValue);
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: settings.valueOf<bool>(Settings.shopShowQuickView),
                      onChanged: (val) {
                        settingProvider.setValue(
                            Settings.shopShowQuickView, val);
                      },
                    ),
                    const Text("Cart Quick View Panel"),
                  ],
                ),
              ),
            ],
          ),
        )),
      );
    });
  }
}
