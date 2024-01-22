import 'package:better_serve/presentation/providers/attribute_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/setting_provider.dart';
import '/core/enums/item_action.dart';
import '/core/extenstions.dart';
import '/domain/models/attribute.dart';
import '/domain/models/attribute_option.dart';

class AttributeSetting extends StatelessWidget {
  final VoidCallback onAdd;
  final Null Function(Attribute attribute, ItemAction action) itemAction;
  AttributeSetting({required this.onAdd, required this.itemAction, super.key});

  final SettingProvider settingProvider = SettingProvider();

  @override
  Widget build(BuildContext context) {
    return Consumer<AttributeProvider>(
        builder: (context, attributeProvider, child) {
      final items = attributeProvider.attributes;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                )
              ],
            ),
          ),
          const Divider(
            height: 1,
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      "No attribute templates",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Attribute attr = items[index];
                        return InkWell(
                          onTap: () {
                            itemAction(attr, ItemAction.edit);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.edit_note),
                                    Text(attr.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ))
                                  ],
                                ),
                                Wrap(
                                  spacing: 5,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    for (AttributeOption option in attr.options)
                                      Chip(
                                        backgroundColor: option.isSelected
                                            ? settingProvider.primaryColor
                                            : null,
                                        label: Text(option.value,
                                            style: TextStyle(
                                              color: option.isSelected
                                                  ? Colors.white
                                                  : context.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                            )),
                                      ),
                                    const SizedBox(
                                      height: 40,
                                      child: VerticalDivider(),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        itemAction(attr, ItemAction.delete);
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_outlined,
                                        color: Colors.red,
                                      ),
                                      splashRadius: 20,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: items.length,
                    ),
                  ),
          ),
        ],
      );
    });
  }
}
