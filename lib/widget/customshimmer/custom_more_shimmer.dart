import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(13.05),
        boxShadow: [
          BoxShadow(
            color: AppColors.boxShadowforshimmer,
            blurRadius: 16.32,
            offset: Offset(0, 3.26),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.grayHighforshimmer,
                radius: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.grayHighforshimmer),
                ),
              ),
              SizedBox(height: 10),
              Shimmer.fromColors(
                baseColor: AppColors.grayHighforshimmer,
                highlightColor: AppColors.grayLightforshimmer,
                child: Container(
                  width: 60,
                  height: 10,
                  color: AppColors.grayHighforshimmer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
