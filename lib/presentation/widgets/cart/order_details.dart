import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../providers/cart_provider.dart';
import '../../providers/setting_provider.dart';
import '/domain/models/addon.dart';
import '/domain/models/attribute.dart';
import '/domain/models/attribute_option.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/variation_option.dart';

class OrderDetails extends StatelessWidget {
  OrderDetails({super.key});

  final SettingProvider settingProvider = SettingProvider();
  final CartProvider cartProvider = CartProvider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt),
              SizedBox(
                width: 10,
              ),
              Text(
                "Order Details",
                style: TextStyle(fontSize: 25),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("(${cartProvider.itemCount}) Items"),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    height: 5,
                  ),
                  for (CartItem item in cartProvider.items) ...[
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: item.product.imgUrl,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Builder(
                                builder: (context) {
                                  String str = "${item.quantity}x";
                                  if (item.variation != null) {
                                    VariationOption? option = item
                                        .variation!.options
                                        .firstWhereOrNull((e) => e.isSelected);
                                    str += " ${option?.value}";
                                  }
                                  str += " ${item.product.name}";
                                  if (item.addons.isNotEmpty) {
                                    str += " with ";
                                    for (var i = 0;
                                        i < item.addons.length;
                                        i++) {
                                      Addon addon = item.addons[i];
                                      int len = item.addons.length;
                                      str +=
                                          "${addon.name} ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                                    }
                                  }
                                  return Text(
                                    str,
                                    style: const TextStyle(fontSize: 15),
                                  );
                                },
                              ),
                              if (item.attributes.isNotEmpty) ...[
                                for (Attribute attr in item.attributes)
                                  Builder(
                                    builder: (context) {
                                      List<AttributeOption> options = attr
                                          .options
                                          .where((e) => e.isSelected)
                                          .toList();
                                      String str = "${attr.name} :";
                                      for (var i = 0; i < options.length; i++) {
                                        String opt = options[i].value;
                                        int len = options.length;
                                        str +=
                                            "$opt ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                                      }
                                      return Text(
                                        str,
                                        style: const TextStyle(fontSize: 13),
                                      );
                                    },
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 5,
                    )
                  ],
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Items Total"),
                      Text(
                        "₱${cartProvider.totalAmount}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Discount"),
                      Text(
                        "--",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Grand Total",
                        style: TextStyle(
                            fontSize: 20, color: settingProvider.primaryColor),
                      ),
                      Text(
                        "₱${cartProvider.totalAmount}",
                        style: TextStyle(
                            fontSize: 20, color: settingProvider.primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
