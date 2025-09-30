import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  const CategoryCard({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
