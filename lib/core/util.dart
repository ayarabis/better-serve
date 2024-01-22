import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:better_serve/presentation/providers/auth_provider.dart';
import 'package:better_serve/presentation/providers/setting_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import '../presentation/widgets/common/hero_dialog_route.dart';
import '/constants.dart';

String publicPath(String path, [String bucket = 'images']) {
  return supabase.storage.from(bucket).getPublicUrl("$tenantId/$path");
}

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String> getBase64Logo(String url, [bool redownload = false]) async {
  String path = "${await localPath}/logo.png";
  File logo = File(path);
  if (!await logo.exists() || redownload) {
    await downloadFile(url, "logo.png");
    logo = File(path);
  }

  final bytes = await logo.readAsBytes();
  ByteData data = bytes.buffer.asByteData();
  List<int> imageBytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  String base64Image = base64Encode(imageBytes);
  return base64Image;
}

Future<String> downloadFile(String url, String fileName) async {
  HttpClient httpClient = HttpClient();
  File file;
  String filePath = '';

  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();

  var bytes = await consolidateHttpClientResponseBytes(response);
  filePath = '${await localPath}/$fileName';
  file = File(filePath);
  await file.writeAsBytes(bytes);

  return filePath;
}

double roundDouble(double value, [int places = 2]) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

pushHeroDialog(context, Widget child, [bool barrierDismissible = false]) {
  Navigator.of(context).push(
    HeroDialogRoute(
      dismissible: barrierDismissible,
      builder: (context) {
        return child;
      },
    ),
  );
}

showToast(
  BuildContext context, {
  required Widget child,
  Color? color,
  int duration = 1500,
  ToastGravity? gravity = ToastGravity.TOP,
}) {
  FToast().init(context).showToast(
        gravity: gravity,
        toastDuration: Duration(milliseconds: duration),
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(20),
          color: color,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            child: child,
          ),
        ),
      );
}

showLoading(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Please wait..")
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

bool get useWhite => useWhiteForeground(SettingProvider().primaryColor);
