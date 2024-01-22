import 'dart:io';

import 'package:better_serve/constants.dart';
import 'package:better_serve/presentation/widgets/media/flaticon_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/file_provider.dart';
import '../../providers/setting_provider.dart';
import '../common/dialog_pane.dart';

class ImageForm extends StatefulWidget {
  final String? image;
  final ValueChanged<String?> callback;
  final String? filter;
  final bool allowOnline;
  const ImageForm(this.image, this.callback,
      {Key? key, this.filter, this.allowOnline = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageFormState();
}

class _ImageFormState extends State<ImageForm> {
  String? selected;

  bool showOnline = false;

  final SettingProvider settingProvider = SettingProvider();
  @override
  void initState() {
    selected = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "image_select",
      width: 680,
      scrollable: true,
      header: const Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(Icons.image),
            Text("Select Image"),
          ],
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            TextButton(
                onPressed: () {
                  widget.callback(null);
                },
                child: const Text("Cancel")),
            const SizedBox(
              width: 10,
            ),
            if (widget.allowOnline)
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    showOnline = !showOnline;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      showOnline ? Icons.storage : Icons.cloud,
                      size: 15,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(showOnline ? "Local" : "Online"),
                  ],
                ),
              ),
            if (!showOnline) ...[
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? filePickerResult =
                      await FilePicker.platform.pickFiles();

                  if (filePickerResult != null) {
                    var pickedFile =
                        File(filePickerResult.files.single.path.toString());
                    await FileProvider().upload(pickedFile);
                    setState(() {});
                  }
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.upload,
                      size: 15,
                    ),
                    Text("Upload New"),
                  ],
                ),
              )
            ],
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: FilledButton(
                onPressed: selected != null
                    ? () {
                        widget.callback(selected);
                      }
                    : null,
                child: const Text("Ok"),
              ),
            )
          ],
        ),
      ),
      builder: (context, toggleLoadding) {
        return Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: showOnline
              ? FlatIconPicker(toggleLoadding, (String value) {
                  logger.i(value);
                }, imageBuilder: (String url) {
                  return imageCard(url, size: 70, padding: 5);
                })
              : Consumer<FileProvider>(
                  builder: (context, media, _) {
                    if (media.images.isNotEmpty) {
                      return Wrap(alignment: WrapAlignment.center, children: [
                        for (var item in media.images) imageCard(item)
                      ]);
                    }
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                          child: media.isLoading
                              ? const CircularProgressIndicator()
                              : const Text("No media found")),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget imageCard(String url, {double size = 100, double padding = 0}) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: CachedNetworkImage(
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: size,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        image: DecorationImage(image: settingProvider.logo),
                      ),
                    ),
                  ),
                  imageUrl: url,
                  errorWidget: (context, url, error) {
                    return Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: double.infinity,
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              if (selected == url)
                Container(
                  color: settingProvider.primaryColor.withAlpha(50),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selected = url;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
