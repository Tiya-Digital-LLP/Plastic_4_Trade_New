// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, depend_on_referenced_packages, deprecated_member_use

import 'dart:async';
import 'dart:io' as io;
import 'dart:io' show Platform;
import 'package:Plastic4trade/model/GetBusinessType.dart' as bt;
import 'package:Plastic4trade/model/core_business_model.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_api_google_plac_api.dart';
import 'package:Plastic4trade/utill/custom_loader_button.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/utill/text_capital.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_interface.dart';
import '../../common/bottomSheetList.dart';
import '../../constroller/GetBussinessTypeController.dart';
import 'Bussinessinfo.dart';

class EditBussinessProfile extends StatefulWidget {
  const EditBussinessProfile({Key? key}) : super(key: key);

  @override
  State<EditBussinessProfile> createState() => _EditBussinessProfileState();
}

extension Numeric on String {
  bool get isNumeric => num.tryParse(this) != null ? true : false;
}

class _EditBussinessProfileState extends State<EditBussinessProfile> {
  bool passenable = true;
  var check_value = false;
  bool isprofile = false;
  String? country_code, product_name, category_name;

  late double lat = 0.0;
  late double log = 0.0;
  String state = '', city = '', country = '';
  int? buss_id;
  int? gst_verification_status;

  LatLng startLocation = const LatLng(0, 0);
  String location = "Search Location";
  final TextEditingController _usernm = TextEditingController();
  final TextEditingController _userbussnm = TextEditingController();
  final TextEditingController _userbussnature = TextEditingController();
  final TextEditingController _usercorebusiness = TextEditingController();

  final TextEditingController _userloc = TextEditingController();
  final TextEditingController _bussmbl = TextEditingController();
  final TextEditingController _bussemail = TextEditingController();
  final TextEditingController _gst = TextEditingController();

  final TextEditingController _bussweb = TextEditingController();
  final TextEditingController _bussabout = TextEditingController();
  bool _isloading1 = false;

  int _bussaboutlength = 0;
  Color _color1 = Colors.black45;
  Color _color2 = Colors.black45;
  Color _color4 = Colors.black45;
  Color _color5 = Colors.black45;
  Color _color6 = Colors.black45;
  Color _color7 = Colors.black45;
  Color _color8 = Colors.black45;
  Color _color9 = Colors.black45;
  Color _color10 = Colors.black45;
  List<String> selectedCoreBusinessIds = [];
  List<String> selectedCoreBusinessNames = [];

  List<String> select_cate = [];
  String? bus_type;
  String defaultCountryCode = 'IN';

  Country? _selectedCountry;
  BuildContext? dialogContext;
  final _formKey = GlobalKey<FormState>();
  String crown_color = '';
  String plan_name = '';

  io.File? file;

  @override
  void initState() {
    super.initState();
    _initializeGoogleApiKey();
    initCountry();
    checkNetwork();
  }

  // Function to initialize the Google API Key
  Future<void> _initializeGoogleApiKey() async {
    String? apiKey = await ApiKeyService.fetchGoogleKey();
    if (mounted) {
      setState(() {
        constanst.googleApikey = apiKey ?? '';
      });
    }
  }

  void initCountry() async {
    final country = await getCountryByCountryCode(context, defaultCountryCode);
    setState(() {
      _selectedCountry = country;
    });
  }

