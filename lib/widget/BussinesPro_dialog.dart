// ignore_for_file: camel_case_types

import 'package:Plastic4trade/screen/CategoryScreen.dart';
import 'package:Plastic4trade/screen/GradeScreen.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:Plastic4trade/screen/register/Register2.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Plastic4trade/screen/Type.dart';

import '../constroller/Getmybusinessprofile.dart';

class BussinessPro_dialog extends StatefulWidget {
  const BussinessPro_dialog({Key? key}) : super(key: key);

  @override
  State<BussinessPro_dialog> createState() => _BussinessPro_dialogState();
}

class _BussinessPro_dialogState extends State<BussinessPro_dialog> {
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
          Text('Register Now! \n Grow your Business',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                      fontFamily: 'assets/fonst/Metropolis-Black.otf')
                  .copyWith(fontSize: 23)),
          const SizedBox(
            height: 20,
          ),
          Text(
              'Please Add your Business Profile \n  to Grow Your Plastic Business Globally  \n and Connect with Buyers & Suppliers Worldwide.',
              maxLines: 3,
              textAlign: TextAlign.center,
              style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'assets/fonst/Metropolis-Black.otf',
                      color: AppColors.primaryColor)
                  .copyWith(fontSize: 14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                            builder: (context) => Type(),
                          ));
                    } else if (constanst.isgrade) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Grade(),
                          ));
                    }
                  },
                  child: const Text('Proceed',
                      style: TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.backgroundColor,
                          fontFamily: 'assets/fonst/Metropolis-Black.otf')),
                ),
              ),
            ],
          )
        ],
      ),
    );
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
