import 'package:better_serve/core/enums/discount_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either;

import '../../core/util.dart';
import '../widgets/common/custom_dialog.dart';
import '/constants.dart';
import '/core/extenstions.dart';
import '../../data/models/failure.dart';
import '/data/models/discount.dart';
import '/data/repositories/coupon_repository_impl.dart';
import '/data/sources/coupon_data_source.dart';
import '/domain/models/addon.dart';
import '/domain/models/attribute.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/coupon.dart';
import '/domain/models/order.dart';
import '/domain/models/order_item.dart';
import '/domain/models/product.dart';
import '/domain/models/variation.dart';
import 'order_provider.dart';

class CartProvider with ChangeNotifier {
  static final CartProvider _instance = CartProvider._internal();
  factory CartProvider() => _instance;
  CartProvider._internal();

  CouponRepositoryImpl couponRepositoryImpl =
      CouponRepositoryImpl(source: CouponDataSource());

  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  bool get hasItem => _items.isNotEmpty;

  Order? currentOrder;
  double tenderAmount = 0;
  Discount? discount;
  Coupon? coupon;

  double get totalAmount => _items.fold(0, (value, e) => value + e.total);
  double get discountAmount {
    Discount? discount = coupon?.discount ?? this.discount;
    if (discount == null) return 0;
    if (discount.type == DiscountType.fixed) {
      return discount.value.toDouble();
    } else {
      return roundDouble(totalAmount * (discount.value / 100), 2);
    }
  }

  double get grandTotal => totalAmount - discountAmount;
  bool get shouldPay => tenderAmount == 0 && grandTotal > 0;
  double get paymentChange => tenderAmount - grandTotal;

  OrderProvider orderProvider = OrderProvider();

  void addItem(CartItem newItem) {
    int index = getItemIndex(
        newItem.product, newItem.variation, newItem.attributes, newItem.addons);

    if (index != -1) {
      CartItem item = _items[index];
      item.quantity += newItem.quantity;
    } else {
      _items.add(newItem);
    }

    notifyListeners();
  }

  void updateItem(CartItem item, CartItem update) {
    int index = _items.indexWhere((e) => e.id == item.id);
    _items[index] = update;
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int getItemIndex(Product item, Variation? variation,
      List<Attribute> attributes, List<Addon> addons) {
    int? selectedVariation =
        variation?.options.firstWhereOrNull((e) => e.isSelected)?.id;
    List<int> selectedOptions = listOptionsId(attributes);
    List<int> selectedAddons = addons.map<int>((e) => e.id!).toList();
    return _items.indexWhere((ci) {
      var ciVariation =
          ci.variation?.options.firstWhereOrNull((e) => e.isSelected)?.id;
      List<int> ciOptions = listOptionsId(ci.attributes);
      List<int> ciAddons = ci.addons.map<int>((e) => e.id!).toList();
      return ci.product.id == item.id &&
          selectedVariation == ciVariation &&
          listEquals(selectedOptions, ciOptions) &&
          listEquals(selectedAddons, ciAddons);
    });
  }

  List<int> listOptionsId(List<Attribute> attributes) {
    return attributes.fold([], (value, item) {
      value.addAll(
          item.options.where((e) => e.isSelected).map((e) => e.id!).toList());
      return value;
    });
  }

  void restoreOrder(Order order) {
    _items.clear();
    for (var item in order.items) {
      Product product = item.product!;
      if (item.variationValue != null) {
        product.variation!.options = product.variation!.options.map((e) {
          e.isSelected = e.value == item.variationValue;
          return e;
        }).toList();
      }
      product.attributes = product.attributes.map((e) {
        OrderItemAttribute? attr =
            item.attributes.firstWhereOrNull((attr) => attr.name == e.name);
        if (attr != null) {
          e.options = e.options.map((opt) {
            opt.isSelected = attr.values.contains(opt.value);
            return opt;
          }).toList();
        }
        return e;
      }).toList();

      List<Addon> addons = item.addons.map((e) => e.addon).toList();

      _items.add(CartItem(
          product: item.product!,
          quantity: item.quantity,
          variation: product.variation,
          attributes: product.attributes,
          addons: addons));

      currentOrder = order;
    }

    notifyListeners();
  }

  Future holdTransaction(Order order) async {
    OrderProvider orderProvider = OrderProvider();
    if (currentOrder != null) {
      deleteOrder(currentOrder!.id);
      int index = orderProvider.onHoldOrders
          .indexWhere((e) => e.id == currentOrder!.id);
      orderProvider.onHoldOrders.removeAt(index);
      orderProvider.onHoldOrders.insert(index, order);
    } else {
      orderProvider.onHoldOrders.add(order);
    }
    currentOrder = null;
    _items.clear();
    tenderAmount = 0;
    notifyListeners();
  }

  void confirmCancellation(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomDialog(
            title: "Cancel transaction?",
            content:
                "This will cancel the current transaction and will remove all items from the cart.",
            positiveBtnText: "Yes",
            negativeBtnText: "Cancel",
            type: DialogType.error,
            onPositive: () {
              resetAll();
              Navigator.of(context).popUntil(ModalRoute.withName("/home"));
            },
          );
        });
  }

  Future<void> resetAll() async {
    _items.clear();
    coupon = discount = null;
    tenderAmount = 0;
    if (currentOrder?.id != null) {
      deleteOrder(currentOrder!.id);
      currentOrder = null;
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int value) {
    item.quantity = value;
    notifyListeners();
  }

  void setDiscount(Discount discount) {
    this.discount = discount;
    notifyListeners();
  }

  Future<Either<Failure, Coupon?>> setCoupon(String code) async {
    final result = await couponRepositoryImpl.one(code);
    result.fold(logger.e, (r) {
      coupon = r;
      notifyListeners();
    });
    return result;
  }

  void removeCoupon() {
    coupon = null;
    notifyListeners();
  }

  void resetPayment() {
    tenderAmount = 0;
    notifyListeners();
  }

  void setTenderAmount(double value) {
    tenderAmount = value;
    notifyListeners();
  }

  Future<void> deleteOrder(id) async {
    await orderProvider.deleteOrder(id);
  }
}
