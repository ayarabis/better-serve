import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presentation/widgets/media_preview.dart';
import '../../providers/file_provider.dart';
import '../../providers/setting_provider.dart';
import '/constants.dart';
import '/core/util.dart';
import '/presentation/widgets/common/button.dart';
import '/presentation/widgets/media/media_delete_dialog.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  List<String> selected = List.empty(growable: true);
  bool deleting = false;
  bool uploading = false;

  SettingProvider settingProvider = SettingProvider();

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(
      builder: (BuildContext context, fileProvider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 100),
                firstChild: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "(${fileProvider.images.length}) Images",
                      style: const TextStyle(fontSize: 20),
                    ),
                    PrimaryButton(
                      onPressed: uploading
                          ? null
                          : () {
                              FilePicker.platform.pickFiles().then(
                                (filePickerResult) async {
                                  if (filePickerResult != null) {
                                    setState(() {
                                      uploading = true;
                                    });
                                    showLoading(primaryContext);
                                    var pickedFile = File(filePickerResult
                                        .files.single.path
                                        .toString());
                                    await fileProvider
                                        .upload(pickedFile)
                                        .then((value) {
                                      setState(() {
                                        uploading = false;
                                      });
                                      Navigator.of(primaryContext).pop();
                                    });
                                  }
                                },
                              );
                            },
                      icon: uploading
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.upload_outlined),
                      text: 'Upload',
                    ),
                  ],
                ),
                secondChild: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "(${selected.length}) Selected",
                      style: const TextStyle(fontSize: 20),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selected.clear();
                            });
                          },
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: deleting
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return MediaDeleteDialog(selected, () {
                                        setState(() {
                                          selected.clear();
                                        });
                                      });
                                    },
                                  );
                                },
                          child: SizedBox(
                            width: 70,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: deleting
                                  ? [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    ]
                                  : const [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Delete",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                crossFadeState: selected.isEmpty
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
            ),
            const Divider(
              height: 1,
            ),
            fileProvider.isLoading
                ? const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Loading...")
                      ],
                    ),
                  )
                : Expanded(
                    child: (fileProvider.images.isEmpty)
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 50,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text("No Images Found!")
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: [
                                for (String item in fileProvider.images)
                                  imageCard(item)
                              ],
                            ),
                          ),
                  )
          ],
        );
      },
    );
  }

  Widget imageCard(String url) {
    return Hero(
      tag: url,
      child: Card(
        elevation: 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                CachedNetworkImage(
                  fadeInDuration: const Duration(milliseconds: 100),
                  fadeOutDuration: const Duration(milliseconds: 100),
                  placeholderFadeInDuration: const Duration(milliseconds: 100),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        image: DecorationImage(image: settingProvider.logo),
                      ),
                    ),
                  ),
                  imageUrl: url,
                  errorWidget: (context, url, error) {
                    return const SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Icon(Icons.error),
                    );
                  },
                ),
                if (selected.contains(url))
                  Container(
                    color: settingProvider.primaryColor.withAlpha(50),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                if (selected.contains(url) && deleting)
                  Container(
                    color: Colors.red.withAlpha(50),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.delete_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() {
                      if (selected.contains(url)) {
                        selected.remove(url);
                      } else if (selected.isNotEmpty) {
                        selected.add(url);
                      } else {
                        pushHeroDialog(
                          primaryContext,
                          MediaPreview(
                            url: url,
                          ),
                          true,
                        );
                      }
                    }),
                    onLongPress: () => setState(
                      () {
                        selected.add(url);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
