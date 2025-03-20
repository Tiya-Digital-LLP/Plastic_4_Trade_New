// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, import_of_legacy_library_into_null_safe, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:Plastic4trade/model/GetSalePostList.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:email_validator/email_validator.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_interface.dart';
import '../widget/HomeAppbar.dart';
import 'package:country_calling_code_picker/picker.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  String? _selectitem;
  bool? passenable = true, load;
  var check_value = false;
  String? location, email = 'email', countryCode = "+91", phone = 'phone';
  List listitem2 = [
    'Feedback & Suggestions',
    'Advertisement',
  ];
  final TextEditingController _usernm = TextEditingController();
  final TextEditingController _usermbl = TextEditingController();
  final TextEditingController _bussemail = TextEditingController();
  final TextEditingController _bussabout = TextEditingController();
  final TextEditingController _bussnm = TextEditingController();

  String? username,
      b_countryCode,
      business_name,
      image_url,
      website,
      address,
      like_count,
      bussmbl,
      usermbl,
      b_email,
      verify_status,
      instagram_url,
      youtube_url,
      facebook_url,
      linkedin_url,
      twitter_url,
      telegram_url,
      other_email_url,
      business_phone_url;
  String? ex_import_number,
      production_capacity,
      gst_number,
      Annual_Turnover,
      Premises_Type,
      business_type,
      is_follow,
      abot_buss,
      pan_number,
      product_name,
      firstyear_amount,
      secondyear_amount,
      thirdyear_amount;
  String? First_currency_sign = "",
      Second_currency_sign = "",
      Third_currency_sign = "";
  int? view_count,
      like,
      reviews_count,
      following_count,
      followers_count,
      is_prime;
  bool isload = false;
  bool isLoading = true;
  String crown_color = '';
  String plan_name = '';
  GetSalePostList salePostList = GetSalePostList();
  GetSalePostList buyPostList = GetSalePostList();
  int offset = 0, post_count = 0;
  int count = 0;
  String profileid = "";
  String? packageName;
  PackageInfo? packageInfo;

  String? last_seen = DateTime.now().toString();
  String? signup_date = "";

  Color _color1 = AppColors.black26Color;
  Color _color2 = AppColors.black26Color;
  Color _color7 = AppColors.black26Color;
  Color _color6 = AppColors.black26Color;
  Color _color9 = AppColors.black26Color;
  Color _color = AppColors.black26Color;

  String? whatsappUrl,
      facebookUrl,
      instagramUrl,
      linkedinUrl,
      youtubeUrl,
      telegramUrl,
      twitterUrl;

  final _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  final bool _validusernm = false;
  bool _isValid = false;
  String device_name = '';
  String defaultCountryCode = 'IN';

  //PhoneNumber number = PhoneNumber(isoCode: 'IN');
  Country? _selectedCountry;

  bool _isloading1 = false;

  @override
  void initState() {
    super.initState();
    initCountry();
    checknetowork();
  }

  void initCountry() async {
    final country = await getCountryByCountryCode(context, defaultCountryCode);
    setState(() {
      _selectedCountry = country;
    });
  }

  @override
  Widget build(BuildContext context) {
    return initwidget();
  }

  Widget initwidget() {
    final country = _selectedCountry;
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      resizeToAvoidBottomInset: true,
      appBar: CustomeApp('ContactUs'),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            // height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SafeArea(
                  top: true,
                  left: true,
                  right: true,
                  maintainBottomViewPadding: true,
                  child: Column(
                    children: [
                      select_sub_dropdown(listitem2, 'Select Subject'),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                        child: CustomTextField(
                          controller: _usernm,
                          keyboardType: TextInputType.name,
                          labelText: "Name *",
                          borderColor: _color1,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z\s]"),
                            ),
                            LengthLimitingTextInputFormatter(30),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              showCustomToast('Please Enter Your Name');
                              _color1 = AppColors.red;
                            } else if (value.length > 30) {
                              _color1 = AppColors.red;
                              return 'Name should be 30 characters or less';
                            } else {
                              _color1 = AppColors.greenWithShade;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Capitalize the first letter of each word
                            final capitalizedValue =
                                value.split(' ').map((word) {
                              if (word.isNotEmpty) {
                                return word[0].toUpperCase() +
                                    word.substring(1).toLowerCase();
                              }
                              return word;
                            }).join(' ');

                            // Update the controller text only if the capitalized value differs
                            if (capitalizedValue != value) {
                              _usernm.value = TextEditingValue(
                                text: capitalizedValue,
                                selection: TextSelection.collapsed(
                                    offset: capitalizedValue.length),
                              );
                            }

                            if (value.isEmpty) {
                              showCustomToast('Please Enter Your Name');
                              setState(() {
                                _color1 = AppColors.red;
                              });
                            } else {
                              setState(() {
                                _color1 = AppColors.greenWithShade;
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (value.isEmpty) {
                              showCustomToast('Please Enter Your Name');
                              setState(() {
                                _color1 = AppColors.red;
                              });
                            } else {
                              setState(() {
                                _color1 = AppColors.greenWithShade;
                              });
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                        child: CustomTextField(
                          controller: _bussnm,
                          keyboardType: TextInputType.name,
                          labelText: "Company Name *",
                          borderColor: _color2,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z\s]"),
                            ),
                            LengthLimitingTextInputFormatter(30),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              showCustomToast(
                                  'Please Enter Your Bussiness Name');
                              _color2 = AppColors.red;
                            } else if (value.length > 50) {
                              _color2 = AppColors.red;
                              return 'Name Should be 50 Character';
                            } else {
                              // setState(() {
                              _color2 = AppColors.greenWithShade;
                              // });
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Capitalize the first letter of each word
                            final capitalizedValue =
                                value.split(' ').map((word) {
                              if (word.isNotEmpty) {
                                return word[0].toUpperCase() +
                                    word.substring(1).toLowerCase();
                              }
                              return word;
                            }).join(' ');

                            // Update the controller text only if the capitalized value differs
                            if (capitalizedValue != value) {
                              _bussnm.value = TextEditingValue(
                                text: capitalizedValue,
                                selection: TextSelection.collapsed(
                                    offset: capitalizedValue.length),
                              );
                            }
                            if (value.isEmpty) {
                              showCustomToast(
                                  'Please Enter Your Bussiness Name');
                              setState(() {
                                _color2 = AppColors.red;
                              });
                            } else {
                              setState(() {
                                _color2 = AppColors.greenWithShade;
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (value.isEmpty) {
                              showCustomToast(
                                  'Please Enter Your Bussiness Name');
                              setState(() {
                                _color2 = AppColors.red;
                              });
                            } else {
                              setState(() {
                                _color2 = AppColors.greenWithShade;
                              });
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 0),
                        child: CustomTextField(
                          controller: _bussemail,
                          keyboardType: TextInputType.emailAddress,
                          labelText: "Email *",
                          borderColor: _color7,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z\s]"),
                            ),
                            LengthLimitingTextInputFormatter(30),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              showCustomToast('Please enter a Email');
                              _color7 = AppColors.red;

                              return null;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (!EmailValidator.validate(value)) {
                              setState(() {
                                _color7 = AppColors.red;
                              });
                            } else if (value.isNotEmpty) {
                              setState(() {
                                _color7 = AppColors.greenWithShade;
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (!EmailValidator.validate(value)) {
                              setState(() {
                                _color7 = AppColors.red;
                              });
                              showCustomToast('Please enter a valid email');
                            } else if (value.isNotEmpty) {
                              setState(() {
                                _color7 = AppColors.greenWithShade;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 68,
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(25.0, 0.0, 5.0, 0),
                              child: Container(
                                height: 58,
                                //width: 130,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: AppColors.black26Color),
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  //mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 58,
                                      padding: const EdgeInsets.only(left: 2),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: AppColors.black26Color),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Image.asset(
                                              country!.flag,
                                              package: countryCodePackageName,
                                              width: 30,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              country.callingCode,
                                              textAlign: TextAlign.center,
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin:
                                    const EdgeInsets.only(left: 0.0, right: 25),
                                child: CustomTextField(
                                  controller: _usermbl,
                                  keyboardType: TextInputType.number,
                                  labelText: "Bussiness Mobile *",
                                  borderColor: _color6,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      _color6 = AppColors.red;
                                      showCustomToast(
                                          'Please Enter Your Business Mobile');
                                    } else {
                                      _color6 = AppColors.greenWithShade;
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) {
                                    var numValue = value.length;
                                    if (numValue >= 6 && numValue <= 11) {
                                      _color6 = AppColors.greenWithShade;
                                    } else {
                                      _color6 = AppColors.red;
                                      showCustomToast(
                                          'Please Enter a Correct Number');
                                    }
                                    setState(
                                        () {}); // Update the state to refresh the UI
                                  },
                                  onChanged: (value) {
                                    var numValue = value.length;
                                    setState(() {
                                      if (numValue >= 6 && numValue <= 11) {
                                        _color6 = AppColors.greenWithShade;
                                      } else {
                                        _color6 = AppColors.red;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _color9,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: SizedBox(
                            height: 120,
                            child: TextFormField(
                              controller: _bussabout,
                              keyboardType: TextInputType.multiline,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.blackColor,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf'),
                              maxLines: 4,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: "Message*",
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: AppColors.backgroundColor,
                                labelStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  _color9 = AppColors.red;
                                  showCustomToast('Please Enter Your Message');
                                } else {
                                  _color9 = AppColors.greenWithShade;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  showCustomToast('Please Enter Your Message');
                                  setState(() {
                                    _color9 = AppColors.red;
                                  });
                                } else if (value.isNotEmpty) {
                                  setState(() {
                                    _color9 = AppColors.greenWithShade;
                                  });
                                }
                              },
                              onFieldSubmitted: (value) {
                                if (value.isEmpty) {
                                  showCustomToast('Please Enter Your Message');
                                  setState(() {
                                    _color9 = AppColors.red;
                                  });
                                } else if (value.isNotEmpty) {
                                  setState(() {
                                    _color9 = AppColors.greenWithShade;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      CustomButton(
                        buttonText: 'Submit',
                        onPressed: _isloading1
                            ? () {} // Empty function instead of null
                            : () async {
                                FocusScope.of(context).unfocus();
                                await valid_data();
                              },
                        isLoading: _isloading1,
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 25, right: 25, top: 10),
                        decoration: ShapeDecoration(
                            color: AppColors.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13.05),
                            ),
                            shadows: [
                              BoxShadow(
                                color: AppColors.boxShadowforshimmer,
                                blurRadius: 16.32,
                                offset: Offset(0, 3.26),
                                spreadRadius: 0,
                              )
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 60,
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            launchUrl(
                                              Uri.parse(
                                                  'tel:$countryCode + ${phone.toString()}'),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          },
                                          child: Text(
                                              countryCode.toString() +
                                                  phone.toString(),
                                              style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.blackColor,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-SemiBold.otf')),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                launchUrl(
                                  Uri.parse(
                                      'tel:$countryCode + ${phone.toString()}'),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              icon: Image.asset(
                                'assets/call1.png',
                                height: 32,
                                width: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 25, right: 25, top: 10),
                        decoration: ShapeDecoration(
                            color: AppColors.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13.05),
                            ),
                            shadows: [
                              BoxShadow(
                                color: AppColors.boxShadowforshimmer,
                                blurRadius: 16.32,
                                offset: Offset(0, 3.26),
                                spreadRadius: 0,
                              )
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 60,
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            launchUrl(
                                              Uri.parse(
                                                  'mailto:${email.toString()}'),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          },
                                          child: Text(
                                            email.toString(),
                                            style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.blackColor,
                                                fontFamily:
                                                    'assets/fonst/Metropolis-SemiBold.otf'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                launchUrl(
                                  Uri.parse('mailto:${email.toString()}'),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              icon: Image.asset(
                                'assets/msg1.png',
                                height: 32,
                                width: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      load == true
                          ? Container(
                              margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                              height: 210,
                              width: MediaQuery.of(context).size.width * 0.88,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                image: DecorationImage(
                                  image:
                                      AssetImage("assets/contactus_back.png"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 10,
                                    left: 20,
                                    child: Container(
                                      child: Text('Our Location',
                                          style: const TextStyle(
                                                  fontSize: 26.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.blackColor,
                                                  fontFamily:
                                                      'assets/fonst/Metropolis-Black.otf')
                                              .copyWith(fontSize: 16)),
                                    ),
                                  ),
                                  Positioned(
                                    top: 35,
                                    left: 20,
                                    child: Container(
                                        child: SizedBox(
                                            height: 130,
                                            width: 200,
                                            child: Html(
                                              data: location,
                                            ))),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      child: Center(
                                          child: Image.asset(
                                        'assets/plastic4trade logo final.png',
                                        width: 100,
                                        height: 30,
                                      )),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Container(
                                      child: Center(
                                          child: GestureDetector(
                                        onTap: () {
                                          openMap();
                                        },
                                        child: Image.asset(
                                          'assets/contactus_loc.png',
                                          width: 200,
                                          height: 30,
                                        ),
                                      )),
                                    ),
                                  ),
                                ],
                              ))
                          : Center(
                              child: CustomLottieContainer(
                                child: Lottie.asset(
                                  'assets/loading_animation.json',
                                ),
                              ),
                            ),
                      Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          margin:
                              const EdgeInsets.fromLTRB(25.0, 10.0, 23.0, 15.0),
                          decoration: ShapeDecoration(
                              color: AppColors.backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13.05),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: AppColors.boxShadowforshimmer,
                                  blurRadius: 16.32,
                                  offset: Offset(0, 3.26),
                                  spreadRadius: 0,
                                )
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text(
                                'Follow Plastic4trade',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf',
                                    color: AppColors.blackColor),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    iconSize: 25,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {
                                      GtmUtil.logScreenView(
                                        'WhatsApp_ContactUs_click',
                                        'whatsappclick',
                                      );
                                      launchUrl(
                                        Uri.parse(whatsappUrl!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    icon: Image.asset(
                                      'assets/whatsapp.png',
                                      height: 25,
                                      width: 25,
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 25,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {
                                      GtmUtil.logScreenView(
                                        'Linkdien_ContactUs_click',
                                        'linkdienclick',
                                      );
                                      launchUrl(
                                        Uri.parse(linkedinUrl!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    icon: Image.asset('assets/linkdin.png',
                                        height: 25, width: 25),
                                  ),
                                  IconButton(
                                    iconSize: 25,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {
                                      GtmUtil.logScreenView(
                                        'Youtube_ContactUs_click',
                                        'youtubeclick',
                                      );
                                      launchUrl(
                                        Uri.parse(youtubeUrl!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    icon: Image.asset('assets/youtube.png',
                                        height: 25, width: 25),
                                  ),
                                  IconButton(
                                    iconSize: 25,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {
                                      GtmUtil.logScreenView(
                                        'Facebook_ContactUs_click',
                                        'facebookclick',
                                      );
                                      launchUrl(
                                        Uri.parse(facebookUrl!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    icon: Image.asset('assets/facebook.png',
                                        height: 25, width: 25),
                                  ),
                                  IconButton(
                                    iconSize: 25,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {
                                      GtmUtil.logScreenView(
                                        'Instagram_ContactUs_click',
                                        'instagramclick',
                                      );
                                      launchUrl(
                                        Uri.parse(instagramUrl!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    icon: Image.asset('assets/instagram.png',
                                        height: 25, width: 25),
                                  ),
                                  IconButton(
                                    iconSize: 25,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {
                                      GtmUtil.logScreenView(
                                        'Telegram_ContactUs_click',
                                        'telegramclick',
                                      );
                                      launchUrl(
                                        Uri.parse(telegramUrl!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    icon: Image.asset('assets/Telegram.png',
                                        height: 25, width: 25),
                                  ),
                                  IconButton(
                                    iconSize: 25,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {
                                      GtmUtil.logScreenView(
                                        'Twitter_ContactUs_click',
                                        'twitterclick',
                                      );
                                      launchUrl(
                                        Uri.parse(twitterUrl!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    icon: Image.asset('assets/xIcon.jpg',
                                        height: 25, width: 25),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getProfiless() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    // Safely get user_id and userToken with null checks
    String userId = pref.getString('user_id') ?? '';
    String apiToken = pref.getString('userToken') ?? '';
    String profileId = pref.getString('user_id') ?? '';

    var res = await getbussinessprofile(
      userId,
      apiToken,
      device,
      profileId,
      context,
    );

    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(device)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      print('telegram_url: $telegram_url');
      _usermbl.text = res['user']['phoneno'] ?? '';
      _usernm.text = res['user']['username'] ?? '';
      _bussnm.text = res['profile']['business_name'] ?? '';
      _bussemail.text = res['user']['email'] ?? '';
    } else {
      showCustomToast(res['message']);
    }

    setState(() {});
  }

  Widget select_sub_dropdown(List listitem, String hint) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
        child: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: _color), // Use _color here
            borderRadius: BorderRadius.circular(15.0),
            color: AppColors.backgroundColor,
          ),
          child: DropdownButton(
            value: _selectitem,
            hint: Text(
              hint,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
                fontFamily: 'assets/fonts/Metropolis-Black.otf',
              ).copyWith(color: Colors.black45),
            ),
            dropdownColor: AppColors.backgroundColor,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 30,
            isExpanded: true,
            underline: const SizedBox(),
            items: listitem.map((valueItem) {
              return DropdownMenuItem(
                value: valueItem,
                child: Text(
                  valueItem,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackColor,
                    fontFamily: 'assets/fonts/Metropolis-Black.otf',
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectitem = value.toString();
                _color = Colors
                    .green; // Change the border color to green on selection
              });
            },
          ),
        ),
      ),
    );
  }

  // Rest of your code remains the same...
  Future<void> valid_data() async {
    if (_isloading1) return;

    setState(() {
      _isloading1 = true;
    });

    try {
      _isValid = EmailValidator.validate(_bussemail.text);
      var numValue = _usermbl.text.length;

      if (_selectitem == null) {
        setState(() {
          _color = AppColors.red;
        });
        showCustomToast('Please Select a Subject');
        return;
      }

      if (numValue <= 6 || numValue >= 13) {
        setState(() {
          _color6 = AppColors.red;
        });
        showCustomToast('Please Enter Correct Number');
        return;
      }

      if (_bussabout.text.isEmpty) {
        setState(() {
          _color9 = AppColors.red;
        });
        showCustomToast('Please Enter Message');
        return;
      }

      if (_usernm.text.isEmpty ||
          _bussemail.text.isEmpty ||
          _usermbl.text.isEmpty ||
          _bussnm.text.isEmpty ||
          _bussabout.text.isEmpty ||
          !_isValid) {
        showCustomToast('Please fill all required fields correctly.');
        return;
      }

      await setContact();
    } catch (e) {
      showCustomToast('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isloading1 = false;
      });
    }
  }

  Future<void> setContact() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String device = Platform.isAndroid ? 'android' : 'ios';

      var res = await add_contact(
        pref.getString('user_id').toString(),
        pref.getString('userToken').toString(),
        _selectitem.toString(),
        _usernm.text.toString(),
        _bussemail.text.toString(),
        countryCode.toString(),
        _usermbl.text.toString(),
        _bussabout.text.toString(),
        _bussnm.text.toString(),
        device_name,
        device,
      );

      if (res['status'] == 1) {
        showCustomToast(
            "Your Query is Submitted. We will get back to you shortly.");
      } else {
        showCustomToast(res['message']);
      }
    } catch (e) {
      showCustomToast('Failed to submit query. Please try again.');
    }
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      get_ContactDetails();
      getSocialMedia();
      getProfiless();
    }
  }

  Future<void> get_ContactDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await getContactDetails(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
    );

    var jsonArray;
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      if (res['result'] != null) {
        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');
        jsonArray = res['result'];
        print("jsonArray:-${jsonArray}");
        location = jsonArray['location'];
        countryCode = jsonArray['countryCode'];
        phone = jsonArray['phone'];
        countryCode = jsonArray['countryCode'];
        email = jsonArray['email'];
        load = true;

        if (mounted) {
          setState(() {});
        }
      } else {
        load = true;
      }
    } else {
      showCustomToast(res['message']);
    }
    return jsonArray;
  }

  getSocialMedia() async {
    var res = await getSocialLinks();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String username = pref.getString('name').toString();
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      print("${res['result']}");
      print("username:-${username}");
      whatsappUrl = res['result']['site_whatsapp_url'] +
          '?text=Hello, I am $username \n I Want Know Regarding ';
      facebookUrl = res['result']['site_facebook_url'];
      instagramUrl = res['result']['site_instagram_url'];
      linkedinUrl = res['result']['site_linkedin_url'];
      youtubeUrl = res['result']['site_youtube_url'];
      telegramUrl = res['result']['site_telegram_url'];
      twitterUrl = res['result']['site_twitter_url'];
      setState(() {});
    } else {}
  }

  void openMap() async {
    // 23.016189, 72.468770  == HAR IMPEX OFFICE

    // final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place=$label";
    const String googleMapsUrl =
        "https://www.google.com/maps/place/Plastic4trade/@23.0161915,72.4661721,17z/data=!3m1!4b1!4m6!3m5!1s0x395e9b21c3b75b55:0xd74cdf40aaa80916!8m2!3d23.0161866!4d72.468747!16s%2Fg%2F11rv7yjdsv?entry=ttu";

    // ignore: deprecated_member_use
    if (await canLaunch(googleMapsUrl)) {
      // ignore: deprecated_member_use
      await launch(googleMapsUrl);
    } else {}
  }
}
