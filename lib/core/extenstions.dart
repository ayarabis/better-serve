import 'package:better_serve/domain/models/coupon.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/domain/models/cart_item.dart';
import '/domain/models/order.dart';
import '/domain/models/variation.dart';
import '/domain/models/variation_option.dart';
import 'enums/order_status.dart';

extension CartItemPricing on CartItem {
  double get price =>
      variation?.options.firstWhereOrNull((e) => e.isSelected)?.price ??
      product.basePrice;

  double get total {
    double addonsTotal = addons.fold(0, (value, e) => value + e.price);
    return (price * quantity) + addonsTotal;
  }
}

extension ParitionList on List {
  List<List<dynamic>> partition(int size) {
    var len = length;
    List<List<dynamic>> chunks = [];

    for (var i = 0; i < len; i += size) {
      var end = (i + size < len) ? i + size : len;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
}

extension FancyOrder on Order {
  String get statusName => OrderStatus.valueOf(status).name;

  Color get statusColor {
    switch (OrderStatus.valueOf(status)) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.onhold:
        return Colors.green;
      case OrderStatus.processing:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}

extension VariationOptionExt on VariationOption {
  bool get isBlank => id == 0 && value.isEmpty && price == 0;
}

extension VariationPricing on Variation {
  double get basePrice {
    options.sort((a, b) => a.price.compareTo(b.price));
    return options.first.price;
  }
}

extension CouponUsage on Coupon {
  bool get available => quantity == 0 || quantity > usageCount;
  bool get expired => expiryDate?.isBefore(DateTime.now()) ?? false;
}

extension DarkMode on BuildContext {
  bool get isDarkMode {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark;
  }
}

extension UserProfile on User {
  String get firstName => userMetadata?["first_name"] ?? "--";
  String get lastName => userMetadata?["last_name"] ?? "--";
  String get fullName => "$firstName $lastName";
  String get initials {
    final fname = userMetadata?['first_name'] ?? "-";
    final lname = userMetadata?['last_name'] ?? "-";
    return fname[0] + lname[0];
  }
}

extension UIUX on BuildContext {
  void showSnackBar({
    required String message,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }

  get isMobile => ResponsiveBreakpoints.of(this).isMobile;
  get isTablet => ResponsiveBreakpoints.of(this).isTablet;
  get screenSize => MediaQuery.of(this).size;
  get viewInsets => MediaQuery.of(this).viewInsets;
  get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
}
