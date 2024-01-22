import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/setting_provider.dart';
import '../../../core/config/settings.dart';
import '/domain/models/product.dart';
import '/domain/models/variation_option.dart';

class ShopProductCard extends StatelessWidget {
  final Product item;
  final Function() onSelect;
  final int gridSize;
  const ShopProductCard(this.item,
      {Key? key, required this.onSelect, this.gridSize = 6})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(
        builder: (context, settingProvider, child) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.hardEdge,
        elevation: 5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CachedNetworkImage(
              width: double.infinity,
              fadeInDuration: const Duration(milliseconds: 100),
              fadeOutDuration: const Duration(milliseconds: 100),
              placeholderFadeInDuration: const Duration(milliseconds: 100),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Container(
                alignment: Alignment.center,
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: settingProvider.logo),
                  ),
                ),
              ),
              imageUrl: item.imgUrl,
              errorWidget: (context, url, error) {
                return const Center(
                  child: Icon(Icons.error),
                );
              },
            ),
            InkWell(
              onTap: () {
                onSelect.call();
              },
              child: SizedBox(
                height: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: {6: 15, 5: 20, 4: 30, 3: 30}[gridSize]
                              ?.toDouble(),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (settingProvider
                        .valueOf<bool>(Settings.shopShowItemPrice))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 3),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: item.variation != null
                              ? [
                                  for (VariationOption opt
                                      in item.variation!.options)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          opt.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "₱${opt.price}",
                                          style: TextStyle(
                                            fontSize: {
                                              6: 15,
                                              5: 18,
                                              4: 20
                                            }[gridSize]
                                                ?.toDouble(),
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    )
                                ]
                              : [
                                  Text(
                                    "₱${item.basePrice}",
                                    style: TextStyle(
                                      fontSize: {6: 15, 5: 18, 4: 20}[gridSize]
                                          ?.toDouble(),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
