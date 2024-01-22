import 'package:better_serve/core/extenstions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/printer_provider.dart';
import '../providers/setting_provider.dart';
import '../widgets/cart/cart_item_card.dart';
import '../widgets/cart/coupon_dialog.dart';
import '../widgets/cart/discount_dialog.dart';
import '../widgets/cart/invoice_line.dart';
import '../widgets/cart/order_placed.dart';
import '../widgets/cart/tender_dialog.dart';
import '/constants.dart';
import '/core/enums/discount_type.dart';
import '/core/util.dart';
import '/data/models/discount.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/order.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final SwipeActionController swipeController = SwipeActionController();
  final SettingProvider settingProvider = SettingProvider();
  final PrinterProvider printerProvider = PrinterProvider();

  Widget pesoSign = const Text(
    "₱",
    style: TextStyle(fontSize: 20),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, OrderProvider>(
      builder: (context, cartProvider, orderProvider, _) {
        double tenderAmount = cartProvider.tenderAmount;
        Discount? discount =
            cartProvider.coupon?.discount ?? cartProvider.discount;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 1,
            shadowColor: Theme.of(context).shadowColor,
            title: cartProvider.currentOrder != null
                ? Text(
                    "#${(cartProvider.currentOrder!.id).toString().padLeft(6, '0')}")
                : const Text(""),
            actions: [
              Row(
                children: [
                  for (int i = 0; i < orderProvider.onHoldOrders.length; i++)
                    Builder(
                      builder: (context) {
                        Order order = orderProvider.onHoldOrders[i];
                        bool active = cartProvider.currentOrder?.id == order.id;
                        return OutlinedButton(
                          onPressed: () {
                            cartProvider.restoreOrder(order);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(width: active ? 3 : 1),
                            minimumSize: const Size.square(35),
                            shape: const CircleBorder(),
                          ),
                          child: Text(
                            "${i + 1}",
                            style: TextStyle(
                                fontWeight: active ? FontWeight.bold : null),
                          ),
                        );
                      },
                    ),
                  const SizedBox(
                    width: 20,
                  ),
                  FilledButton(
                    onPressed: cartProvider.items.isNotEmpty
                        ? () {
                            showLoading(context);
                            orderProvider
                                .createOrder(cartProvider.items, discount,
                                    tenderAmount, cartProvider.coupon, true)
                                .then(
                              (res) async {
                                res.fold((l) => null, (r) async {
                                  Navigator.of(context).pop();
                                  await cartProvider.holdTransaction(r);
                                });
                              },
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.back_hand_outlined,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Hold",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FilledButton(
                    onPressed: cartProvider.items.isEmpty
                        ? null
                        : () => cartProvider.confirmCancellation(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Cancel",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          body: context.isPortrait
              ? Column(
                  children: [
                    buildItemList(cartProvider),
                    invoiceView(context, cartProvider, orderProvider)
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildItemList(cartProvider),
                    invoiceView(context, cartProvider, orderProvider)
                  ],
                ),
        );
      },
    );
  }

  Widget buildItemList(CartProvider cartProvider) {
    return Expanded(
      child: cartProvider.items.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: cartProvider.items.length,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = cartProvider.items[index];
                      return Card(
                        elevation: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: SwipeActionCell(
                            controller: swipeController,
                            key: ObjectKey(item),
                            index: index,
                            fullSwipeFactor: 0.3,
                            trailingActions: [
                              SwipeAction(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                  forceAlignmentToBoundary: true,
                                  performsFirstActionWithFullSwipe: true,
                                  onTap: (CompletionHandler handler) async {
                                    await handler(true);
                                    cartProvider.removeItem(item);
                                  },
                                  color: Colors.red),
                            ],
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: CartItemCard(
                                index,
                                item,
                                onQtyChange: (value) {
                                  if (value > 0) {
                                    item.quantity = value;
                                    cartProvider.updateQuantity(item, value);
                                    return true;
                                  } else {
                                    confirmAndRemove(cartProvider, item);
                                  }
                                  return false;
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(),
                  ),
                ],
              ),
            )
          : Container(
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.cartOutline,
                    size: 100,
                    color: Colors.grey,
                  ),
                  Text(
                    "No Items",
                    style: TextStyle(fontSize: 30, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> invoiceLines(BuildContext context, CartProvider cartProvider) {
    return [
      InvoiceLine(
        label: "Order Amount",
        amount: roundDouble(cartProvider.totalAmount),
      ),
      Builder(builder: (context) {
        final discount = cartProvider.discount;
        String str = "Discounts";
        if (cartProvider.coupon != null) {
          str += " (${cartProvider.coupon?.description})";
        } else if (discount != null &&
            discount.type == DiscountType.rate &&
            discount.value != 0) {
          str += " (${discount.value}%)";
        }
        return InvoiceLine(
            label: str, amount: roundDouble(cartProvider.discountAmount));
      }),
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Grand Total",
            style: TextStyle(fontSize: 20, color: settingProvider.primaryColor),
          ),
          Row(
            children: [
              pesoSign,
              Text(
                " ${roundDouble(cartProvider.grandTotal, 2)}",
                style: TextStyle(
                    fontSize: 30,
                    color: settingProvider.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      const Divider(),
      InvoiceLine(label: "Tendered", amount: cartProvider.tenderAmount),
      InvoiceLine(
        label: "Change",
        amount: roundDouble(cartProvider.paymentChange),
      )
    ];
  }

  Widget buildActions(BuildContext context, CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: context.isLandscape
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed:
                cartProvider.items.isNotEmpty && cartProvider.coupon == null
                    ? () {
                        pushHeroDialog(
                          primaryContext,
                          DiscountDialog(
                            initialValue: cartProvider.discount,
                            onComplete: (discount) {
                              cartProvider.setDiscount(discount);
                            },
                          ),
                        );
                      }
                    : null,
            child: Row(
              children: [
                const Icon(Icons.discount_outlined),
                const SizedBox(
                  width: 5,
                ),
                if (context.isTablet) const Text("Discounts"),
              ],
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: cartProvider.hasItem
                ? () {
                    pushHeroDialog(
                      primaryContext,
                      CouponDialog(
                        value: cartProvider.coupon,
                        onComplete: (code) {
                          showLoading(context);

                          cartProvider.setCoupon(code).then((res) {
                            res.fold((l) {
                              showToast(
                                context,
                                child: Text(l.message),
                                color: Colors.red,
                              );
                            }, (r) {
                              showToast(
                                context,
                                child: const Text("Coupon Applied"),
                              );
                            });
                            Navigator.of(context).pop();
                          });
                        },
                        onRemove: () {
                          cartProvider.removeCoupon();
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  }
                : null,
            child: Row(
              children: [
                const Icon(MdiIcons.ticketOutline),
                const SizedBox(
                  width: 5,
                ),
                if (context.isTablet) const Text("Coupon"),
              ],
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: cartProvider.tenderAmount == 0
                ? null
                : () {
                    cartProvider.resetPayment();
                  },
            child: Row(
              children: [
                const Icon(MdiIcons.cancel),
                const SizedBox(
                  width: 5,
                ),
                if (context.isTablet ||
                    (context.isMobile && context.isPortrait))
                  const Text("Void"),
              ],
            ),
          ),
          if (context.isMobile && context.isLandscape) ...[
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Icon(Icons.check),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget invoiceView(BuildContext context, CartProvider cartProvider,
      OrderProvider orderProvider) {
    final content = Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: invoiceLines(context, cartProvider),
            ),
          ),
          if (context.isLandscape) const Spacer(),
          buildActions(context, cartProvider),
          const SizedBox(
            height: 10,
          ),
          if (context.isTablet || (context.isMobile && context.isPortrait)) ...[
            FilledButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const RoundedRectangleBorder(),
              ),
              onPressed: cartProvider.items.isEmpty
                  ? null
                  : () {
                      if (cartProvider.shouldPay) {
                        Navigator.of(context).push(
                          DialogRoute(
                            context: context,
                            builder: (context) {
                              return TenderDialog(
                                cartProvider.grandTotal,
                                onTender: (double value) {
                                  cartProvider.setTenderAmount(value);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                        );
                        return;
                      }
                      showLoading(context);
                      orderProvider
                          .createOrder(
                              cartProvider.items,
                              cartProvider.discount,
                              cartProvider.tenderAmount,
                              cartProvider.coupon)
                          .then(
                        (res) {
                          Navigator.of(context).pop();
                          res.fold(
                            (l) {
                              showToast(context,
                                  child: Text(
                                      "Failed to create order : ${l.message}"));
                            },
                            (order) {
                              try {
                                printerProvider.printReceipt(order);
                              } catch (_) {
                                showToast(context,
                                    child:
                                        const Text("Failed to print receipt!"));
                              }

                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  "/home", (route) => false);
                              cartProvider.resetAll();
                              pushHeroDialog(
                                primaryContext,
                                OrderPlacedDialog(
                                  order: order,
                                  tenderAmount: cartProvider.tenderAmount,
                                  changeAmount: cartProvider.paymentChange,
                                ),
                                false,
                              );
                            },
                          );
                        },
                      );
                    },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    cartProvider.shouldPay
                        ? "Pay (₱${cartProvider.grandTotal})"
                        : "Done - Send Order",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
    return context.isLandscape
        ? SizedBox(
            width: 420,
            child: content,
          )
        : content;
  }

  void confirmAndRemove(CartProvider cart, CartItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text("Do you want to remove this item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                cart.removeItem(item);
                Navigator.of(context).pop();
                showToast(context, child: const Text("Item deleted!"));
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
