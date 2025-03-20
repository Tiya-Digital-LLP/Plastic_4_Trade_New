import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:flutter/material.dart';

GlobalKey bottomNavKey = GlobalKey(debugLabel: 'btm_app_bar');

// ignore: must_be_immutable
class BottomMenu extends StatelessWidget {
  final selectedIndex;
  ValueChanged<int> onClicked;
  BottomMenu({super.key, this.selectedIndex, required this.onClicked});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: AppColors.backgroundColor,
        primaryColor: AppColors.backgroundColor,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10.0,
        unselectedFontSize: 10.0,
        iconSize: 25,
        key: bottomNavKey,
        backgroundColor: AppColors.backgroundColor,
        currentIndex: selectedIndex,
        onTap: onClicked,
        selectedItemColor: AppColors.primaryColor,
        showUnselectedLabels: true,
        unselectedItemColor: AppColors.blackColor,
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/Home.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/sale.png')),
            label: 'Seller',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/buyer.png')),
            label: 'Buyer',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/news.png')),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/menu.png'), size: 25),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