  void get_data() async {
    GetBussinessTypeController bt = GetBussinessTypeController();
    constanst.bt_data = null;
    constanst.btype_data = [];
    constanst.bt_data = bt.getBussiness_Type();
    constanst.bt_data!.then((value) {
      for (var item in value) {
        constanst.btype_data.add(item);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    constanst.select_Bussiness_nature = "";
    constanst.lstBussiness_nature.clear();

    constanst.selectbusstype_id.clear();
    constanst.selectcore_id.clear();
    constanst.itemsCheck.clear();
    constanst.selectbusstype_id.clear();
    constanst.btype_data.clear();
  }

  @override
  Widget build(BuildContext context) {
    return initwidget();
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(
      context,
      cornerRadius: BorderSide.strokeAlignInside,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country;
        country_code = country.callingCode.toString();
      });
    }
  }

  Widget initwidget() {
    final country1 = _selectedCountry;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: const Text('Business Info',
              softWrap: false,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: 'Metropolis',
              )),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        body: isprofile
            ? SafeArea(
                top: true,
                left: true,
                right: true,
                maintainBottomViewPadding: true,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 18.0, 25.0, 10.0),
                          child: CustomTextField(
                            controller: _usernm,
                            labelText: "Your Name *",
                            borderColor: _color1,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r"[a-zA-Z\s]+")),
                              LengthLimitingTextInputFormatter(50),
                            ],
                            onChanged: (value) {
                              final capitalizedValue =
                                  value.split(' ').map((word) {
                                if (word.isNotEmpty) {
                                  return word[0].toUpperCase() +
                                      word.substring(1).toLowerCase();
                                }
                                return word;
                              }).join(' ');

                              if (capitalizedValue != value) {
                                _usernm.value = TextEditingValue(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(
                                      offset: capitalizedValue.length),
                                );
                              }

                              if (value.isEmpty) {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
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
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
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
                              const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 10.0),
                          child: CustomTextField(
                            controller: _userbussnm,
                            labelText: "Company Name *",
                            readOnly: gst_verification_status == 1,

                            borderColor:
                                _color2, // Customize the border color here
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(
                                  r"[a-zA-Z\s]+")), // Allow only alphabets and spaces
                              LengthLimitingTextInputFormatter(50),
                            ],

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
                                _userbussnm.value = TextEditingValue(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(
                                      offset: capitalizedValue.length),
                                );
                              }
                              if (value.isEmpty) {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast(
                                    'Please Enter Your Company Name');
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
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
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
                              const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 10.0),
                          child: CustomTextField(
                            controller: _userbussnature,
                            labelText: "Nature Of Business *",
                            readOnly: true,
                            suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                            borderColor: _color4,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z]+|\s"),
                              ),
                            ],
                            onTap: () async {
                              setState(() {});
                              final connectivityResult =
                                  await Connectivity().checkConnectivity();
                              if (connectivityResult ==
                                  ConnectivityResult.none) {
                                showCustomToast(
                                    'Internet Connection not available');
                              } else {
                                ViewItem(context);
                              }
                            },
                            onChanged: (value) {
                              if (value.isEmpty) {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast(
                                    'Please Enter Nature Of Business');
                                setState(() {
                                  _color4 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color4 = AppColors.greenWithShade;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast('Please Nature Of Business');
                                setState(() {
                                  _color4 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color4 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 10.0),
                          child: CustomTextField(
                            controller: _usercorebusiness,
                            labelText: "Core Business *",
                            readOnly: true,
                            suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                            borderColor: _color10,
                            inputFormatters: [],
                            onTap: () async {
                              setState(() {});
                              final connectivityResult =
                                  await Connectivity().checkConnectivity();

                              if (connectivityResult ==
                                  ConnectivityResult.none) {
                                showCustomToast(
                                    'Internet Connection not available');
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.95,
                                      child: CoreBusinessBottomSheet(
                                        initialSelectedCoreBusinessIds:
                                            selectedCoreBusinessIds,
                                        initialSelectedCoreBusinessNames:
                                            selectedCoreBusinessNames,
                                        onSelect:
                                            (List<Core> selectedBusinesses) {
                                          _usercorebusiness.text =
                                              selectedBusinesses
                                                  .map((e) => e.name)
                                                  .join(', ');

                                          setState(() {
                                            _color9 = AppColors.greenWithShade;
                                          });

                                          selectedCoreBusinessIds =
                                              selectedBusinesses
                                                  .map((e) => e.id.toString())
                                                  .toList();
                                          selectedCoreBusinessNames =
                                              selectedBusinesses
                                                  .map((e) => e.name)
                                                  .toList();
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            onChanged: (value) {
                              if (value.isEmpty) {
                                showCustomToast('Please Select Core Business');
                                setState(() {
                                  _color9 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color9 = AppColors.greenWithShade;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                showCustomToast('Please Select Core Business');
                                setState(() {
                                  _color9 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color9 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _userloc,
                            labelText: "Location/ Address/ City *",
                            readOnly: true,
                            borderColor: _color5,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z]+|\s"),
                              ),
                            ],
                            onTap: () async {
                              var place = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: constanst.googleApikey,
                                mode: Mode.overlay,
                                types: ['establishment', 'geocode'],
                                // types: ['geocode', 'ADDRESS'],
                                strictbounds: false,
                                onError: (err) {},
                              );

                              if (place != null) {
                                setState(() {
                                  location = place.description.toString();
                                  _userloc.text = location;
                                  _color5 = AppColors.greenWithShade;
                                });

                                final plist = GoogleMapsPlaces(
                                  apiKey: constanst.googleApikey,
                                  apiHeaders: await const GoogleApiHeaders()
                                      .getHeaders(),
                                );
                                String placeid = place.placeId ?? "0";
                                final detail =
                                    await plist.getDetailsByPlaceId(placeid);
                                setState(() {
                                  for (var component
                                      in detail.result.addressComponents) {
                                    for (var type in component.types) {
                                      if (type ==
                                          "administrative_area_level_1") {
                                        state = component.longName;
                                        print("State: ${component.longName}");
                                      } else if (type == "locality") {
                                        city = component.longName;
                                        print("City: ${component.longName}");
                                      } else if (type == "country") {
                                        country = component.longName;
                                        print("Country: ${component.longName}");
                                      }
                                    }
                                  }
                                  final geometry = detail.result.geometry!;
                                  lat = geometry.location.lat;
                                  log = geometry.location.lng;
                                });
                              }
                            },
                            onChanged: (value) {
                              if (value.isEmpty) {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast('Please Enter Your Location');
                                setState(() {
                                  _color5 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color5 = AppColors.greenWithShade;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast('Please Enter Your Location');
                                setState(() {
                                  _color5 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color5 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                                height: 55,
                                //width: 130,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white),
                                margin: const EdgeInsets.fromLTRB(
                                    28.0, 5.0, 5.0, 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  //mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        height: 57,
                                        padding: const EdgeInsets.only(left: 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1, color: Colors.black26),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            _onPressedShowBottomSheet();
                                          },
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Image.asset(
                                                country1!.flag,
                                                package: countryCodePackageName,
                                                width: 30,
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                country_code ??
                                                    country1.callingCode,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                )),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 0.0, right: 25, bottom: 5.0),
                                child: CustomTextField(
                                  controller: _bussmbl,
                                  labelText: "Bussiness Moblie *",
                                  borderColor: _color6,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      WidgetsBinding
                                          .instance.focusManager.primaryFocus
                                          ?.unfocus();
                                      showCustomToast(
                                          'Please Add Correct Mobile Numbe');
                                      setState(() {
                                        _color6 = Colors.red;
                                      });
                                    } else {
                                      setState(() {
                                        _color6 = Colors.green.shade600;
                                      });
                                    }
                                  },
                                  onFieldSubmitted: (value) {
                                    var numValue = value.length;
                                    if (numValue >= 6 && numValue < 12) {
                                      _color6 = AppColors.greenWithShade;
                                    } else {
                                      _color6 = AppColors.red;
                                      WidgetsBinding
                                          .instance.focusManager.primaryFocus
                                          ?.unfocus();
                                      showCustomToast(
                                          'Please Enter Correct Number');
                                    }
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _bussemail,
                            labelText: "Business Email",
                            borderColor: _color7,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-z0-9@._-]')),
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                return TextEditingValue(
                                  text: newValue.text.toLowerCase(),
                                  selection: newValue.selection,
                                );
                              }),
                            ],
                            onFieldSubmitted: (value) {
                              if (!EmailValidator.validate(value)) {
                                _color7 = AppColors.red;
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast('Please enter a valid email');
                                setState(() {});
                              } else if (value.isEmpty) {
                                WidgetsBinding
                                    .instance.focusManager.primaryFocus
                                    ?.unfocus();
                                showCustomToast('Please enter your email');
                                setState(() {
                                  _color7 = AppColors.red;
                                });
                              } else if (value.isNotEmpty) {
                                setState(() {
                                  _color7 = Colors.green.shade600;
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _gst,
                            labelText: "GST/Tax/VAT Number",
                            readOnly: gst_verification_status == 1,
                            borderColor: _color7,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z]+|\d"),
                              ),
                              LengthLimitingTextInputFormatter(15),
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                return TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection,
                                );
                              }),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _bussweb,
                            labelText: "Website",
                            borderColor: _color8,
                            keyboardType: TextInputType.text,
                            inputFormatters: [],
                            onFieldSubmitted: (value) {
                              if (value != '') {
                                setState(() {
                                  _color8 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: Stack(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        _color9, // Use the external borderColor parameter
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
                                    maxLength: 2000,
                                    onChanged: (value) {
                                      setState(() {
                                        _bussaboutlength = value.length;
                                      });
                                    },
                                    style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf'),
                                    maxLines: 4,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      border: InputBorder.none,
                                      counterText: "",
                                      labelText: "About Business",
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                    ),
                                    onFieldSubmitted: (value) {
                                      if (value.isEmpty) {
                                        WidgetsBinding
                                            .instance.focusManager.primaryFocus
                                            ?.unfocus();
                                        showCustomToast(
                                            'Please Your About Bussiness');
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
                              Positioned(
                                  bottom: 0,
                                  right: 5,
                                  child: Text(
                                    "${_bussaboutlength}/2000",
                                    style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black38,
                                        fontFamily:
                                            'assets/fonst/Metropolis-Black.otf'),
                                  )),
                            ],
                          ),
                        ),
                        CustomButton(
                          buttonText: 'Update',
                          onPressed: () {
                            if (selectedCoreBusinessIds.isEmpty) {
                              _color10 = AppColors.red;
                              showCustomToast('Please Select Core Business');
                              setState(() {
                                _isloading1 = false;
                              });
                              return;
                            } else {
                              _color10 = AppColors.greenWithShade;
                              setState(() {});
                            }

                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isloading1 = true;
                              });

                              updateUserBusiness_Profile().then((success) {
                                setState(() {
                                  _isloading1 = false;
                                });

                                if (success) {
                                } else {
                                  showCustomToast(
                                      "Failed to update. Please try again.");
                                }
                              }).catchError((error) {
                                setState(() {
                                  _isloading1 = false;
                                });
                                print("An error occurred: $error");
                              });
                            } else {
                              showCustomToast(
                                  "Please correct the errors in the form.");
                            }
                          },
                          isLoading: _isloading1,
                        ),
                        10.sbh,
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: CustomLottieContainer(
                child: Lottie.asset(
                  'assets/loading_animation.json',
                ),
              )));
  }

  List<String> _getCoreBusinessList(dynamic value) {
    if (value == null) {
      return [];
    } else if (value is String) {
      // If it's a String, split it by commas
      return value.split(',').map((e) => e.trim()).toList();
    } else if (value is List) {
      // If it's already a List, cast and return it
      // ignore: unnecessary_cast
      return (value as List).map((e) => e.toString()).toList();
    }
    return [];
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

    var res = await getbussinessprofile(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
      pref.getString('user_id').toString(),
      context,
    );

    print("GET PROFILE RESPONSE  === $res");

    if (res['status'] == 1) {
      setState(() {
        _usernm.text = res['user']['username'] ?? "";
        _userbussnm.text = res['profile']['business_name'] ?? "";
        buss_id = res['profile']['id'] ?? "";
        _bussemail.text = res['profile']['other_email'] ?? "";
        _gst.text = res['profile']['gst_tax_vat'] ?? "";

        _bussweb.text = res['profile']['website'] ?? "";
        _bussmbl.text = res['profile']['business_phone'] ?? "";
        _bussabout.text = res['profile']['about_business'] ?? "";
        _userloc.text = res['profile']['address'] ?? "";
        country_code = res['profile']['countryCode'] ?? "";
        // _userbussnature.text = res['profile']['business_type_name'] ?? "";
        if (res['profile']['latitude'] != null &&
            res['profile']['latitude'] != "null" &&
            res['profile']['latitude'] != "") {
          lat = double.parse(res['profile']['latitude'].toString());
        }
        if (res['profile']['longitude'] != null &&
            res['profile']['longitude'] != "null" &&
            res['profile']['longitude'] != "") {
          log = double.parse(res['profile']['longitude'].toString());
        }
        city = res['profile']['city'] ?? "";
        state = res['profile']['state'] ?? "";
        country = res['profile']['country'] ?? "";
        product_name = res['profile']['product_name'] ?? "";
        category_name = res['user']['category_name'] ?? "";
        gst_verification_status = res['profile']['gst_verification_status'];

        constanst.selectbusstype_id =
            res['profile']['business_type'].split(',');
        constanst.lstBussiness_nature =
            res['profile']['business_type_name'].split(',');
        _userbussnature.text = constanst.lstBussiness_nature.join(', ');

        // Now use it after the method declaration
// Parse the response and update local variables
        final coreBusinessIds =
            _getCoreBusinessList(res['profile']['core_businesses']);
        final coreBusinessNames =
            _getCoreBusinessList(res['profile']['core_businesses_name']);

// Print the parsed core business IDs and names
        print("Parsed Core Business IDs: $coreBusinessIds");
        print("Parsed Core Company Names: $coreBusinessNames");

// Update local variables
        selectedCoreBusinessIds = coreBusinessIds;
        selectedCoreBusinessNames = coreBusinessNames;

// Print the updated selected core business data
        print("Selected Core Business IDs: $selectedCoreBusinessIds");
        print("Selected Core Company Names: $selectedCoreBusinessNames");

// Update the text field and print the result
        _usercorebusiness.text = coreBusinessNames.join(', ');
        print("Updated TextField Value: ${_usercorebusiness.text}");

        isprofile = true;
      });
    } else {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(res['message']);
    }
    return res;
  }

  Future<bool> updateUserBusiness_Profile() async {
    setState(() {
      _isloading1 = true; // Show loader
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = Platform.isAndroid ? 'android' : 'ios';

    // Logging for debugging
    _logUserDetails(pref, device);

    // Call API to update business profile
    var res = await updateUserBusinessProfile(
      pref.getString('user_id') ?? '',
      pref.getString('userToken') ?? '',
      _userbussnm.text.trim(),
      constanst.selectbusstype_id.join(","),
      selectedCoreBusinessIds.join(","),
      _userloc.text.trim(),
      lat.toString(),
      log.toString(),
      '',
      country,
      country_code ?? '',
      _bussmbl.text.trim(),
      '11',
      city,
      _bussemail.text.trim(),
      _gst.text.trim(),
      _bussweb.text.trim(),
      _bussabout.text.trim(),
      buss_id.toString(),
      state,
      _usernm.text.trim(),
      device,
    );

    setState(() {
      _isloading1 = false; // Stop loader
    });

    // Dismiss keyboard
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

    // Show response message
    String message = res['message'] ?? 'An error occurred';
    print('Response: $message'); // Print response message for debugging
    showCustomToast(message);

    // Navigate if successful
    if (res['status'] == 1) {
      print('Success: Business profile updated successfully');
      print('Full Response Business profile: $res');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Bussinessinfo()),
      );
    } else {
      print('Error updating business profile: $message');
    }

    return res['status'] == 1;
  }

// Log user details for debugging purposes
  void _logUserDetails(SharedPreferences pref, String device) {
    print('Device Name: $device');
    print('User ID: ${pref.getString('user_id') ?? 'Unknown'}');
    print('API Token: ${pref.getString('userToken') ?? 'Unknown'}');
    print('Company Name: ${_userbussnm.text.trim()}');
    print('Business Type IDs: ${constanst.selectbusstype_id.join(",")}');
    print('Core Business: ${constanst.selectcore_id.join(",")}');
    print('Location: ${_userloc.text.trim()}');
    print('Latitude: $lat, Longitude: $log');
    print('Country: $country');
    print('Country Code: $country_code');
    print('Business Mobile: ${_bussmbl.text.trim()}');
    print('City: $city');
    print('Business Email: ${_bussemail.text.trim()}');
    print('GST: ${_gst.text.trim()}');
    print('Website: ${_bussweb.text.trim()}');
    print('About Business: ${_bussabout.text.trim()}');
    print('Business ID: $buss_id');
    print('State: $state');
    print('User Name: ${_usernm.text.trim()}');
  }

  ViewItem(BuildContext context) {
    return showModalBottomSheet(
        backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        useRootNavigator: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          // <-- SEE HERE
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        )),
        builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize:
                0.90, // Initial height as a fraction of screen height
            builder: (BuildContext context, ScrollController scrollController) {
              return const YourWidget();
            })).then(
      (value) {
        setState(() {
          _userbussnature.text = constanst.lstBussiness_nature.join(", ");
          _color2 = AppColors.greenWithShade;
        });
      },
    );
  }

  Future<void> checkNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      isprofile = true;
    } else {
      get_data();
      getProfiless();
    }
  }
}

class YourWidget extends StatefulWidget {
  const YourWidget({Key? key}) : super(key: key);

  @override
  State<YourWidget> createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        Image.asset(
          'assets/hori_line.png',
          width: 150,
          height: 5,
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text('Select Nature Of Business',
              style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'assets/fonst/Metropolis-Black.otf')),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: constanst.btype_data.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                bt.Result record = constanst.btype_data[index];
                return CommanBottomSheet(
                  onTap: () {
                    setState(() {
                      if (constanst.selectbusstype_id
                          .contains(record.businessTypeId.toString())) {
                        constanst.lstBussiness_nature
                            .remove(record.businessType.toString());
                        constanst.selectbusstype_id
                            .remove(record.businessTypeId.toString());
                      } else {
                        if (constanst.selectbusstype_id.length <= 2) {
                          constanst.lstBussiness_nature
                              .add(record.businessType.toString());
                          constanst.selectbusstype_id
                              .add(record.businessTypeId.toString());
                        } else {
                          WidgetsBinding.instance.focusManager.primaryFocus
                              ?.unfocus();
                          showCustomToast(
                              'You Can Select Maximum 3 Nature of Business');
                        }
                      }
                    });
                  },
                  checked: constanst.selectbusstype_id
                      .contains(record.businessTypeId.toString()),
                  title: record.businessType,
                );
              }),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 1.2,
          height: 60,
          margin: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(50.0),
              color: AppColors.primaryColor),
          child: TextButton(
            onPressed: () {
              if (constanst.selectbusstype_id.isNotEmpty) {
                Navigator.pop(context);
                setState(() {});
              } else {
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                showCustomToast('Select Minimum 1 Nature of Bussiness ');
              }
            },
            child: const Text('Update',
                style: TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'assets/fonst/Metropolis-Black.otf')),
          ),
        ),
      ],
    );
  }
}

