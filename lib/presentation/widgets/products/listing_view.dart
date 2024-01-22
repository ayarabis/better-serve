import 'package:better_serve/core/extenstions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/constants.dart';
import '../../../core/config/settings.dart';
import '/core/util.dart';
import '/domain/models/product.dart';
import '/presentation/providers/category_provider.dart';
import '/presentation/providers/product_provider.dart';
import '/presentation/providers/setting_provider.dart';
import '/presentation/widgets/orders/order_item_dialog.dart';
import 'shop_product_card.dart';

class ListingView extends StatefulWidget {
  final Function(Product item) onSelect;
  final int gridSize;
  const ListingView(
      {required this.onSelect, required this.gridSize, super.key});

  @override
  State<ListingView> createState() => _ListingViewState();
}

class _ListingViewState extends State<ListingView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer3<ProductProvider, CategoryProvider, SettingProvider>(
          builder: (context, productProvider, categoryProvider, settingProvider,
              child) {
        final activeCategory = categoryProvider.activeCategory;
        var products = activeCategory == null
            ? productProvider.products
            : productProvider.products
                .where((p) => p.category.id == activeCategory.id);

        var categorizedProducts = <String, List<Product>>{};
        for (var e in products) {
          var c = e.category;
          var k = "${c.order}_${c.name}";
          if (!categorizedProducts.containsKey(k)) {
            categorizedProducts.addAll({k: []});
          }
          categorizedProducts[k]?.add(e);
        }
        return products.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    for (final key in categorizedProducts.keys.toList()
                      ..sort()) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              width: 20,
                              imageUrl: categorizedProducts[key]!
                                  .first
                                  .category
                                  .iconUrl,
                              errorWidget: (context, url, error) {
                                return const Center(
                                  child: Icon(Icons.error),
                                );
                              },
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              key.substring(2),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        crossAxisCount: widget.gridSize,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final item in categorizedProducts[key]!)
                            Hero(
                              tag: "product_${item.id}",
                              child: ShopProductCard(
                                item,
                                gridSize: widget.gridSize,
                                onSelect: () {
                                  if (settings.valueOf(
                                          Settings.shopShowQuickView) &&
                                      context.isLandscape) {
                                    widget.onSelect(item);
                                  } else {
                                    pushHeroDialog(primaryContext,
                                        OrderItemDialog(item), true);
                                  }
                                },
                              ),
                            )
                        ],
                      )
                    ]
                  ],
                ),
              )
            : Center(
                child: productProvider.isLoading
                    ? const CircularProgressIndicator()
                    : Text(categoryProvider.categories.isEmpty ||
                            activeCategory == null
                        ? "No items available"
                        : "No items for the seleted category"),
              );
      }),
    );
  }
}
