import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

import '../../providers/category_provider.dart';
import '../../widgets/categories/category_delete_dialog.dart';
import '../../widgets/categories/category_form_dialog.dart';
import '/constants.dart';
import '/core/util.dart';
import '/domain/models/category.dart';
import '/presentation/widgets/common/button.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(builder: (context, categoryProvider, _) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "(${categoryProvider.categories.length}) Categories",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      pushHeroDialog(
                          primaryContext, const CategoryFormDialog());
                    },
                    icon: const Icon(Icons.add),
                    text: "Add",
                  )
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: categoryProvider.categories.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ReorderableTable(
                            header: ReorderableTableRow(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      'Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      'Icon',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      'Products Count',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(''),
                                ]),
                            onReorder: (oldIndex, newIndex) {
                              categoryProvider.swapOrder(oldIndex, newIndex);
                            },
                            children: [
                              for (Category category
                                  in categoryProvider.categories)
                                ReorderableTableRow(
                                  key: ObjectKey(category.id),
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(category.name),
                                    ),
                                    CachedNetworkImage(
                                      width: 20,
                                      imageUrl: category.iconUrl,
                                      errorWidget: (context, url, error) {
                                        return const Center(
                                          child: Icon(Icons.error),
                                        );
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          category.productCount.toString(),
                                          textAlign: TextAlign.right,
                                        ),
                                        IconButton(
                                          splashRadius: 20,
                                          onPressed: () {
                                            Navigator.of(managerContext)
                                                .pushReplacementNamed(
                                                    "products",
                                                    arguments: category);
                                          },
                                          icon: const Icon(
                                            Icons.open_in_new,
                                            size: 15,
                                            color: Colors.blueAccent,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Hero(
                                          tag: "edit_category_${category.id}",
                                          child: Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              splashRadius: 20,
                                              onPressed: () {
                                                pushHeroDialog(
                                                    primaryContext,
                                                    CategoryFormDialog(
                                                      category: category,
                                                    ));
                                              },
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Hero(
                                          tag: "delete_category_${category.id}",
                                          child: Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              splashRadius: 20,
                                              onPressed:
                                                  category.productCount > 0
                                                      ? null
                                                      : () {
                                                          pushHeroDialog(
                                                            primaryContext,
                                                            CategoryDeleteDialog(
                                                                category),
                                                          );
                                                        },
                                              icon: Icon(
                                                Icons.delete,
                                                color: category.productCount > 0
                                                    ? Colors.grey
                                                    : Colors.redAccent,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                            ],
                          ),
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/menu.png",
                          width: 200,
                          opacity: const AlwaysStoppedAnimation(100),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Add your first category",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Tap '+ Add' button to add product category",
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        )
                      ],
                    ),
            ),
          ],
        ),
      );
    });
  }
}
