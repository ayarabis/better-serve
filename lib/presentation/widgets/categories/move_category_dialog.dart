import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../common/dialog_pane.dart';
import '/core/util.dart';
import '/domain/models/category.dart';
import '/domain/models/product.dart';

class MoveCategoryDialog extends StatefulWidget {
  final List<Product> items;
  final VoidCallback onComplete;
  const MoveCategoryDialog(
      {required this.items, super.key, required this.onComplete});

  @override
  State<MoveCategoryDialog> createState() => _MoveCategoryDialogState();
}

class _MoveCategoryDialogState extends State<MoveCategoryDialog> {
  int? selectedCategory;
  bool moving = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryProvider, ProductProvider>(
        builder: (context, categoryProvider, productProvider, _) {
      final List<Map<String, dynamic>> categorySelectItems = [
        for (Category c in categoryProvider.categories)
          {
            'value': c.id,
            'label': c.name,
          }
      ];
      return DialogPane(
          tag: "move_category",
          width: 400,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text("Select category"),
              const Divider(),
              SelectFormField(
                type: SelectFormFieldType.dropdown,
                icon: const Icon(Icons.category),
                labelText: 'Category',
                items: categorySelectItems,
                onChanged: (val) {
                  setState(() {
                    selectedCategory = int.parse(val);
                  });
                },
              ),
              const Divider(),
              Row(
                children: [
                  TextButton(
                    onPressed: moving
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: moving
                          ? null
                          : () {
                              if (selectedCategory != null) {
                                setState(() {
                                  moving = true;
                                });
                                productProvider
                                    .changeCategory(
                                        widget.items, selectedCategory!)
                                    .then((res) {
                                  res.fold((l) {
                                    showToast(context,
                                        child: Text(l.message),
                                        color: Colors.red);
                                  }, (r) {
                                    widget.onComplete();
                                    Navigator.of(context).pop();
                                  });
                                });
                              }
                            },
                      child: moving
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ))
                          : const Text("Ok"),
                    ),
                  )
                ],
              )
            ]),
          ));
    });
  }
}
