import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '/constants.dart';
import '/core/util.dart';
import '/domain/models/addon.dart';
import '/domain/models/attribute.dart';
import '/domain/models/attribute_option.dart';
import 'cart_item_edit_dialog.dart';

class QuickViewPanel extends StatefulWidget {
  const QuickViewPanel({super.key});

  @override
  State<QuickViewPanel> createState() => _QuickViewPanelState();
}

class _QuickViewPanelState extends State<QuickViewPanel> {
  late SwipeActionController swipeController;

  @override
  void initState() {
    swipeController = SwipeActionController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        width: 265,
        child: Consumer<CartProvider>(builder: (context, cartProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(
                    MdiIcons.cart,
                    size: 13,
                  ),
                  Text(
                    " Cart Items",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
              ListView.separated(
                shrinkWrap: true,
                itemCount: cartProvider.items.length,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  var item = cartProvider.items[index];
                  var variation = item.variation?.options
                      .firstWhereOrNull((e) => e.isSelected);
                  List<Widget> others = List.empty(growable: true);
                  if (variation != null && !variation.isDefault) {
                    others.add(Text(
                      " - ${variation.value}",
                      style: const TextStyle(fontSize: 14),
                    ));
                  }
                  for (Attribute attr in item.attributes) {
                    others.add(Builder(builder: (context) {
                      List<AttributeOption> selectedOptions =
                          attr.options.where((e) => e.isSelected).toList();

                      String str = " - ${attr.name} | ";
                      for (int i = 0; i < selectedOptions.length; i++) {
                        AttributeOption opt = selectedOptions[i];
                        str += opt.value;
                        if (i != selectedOptions.length - 1) {
                          str += ", ";
                        }
                      }
                      if (selectedOptions.length == 1 &&
                          selectedOptions[0].isDefault) {
                        return const SizedBox();
                      }
                      return Text(
                        str,
                        style: const TextStyle(fontSize: 14),
                      );
                    }));
                  }
                  for (Addon addon in item.addons) {
                    others.add(Text(
                      " - ${addon.name}",
                      style: const TextStyle(fontSize: 14),
                    ));
                  }
                  return ClipRRect(
                    child: SwipeActionCell(
                      controller: swipeController,
                      key: ObjectKey(item),
                      index: index,
                      deleteAnimationDuration: 200,
                      fullSwipeFactor: 0.3,
                      trailingActions: [
                        SwipeAction(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                            forceAlignmentToBoundary: true,
                            performsFirstActionWithFullSwipe: true,
                            onTap: (CompletionHandler handler) async {
                              await handler(true);
                              cartProvider.removeItem(item);
                            },
                            color: Colors.red),
                      ],
                      child: Hero(
                        tag: "cart_item_update_$index",
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              pushHeroDialog(primaryContext,
                                  CartItemEditDialog(index, item), true);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 5),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        CachedNetworkImage(
                                          width: 15,
                                          imageUrl:
                                              item.product.category.iconUrl,
                                          errorWidget: (context, url, error) {
                                            return const Center(
                                              child: Icon(Icons.error),
                                            );
                                          },
                                        ),
                                        Text(
                                          " ${item.quantity}x ${item.product.name}",
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    if (others.isNotEmpty)
                                      const SizedBox(
                                        height: 3,
                                      ),
                                    ...others,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 3,
                  );
                },
              ),
              Expanded(
                child: cartProvider.hasItem
                    ? const SizedBox()
                    : const Center(
                        child: Text(
                          "Cart is Empty",
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent),
                      onPressed: cartProvider.items.isEmpty
                          ? null
                          : () => cartProvider.confirmCancellation(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MdiIcons.cartRemove,
                            size: 15,
                          ),
                          Text(
                            " Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: cartProvider.items.isEmpty
                            ? null
                            : () => Navigator.of(context).pushNamed("/cart"),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              MdiIcons.cart,
                              size: 15,
                            ),
                            Text(
                              " Open Cart",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
