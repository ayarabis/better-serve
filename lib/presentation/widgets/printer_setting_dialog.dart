import 'package:better_serve/core/config/settings.dart';
import 'package:better_serve/presentation/providers/setting_provider.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/printer_provider.dart';
import 'common/dialog_pane.dart';

class PrinterSettingDialog extends StatefulWidget {
  const PrinterSettingDialog({super.key});

  @override
  State<PrinterSettingDialog> createState() => _PrinterSettingDialogState();
}

class _PrinterSettingDialogState extends State<PrinterSettingDialog> {
  final PrinterProvider _pritner = PrinterProvider();

  @override
  void initState() {
    if (!_pritner.isScanning) {
      bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    }
    super.initState();
  }

  @override
  void dispose() {
    bluetoothPrint.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "printer_setting",
      width: 400,
      maxHeight: 400,
      builder: (context, toggleLoadding) {
        return Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.print_rounded),
                  SizedBox(width: 5),
                  Text("Select Printer"),
                ],
              ),
              const Divider(),
              Consumer<PrinterProvider>(
                builder: (context, printer, _) {
                  return StreamBuilder<List<BluetoothDevice>>(
                    stream: bluetoothPrint.scanResults,
                    builder: (c, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return SingleChildScrollView(
                          child: Column(
                            children:
                                snapshot.data!.where((e) => e.type == 3).map(
                              (d) {
                                return ListTile(
                                  title: Text("${d.name}"),
                                  subtitle: Text(d.address!),
                                  onTap: () async {
                                    toggleLoadding();
                                    printer.setConnected(true);
                                    bluetoothPrint.connect(d).then((value) {
                                      SettingProvider()
                                          .setValue(
                                              Settings.printerName, d.name)
                                          .save();
                                      Navigator.of(context).pop();
                                    });
                                  },
                                );
                              },
                            ).toList(),
                          ),
                        );
                      }
                      return const Text("Scanning...");
                    },
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
