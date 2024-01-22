import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, _) {
      return Scaffold(
        appBar: AppBar(
            title: StreamBuilder(
          stream: orderProvider.ordersCountAsStream,
          builder: (context, snapshot) {
            final count = snapshot.data?.count ?? 0;
            return Text("($count) Completed Orders");
          },
        )),
        body: Container(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder(
              stream: orderProvider.ordersAsStream,
              builder: (context, snapshot) {
                return DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 600,
                  columns: const [
                    DataColumn2(
                      label: Text('Order Date'),
                      size: ColumnSize.L,
                    ),
                    DataColumn(
                      label: Text('Server'),
                    ),
                    DataColumn(label: Text('Order Amount'), numeric: true),
                    DataColumn(label: Text('Grand Total'), numeric: true),
                    DataColumn(
                      label: Text(""),
                    ),
                    DataColumn(
                      label: Text('Payment Type'),
                    ),
                    DataColumn(
                      label: Text('# of Items'),
                      numeric: true,
                    ),
                  ],
                  rows: snapshot.hasData
                      ? snapshot.data!.map((order) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(order.orderDate),
                              ),
                              DataCell(
                                Text(order.serverName),
                              ),
                              DataCell(
                                Text("₱ ${order.orderAmount}"),
                              ),
                              DataCell(
                                Text("₱ ${order.grandTotal}"),
                              ),
                              const DataCell(
                                Text(""),
                              ),
                              DataCell(
                                Text(order.paymentMethod),
                              ),
                              DataCell(Text("${order.itemCount}"))
                            ],
                          );
                        }).toList()
                      : [],
                  empty: Center(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const CircularProgressIndicator()
                        : const Text("No orders yet"),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