class CoreBusinessBottomSheet extends StatefulWidget {
  final Function(List<Core> selectedBusinesses) onSelect;
  final List<String> initialSelectedCoreBusinessIds;
  final List<String> initialSelectedCoreBusinessNames;

  const CoreBusinessBottomSheet({
    Key? key,
    required this.onSelect,
    this.initialSelectedCoreBusinessIds = const [],
    this.initialSelectedCoreBusinessNames = const [],
  }) : super(key: key);

  @override
  _CoreBusinessBottomSheetState createState() =>
      _CoreBusinessBottomSheetState();
}

class _CoreBusinessBottomSheetState extends State<CoreBusinessBottomSheet> {
  bool isLoading = true;
  List<Core> businessList = [];
  late List<Core> selectedBusinesses;
  final TextEditingController _corebusiness = TextEditingController();
  Color _color1 = Colors.black26; // name
  TextEditingController coreSearch = TextEditingController();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    selectedBusinesses = [];
    // Select businesses based on passed IDs
    _selectBusinessesByIds();
    fetchCoreBusiness();
  }

  void _selectBusinessesByIds() {
    for (int i = 0; i < businessList.length; i++) {
      if (widget.initialSelectedCoreBusinessIds
          .contains(businessList[i].id.toString())) {
        selectedBusinesses.add(businessList[i]);
      }
    }
  }

  Future<void> fetchCoreBusiness() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    var res = await getCoreBusiness(
      pref.getString('user_id').toString(),
      coreSearch.text.toString(),
    );
    if (res != null && res.status == 1) {
      setState(() {
        businessList = res.getCore;
        _selectBusinessesByIds();
        isLoading = false;
      });
    } else {
      print('Error fetching core business: ${res?.message}');
      showCustomToast(res?.message ?? 'An error occurred');
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleSelection(Core business) {
    if (selectedBusinesses.contains(business)) {
      setState(() {
        selectedBusinesses.remove(business);
      });
    } else {
      if (selectedBusinesses.length < 3) {
        setState(() {
          selectedBusinesses.add(business);
        });
      } else {
        showCustomToast('You can select only three core businesses.');
      }
    }

    widget.onSelect(selectedBusinesses);
  }

  Future<void> _updateCoreBusiness() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (selectedBusinesses.isNotEmpty) {
      var userId = pref.getString('user_id').toString();
      var apiToken = pref.getString('userToken').toString();
      var coreBusinessText = _corebusiness.text;

      print('User ID: $userId');
      print('API Token: $apiToken');
      print('Core Business Text: $coreBusinessText');

      var response = await saveCoreBusiness(
        userId,
        apiToken,
        coreBusinessText,
      );

      print('Response: $response');

      if (response != null && response['status'] == 1) {
        Navigator.pop(context);
        var coreId = response['core']['id'];
        var coreName = response['core']['name'];

        print('Core ID: $coreId');
        print('Core Name: $coreName');

        selectedBusinesses.add(Core(id: coreId, name: coreName, status: 0));

        widget.onSelect(selectedBusinesses);

        setState(() {});
        showCustomToast('Core Business updated successfully');
      } else {
        var errorMessage =
            response?['message'] ?? 'Failed to update Core Business';
        print('Error: $errorMessage');
        showCustomToast(errorMessage);
      }
    } else {
      print('No business selected');
      showCustomToast('Select Minimum 1 Nature Of Business');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Select Core Business',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                10.sbh,
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: SizedBox(
                    height: 50,
                    child: TextFormField(
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackColor,
                        fontFamily: 'assets/fonst/Metropolis-Black.otf',
                      ),
                      textCapitalization: TextCapitalization.words,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.text,
                      controller: coreSearch,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z]+|\s"),
                        ),
                      ],
                      onFieldSubmitted: (value) {
                        businessList.clear();
                        fetchCoreBusiness();
                        setState(() {});
                      },
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();

                        _debounce =
                            Timer(const Duration(milliseconds: 300), () {
                          if (value.isNotEmpty) {
                            fetchCoreBusiness();
                          } else {
                            setState(() {
                              businessList.clear();
                              fetchCoreBusiness();
                            });
                          }
                        });
                      },
                      decoration: InputDecoration(
                        fillColor: AppColors.backgroundColor,
                        filled: true,
                        hintText: "Search Core Business",
                        hintStyle: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blackColor,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf')
                            .copyWith(color: AppColors.black45Color),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        prefixIcon: const Icon(Icons.search),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 1, color: AppColors.black45Color),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 1, color: AppColors.black45Color),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                ),
                10.sbh,
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: businessList.length + 1,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      if (index < businessList.length) {
                        final coreBusiness = businessList[index];
                        bool isSelected =
                            selectedBusinesses.contains(coreBusiness);

                        return CommanBottomSheet(
                          onTap: () {
                            toggleSelection(coreBusiness);
                          },
                          checked: isSelected,
                          title: coreBusiness.name,
                        );
                      } else {
                        return TextFormField(
                          controller: _corebusiness,
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            CapitalizingTextInputFormatter(),
                            LengthLimitingTextInputFormatter(40),
                          ],
                          style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf'),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Add Core Business",
                            hintStyle: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                            ).copyWith(color: Colors.black45),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: _color1),
                                borderRadius: BorderRadius.circular(10.0)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: _color1),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: _color1),
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width * 1.2,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(50.0),
                      color: AppColors.primaryColor,
                    ),
                    child: TextButton(
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());

                        if (selectedBusinesses.isNotEmpty) {
                          if (_corebusiness.text.isNotEmpty) {
                            await _updateCoreBusiness();
                          } else {
                            Navigator.pop(context);
                          }
                          setState(() {});
                        } else {
                          showCustomToast(
                              'Select Minimum 1 Nature Of Business');
                        }
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
