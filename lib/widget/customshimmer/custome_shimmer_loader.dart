import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerLoader extends StatelessWidget {
  final double width;
  final double height;

  const CustomShimmerLoader({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13.05),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.grayHighforshimmer,
        highlightColor: AppColors.grayLightforshimmer,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.05),
            boxShadow: [
              BoxShadow(
                color: AppColors.boxShadowforshimmer,
                blurRadius: 16.32,
                offset: Offset(0, 3.26),
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 170,
                width: 175,
                margin: const EdgeInsets.all(5.0),
                color: AppColors.grayHighforshimmer,
              ),
              SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 10,
                        width: 150,
                        color: AppColors.grayHighforshimmer,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 10,
                        width: 100,
                        color: AppColors.grayHighforshimmer,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 10,
                        width: 100,
                        color: AppColors.grayHighforshimmer,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 10,
                        width: 80,
                        color: AppColors.grayHighforshimmer,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
