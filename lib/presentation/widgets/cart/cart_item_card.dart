import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/setting_provider.dart';
import '../common/num_spinner.dart';
import '/constants.dart';
import '/core/util.dart';
import '/domain/models/addon.dart';
import '/domain/models/attribute.dart';
import '/domain/models/attribute_option.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/product.dart';
import 'cart_item_edit_dialog.dart';

class CartItemCard extends StatefulWidget {
  final int index;
  final CartItem item;
  final bool Function(int) onQtyChange;
  const CartItemCard(this.index, this.item,
      {Key? key, required this.onQtyChange})
      : super(key: key);

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late TextEditingController qtyInputController;
  @override
  void initState() {
    qtyInputController =
        TextEditingController(text: widget.item.quantity.toString());
    super.initState();
  }

  @override
  void dispose() {
    qtyInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Product product = widget.item.product;
    CartItem cartItem = widget.item;
    return Consumer<SettingProvider>(builder: (context, settings, _) {
      return Hero(
        tag: "cart_item_update_${widget.index}",
        child: Material(
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            child: Row(
              children: [
                Material(
                  child: InkWell(
                    onTap: () {
                      pushHeroDialog(primaryContext,
                          CartItemEditDialog(widget.index, widget.item), true);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              product.imgUrl,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Builder(builder: (context) {
                        var item = widget.item;
                        var selectedVariation = item.variation?.options
                            .firstWhereOrNull((e) => e.isSelected);
                        String str = "${item.quantity}x ";
                        if (item.variation != null) {
                          str += "${selectedVariation?.value} - ";
                        }
                        str += item.product.name;
                        if (item.addons.isNotEmpty) {
                          str += " with ";
                          for (var i = 0; i < item.addons.length; i++) {
                            Addon addon = item.addons[i];
                            int len = item.addons.length;
                            str +=
                                "${addon.name} ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                          }
                        }
                        return Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // item descriptive name
                              Wrap(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      pushHeroDialog(
                                        primaryContext,
                                        CartItemEditDialog(
                                          widget.index,
                                          widget.item,
                                        ),
                                        true,
                                      );
                                    },
                                    child: Text(
                                      str,
                                      style: const TextStyle(fontSize: 20),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              for (Attribute attr in item.attributes) ...[
                                Builder(builder: (context) {
                                  List<AttributeOption> selectedOptions = attr
                                      .options
                                      .where((e) => e.isSelected)
                                      .toList();
                                  String str = "${attr.name} | ";
                                  for (int i = 0;
                                      i < selectedOptions.length;
                                      i++) {
                                    AttributeOption opt = selectedOptions[i];
                                    str += opt.value;
                                    if (i != selectedOptions.length - 1) {
                                      str += ", ";
                                    }
                                  }
                                  // no need to show default option
                                  if (selectedOptions.length == 1 &&
                                      selectedOptions[0].isSelected) {
                                    return const SizedBox();
                                  }
                                  return Text(str);
                                }),
                              ]
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                NumSpinner(cartItem.quantity, widget.onQtyChange),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
