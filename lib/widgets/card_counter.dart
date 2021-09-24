import 'package:flutter/material.dart';

class CardCounter extends StatelessWidget {
  final String title;
  final int amount;
  final VoidCallback? onTap;
  final double aspectRatio;
  const CardCounter({
    Key? key,
    this.aspectRatio = 1,
    required this.title,
    required this.amount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "$amount",
              style: const TextStyle(fontSize: 36),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
