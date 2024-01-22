import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../providers/addon_provider.dart';
import '../common/dialog_pane.dart';
import '../common/flip_dialog.dart';
import '../products/image_form.dart';
import '/domain/models/addon.dart';

class AddonFormDialog extends StatefulWidget {
  final Addon? addon;
  const AddonFormDialog({super.key, this.addon});

  @override
  State<AddonFormDialog> createState() => _AddonFormDialogState();
}

class _AddonFormDialogState extends State<AddonFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  String imageUrl = "";

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Addon? addon = widget.addon;
    _nameController = TextEditingController(text: addon?.name);
    _priceController = TextEditingController(text: addon?.price.toString());

    if (addon != null) {
      imageUrl = addon.imgUrl;
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Addon? addon = widget.addon;
    return Consumer<AddonProvider>(builder: (context, addonProvider, _) {
      return FlipDialog(
        frontBuilder: (context, flip) {
          return DialogPane(
            tag: "addon_${addon == null ? "new" : addon!.id}",
            width: 400,
            builder: (context, toggleLoadding) {
              return Container(
                padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: addon == null
                            ? const Row(
                                children: [
                                  Icon(Icons.add),
                                  Text(
                                    "Create New Addon",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              )
                            : const Row(
                                children: [
                                  Icon(Icons.edit),
                                  Text(
                                    "Edit Addon",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                      ),
                      const Divider(),
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          icon: Icon(Icons.text_fields_sharp),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required!';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          icon: Icon(MdiIcons.currencyPhp),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Price is required!';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        readOnly: true,
                        controller:
                            TextEditingController(text: basename(imageUrl)),
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
                          flip();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Image is required!';
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
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        String name = _nameController.text;
                        double price = double.parse(_priceController.text);
                        toggleLoadding();
                        if (addon != null) {
                          addon!.name = _nameController.text;
                          addon!.price = price;
                          addon!.imgUrl = imageUrl;
                        } else {
                          addon = Addon(
                              id: null,
                              name: name,
                              price: price,
                              imgUrl: imageUrl);
                        }
                        addonProvider.saveAddon(addon!).then((value) {
                          Navigator.of(context).pop();
                        });
                      },
                      child: const Icon(Icons.check),
                    ),
                  )
                ],
              );
            },
          );
        },
        backBuilder: (context, flip) {
          return ImageForm(
            imageUrl,
            (String? value) {
              if (value != null) {
                setState(() {
                  imageUrl = value;
                });
              }
              flip();
            },
          );
        },
      );
    });
  }
}
