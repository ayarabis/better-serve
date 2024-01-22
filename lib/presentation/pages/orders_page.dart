import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/orders/order_card.dart';
import '/domain/models/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text("(${orderProvider.ongoingOrders.length}) Orders"),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: orderProvider.ongoingOrders.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          MdiIcons.clipboardListOutline,
                          size: 100,
                          color: Colors.grey,
                        ),
                        Text(
                          "No ongoing orders right now",
                          style: TextStyle(fontSize: 30, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.count(
                    childAspectRatio: 1.8,
                    crossAxisCount: 3,
                    children: [
                      for (Order order in orderProvider.ongoingOrders)
                        OrderCard(order: order)
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
