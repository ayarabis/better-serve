import 'package:better_serve/presentation/providers/variation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/setting_provider.dart';
import '/core/enums/item_action.dart';
import '/core/extenstions.dart';
import '/domain/models/variation.dart';
import '/domain/models/variation_option.dart';

class VariationSetting extends StatelessWidget {
  final VoidCallback onAdd;
  final Null Function(Variation attribute, ItemAction action) itemAction;

  VariationSetting({required this.onAdd, required this.itemAction, super.key});

  final SettingProvider settingProvider = SettingProvider();

  @override
  Widget build(BuildContext context) {
    return Consumer<VariationProvider>(
        builder: (context, variationProvider, child) {
      final items = variationProvider.variations;
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
                      "No variation templates",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        Variation variation = items[index];
                        return InkWell(
                          onTap: () {
                            itemAction(variation, ItemAction.edit);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.edit_note),
                                    Text(
                                      variation.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    for (VariationOption option
                                        in variation.options)
                                      Chip(
                                        backgroundColor: option.isSelected
                                            ? settingProvider.primaryColor
                                            : null,
                                        label: Text(
                                          "${option.value} | ₱${option.price}",
                                          style: TextStyle(
                                            color: option.isSelected
                                                ? Colors.white
                                                : context.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(
                                      height: 40,
                                      child: VerticalDivider(),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        itemAction(
                                            variation, ItemAction.delete);
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
