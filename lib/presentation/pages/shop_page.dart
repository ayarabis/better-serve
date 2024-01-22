import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/cart/quick_view_panel.dart';
import '../../core/config/settings.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/product.dart';
import '/presentation/providers/setting_provider.dart';
import '/presentation/widgets/products/listing_view.dart';
import '/presentation/widgets/products/products_category_navigation.dart';

class ShopPage extends StatefulWidget {
  final int gridSize;
  const ShopPage(this.gridSize, {Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  CartProvider cartProvider = CartProvider();
  CategoryProvider categoryProvider = CategoryProvider();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, SettingProvider>(
      builder: (context, productProvider, settingProvider, child) {
        return OrientationBuilder(builder: (context, orientation) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (orientation == Orientation.landscape)
                const ProductsCategoryNavigation(
                  orientation: Orientation.portrait,
                ),
              ListingView(
                gridSize: widget.gridSize,
                onSelect: quickAdd,
              ),
              if (settingProvider.valueOf<bool>(Settings.shopShowQuickView) &&
                  orientation == Orientation.landscape)
                const QuickViewPanel()
            ],
          );
        });
      },
    );
  }

  void quickAdd(Product item) {
    cartProvider.addItem(CartItem(
        product: item,
        addons: const [],
        variation: item.variation,
        attributes: item.attributes,
        quantity: 1));
  }
}
