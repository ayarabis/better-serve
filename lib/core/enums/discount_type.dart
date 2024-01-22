enum DiscountType {
  fixed("Fixed"),
  rate("Rate");

  final String name;
  const DiscountType(this.name);

  static DiscountType fromValue(String name) {
    if (name.toLowerCase() == "fixed") return DiscountType.fixed;
    return DiscountType.rate;
  }
}
