import 'package:Plastic4trade/screen/auth/email_name_registration.dart';
import 'package:Plastic4trade/screen/buisness_profile/BussinessProfile.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/save_user_id.dart';
import 'package:flutter/material.dart';
import 'package:Plastic4trade/screen/post/AddPost.dart';
import 'package:Plastic4trade/screen/GradeScreen.dart';
import 'package:Plastic4trade/screen/register/Register2.dart';
import 'package:Plastic4trade/screen/Type.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constroller/Getmybusinessprofile.dart';
import '../screen/buisness_profile/Bussinessinfo.dart';
import '../screen/buyer_seller/Buyer_sell_detail.dart';
import '../screen/CategoryScreen.dart';
import '../screen/chat/Chat.dart';
import '../screen/liveprice/Liveprice.dart';

import '../screen/post/ManagePost.dart';
import '../screen/upgrade/updateCategoryScreen.dart';

class AddPost_dialog extends StatefulWidget {
  const AddPost_dialog({Key? key}) : super(key: key);

  @override
  State<AddPost_dialog> createState() => _BussinessPro_dialogState();
}

class _BussinessPro_dialogState extends State<AddPost_dialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.bottomCenter,
      elevation: 0,
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15, top: 15),
              child: const Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.clear),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Image(
            image: const AssetImage('assets/bussines_profile.png'),
            height: MediaQuery.of(context).size.height / 5.8,
            width: MediaQuery.of(context).size.width,
          ),
          const SizedBox(
            height: 30,
          ),
          Text('Buy & Sell - \n Digital Product Catalogue ',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                      fontFamily: 'assets\fonst\Metropolis-Black.otf')
                  .copyWith(fontSize: 23)),
          const SizedBox(
            height: 20,
          ),
          Text(
              'Please Add Your Buy Post or Sell Post to \n Make Your Digital Product Catalogue & Find \n Buyers or Suppliers Worldwide.',
              maxLines: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'assets\fonst\Metropolis-Black.otf')
                  .copyWith(fontSize: 14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 3.5,
                height: 55,
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: TextButton(
                  onPressed: () {
                    if (constanst.isprofile) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Register2()),
                      );
                    } else {
                      switch (constanst.redirectpage) {
                        case "email_verification":
                          showEmailNameBottomSheet(context);
                          break;
                        case "sale_buy":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Buyer_sell_detail(
                                prod_id: constanst.productId,
                                post_type: constanst.post_type,
                              ),
                            ),
                          );
                          break;
                        case "add_post":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddPost()),
                          );
                          break;
                        case "chat":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Chat()),
                          );
                          break;
                        case "live_price":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LivepriceScreen()),
                          );
                          break;
                        case "Manage_Sell_Posts":
                        case "Manage_Buy_Posts":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Managepost(),
                            ),
                          );
                          break;

                        case "update_category":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UpdateCategoryScreen(),
                            ),
                          );
                          break;
                        case "edit_profile":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Bussinessinfo(),
                            ),
                          );
                          break;
                        case "business_profile":
                          redirectToBussinessProfileScreen(context);
                          break;
                      }
                    }
                  },
                  child: const Text('Skip',
                      style: TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                          fontFamily: 'assets\fonst\Metropolis-Black.otf')),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3.5,
                height: 55,
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(50.0),
                    color: AppColors.primaryColor),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    getBussinessProfile();
                    if (constanst.isprofile) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register2(),
                          ));
                    } else if (constanst.iscategory) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoryScreen(),
                          ));
                    } else if (constanst.istype) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Type(),
                          ));
                    } else if (constanst.isgrade) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Grade(),
                          ));
                    } else if (constanst.step != 11) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddPost(),
                          ));
                    }
                  },
                  child: const Text('Proceed',
                      style: TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.backgroundColor,
                          fontFamily: 'assets\fonst\Metropolis-Black.otf')),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void showEmailNameBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const EmailNameRegistration(),
    );
  }

  void redirectToBussinessProfileScreen(BuildContext context) async {
    try {
      // Await the Future to get the actual value
      final userIdFuture = SharedPrefService.getUserId();
      final userId = await userIdFuture;

      if (userId == null || userId.isEmpty) {
        print("Error: User ID is null or empty.");
        return;
      }

      // Validate and parse the user ID
      if (RegExp(r'^\d+$').hasMatch(userId)) {
        final parsedUserId = int.parse(userId);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => bussinessprofile(parsedUserId),
          ),
        );
      } else {
        print("Invalid user ID: $userId");
      }
    } catch (e) {
      print("Error parsing user ID: $e");
    }
  }

  getBussinessProfile() async {
    GetmybusinessprofileController bt = GetmybusinessprofileController();
    SharedPreferences pref = await SharedPreferences.getInstance();
    constanst.getmyprofile = bt.Getmybusiness_profile(
      userId: pref.getString('user_id').toString(),
      apiToken: pref.getString('userToken').toString(),
      context: context,
      profileId: pref.getString('user_id').toString(),
    );
  }
}
