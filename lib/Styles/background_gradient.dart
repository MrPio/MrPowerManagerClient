import 'package:flutter/material.dart';

BoxDecoration getBackgroundGradient() {
  return BoxDecoration(
/*    image: const DecorationImage(
      image: AssetImage("assets/images/hex_s_45.png"),
      fit: BoxFit.cover,
    ),*/
    gradient: RadialGradient(

      radius: 2,
      stops: const [0.1, 0.5, ],
      colors: [
        Colors.grey[850]!,
        Colors.grey[900]!,
      ],
    ),
  );
}
