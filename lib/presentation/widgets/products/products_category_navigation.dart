import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/setting_provider.dart';
import '/domain/models/category.dart';
import '/presentation/providers/category_provider.dart';

class ProductsCategoryNavigation extends StatefulWidget {
  final Orientation orientation;

  const ProductsCategoryNavigation({super.key, required this.orientation});

  @override
  State<ProductsCategoryNavigation> createState() =>
      _ProductsCategoryNavigationState();
}

class _ProductsCategoryNavigationState
    extends State<ProductsCategoryNavigation> {
  Category? selected;

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
      final isLandscape = widget.orientation == Orientation.landscape;
      final allButton = builAllButton(categoryProvider);
      final items = buildItems(categoryProvider);
      final content = Material(
        elevation: 10,
        child: SingleChildScrollView(
          scrollDirection: isLandscape ? Axis.horizontal : Axis.vertical,
          child: isLandscape
              ? Row(
                  children: [allButton, ...items],
                )
              : Column(
                  children: [allButton, ...items],
                ),
        ),
      );
      return isLandscape
          ? SizedBox(
              height: 100,
              child: content,
            )
          : SizedBox(
              height: double.infinity,
              child: content,
            );
    });
  }

  List<Widget> buildItems(CategoryProvider provider) {
    final categories = provider.categories;
    return [
      for (Category category in categories)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Material(
            elevation: selected == category ? 5 : 0,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  selected = category;
                });
                provider.setActiveCategory(category);
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 2,
                    color: selected == category
                        ? SettingProvider().primaryColor
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholderFadeInDuration: Duration.zero,
                      placeholder: (context, url) {
                        return const SizedBox(
                          width: 30,
                          height: 30,
                        );
                      },
                      imageUrl: category.iconUrl,
                      errorWidget: (context, url, error) {
                        return const Center(
                          child: Icon(Icons.error),
                        );
                      },
                      width: 30,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      category.name,
                      style: selected == category
                          ? const TextStyle(fontWeight: FontWeight.bold)
                          : null,
                    )
                  ],
                ),
              ),
            ),
          ),
        )
    ];
  }

  Widget builAllButton(CategoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              selected = null;
            });
            provider.setActiveCategory(null);
          },
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  width: 2,
                  color: selected == null
                      ? SettingProvider().primaryColor
                      : Colors.transparent),
            ),
            child: Column(children: [
              const Icon(Icons.dashboard_customize_outlined),
              const SizedBox(
                height: 10,
              ),
              Text(
                "All",
                style: selected == null
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
