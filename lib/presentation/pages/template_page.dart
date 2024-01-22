import 'package:flutter/material.dart';

import '../widgets/common/flip_dialog.dart';
import '../widgets/products/attribute_form.dart';
import '../widgets/products/variation_form.dart';
import '../widgets/settings/attribute_setting.dart';
import '../widgets/settings/variation_setting.dart';
import '/core/enums/item_action.dart';
import '/domain/models/attribute.dart';
import '/domain/models/variation.dart';
import '/presentation/providers/attribute_provider.dart';
import '/presentation/providers/setting_provider.dart';
import '/presentation/providers/variation_provider.dart';
import '/presentation/widgets/common/dialog_pane.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

enum BackSetting { variation, attribute }

class _TemplatePageState extends State<TemplatePage>
    with SingleTickerProviderStateMixin {
  SettingProvider settingProvider = SettingProvider();

  late TabController _controller;

  Variation? editingVariation;
  Attribute? editingAttribute;

  BackSetting backSetting = BackSetting.variation;

  VariationProvider variationProvider = VariationProvider();
  AttributeProvider attributeProvider = AttributeProvider();

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = settingProvider.primaryColor;
    return FlipDialog(
      frontBuilder: (context, flip) {
        return DialogPane(
          tag: "template",
          width: 600,
          scrollable: true,
          header: const Row(children: [
            Icon(Icons.tag),
            Text(
              "Variants/Attributes Templates",
              style: TextStyle(fontSize: 18),
            ),
          ]),
          tabs: TabBar(
            controller: _controller,
            indicatorColor: primaryColor,
            tabs: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Variants",
                  style: TextStyle(color: primaryColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Attributes",
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
          builder: (context, toggleLoadding) {
            return SizedBox(
              height: 400,
              child: TabBarView(
                controller: _controller,
                children: [
                  VariationSetting(
                    onAdd: () {
                      backSetting = BackSetting.variation;
                      flip();
                    },
                    itemAction: (variation, action) {
                      switch (action) {
                        case ItemAction.edit:
                          setState(() {
                            editingVariation = variation;
                          });
                          backSetting = BackSetting.variation;
                          flip();
                          break;
                        case ItemAction.delete:
                          if (variation.id != null) {
                            toggleLoadding();
                            variationProvider
                                .deleteVariation(variation.id!)
                                .then((_) {
                              toggleLoadding();
                            });
                          }
                          toggleLoadding();
                          break;
                      }
                    },
                  ),
                  AttributeSetting(
                    onAdd: () {
                      backSetting = BackSetting.attribute;
                      flip();
                    },
                    itemAction: (attribute, action) {
                      switch (action) {
                        case ItemAction.edit:
                          setState(() {
                            editingAttribute = attribute;
                          });
                          backSetting = BackSetting.attribute;
                          flip();
                          break;
                        case ItemAction.delete:
                          if (attribute.id != null) {
                            toggleLoadding();
                            attributeProvider
                                .deleteAttribute(attribute.id!)
                                .then((_) {
                              toggleLoadding();
                            });
                          }
                          break;
                      }
                    },
                  )
                ],
              ),
            );
          },
          footerBuilder: (context, toggleLoadding) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close")),
                const SizedBox(
                  width: 10,
                ),
              ],
            );
          },
        );
      },
      backBuilder: (context, flip) {
        switch (backSetting) {
          case BackSetting.variation:
            return VariationForm(
              editingVariation,
              inputLabel: true,
              (v, toggleLoading) async {
                if (v != null) {
                  toggleLoading();
                  variationProvider.saveVariation(v).then((r) {
                    toggleLoading();
                    editingVariation = null;
                    flip();
                  });
                }
              },
              title:
                  editingVariation != null ? "Edit Variation" : "Add Variation",
            );
          case BackSetting.attribute:
            return AttributeForm(
              editingAttribute,
              inputLabel: true,
              (v, toggleLoading) {
                if (v != null) {
                  toggleLoading();
                  attributeProvider.saveAttribute(v).then((r) {
                    toggleLoading();
                    editingVariation = null;
                    flip();
                  });
                }
              },
              title:
                  editingAttribute != null ? "Edit Attribute" : "Add Attribute",
            );
        }
      },
    );
  }
}
