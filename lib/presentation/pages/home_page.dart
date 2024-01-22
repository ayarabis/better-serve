import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/settings.dart';
import '../drawer/main_navigation_drawer.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/setting_provider.dart';
import '../widgets/printer_action.dart';
import '../widgets/products/products_category_navigation.dart';
import '/constants.dart';
import 'shop_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int gridSize = 6;

  late SettingProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = SettingProvider();
    gridSize = settings.valueOf(Settings.shopGridSize);
    final quickView =
        settings.valueOf<bool>(Settings.shopShowQuickView) ?? true;
    if (quickView && gridSize >= 8) {
      gridSize = 6;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CartProvider, OrderProvider, SettingProvider>(
        builder: (context, cartProvider, orderProvider, settingProvider, _) {
      return OrientationBuilder(builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        int minGridSize = 4;
        int maxGridSize = isLandscape ? 6 : 5;
        if (!settingProvider.valueOf(Settings.shopShowQuickView)) {
          minGridSize += 1;
        }
        if (gridSize > maxGridSize) gridSize = maxGridSize;
        if (gridSize < minGridSize) gridSize = minGridSize;
        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            scrolledUnderElevation: 5,
            title: Row(children: [
              const PrinterAction(),
              const SizedBox(
                width: 20,
              ),
              Image.asset(
                "assets/images/logo.png",
                width: 30,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text("Better Serve"),
            ]),
            actions: [
              InkWell(
                customBorder: const CircleBorder(),
                onTap: (() => Navigator.of(context).pushNamed("/orders")),
                child: Center(
                  child: Badge(
                    label: Text(
                      orderProvider.ongoingOrders.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    child: const Icon(Icons.format_list_numbered),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: (() => Navigator.of(context).pushNamed("/cart")),
                child: Center(
                  child: Badge(
                    label: Text(
                      cartProvider.itemCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    child: const Icon(Icons.shopping_cart),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          drawer: const MainNavigationDrawer(),
          body: ShopPage(gridSize),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: isLandscape
              ? const SizedBox()
              : const ProductsCategoryNavigation(
                  orientation: Orientation.landscape,
                ),
          floatingActionButton: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 20,
                onPressed: gridSize < maxGridSize
                    ? () {
                        setState(() {
                          gridSize += 1;
                        });
                        settingProvider.setValue(
                            Settings.shopGridSize, gridSize);
                      }
                    : null,
                icon: const Icon(Icons.zoom_out),
              ),
              SizedBox(
                width: 5,
                child: Text("$gridSize"),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 20,
                onPressed: gridSize > minGridSize
                    ? () {
                        setState(() {
                          gridSize -= 1;
                        });
                        settingProvider.setValue(
                            Settings.shopGridSize, gridSize);
                      }
                    : null,
                icon: const Icon(Icons.zoom_in),
              ),
            ]),
          ),
        );
      });
    });
  }
}
