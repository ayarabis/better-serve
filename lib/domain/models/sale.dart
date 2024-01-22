class Sale {
  int orderCount;
  int itemCount;
  double orderAmount;
  double grandTotal;

  Sale({
    required this.orderCount,
    required this.itemCount,
    required this.orderAmount,
    required this.grandTotal,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      orderCount: map['order_count'] as int,
      itemCount: map['item_count'] as int,
      orderAmount: double.parse(map['order_amount'].toString()),
      grandTotal: double.parse(map['grand_total'].toString()),
    );
  }
}
