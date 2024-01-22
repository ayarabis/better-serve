import 'package:better_serve/presentation/providers/variation_provider.dart';
import 'package:better_serve/presentation/widgets/common/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/setting_provider.dart';
import '../common/dialog_pane.dart';
import '../custom_form_field.dart';
import '/core/extenstions.dart';
import '/core/util.dart';
import '/domain/models/variation.dart';
import '/domain/models/variation_option.dart';

class VariationForm extends StatefulWidget {
  final Variation? value;
  final Function(Variation?, Function) callback;
  final VoidCallback? onRemove;
  final String? title;
  final bool showTemplate;
  final bool inputLabel;
  const VariationForm(
    this.value,
    this.callback, {
    this.onRemove,
    this.title,
    this.showTemplate = false,
    this.inputLabel = false,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VariationFormState();
}

class _VariationFormState extends State<VariationForm> {
  late Variation editingVariation;
  int? defaultSelected;

  final _formKey = GlobalKey<FormState>();

  final SettingProvider settingProvider = SettingProvider();
  @override
  void initState() {
    if (widget.value != null) {
      editingVariation = widget.value!.clone();
      var selectedIndex =
          editingVariation.options.indexWhere((e) => e.isSelected);
      if (selectedIndex != -1) {
        defaultSelected = selectedIndex;
      }
    } else {
      editingVariation = Variation.empty();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "variation_form",
      width: 500,
      header: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              widget.title ?? "Add Variation",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      builder: (context, toggleLoadding) {
        return Padding(
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showTemplate)
                  Consumer<VariationProvider>(
                      builder: (context, variationProvider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (Variation variation
                            in variationProvider.variations)
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                editingVariation = variation;
                                editingVariation.name =
                                    variation.label ?? variation.name;
                                defaultSelected = variation.options
                                    .indexWhere((opt) => opt.isSelected);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: settingProvider.primaryColor),
                              ),
                              child: Text(
                                variation.name,
                                style: TextStyle(
                                    color: settingProvider.primaryColor),
                              ),
                            ),
                          )
                      ],
                    );
                  }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      TextFormField(
                        controller:
                            TextEditingController(text: editingVariation.name),
                        decoration: const InputDecoration(
                            label: Text("Variation Name"), isDense: true),
                        onChanged: (value) {
                          editingVariation.name = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Variation name is required!";
                          }
                          return null;
                        },
                      ),
                      if (widget.inputLabel)
                        TextFormField(
                          controller: TextEditingController(
                              text: editingVariation.label),
                          decoration: const InputDecoration(
                              label: Text("Variation Label"), isDense: true),
                          onChanged: (value) {
                            editingVariation.label = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Variation name is required!";
                            }
                            return null;
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Options",
                  style: TextStyle(
                    color: settingProvider.primaryColor,
                  ),
                ),
                const Divider(
                  height: 15,
                ),
                buildVariationsTable(),
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: CustomFormField(
                    validator: (value) {
                      if (editingVariation.options.length < 2) {
                        return "At least 2 options is required!";
                      }
                      return null;
                    },
                    builder: (FormFieldState<dynamic> field) {
                      return Text(
                        field.errorText ?? "",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.red.shade900, fontSize: 12),
                      );
                    },
                  ),
                ),
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        editingVariation.options.add(VariationOption.empty());
                      });
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        Text("Add Another"),
                      ],
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        widget.callback(null, toggleLoadding);
                        editingVariation = Variation.empty();
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (widget.value != null)
                      ElevatedButton(
                        onPressed: () {
                          widget.onRemove?.call();
                          widget.callback(null, toggleLoadding);
                        },
                        child: const Text(
                          "Remove",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          if (editingVariation.options.length < 2) {
                            showToast(
                              context,
                              child:
                                  const Text("At least 2 options is required!"),
                            );
                            return;
                          }
                          setState(() {
                            for (var i = 0;
                                i < editingVariation.options.length;
                                i++) {
                              VariationOption v = editingVariation.options[i];
                              if (v.isBlank) {
                                editingVariation.options.removeAt(i);
                              } else {
                                v.isSelected = defaultSelected == i;
                              }
                            }
                          });
                          widget.callback(editingVariation, toggleLoadding);
                        },
                        icon: const Icon(
                          Icons.check,
                          size: 30,
                        ),
                        text: "",
                        alignment: MainAxisAlignment.center,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildVariationsTable() {
    return SizedBox(
      width: double.infinity,
      child: Table(
        columnWidths: const {
          0: FractionColumnWidth(0.1),
          1: FractionColumnWidth(0.5),
          2: FractionColumnWidth(0.15),
          3: FractionColumnWidth(0.15),
          4: FractionColumnWidth(0.1),
        },
        children: [
          const TableRow(children: [
            Center(child: Text("#")),
            Text("Option"),
            Text("Price"),
            Text("Selected"),
            Text(""),
          ]),
          // ignore: prefer_const_constructors
          TableRow(children: const [
            Divider(),
            Divider(),
            Divider(),
            Divider(),
            Divider(),
          ]),
          for (int i = 0; i < editingVariation.options.length; i++)
            createVariationRow(i)
        ],
      ),
    );
  }

  TableRow createVariationRow(int i) {
    VariationOption option = editingVariation.options[i];
    return TableRow(children: [
      Container(
          padding: const EdgeInsets.only(top: 10),
          alignment: Alignment.center,
          child: Text((i + 1).toString())),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: TextFormField(
          controller: TextEditingController(
            text: option.value,
          ),
          onChanged: (value) {
            option.value = value;
          },
          decoration: const InputDecoration(isDense: true),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Option value is required!";
            }
            return null;
          },
        ),
      ),
      TextFormField(
        textAlign: TextAlign.end,
        controller: TextEditingController(
          text: (option.price == 0 ? "" : option.price).toString(),
        ),
        onChanged: (value) {
          double? v = value.isEmpty ? 0 : double.parse(value);
          option.price = v;
        },
        decoration: const InputDecoration(isDense: true),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required!";
          }
          return null;
        },
      ),
      Radio(
        toggleable: true,
        value: i,
        groupValue: defaultSelected,
        onChanged: (val) {
          setState(() {
            defaultSelected = val;
          });
        },
      ),
      Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: () {
            setState(() {
              editingVariation.options.removeAt(i);
            });
          },
          splashRadius: 20,
          icon: const Icon(Icons.delete_outline),
        ),
      )
    ]);
  }
}
