import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../providers/setting_provider.dart';
import '/constants.dart';
import '../../../core/config/settings.dart';

class GeneralSetting extends StatefulWidget {
  final VoidCallback onFlip;
  const GeneralSetting({super.key, required this.onFlip});

  @override
  State<GeneralSetting> createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {
  final SettingProvider settingProvider = SettingProvider();

  final TextEditingController _companyNameController =
      TextEditingController(text: settings.valueOf(Settings.companyName));
  final TextEditingController _companyAddressController =
      TextEditingController(text: settings.valueOf(Settings.companyAddress));
  final TextEditingController _companyVatRegistrationController =
      TextEditingController(
          text: settings.valueOf(Settings.companyVatRegistration));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Company Profile"),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Company Name"),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _companyNameController,
                      onChanged: (value) {
                        settingProvider.setValue(Settings.companyName, value);
                      },
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Company Address"),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _companyAddressController,
                      minLines: 2,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (value) {
                        settingProvider.setValue(
                            Settings.companyAddress, value);
                      },
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("VAT Registration"),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _companyVatRegistrationController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (value) {
                        settingProvider.setValue(
                            Settings.companyVatRegistration, value);
                      },
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Theme"),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Interface"),
                    SizedBox(
                      width: 300,
                      child: SelectFormField(
                        initialValue: settingProvider.themeMode.name,
                        items: const [
                          {
                            'value': 'system',
                            'label': 'System',
                            'icon': Icon(Icons.phone_android_rounded),
                          },
                          {
                            'value': 'light',
                            'label': 'Light',
                            'icon': Icon(Icons.light_mode),
                          },
                          {
                            'value': 'dark',
                            'label': 'Dark',
                            'icon': Icon(Icons.dark_mode),
                          },
                        ],
                        onChanged: (value) {
                          settingProvider.setValue(
                              Settings.appThemeInterface, value);
                        },
                      ),
                    )
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Color",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      width: 300,
                      child: FilledButton(
                        onPressed: () => widget.onFlip(),
                        child: const Icon(MdiIcons.cursorPointer),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
