import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class managePostShimmerLoader extends StatelessWidget {
  final double width;
  final double height;

  const managePostShimmerLoader({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        color: AppColors.backgroundColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13.05),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: AppColors.grayHighforshimmer,
            highlightColor: AppColors.grayLightforshimmer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - CircleAvatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.grayHighforshimmer,
                      borderRadius: BorderRadius.circular(
                          20), // Adjust the value as needed
                    ),
                  ),

                  10.sbw,
                  // Right side - Placeholder content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 15,
                          width: double.infinity,
                          color: AppColors.grayHighforshimmer,
                          margin: const EdgeInsets.only(bottom: 5),
                        ),
                        Container(
                          height: 15,
                          width: width * 0.6, // Adjust width as needed
                          color: AppColors.grayHighforshimmer,
                          margin: const EdgeInsets.only(bottom: 5),
                        ),
                        Container(
                          height: 10,
                          width: width * 0.6, // Adjust width as needed
                          color: AppColors.grayHighforshimmer,
                          margin: const EdgeInsets.only(bottom: 5),
                        ),
                        Container(
                          height: 10,
                          width: width * 0.4, // Adjust width as needed
                          color: AppColors.grayHighforshimmer,
                          margin: const EdgeInsets.only(bottom: 5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
