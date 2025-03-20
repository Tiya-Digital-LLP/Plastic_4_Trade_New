import 'package:flutter/material.dart';

class CustomBackIcon extends StatelessWidget {
  const CustomBackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(
          context,
        );
      },
      child: Image.asset(
        'assets/back.png',
        height: 50,
        width: 60,
      ),
    );
  }
}
