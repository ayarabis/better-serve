import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/file_provider.dart';
import '../common/custom_dialog.dart';
import '/core/util.dart';

class MediaDeleteDialog extends StatefulWidget {
  final List<String> media;
  final VoidCallback callback;
  const MediaDeleteDialog(this.media, this.callback, {super.key});

  @override
  State<MediaDeleteDialog> createState() => _MediaDeleteDialogState();
}

class _MediaDeleteDialogState extends State<MediaDeleteDialog> {
  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    List<String> media = widget.media;
    return Consumer<FileProvider>(builder: (context, fileProvider, _) {
      return CustomDialog(
        title: "Delete Media?",
        content: "Are you sure you want to delete ${media.length} media?",
        positiveBtnText: "Yes",
        negativeBtnText: "Cancel",
        destructive: true,
        type: DialogType.error,
        icon: CircleAvatar(
          maxRadius: 40.0,
          backgroundColor: Colors.redAccent,
          child: deleting
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Icon(
                  MdiIcons.trashCan,
                  size: 30,
                  color: Colors.white,
                ),
        ),
        onPositive: deleting
            ? null
            : () {
                setState(() {
                  deleting = true;
                });
                fileProvider.delete(media).then((r) {
                  r.fold((l) {
                    showToast(context, child: Text(l.message));
                  }, (r) {
                    showToast(context,
                        child: Text("${media.length} media deleted"));
                    Navigator.of(context).pop();
                    widget.callback();
                  });
                });
              },
      );
    });
  }
}
