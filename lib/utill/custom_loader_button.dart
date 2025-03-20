import 'package:Plastic4trade/utill/custom_dot_loader.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'app_colors.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Function onPressed;
  final bool isLoading; // Pass loading state as a parameter

  const CustomButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    required this.isLoading, // Loading state controlled from parent
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 57, // Set a fixed height for the button
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(50.0),
        color: AppColors.primaryColor,
      ),
      child: TextButton(
        onPressed: () => onPressed(), // Just trigger the callback
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero, // Remove padding to keep the height fixed
        ),
        child: Center(
          child: isLoading
              ? CustomDotLoader(
                  child: Lottie.asset(
                    'assets/Dot_Lottie.json',
                  ),
                )
              : Text(
                  buttonText,
                  style: TextStyle(
                      fontSize: 19.0,
                      color: Colors.white,
                      fontFamily: 'Metropolis-Black', // Custom font
                      fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }
}
