import 'package:flutter/material.dart';

BoxDecoration getBackgroundGradient() {
  return BoxDecoration(
    gradient: RadialGradient(
      radius: 2,
      stops: const [0.1, 0.5, 0.7, 0.9],
      colors: [
        Colors.grey[850]!,
        Colors.grey[900]!,
        Colors.grey[800]!,
        Colors.grey[900]!,
      ],
    ),
  );
}
