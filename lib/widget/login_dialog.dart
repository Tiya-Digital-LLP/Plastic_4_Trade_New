import 'package:Plastic4trade/screen/auth/login_registration.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:flutter/material.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({Key? key}) : super(key: key);
  //{super.key}

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
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
          Text('SignUp Now! \n Start your Business',
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
              'Please SignUp \n to Start Your Plastic Business Globally \n and Connect with Buyers & Suppliers Worldwide.',
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginRegistration()));
                  },
                  child: const Text('Sign Up',
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
}
