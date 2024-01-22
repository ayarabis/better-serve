enum OrderStatus {
  onhold(0),
  pending(1),
  processing(2),
  done(3);

  final int ordinal;
  const OrderStatus(this.ordinal);

  factory OrderStatus.valueOf(int ordinal) {
    return OrderStatus.values.firstWhere((e) => e.ordinal == ordinal);
  }
}
