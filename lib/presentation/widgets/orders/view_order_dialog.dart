import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../providers/order_provider.dart';
import '../../providers/printer_provider.dart';
import '../common/dialog_pane.dart';
import '/core/extenstions.dart';
import '/domain/models/order.dart';
import '/domain/models/order_item.dart';

class ViewOrderDialog extends StatelessWidget {
  final Order order;
  ViewOrderDialog({required this.order, super.key});

  final PrinterProvider printerProvider = PrinterProvider();
  final OrderProvider orderProvider = OrderProvider();

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "order_${order.id}",
      width: 500,
      maxHeight: 500,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${order.queueNumber}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  decoration: BoxDecoration(
                    color: order.statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order.statusName,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                )
              ],
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (OrderItem item in order.items) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                            imageUrl: item.imgUrl,
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
                                if (item.variationValue != null) {
                                  str += " ${item.variationValue}";
                                }
                                str += " ${item.productName}";
                                if (item.addons.isNotEmpty) {
                                  str += " with ";
                                  for (var i = 0; i < item.addons.length; i++) {
                                    OrderItemAddon addon = item.addons[i];
                                    int len = item.addons.length;
                                    str +=
                                        "${addon.name} ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                                  }
                                }
                                return Text(
                                  str,
                                  style: const TextStyle(fontSize: 25),
                                );
                              },
                            ),
                            if (item.attributes.isNotEmpty) ...[
                              for (OrderItemAttribute attr in item.attributes)
                                Builder(
                                  builder: (context) {
                                    String str = "${attr.name} :";
                                    for (var i = 0;
                                        i < attr.values.length;
                                        i++) {
                                      String opt = attr.values[i];
                                      int len = attr.values.length;
                                      str +=
                                          "$opt ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                                    }
                                    return Text(
                                      str,
                                      style: const TextStyle(fontSize: 18),
                                    );
                                  },
                                ),
                            ],
                          ],
                        ),
                      )
                    ],
                  ),
                  const Divider(
                    height: 10,
                  ),
                ]
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: PrinterProvider().isConnected
                      ? OutlinedButton(
                          onPressed: () {
                            printerProvider.printReceipt(order);
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 20,
                              ),
                              Text("Re-print Receipt"),
                            ],
                          ),
                        )
                      : null,
                ),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        orderProvider.completeOrder(order);
                      },
                      child: const Text("Complete Order"),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close"),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
