import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' show basename;
import 'package:select_form_field/select_form_field.dart';

import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/setting_provider.dart';
import '../common/dialog_pane.dart';
import '../common/flip_dialog.dart';
import '/core/extenstions.dart';
import '/core/util.dart';
import '/domain/models/attribute.dart';
import '/domain/models/attribute_option.dart';
import '/domain/models/category.dart';
import '/domain/models/product.dart';
import '/domain/models/variation.dart';
import '/domain/models/variation_option.dart';
import 'attribute_form.dart';
import 'image_form.dart';
import 'variation_form.dart';

enum BackForm { variation, attribute, image }

class ProductFormDialog extends StatefulWidget {
  final BuildContext ctx;
  final Product? product;
  final Category? category;
  const ProductFormDialog(this.ctx, this.product, this.category, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog>
    with TickerProviderStateMixin {
  String name = "";
  String price = '';
  Variation? variation;
  List<Attribute> attributes = List.empty(growable: true);
  Attribute? editingAttribute;

  BackForm backForm = BackForm.variation;

  Product? product;
  Category? selectedCategory;
  String imageUrl = "";
  bool allowAddon = true;

  late TextEditingController _priceController;

  final SettingProvider settingProvider = SettingProvider();
  final CategoryProvider categoryProvider = CategoryProvider();
  final ProductProvider productProvider = ProductProvider();

  final _formKey = GlobalKey<FormState>();

  get variationPriceRange {
    List<VariationOption> options = variation!.options;
    options.sort((a, b) => a.price.compareTo(b.price));
    return "₱${options.first.price} - ₱${options.last.price}";
  }

  @override
  void initState() {
    product = widget.product;
    if (product != null) {
      selectedCategory = product!.category;
      name = product!.name;
      price = product!.basePrice.toString();
      product = widget.product;
      imageUrl = product!.imgUrl;
      allowAddon = product!.allowAddon;

      if (widget.product?.variation != null) {
        variation = widget.product?.variation!.clone();
      }
      attributes = product!.attributes.map((e) => e.clone()).toList();
    }
    if (widget.category != null) selectedCategory = widget.category!;
    _priceController = TextEditingController(
        text: variation != null ? variationPriceRange : (price).toString());
    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlipDialog(
      frontBuilder: (context, flip) {
        return mainForm(flip);
      },
      backBuilder: (context, flip) {
        return backForm == BackForm.variation
            ? VariationForm(variation, (Variation? result, _) {
                if (result != null) {
                  setState(() {
                    variation = result;
                  });
                }
                flip();
              }, onRemove: () {
                setState(() {
                  variation = null;
                  _priceController.text = (price).toString();
                });
              }, showTemplate: true)
            : backForm == BackForm.attribute
                ? AttributeForm(
                    editingAttribute,
                    (Attribute? result, _) {
                      if (result != null) {
                        if (editingAttribute == null) {
                          if (attributes.firstWhereOrNull(
                                (e) => e.name == result.name,
                              ) !=
                              null) {
                            showToast(context,
                                child: const Text(
                                  "Attribute name must be unique!",
                                  style: TextStyle(color: Colors.red),
                                ));
                            return;
                          }
                          setState(() {
                            attributes.add(result);
                            flip();
                          });
                        } else {
                          var index = attributes.indexOf(editingAttribute!);
                          attributes[index] = result;
                          flip();
                        }
                      } else {
                        flip();
                      }
                    },
                    onRemove: () {
                      attributes.remove(editingAttribute);
                    },
                    showTemplate: true,
                  )
                : ImageForm(
                    imageUrl,
                    (String? url) {
                      if (url != null) {
                        setState(() {
                          imageUrl = url;
                        });
                      }
                      flip();
                    },
                    allowOnline: false,
                  );
      },
    );
  }

  Widget mainForm(void Function() flip) {
    final List<Map<String, dynamic>> categorySelectItems = [
      for (Category c in categoryProvider.categories)
        {
          'value': c.id,
          'label': c.name,
          'icon': CachedNetworkImage(
            imageUrl: c.iconUrl,
            errorWidget: (context, url, error) {
              return const Center(
                child: Icon(Icons.error),
              );
            },
            width: 20,
          ),
        }
    ];
    return DialogPane(
      tag: "product_${product == null ? "new" : product!.id}",
      width: 500,
      scrollable: true,
      headerBuilder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: product == null
                ? [
                    const Icon(Icons.add),
                    const Text(
                      "Create New Item",
                      style: TextStyle(fontSize: 18),
                    ),
                  ]
                : [
                    const Icon(Icons.edit),
                    const Text(
                      "Update Item",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
          ),
        );
      },
      builder: (context, toggleLoadding) {
        return Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'Name', icon: Icon(Icons.inventory)),
                  initialValue: name,
                  onChanged: (val) {
                    setState(() {
                      name = val;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SelectFormField(
                  type: SelectFormFieldType.dropdown,
                  icon: const Icon(Icons.category),
                  labelText: 'Category',
                  items: categorySelectItems,
                  initialValue: selectedCategory?.id.toString(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategory = categoryProvider.categories
                          .singleWhere((c) => c.id.toString() == val);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  readOnly: variation != null,
                  controller: _priceController,
                  keyboardType: variation != null
                      ? TextInputType.text
                      : TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onChanged: (newValue) {
                    price = newValue;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    icon: Icon(MdiIcons.currencyPhp),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: basename(imageUrl)),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Image',
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (imageUrl.isNotEmpty)
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 14,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.image),
                      ],
                    ),
                  ),
                  onTap: () {
                    backForm = BackForm.image;
                    flip();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an image';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Icon(
                      MdiIcons.foodVariant,
                      color: context.isDarkMode
                          ? Colors.white.withAlpha(170)
                          : Colors.grey,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text("Allow Addon?"),
                    Checkbox(
                        value: allowAddon,
                        onChanged: (v) {
                          setState(() {
                            allowAddon = v!;
                          });
                        }),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                if (variation != null) ...[
                  Text(
                    "Variation",
                    style: TextStyle(
                      color: settingProvider.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (variation != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          variation!.name,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Wrap(
                          spacing: 10,
                          children: [
                            for (VariationOption option in variation!.options)
                              Chip(
                                backgroundColor: option.isSelected
                                    ? settingProvider.primaryColor
                                    : null,
                                label: Text(
                                  "${option.value} | ₱${option.price}",
                                  style: TextStyle(
                                    color: option.isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              )
                          ],
                        )
                      ],
                    ),
                  const Divider(),
                ],
                if (attributes.isNotEmpty) ...[
                  Text(
                    "Attributes",
                    style: TextStyle(
                      color: settingProvider.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  for (Attribute attr in attributes)
                    Card(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            backForm = BackForm.attribute;
                            editingAttribute = attr;
                            flip();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.edit_note),
                                  Text(
                                    attr.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                              Wrap(
                                spacing: 10,
                                children: [
                                  for (AttributeOption option in attr.options)
                                    Chip(
                                      backgroundColor: option.isSelected
                                          ? settingProvider.primaryColor
                                          : null,
                                      label: Text(
                                        option.value,
                                        style: TextStyle(
                                          color: option.isSelected
                                              ? Colors.white
                                              : context.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                ],
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                          onPressed: () {
                            backForm = BackForm.attribute;
                            editingAttribute = null;
                            flip();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(attributes.isEmpty
                                  ? Icons.add
                                  : Icons.edit_note_sharp),
                              const Text("Add Attributes"),
                            ],
                          )),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: OutlinedButton(
                          onPressed: () {
                            backForm = BackForm.variation;
                            flip();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(variation == null
                                  ? Icons.add
                                  : Icons.edit_note_sharp),
                              Text(variation == null
                                  ? "Enable Variation"
                                  : "Edit Variation"),
                            ],
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      footerBuilder: (context, toggleLoadding) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: () {
                  close();
                },
                child: const Text("Cancel")),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  toggleLoadding();
                  if (product != null) {
                    await productProvider.updateProduct(
                      product!.id,
                      name,
                      double.tryParse(price) ?? 0,
                      selectedCategory!.id!,
                      variation,
                      attributes,
                      imageUrl,
                      allowAddon,
                    );
                  } else {
                    await productProvider.saveProduct(
                      name,
                      double.tryParse(price) ?? 0,
                      selectedCategory!.id!,
                      variation,
                      attributes,
                      imageUrl,
                      allowAddon,
                    );
                  }
                  close();
                },
                child: const Icon(
                  Icons.check,
                  size: 30,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void close() {
    setState(() {
      attributes.clear();
      variation = null;
    });
    Navigator.of(context).pop();
  }
}
