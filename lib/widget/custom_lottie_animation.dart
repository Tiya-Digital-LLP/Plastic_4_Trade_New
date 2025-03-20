import 'package:flutter/material.dart';

class CustomLottieContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final BoxFit fit;

  const CustomLottieContainer({
    Key? key,
    required this.child,
    this.width = 120,
    this.height = 120,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: FittedBox(
        fit: fit,
        child: child,
      ),
    );
  }
}
