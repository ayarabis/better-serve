import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Widget? icon;
  final MainAxisAlignment? alignment;

  const PrimaryButton(
      {required this.onPressed,
      required this.text,
      required this.icon,
      this.alignment = MainAxisAlignment.start,
      super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: alignment!,
          children: [
            if (icon != null) icon! else ...[],
            const SizedBox(
              width: 5,
            ),
            Text(text ?? ""),
          ],
        ));
  }
}
