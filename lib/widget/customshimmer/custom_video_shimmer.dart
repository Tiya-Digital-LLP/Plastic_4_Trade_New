import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VideoShimmerLoader extends StatelessWidget {
  final double width;
  final double height;

  const VideoShimmerLoader({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: AppColors.backgroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.05),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
              baseColor: AppColors.grayHighforshimmer,
              highlightColor: AppColors.grayLightforshimmer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  15.sbh,
                  Expanded(
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
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
