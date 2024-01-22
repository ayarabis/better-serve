import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../providers/setting_provider.dart';

class AvatarPicker extends StatefulWidget {
  final Either<File, String>? value;
  final double radius;
  final Null Function() onTap;
  const AvatarPicker(
      {super.key, this.value, required this.radius, required this.onTap});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  @override
  Widget build(BuildContext context) {
    Widget img = const SizedBox();
    widget.value?.fold(
      (l) => img = Image.file(
        l,
        fit: BoxFit.cover,
      ),
      (r) => img = CachedNetworkImage(
        imageUrl: r,
        fit: BoxFit.cover,
      ),
    );
    return SizedBox(
      width: widget.radius * 2,
      height: widget.radius * 2,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.transparent,
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(widget.radius),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              ClipOval(
                clipBehavior: Clip.hardEdge,
                child: img,
              ),
              Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(widget.radius),
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  radius: widget.radius * 2,
                  borderRadius: BorderRadius.circular(widget.radius),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: SettingProvider().primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(widget.radius),
                    ),
                    child: Icon(
                      MdiIcons.camera,
                      color: SettingProvider().primaryColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
