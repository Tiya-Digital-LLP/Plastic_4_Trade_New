import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class customExhibition extends StatelessWidget {
  final double width;
  final double height;

  const customExhibition({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
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
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.grayHighforshimmer,
                    ),
                    10.sbw,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 15,
                            width: double.infinity,
                            color: AppColors.grayHighforshimmer,
                            margin: const EdgeInsets.only(bottom: 10),
                          ),
                          Container(
                            height: 15,
                            width: width * 0.6, // Adjust width as needed
                            color: AppColors.grayHighforshimmer,
                            margin: const EdgeInsets.only(bottom: 10),
                          ),
                          Container(
                            height: 15,
                            width: width * 0.5, // Adjust width as needed
                            color: AppColors.grayHighforshimmer,
                            margin: const EdgeInsets.only(bottom: 10),
                          ),
                          Container(
                            height: 15,
                            width: width * 0.4, // Adjust width as needed
                            color: AppColors.grayHighforshimmer,
                            margin: const EdgeInsets.only(bottom: 10),
                          ),
                          Container(
                            height: 15,
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
      ),
    );
  }
}
