import 'package:Plastic4trade/screen/post/AddPost.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/HomeAppbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAddButton extends StatelessWidget {
  final Function onPressed;

  const CustomAddButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () async {
          GtmUtil.logScreenView('Add_Post_Home', 'homepost');
          constanst.redirectpage = "add_post";
          SharedPreferences pref = await SharedPreferences.getInstance();

          if (pref.getBool('isWithoutLogin') == true) {
            showLoginDialog(context);
            return;
          }
          print("Current step before switch: ${constanst.step}");
          switch (constanst.step) {
            case 3:
              showEmailDialog(context);
              break;
            case 5:
              showInformationDialog(context);
              break;
            case 6:
            case 7:
            case 8:
              categoryDialog(context);
              break;
            case 9:
              addPostDialog(context);
              break;
            case 10:
              addPostDialog(context);
              break;
            case 11:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPost(),
                ),
              );
              break;
            default:
              print("Unexpected value: ${constanst.step}");
              break;
          }
        },
        icon: const Icon(Icons.add, color: AppColors.backgroundColor, size: 40),
      ),
    );
  }
}
