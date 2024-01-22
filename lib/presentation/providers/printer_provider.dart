import 'dart:collection';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';

import '/constants.dart';
import '../../core/config/settings.dart';
import '/domain/models/order.dart';
import '/domain/models/order_item.dart';

BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

class PrinterProvider with ChangeNotifier {
  static final PrinterProvider _instance = PrinterProvider._internal();
  factory PrinterProvider() => _instance;
  PrinterProvider._internal() {
    initService();
  }

  bool isScanning = false;
  bool isConnected = false;

  Future<void> initService() async {
    bluetoothPrint.isScanning.listen((event) {
      isScanning = event;
      notifyListeners();
    });

    bluetoothPrint.state.listen((event) {
      if (event == BluetoothPrint.DISCONNECTED) {
        logger.i("Printer disconnected!");
        isConnected = false;
        scan();
      } else if (event == BluetoothPrint.CONNECTED) {
        logger.i("Printer connected!");
        isConnected = true;
      }
      notifyListeners();
    });

    bluetoothPrint.scanResults.listen((devices) {
      for (BluetoothDevice d in devices) {
        if (d.name == settings.valueOf<String>(Settings.printerName)) {
          bluetoothPrint.stopScan().then((_) {
            isScanning = false;
          });
          bluetoothPrint.connect(d).then((_) async {
            isConnected = true;
            notifyListeners();
          });
          break;
        }
      }
    });

    isConnected = await bluetoothPrint.isConnected ?? false;
    if (isConnected) {
      notifyListeners();
    } else {
      scan();
    }
  }

  Future<void> scan() async {
    try {
      await bluetoothPrint.startScan(timeout: const Duration(minutes: 1));
    } catch (_) {}
  }

  Future<bool> printReceipt(Order order) async {
    if (!isConnected) {
      return false;
    }
    LineText lineFeed = LineText(linefeed: 1);
    Map<String, dynamic> config = HashMap();
    List<LineText> lines = List.empty(growable: true);

    // String base64Image =
    //     await getBase64Logo(settingsService.receiptLogoPath, true);
    // lines.add(LineText(
    //     type: LineText.TYPE_IMAGE,
    //     align: LineText.ALIGN_CENTER,
    //     width: 150,
    //     content: base64Image,
    //     linefeed: 1));
    lines.add(lineFeed);
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: settings.valueOf(Settings.companyName),
        weight: 0,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(LineText(linefeed: 1));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: settings.valueOf(Settings.companyAddress),
        weight: 0,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content:
            "VAT Reg. ${settings.valueOf(Settings.companyVatRegistration)}",
        weight: 0,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(lineFeed);
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "Serving #${order.queueNumber}",
        weight: 1,
        fontZoom: 2,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(receiptDivider);
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "${order.orderDate} ${order.orderTime}",
        weight: 0,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(receiptDivider);
    lines.add(LineText(linefeed: 1));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "Order No. : ${order.id.toString().padLeft(6, '0')}",
        weight: 0,
        linefeed: 1));
    lines.add(receiptDivider);

    for (OrderItem item in order.items) {
      lines.add(receiptLine(
          formatLine(item.productName, item.unitPrice, item.quantity)));
      for (OrderItemAddon addon in item.addons) {
        lines.add(receiptLine(formatLine(" ${addon.name}", addon.price)));
      }
    }
    lines.add(receiptDivider);

    lines.add(receiptLine(formatLine("Total Due", order.orderAmount), 1));
    lines
        .add(receiptLine(formatLine("Discount", -(order.discountAmount ?? 0))));
    lines.add(receiptDivider);
    lines.add(receiptLine(formatLine("Grand Total", order.grandTotal), 1));
    lines.add(receiptLine(formatLine("Payment", order.paymentAmount)));

    double change = order.paymentAmount - order.grandTotal;
    lines.add(receiptLine(formatLine("Change", change)));

    lines.add(lineFeed);
    lines.add(lineFeed);
    lines.add(receiptLine("**CUSTOMER COPY**", 1, true));
    lines.add(lineFeed);
    lines.add(receiptLine("Thanks for Visiting", 0, true));
    lines.add(lineFeed);
    bluetoothPrint.printReceipt(config, lines);

    return true;
  }

  static LineText receiptLine(
    String content, [
    int weight = 0,
    bool center = false,
  ]) =>
      LineText(
          type: LineText.TYPE_TEXT,
          content: content,
          weight: weight,
          align: center ? LineText.ALIGN_CENTER : LineText.ALIGN_LEFT,
          linefeed: 1);

  static LineText get receiptDivider => LineText(
      type: LineText.TYPE_TEXT,
      content: ''.padRight(32, "-"),
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1);

  static String formatLine(String name, num price, [int? qty]) {
    String line = "${qty ?? ''} $name";
    String priceStr = price.toStringAsFixed(2).replaceAll("-", "");
    priceStr = ((price) < 0 ? "($priceStr)" : priceStr);

    int spaces = 32 - (line.length + priceStr.length);

    return line.padRight(line.length + spaces, " ") + priceStr;
  }

  void setConnected(bool bool) {
    isConnected = bool;
    notifyListeners();
  }
}
