import 'package:flutter/material.dart';

class CustomDotLoader extends StatelessWidget {
  final Widget child;
  final double width;
  final double height; // Add height parameter
  final BoxFit fit;

  const CustomDotLoader({
    Key? key,
    required this.child,
    this.width = 180,
    this.height = 180,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height, // Apply the height constraint
      child: FittedBox(
        fit:
            fit, // Ensures the child fits within the container without overflowing
        child: child,
      ),
    );
  }
}
