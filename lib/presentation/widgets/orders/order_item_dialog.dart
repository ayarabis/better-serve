import 'package:flutter/material.dart';

import '../../providers/cart_provider.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/product.dart';
import 'order_form.dart';

class OrderItemDialog extends StatefulWidget {
  final Product product;
  const OrderItemDialog(this.product, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderItemDialogState();
}

class _OrderItemDialogState extends State<OrderItemDialog> {
  final CartProvider cartProvider = CartProvider();

  @override
  Widget build(BuildContext context) {
    Product product = widget.product;
    return OrderForm(
      tag: "product_${product.id}",
      product: product,
      quantity: 1,
      onComplete: (CartItem cartItem) {
        cartProvider.addItem(cartItem);
        Navigator.of(context).pop();
      },
    );
  }
}
