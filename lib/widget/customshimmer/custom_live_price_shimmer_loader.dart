import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LivePriceShimmerLoader extends StatelessWidget {
  final double width;
  final double height;

  const LivePriceShimmerLoader({
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: double.infinity,
                          color: AppColors.grayHighforshimmer,
                          margin: const EdgeInsets.only(bottom: 8),
                        ),
                        Container(
                          height: 5,
                          width: width * 0.6,
                          color: AppColors.grayHighforshimmer,
                          margin: const EdgeInsets.only(bottom: 0),
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
