import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show basename;

import '../../providers/category_provider.dart';
import '../../providers/setting_provider.dart';
import '../common/dialog_pane.dart';
import '../common/flip_dialog.dart';
import '../products/image_form.dart';
import '/domain/models/category.dart';

class CategoryFormDialog extends StatefulWidget {
  final Category? category;
  const CategoryFormDialog({Key? key, this.category}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  String categoryName = "";
  String iconUrl = "";
  bool uploading = false;

  String selectingIcon = "";

  late TextEditingController _nameController;

  final SettingProvider settingProvider = SettingProvider();
  final CategoryProvider categoryProvider = CategoryProvider();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.category != null) {
      categoryName = widget.category!.name;
      iconUrl = widget.category!.iconUrl;
    }
    _nameController = TextEditingController(text: categoryName);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Category? category = widget.category;
    return FlipDialog(
      frontBuilder: (context, flip) {
        return DialogPane(
          tag: category == null
              ? "add_category"
              : "edit_category_${category!.id}",
          width: 400,
          builder: (context, toggleLoadding) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            const Icon(Icons.add),
                            Text(
                              category == null
                                  ? "Create New Category"
                                  : "Edit Category",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Name',
                        icon: Icon(Icons.category),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      readOnly: true,
                      controller:
                          TextEditingController(text: basename(iconUrl)),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Logo',
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (iconUrl.isNotEmpty)
                              CachedNetworkImage(
                                width: 30,
                                imageUrl: iconUrl,
                                errorWidget: (context, url, error) {
                                  return const Center(
                                    child: Icon(Icons.error),
                                  );
                                },
                              )
                            else
                              const Icon(Icons.image),
                          ],
                        ),
                      ),
                      onTap: () {
                        flip();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Logo is required';
                        }
                        return null;
                      },
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
                      Navigator.of(context).pop();
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
                      String name = _nameController.text;
                      toggleLoadding();
                      if (category != null) {
                        category!.name = name;
                        category!.iconUrl = iconUrl;
                      } else {
                        category = Category(
                          name: name,
                          iconUrl: iconUrl,
                          order: categoryProvider.categories.length,
                        );
                      }
                      categoryProvider.saveCategory(category!).then((_) {
                        Navigator.of(context).pop();
                      });
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
      },
      backBuilder: (context, flip) {
        return ImageForm(iconUrl, (String? value) {
          if (value != null) {
            setState(() {
              iconUrl = value;
            });
          }
          flip();
        });
      },
    );
  }
}
