import 'package:better_serve/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../orders/order_form.dart';
import '/domain/models/attribute.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/product.dart';
import '/domain/models/variation.dart';

class CartItemEditDialog extends StatefulWidget {
  final int index;
  final CartItem item;
  const CartItemEditDialog(this.index, this.item, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CartItemEditDialogState();
}

class _CartItemEditDialogState extends State<CartItemEditDialog>
    with TickerProviderStateMixin {
  int quantity = 1;
  Variation? variation;
  late List<Attribute> attributes;

  @override
  void initState() {
    if (widget.item.variation != null) {
      variation = widget.item.variation!.clone();
    }
    attributes = widget.item.attributes.map((e) => e.clone()).toList();
    quantity = widget.item.quantity;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CartItem item = widget.item;
    Product product = item.product;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return OrderForm(
          tag: "cart_item_update_${widget.index}",
          product: product,
          quantity: quantity,
          variation: variation,
          attributes: attributes,
          addons: item.addons,
          onComplete: (CartItem cartItem) {
            logger.i(item.attributes);
            cartProvider.updateItem(item, cartItem);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
