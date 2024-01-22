import 'package:flutter/material.dart';

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget append;
  const DashboardSectionHeader(
      {super.key,
      required this.title,
      required this.icon,
      this.append = const SizedBox()});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          append
        ],
      ),
    );
  }
}
