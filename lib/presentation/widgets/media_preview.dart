import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'common/dialog_pane.dart';

class MediaPreview extends StatelessWidget {
  final String url;
  const MediaPreview({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: url,
      width: 500,
      maxHeight: 500,
      builder: (context, toggleLoadding) {
        return Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CachedNetworkImage(
                imageUrl: url,
                errorWidget: (context, url, error) {
                  return const Center(
                    child: Icon(Icons.error),
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
