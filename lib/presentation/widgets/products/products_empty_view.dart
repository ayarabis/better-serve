import 'package:flutter/material.dart';

class ProductsEmptyView extends StatelessWidget {
  const ProductsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/food.png",
          width: 200,
          opacity: const AlwaysStoppedAnimation(100),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          "Add your first product",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Tap '+ Add' button to add product to your inventory",
          style: TextStyle(fontSize: 15, color: Colors.grey),
        )
      ],
    );
  }
}
