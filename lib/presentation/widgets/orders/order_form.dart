import 'dart:ui';

import 'package:better_serve/core/extenstions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../providers/setting_provider.dart';
import '../addons/addon_form.dart';
import '../common/dialog_pane.dart';
import '../common/flip_dialog.dart';
import '../common/multi_option_select.dart';
import '../common/num_spinner.dart';
import '../common/single_option_select.dart';
import '/data/models/option_select_item.dart';
import '/domain/models/addon.dart';
import '/domain/models/attribute.dart';
import '/domain/models/attribute_option.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/product.dart';
import '/domain/models/variation.dart';

class OrderForm extends StatefulWidget {
  final String tag;
  final Product product;
  final int quantity;
  final Variation? variation;
  final List<Attribute>? attributes;
  final List<Addon>? addons;
  final ValueSetter<CartItem> onComplete;
  const OrderForm(
      {super.key,
      required this.tag,
      required this.product,
      required this.quantity,
      this.variation,
      this.attributes,
      this.addons,
      required this.onComplete});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  late int quantity;
  Variation? variation;
  List<Attribute> attributes = [];
  List<Addon> selectedAddons = [];

  final SettingProvider settingProvider = SettingProvider();

  @override
  void initState() {
    quantity = widget.quantity;
    var variation = widget.variation ?? widget.product.variation;
    if (variation != null) {
      this.variation = variation.clone();
    }
    attributes = (widget.attributes ?? widget.product.attributes)
        .map((e) => e.clone())
        .toList();
    if (widget.addons != null) {
      selectedAddons = widget.addons!.map((e) => e.clone()).toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Product product = widget.product;
    return FlipDialog(
      flipDuration: 0,
      frontBuilder: (context, flip) {
        return DialogPane(
          tag: widget.tag,
          width: 500,
          scrollable: true,
          footer: SizedBox(
            height: 45,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                  ),
                ),
                if (product.allowAddon) ...[
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: flip,
                    child: const Text("Addons"),
                  ),
                ],
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      widget.onComplete(CartItem(
                          product: widget.product,
                          addons: selectedAddons,
                          variation: variation,
                          attributes: attributes,
                          quantity: quantity));
                    },
                    child: const Icon(
                      Icons.check,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((context.isMobile && context.isPortrait) ||
                      context.isTablet)
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(5),
                            ),
                            child: ImageFiltered(
                              imageFilter:
                                  ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      product.imgUrl,
                                    ),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                          Center(
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              imageUrl: product.imgUrl,
                              width: 200,
                              errorWidget: (context, url, error) {
                                return const Center(
                                  child: Icon(Icons.error),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Divider(
                          height: 10,
                          color: Colors.black26,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Quantity"),
                            NumSpinner(
                              quantity,
                              (value) {
                                if (value > 0) {
                                  quantity = value;
                                  return true;
                                }
                                return false;
                              },
                              minValue: 1,
                            )
                          ],
                        ),
                        if (variation != null) ...[
                          const Divider(
                            height: 10,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(variation!.name),
                              SingleOptionSelect(
                                options: variation!.options
                                    .map((e) => OptionSelectItem(
                                        e.value, e, e.isSelected))
                                    .toList(),
                                onSelect: (OptionSelectItem selected) {
                                  for (var item in variation!.options) {
                                    item.isSelected =
                                        selected.value.id == item.id;
                                  }
                                },
                                color: settingProvider.primaryColor,
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (attributes.isNotEmpty) ...[
                          const Divider(
                            height: 10,
                            color: Colors.black26,
                          ),
                          for (int i = 0;
                              i < product.attributes.length;
                              i++) ...[
                            attributeWidget(i),
                          ],
                        ],
                        if (selectedAddons.isNotEmpty) const Divider(),
                        if (selectedAddons.isNotEmpty) ...[
                          Text("Addons (${selectedAddons.length})"),
                          const SizedBox(
                            height: 5,
                          ),
                          Wrap(
                            children: [
                              for (Addon addon in selectedAddons)
                                Card(
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(minWidth: 100),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: settingProvider.primaryColor
                                            .withAlpha(20),
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Column(
                                      children: [
                                        Text(addon.name),
                                        SizedBox(
                                          width: 40,
                                          child: CachedNetworkImage(
                                            placeholderFadeInDuration:
                                                const Duration(
                                                    milliseconds: 200),
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Container(
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: 100,
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image:
                                                          settingProvider.logo),
                                                ),
                                              ),
                                            ),
                                            imageUrl: addon.imgUrl,
                                            errorWidget: (context, url, error) {
                                              return const Center(
                                                child: Icon(Icons.error),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ]),
          ),
        );
      },
      backBuilder: (context, flip) {
        return AddonForm(
            selected: selectedAddons,
            onComplete: (List<Addon>? result) {
              selectedAddons = result ?? [];
              flip();
            });
      },
    );
  }

  Widget attributeWidget(int i) {
    Attribute attribute = attributes[i];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(attribute.name),
          if (attribute.isMultiple)
            MultiOptionSelect(
              options: attribute.options
                  .map((e) => OptionSelectItem(e.value, e, e.isSelected))
                  .toList(),
              onSelect: (items) {
                List<int> selectedIds = items
                    .map((e) => e.value as AttributeOption)
                    .map((e) => e.id!)
                    .toList();
                for (var item in attributes[i].options) {
                  item.isSelected = selectedIds.contains(item.id);
                }
              },
              color: settingProvider.primaryColor,
            )
          else
            SingleOptionSelect(
              options: attribute.options
                  .map((e) => OptionSelectItem(e.value, e, e.isSelected))
                  .toList(),
              onSelect: (OptionSelectItem value) {
                for (var item in attributes[i].options) {
                  item.isSelected = item.id == value.value.id;
                }
              },
              color: settingProvider.primaryColor,
            )
        ],
      ),
    );
  }
}
