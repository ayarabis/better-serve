import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/categories/move_category_dialog.dart';
import '../../widgets/products/manager_product_card.dart';
import '../../widgets/products/product_delete_dialog.dart';
import '../../widgets/products/product_form_dialog.dart';
import '../../widgets/products/products_category_navigation.dart';
import '../../widgets/products/products_empty_view.dart';
import '../template_page.dart';
import '/constants.dart';
import '/core/util.dart';
import '/domain/models/category.dart';
import '/domain/models/product.dart';
import '/presentation/widgets/common/button.dart';

class ProductsPage extends StatefulWidget {
  final Category? category;
  const ProductsPage(this.category, {super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> selected = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, CategoryProvider>(
        builder: (context, productProvider, categoryProvider, chid) {
      final activeCategory = categoryProvider.activeCategory;
      return OrientationBuilder(builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Row(
          children: [
            if (isLandscape)
              const ProductsCategoryNavigation(
                orientation: Orientation.portrait,
              ),
            FutureBuilder(future: Future.microtask(() {
              var products = activeCategory == null
                  ? productProvider.products
                  : productProvider.products
                      .where((p) => p.category.id == activeCategory.id);

              var categorizedProducts = <String, List<Product>>{};
              if (activeCategory == null) {
                for (var e in products) {
                  var c = e.category;
                  var k = "${c.order}_${c.name}";
                  if (!categorizedProducts.containsKey(k)) {
                    categorizedProducts.addAll({k: []});
                  }
                  categorizedProducts[k]?.add(e);
                }
              } else {
                categorizedProducts[
                        "${activeCategory.order}_${activeCategory.name}"] =
                    products.toList();
              }
              return (products, categorizedProducts);
            }), builder: (context, snapshot) {
              if (snapshot.hasData) {
                var products = snapshot.data!.$1;
                var categorizedProducts = snapshot.data!.$2;
                return Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        child: AnimatedCrossFade(
                          firstChild: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.inventory,
                                      size: 15,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "${products.length} Products",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    ...(isLandscape
                                        ? [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.info,
                                                  size: 14,
                                                ),
                                                Text(categorizedProducts
                                                        .keys.isEmpty
                                                    ? " You must add a category first"
                                                    : " Tap and hold item to start selection"),
                                              ],
                                            )
                                          ]
                                        : [])
                                  ],
                                ),
                              ),
                              if (isLandscape) ...[
                                ElevatedButton.icon(
                                  onPressed: manageTemplate,
                                  icon: const Icon(Icons.list),
                                  label:
                                      const Text("Manage Variants/Attributes"),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton.icon(
                                  onPressed: manageCategories,
                                  icon: const Icon(Icons.category),
                                  label: const Text("Manage Categories"),
                                )
                              ] else ...[
                                ElevatedButton(
                                  onPressed: manageTemplate,
                                  child: const Icon(Icons.list),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: manageCategories,
                                  child: const Icon(Icons.category),
                                )
                              ],
                              const SizedBox(
                                width: 10,
                              ),
                              PrimaryButton(
                                onPressed: categorizedProducts.keys.isEmpty
                                    ? null
                                    : () {
                                        pushHeroDialog(
                                            primaryContext,
                                            ProductFormDialog(
                                                context, null, activeCategory));
                                      },
                                icon: const Icon(Icons.add),
                                text: "Add",
                              )
                            ],
                          ),
                          secondChild: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.inventory,
                                      size: 15,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "${selected.length}/${products.length} Selected",
                                      style: const TextStyle(fontSize: 20),
                                    )
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selected.clear();
                                  });
                                },
                                child: const Text("Cancel"),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    DialogRoute(
                                      context: context,
                                      builder: (context) {
                                        return MoveCategoryDialog(
                                          items: selected,
                                          onComplete: () {
                                            setState(() {
                                              selected.clear();
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text("Move to Category"),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              FilledButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.redAccent),
                                ),
                                onPressed: () => onDeleteAction(),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 15,
                                    ),
                                    Text("Delete")
                                  ],
                                ),
                              )
                            ],
                          ),
                          crossFadeState: selected.isEmpty
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 100),
                        ),
                      ),
                      const Divider(
                        height: 1,
                      ),
                      Expanded(
                        child: productProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : productProvider.products.isEmpty
                                ? const ProductsEmptyView()
                                : SizedBox(
                                    width: double.infinity,
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (final key
                                                in categorizedProducts.keys
                                                    .toList()
                                                  ..sort()) ...[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  key.substring(2),
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ),
                                              Wrap(
                                                spacing: 5,
                                                runSpacing: 5,
                                                children: [
                                                  for (Product product
                                                      in categorizedProducts[
                                                          key]!)
                                                    FutureBuilder(
                                                      future: Future.delayed(
                                                        const Duration(
                                                            milliseconds: 100),
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        return ManagerProductCard(
                                                          product,
                                                          isActive:
                                                              selected.contains(
                                                                  product),
                                                          onSelectionChanged:
                                                              (bool val) {
                                                            if (val) {
                                                              setState(() {
                                                                selected.add(
                                                                    product);
                                                              });
                                                            }
                                                          },
                                                          onTap: () {
                                                            bool isActive =
                                                                selected
                                                                    .contains(
                                                                        product);
                                                            if (selected
                                                                .isNotEmpty) {
                                                              setState(
                                                                () {
                                                                  if (isActive) {
                                                                    selected.remove(
                                                                        product);
                                                                  } else {
                                                                    selected.add(
                                                                        product);
                                                                  }
                                                                  isActive =
                                                                      !isActive;
                                                                },
                                                              );
                                                            } else {
                                                              pushHeroDialog(
                                                                primaryContext,
                                                                ProductFormDialog(
                                                                  context,
                                                                  product,
                                                                  activeCategory,
                                                                ),
                                                              );
                                                            }
                                                            return isActive;
                                                          },
                                                        );
                                                      },
                                                    )
                                                ],
                                              )
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
          ],
        );
      });
    });
  }

  void manageTemplate() {
    pushHeroDialog(context, const TemplatePage());
  }

  void manageCategories() {
    Navigator.of(managerContext).pushNamed("categories");
  }

  void onDeleteAction() async {
    showDialog(
      context: context,
      builder: (context) {
        return ProductDeleteDialog(selected, () {
          setState(() {
            selected.clear();
          });
        });
      },
    );
  }
}
