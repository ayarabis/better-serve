import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../providers/setting_provider.dart';
import '../common/dialog_pane.dart';
import '../custom_form_field.dart';
import '/domain/models/attribute.dart';
import '/domain/models/attribute_option.dart';
import '/presentation/providers/attribute_provider.dart';
import '/presentation/widgets/common/button.dart';

class AttributeForm extends StatefulWidget {
  final Attribute? value;
  final Function(Attribute?, Function) callback;
  final VoidCallback? onRemove;
  final String? title;
  final bool showTemplate;
  final bool inputLabel;
  const AttributeForm(
    this.value,
    this.callback, {
    Key? key,
    this.onRemove,
    this.title,
    this.showTemplate = false,
    this.inputLabel = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AttributeFormState();
}

class _AttributeFormState extends State<AttributeForm> {
  Attribute editingAttribute = Attribute.empty();
  int? singleDefaultSelected = 0;
  bool ordering = false;

  List<Map<String, dynamic>> selectionTypes = [
    {
      'value': "Single",
      'label': "Single",
    },
    {
      'value': "Multiple",
      'label': "Multiple",
    }
  ];

  final _formKey = GlobalKey<FormState>();

  List<AttributeOption> get options => editingAttribute.options;
  final SettingProvider settingProvider = SettingProvider();
  @override
  void initState() {
    if (widget.value != null) editingAttribute = widget.value!.clone();
    trySelectSingle();
    super.initState();
  }

  void trySelectSingle() {
    if (!editingAttribute.isMultiple) {
      singleDefaultSelected = options.indexWhere((opt) => opt.isSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "attribute_form",
      width: 500,
      scrollable: true,
      header: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              widget.title ?? "Add Attributes",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      footerBuilder: (context, toggleLoadding) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () {
                    widget.callback(null, toggleLoadding);
                  },
                  child: const Text("Cancel")),
              const SizedBox(
                width: 10,
              ),
              if (widget.value != null && !ordering)
                ElevatedButton(
                    onPressed: () {
                      widget.onRemove?.call();
                      widget.callback(null, toggleLoadding);
                    },
                    child: const Text(
                      "Remove",
                      style: TextStyle(color: Colors.red),
                    )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: PrimaryButton(
                  onPressed: () {
                    if (ordering) {
                      setState(() {
                        ordering = false;
                      });
                      return;
                    }
                    if (!_formKey.currentState!.validate()) return;
                    // set selected false for other in single type
                    if (!editingAttribute.isMultiple) {
                      for (int i = 0; i < options.length; i++) {
                        AttributeOption opt = options[i];
                        opt.isSelected = singleDefaultSelected == i;
                        opt.order = i;
                      }
                    }

                    widget.callback(editingAttribute, toggleLoadding);
                  },
                  icon: ordering
                      ? null
                      : const Icon(
                          Icons.check,
                          size: 30,
                        ),
                  text: ordering ? "Done" : "",
                  alignment: MainAxisAlignment.center,
                ),
              )
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTemplate)
                Consumer<AttributeProvider>(
                    builder: (context, attributeProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (Attribute attr in attributeProvider.attributes)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                editingAttribute = attr.clone();
                                trySelectSingle();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: settingProvider.primaryColor)),
                              child: Text(
                                attr.name,
                                style: TextStyle(
                                    color: settingProvider.primaryColor),
                              ),
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
                    SelectFormField(
                      type: SelectFormFieldType.dropdown,
                      labelText: 'Type',
                      items: selectionTypes,
                      initialValue: 'Single',
                      onChanged: (val) => setState(() {
                        editingAttribute.isMultiple = val == "Multiple";
                      }),
                    ),
                    TextFormField(
                      controller:
                          TextEditingController(text: editingAttribute.name),
                      decoration: const InputDecoration(
                          label: Text("Attribute Name"), isDense: true),
                      onChanged: (value) {
                        editingAttribute.name = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    if (widget.inputLabel)
                      TextFormField(
                        controller:
                            TextEditingController(text: editingAttribute.label),
                        decoration: const InputDecoration(
                            label: Text("Attribute Label"), isDense: true),
                        onChanged: (value) {
                          editingAttribute.label = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Attribute name is required!";
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
              buildOptionsTable(),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: CustomFormField(
                  validator: (value) {
                    if (editingAttribute.options.length < 2) {
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
              const Divider(
                height: 10,
              ),
              ordering
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              ordering = true;
                            });
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sort),
                              Text("Reorder"),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              options.add(
                                AttributeOption.empty()..order = options.length,
                              );
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
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOptionsTable() {
    return SizedBox(
      width: double.infinity,
      child: Table(
        columnWidths: {
          0: const FractionColumnWidth(0.1),
          1: const FractionColumnWidth(0.65),
          2: FractionColumnWidth(ordering ? 0.1 : 0.15),
          3: const FractionColumnWidth(0.1),
        },
        children: [
          TableRow(children: [
            const Center(child: Text("#")),
            const Text("Option"),
            Text(ordering ? "" : "Selected"),
            const Text(""),
          ]),
          // ignore: prefer_const_constructors
          TableRow(children: const [
            Divider(),
            Divider(),
            Divider(),
            Divider(),
          ]),
          for (int i = 0; i < options.length; i++) createVariationRow(i)
        ],
      ),
    );
  }

  TableRow createVariationRow(int i) {
    AttributeOption option = options[i];
    return TableRow(
      children: [
        Container(
            padding: const EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Text((i + 1).toString())),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: TextFormField(
            enabled: !ordering,
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
                return 'Option value is required!';
              }
              return null;
            },
          ),
        ),
        ordering
            ? moveArrow(
                const Icon(Icons.arrow_drop_down), i == options.length - 1, () {
                swapOption(i, 1);
              })
            : editingAttribute.isMultiple
                ? Checkbox(
                    value: option.isSelected,
                    onChanged: (value) {
                      setState(() {
                        option.isSelected = value!;
                      });
                    },
                  )
                : Radio(
                    toggleable: true,
                    value: i,
                    groupValue: singleDefaultSelected,
                    onChanged: (val) {
                      setState(
                        () {
                          singleDefaultSelected = val;
                        },
                      );
                    },
                  ),
        ordering
            ? moveArrow(const Icon(Icons.arrow_drop_up), i == 0, () {
                swapOption(i, -1);
              })
            : Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      options.removeAt(i);
                    });
                  },
                  splashRadius: 20,
                  icon: const Icon(Icons.delete_outline),
                ),
              )
      ],
    );
  }

  Widget moveArrow(Icon icon, bool disable, Function() action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(3)),
        onPressed: disable ? () {} : action,
        child: disable
            ? Icon(
                icon.icon,
                color: Colors.grey,
              )
            : icon,
      ),
    );
  }

  void swapOption(int index, int dir) {
    AttributeOption option = options[index];
    option.order = index + dir;
    options[index + dir].order = index;
    sortOptions();
    trySelectSingle();
  }

  void sortOptions() {
    setState(() {
      options.sort((a, b) => a.order.compareTo(b.order));
    });
  }
}
