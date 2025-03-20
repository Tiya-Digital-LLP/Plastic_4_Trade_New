// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, camel_case_types, depend_on_referenced_packages, deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';

import 'package:Plastic4trade/common/commom_dialog_reupload.dart';
import 'package:Plastic4trade/constroller/GetBussinessTypeController.dart';
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
import 'package:Plastic4trade/widget/MainScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_interface.dart';
import '../../common/bottomSheetList.dart';
import '../../model/bussinessProfileModel/addbussiness_profile_model.dart';

class Register2 extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Register2({Key? key}) : super(key: key);

  @override
  State<Register2> createState() => _Register2State();
}

class _Register2State extends State<Register2> {
  final TextEditingController _bussname = TextEditingController();
  final TextEditingController _bussmbl = TextEditingController();
  final TextEditingController _bussemail = TextEditingController();
  final TextEditingController _loc = TextEditingController();
  final TextEditingController _gstno = TextEditingController();
  final TextEditingController _website = TextEditingController();
  final TextEditingController _aboutbuess = TextEditingController();
  final TextEditingController _userbussnature = TextEditingController();
  final TextEditingController _usercorebusiness = TextEditingController();

  Color _color1 = Colors.black26;
  Color _color2 = Colors.black26;
  Color _color3 = Colors.black26;
  Color _color4 = Colors.black26;
  Color _color5 = Colors.black26;
  Color _color6 = Colors.black26;
  Color _color7 = Colors.black26;
  Color _color8 = Colors.black26;
  Color _color9 = Colors.black26;

  io.File? file, file1, file2;

  final ImagePicker _picker = ImagePicker();

  late double lat = 0.0;
  late double log = 0.0;
  String state = '', country_code = '+91', city = '', country = '';
  CameraPosition? cameraPosition;
  LatLng startLocation = const LatLng(0, 0);
  String location = "Search Location";
  bool _isValid = false;
  String defaultCountryCode = 'IN';
  String buss_type = "";
  Country? _selectedCountry;
  BuildContext? dialogContext;
  bool _isloading1 = false;
  List<String> selectedCoreBusinessIds = [];
  List<String> selectedCoreBusinessNames = [];

  @override
  void initState() {
    super.initState();
    _initializeGoogleApiKey();

    initCountry();
    constanst.Bussiness_nature_name = "";
    get_data();
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

  @override
  Widget build(BuildContext context) {
    return initwidget(context);
  }

  @override
  void dispose() {
    super.dispose();
    constanst.lstBussiness_nature.clear();
    constanst.selectbusstype_id.clear();
    constanst.select_Bussiness_nature = "";
    constanst.bt_data = null;
    constanst.btype_data = [];
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

  Future<bool> _onbackpress(BuildContext context) async {
    Navigator.pop(context);
    return Future.value(true);
  }

  Widget initwidget(BuildContext context) {
    final country1 = _selectedCountry;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      resizeToAvoidBottomInset: true,
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          _onbackpress(context);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Form(
            child: SizedBox(
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
                        Row(
                          children: [
                            GestureDetector(
                              child: Image.asset('assets/back.png',
                                  height: 50, width: 70),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 1.3,
                              alignment: Alignment.topLeft,
                              child: const Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Business Profile",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  )),
                            ),
                          ],
                        ),
                        imageprofile(context),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 3.0),
                          child: CustomTextField(
                            controller: _bussname,
                            labelText: "Company Name *",
                            borderColor: _color1,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r"[a-zA-Z\s]+")),
                              LengthLimitingTextInputFormatter(50),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                _color1 = AppColors.red;
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
                                _bussname.value = TextEditingValue(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(
                                      offset: capitalizedValue.length),
                                );
                              }
                              if (value.isEmpty) {
                                showCustomToast('Please Add Your Company Name');
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
                                showCustomToast('Please Enter Bussiness Name');
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
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                              controller: _userbussnature,
                              labelText: "Nature Of Business *",
                              borderColor: _color2,
                              suffixIcon:
                                  const Icon(Icons.arrow_drop_down_sharp),
                              readOnly: true,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(
                                    r"[a-zA-Z\s]+")), // Allow only alphabets and spaces
                                LengthLimitingTextInputFormatter(50),
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
                                  showNatureOfBusiness(context);
                                }
                              },
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  showCustomToast(
                                      'Please Select Nature Of Business');
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
                                      'Please Select Nature Of Business');
                                  setState(() {
                                    _color2 = AppColors.red;
                                  });
                                } else {
                                  setState(() {
                                    _color2 = AppColors.greenWithShade;
                                  });
                                }
                              }),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _usercorebusiness,
                            labelText: "Core Business *",
                            readOnly: true,
                            suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                            borderColor: _color9,
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
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _loc,
                            labelText: "Location/ Address / City *",
                            borderColor: _color5,
                            readOnly: true,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(
                                  r"[a-zA-Z\s]+")), // Allow only alphabets and spaces
                              LengthLimitingTextInputFormatter(50),
                            ],
                            onTap: () async {
                              var place = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: constanst.googleApikey,
                                mode: Mode.overlay,
                                types: ['geocode', 'establishment'],
                                strictbounds: false,
                                onError: (err) {},
                              );

                              if (place != null) {
                                setState(() {
                                  location = place.description.toString();

                                  _loc.text = location;
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
                                for (var component
                                    in detail.result.addressComponents) {
                                  for (var type in component.types) {
                                    if (type == "administrative_area_level_1") {
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
                              }
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                _color5 = AppColors.red;
                              } else {}
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                showCustomToast(
                                    'Please Search and Save your Business Location');
                                setState(() {
                                  _color5 = AppColors.red;
                                });
                              } else if (value.isNotEmpty) {
                                setState(() {
                                  _color5 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: Row(
                            children: [
                              Container(
                                  height: 55,
                                  margin: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 5.0, 0.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          height: 57,
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black26),
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
                                                  package:
                                                      countryCodePackageName,
                                                  width: 30,
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                const SizedBox(
                                                  width: 2,
                                                ),
                                                Text(
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
                                    height: 55,
                                    width: MediaQuery.of(context).size.width /
                                        1.59,
                                    margin: const EdgeInsets.only(bottom: 0.0),
                                    child: CustomTextField(
                                      controller: _bussmbl,
                                      labelText: "Bussiness Moblie *",
                                      borderColor: _color8,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(11),
                                      ],
                                      onFieldSubmitted: (value) {
                                        var numValue = value.length;
                                        if (numValue >= 6 && numValue < 12) {
                                          _color8 = AppColors.greenWithShade;
                                        } else {
                                          _color8 = AppColors.red;
                                          showCustomToast(
                                              'Please Enter Correct Number');
                                        }
                                      },
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          setState(() {
                                            _color8 = Colors.black26;
                                          });
                                        } else {
                                          setState(() {
                                            _color8 = AppColors.greenWithShade;
                                          });
                                        }
                                      },
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _bussemail,
                            labelText: "Bussiness Email",
                            borderColor: _color4,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _color4 = Colors.black26;
                                });
                              } else {
                                setState(() {
                                  _color4 = AppColors.greenWithShade;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (!EmailValidator.validate(value)) {
                                _color4 = AppColors.red;
                                showCustomToast('Please enter a valid email');
                                setState(() {});
                              } else if (value.isEmpty) {
                                setState(() {
                                  _color4 = Colors.black26;
                                });
                              } else if (value.isNotEmpty) {
                                setState(() {
                                  _color4 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _gstno,
                            labelText: "GST/Tax/VAT Number",
                            borderColor: _color3,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.emailAddress,
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
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _color3 = Colors.black26;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              var numValue = value.length;
                              if (value.isEmpty) {
                                setState(() {
                                  _color3 = Colors.black26;
                                });
                              } else if (numValue < 15) {
                                _color3 = AppColors.greenWithShade;
                              } else if (value.isNotEmpty) {
                                setState(() {
                                  _color3 = AppColors.greenWithShade;
                                });
                              } else {
                                _color3 = AppColors.red;

                                showCustomToast(
                                    'Please Enter Valid GST/ VAT/Tax Number');
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _website,
                            labelText: "Website",
                            borderColor: _color6,
                            keyboardType: TextInputType.url,
                            inputFormatters: [],
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _color6 = Colors.black26;
                                });
                              } else {
                                setState(() {
                                  _color6 = AppColors.greenWithShade;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _color6 = Colors.black26;
                                });
                              } else if (value.isNotEmpty) {
                                setState(() {
                                  _color6 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    _color7, // Use the external borderColor parameter
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: SizedBox(
                              height: 120,
                              child: TextFormField(
                                controller: _aboutbuess,
                                keyboardType: TextInputType.multiline,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf'),
                                maxLines: 4,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  border: InputBorder.none,
                                  labelText: "About Bussiness",
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      _color7 = Colors.black26;
                                    });
                                  } else {
                                    setState(() {
                                      _color7 = AppColors.greenWithShade;
                                    });
                                  }
                                },
                                onFieldSubmitted: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      _color7 = Colors.black26;
                                    });
                                  } else if (value.isNotEmpty) {
                                    setState(() {
                                      _color7 = AppColors.greenWithShade;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        CustomButton(
                          buttonText: 'Continue',
                          onPressed: () async {
                            FocusScope.of(context).unfocus();

                            final connectivityResult =
                                await Connectivity().checkConnectivity();
                            if (connectivityResult == ConnectivityResult.none) {
                              showCustomToast('Net Connection not available');
                            } else {
                              vaild_data();
                            }
                          },
                          isLoading: _isloading1,
                        ),
                        10.sbh,
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

  Widget imageprofile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => bottomsheet(),
        );
      },
      child: Center(
        child: Stack(
          children: <Widget>[
            CircleAvatar(
              radius: 60.0,
              backgroundImage: file != null &&
                      file is io.File // Ensure file is a File object
                  ? FileImage(file as io.File)
                  : const AssetImage('assets/addphoto1.png') as ImageProvider,
              backgroundColor: const Color.fromARGB(255, 240, 238, 238),
            ),
            Positioned(
              bottom: 3.0,
              right: 5.0,
              child: SizedBox(
                width: 40,
                height: 33,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    showModalBottomSheet(
                        context: context, builder: (context) => bottomsheet());
                  },
                  child: const ImageIcon(
                    AssetImage('assets/Vector (1).png'),
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomsheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile Photo",
            style: TextStyle(fontSize: 18.0),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                  onPressed: () {
                    takephoto(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera, color: AppColors.primaryColor),
                  label: const Text(
                    'Camera',
                    style: TextStyle(color: AppColors.primaryColor),
                  )),
              TextButton.icon(
                  onPressed: () {
                    takephoto(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image, color: AppColors.primaryColor),
                  label: const Text(
                    'Gallery',
                    style: TextStyle(color: AppColors.primaryColor),
                  )),
            ],
          )
        ],
      ),
    );
  }

  void takephoto(ImageSource imageSource) async {
    final pickedfile =
        await _picker.pickImage(source: imageSource, imageQuality: 100);
    if (pickedfile != null) {
      io.File imageFile = io.File(pickedfile.path);
      int fileSizeInBytes = imageFile.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024;

      if (kDebugMode) {
        print('Original image size: $fileSizeInKB KB');
      }

      if (fileSizeInKB > 5000) {
        showCustomToast('Please Select an image below 5 MB');
        return;
      }

      io.File? processedFile = imageFile;

      if (fileSizeInKB <= 100) {
        processedFile = await _cropImage(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
      } else if (fileSizeInKB > 100) {
        processedFile = await _cropImage(imageFile);
        if (processedFile == null) {
          showCustomToast('Failed to crop image');
          if (kDebugMode) {
            print('Failed to crop image');
          }
          return;
        }
        processedFile = await _compressImage(processedFile);
      }

      double processedFileSizeInKB = processedFile!.lengthSync() / 1024;
      if (kDebugMode) {
        print('Processed image size: $processedFileSizeInKB KB');
      }

      if (mounted) {
        setState(() {
          file = processedFile;
        });

        if (file != null) {
          constanst.imagesList.add(file!);
        }
      }

      var response = await noPromotionCheck(image: processedFile);
      if (response != null) {
        int status = response['status'];

        if (status == 1) {
          print('Status 1: not show image');
          Navigator.of(context).pop();
          return;
        } else if (status == 2) {
          showCustomToast('Warning: Text detected in the image');
          Navigator.of(context).pop();
          return;
        } else if (status == 3) {
          Navigator.of(context).pop();
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return CommomDialogReupload(
                  title: "Uplaod Image",
                  content:
                      "Not Allowed in Image Business cards, phone number, email Id and company name.",
                  onPressed: () {
                    setState(() {
                      constanst.imagesList.remove(file);
                      file = null;
                    });
                    Navigator.of(context).pop();
                  },
                );
              });
          return;
        }
      } else {
        showCustomToast('API response was null');
      }
    } else {
      showCustomToast('Please select an image');
      return;
    }
  }

  Future<io.File?> _cropImage(io.File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedFile != null) {
      return io.File(croppedFile.path);
    } else {
      return null;
    }
  }

  Future<io.File?> _compressImage(io.File imageFile) async {
    print('Step 9a: Starting image compression');

    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/temp.jpg';
    print('Step 9b: Temporary directory path set: $targetPath');

    int quality = 90;
    io.File? compressedFile;
    double fileSizeInKB;

    // Prevent infinite loop by setting a max iteration count
    const maxIterations = 10;
    int currentIteration = 0;

    while (currentIteration < maxIterations) {
      currentIteration++;

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
      );

      if (result == null) {
        print('Step 9c: Compression failed, returning null');
        return null;
      }

      compressedFile = io.File(result.path);
      fileSizeInKB = compressedFile.lengthSync() / 1024;
      print(
          'Step 9d: Compressed image size: $fileSizeInKB KB at quality $quality');

      if (fileSizeInKB <= 100) {
        // If file size is <= 100 KB, aim for a size of 20 to 30 KB
        if (fileSizeInKB <= 30) {
          print(
              'Step 9e: Image size within acceptable range, stopping compression');
          break;
        } else {
          quality = (quality - 10)
              .clamp(0, 100); // Reduce quality to decrease file size
          print('Step 9f: Decreasing quality to $quality');
        }
      } else {
        // If file size is > 100 KB, aim for a size around 100 KB
        if (fileSizeInKB <= 100) {
          print(
              'Step 9g: Image size within acceptable range, stopping compression');
          break;
        } else {
          quality = (quality - 10)
              .clamp(0, 100); // Reduce quality to decrease file size
          print('Step 9h: Decreasing quality to $quality');
        }
      }

      if (quality <= 0 || quality >= 100) {
        print('Step 9i: Quality out of range, breaking loop');
        break;
      }
    }

    if (currentIteration == maxIterations) {
      print('Step 9j: Max iterations reached, stopping compression');
    }

    return compressedFile;
  }

  vaild_data() {
    // Reset colors to default
    resetColors();

    // Perform initial field validations
    if (_bussname.text.isEmpty) {
      _color1 = AppColors.red;
      setState(() {});
      showCustomToast('Please Add Your Company Name');
      return; // Exit early if validation fails
    }

    if (_userbussnature.text.isEmpty) {
      _color2 = AppColors.red;
      setState(() {});
      showCustomToast('Please Select at least 1 Nature of Business');
      return;
    }

    if (selectedCoreBusinessIds.isEmpty) {
      print("Error: Core Business is empty.");
      showCustomToast('Please Select Core Business');
      setState(() {
        _color9 = AppColors.red;
      });
      return false;
    } else {
      setState(() {
        _color9 = AppColors.greenWithShade;
      });
      print("Core Business is valid.");
    }

    if (_loc.text.isEmpty) {
      _color5 = AppColors.red;
      setState(() {});
      showCustomToast('Please Search and Save your Business Location');
      return;
    }

    if (file == null) {
      showCustomToast('Please Add and Save Your Image');
      return;
    }

    // Validate business mobile number
    if (_bussmbl.text.isNotEmpty) {
      var numValue = _bussmbl.text.length;
      if (numValue < 6 || numValue > 10) {
        _color8 = AppColors.red;
        setState(() {});
        showCustomToast('Please Enter Correct Number');
        return;
      } else {
        _color8 = AppColors.greenWithShade;
      }
    }

    // Validate email
    if (_bussemail.text.isNotEmpty) {
      _isValid = EmailValidator.validate(_bussemail.text);
      if (!_isValid) {
        showCustomToast('Enter Valid Email Address');
        _color4 = AppColors.red;
        setState(() {});
        return;
      } else {
        _color4 = AppColors.greenWithShade;
      }
    }

    // // Validate GST Number
    // if (_gstno.text.isNotEmpty) {
    //   var numValue = _gstno.text.length;
    //   if (numValue < 15) {
    //     showCustomToast('Enter Valid GST/ VAT/Tax Number');
    //     setState(() {
    //       _color3 = AppColors.red;
    //     });
    //     return;
    //   } else {
    //     _color3 = AppColors.greenWithShade;
    //   }
    // }

    // If all validations pass, proceed with business profile creation
    add_bussinessProfile().then((value) {
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => MainScreen(0)),
        ModalRoute.withName('/'),
      );
    });
  }

// Function to reset colors to default
  void resetColors() {
    _color1 = _color2 = _color3 =
        _color4 = _color5 = _color8 = _color9 = AppColors.greenWithShade;
    setState(() {});
  }

  Future<bool> add_bussinessProfile() async {
    setState(() {
      _isloading1 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    constanst.step = 6;
    var res = await addbussiness(
      addBussinessProfileRequest: AddBussinessProfileRequest(
        userId: pref.getString('user_id').toString(),
        userToken: pref.getString('userToken').toString(),
        businessName: _bussname.text,
        businessType: constanst.selectbusstype_id.join(","),
        corebusiness: selectedCoreBusinessIds.join(","),
        location: _loc.text,
        latitude: lat.toString(),
        longitude: log.toString(),
        otherMobile1: '',
        country: country,
        countryCode: country_code,
        businessPhone: _bussmbl.text,
        stepCounter: constanst.step.toString(),
        city: city,
        email: _bussemail.text,
        website: _website.text,
        aboutBusiness: _aboutbuess.text,
        //file,
        gstTaxVat: _gstno.text,
        state: state,
      ),
      file: file,
    );
    setState(() {
      _isloading1 = false;
    });
    print("add_bussinessProfile:-$res");
    if (res['status'] == 1) {
      showCustomToast(res['message']);
      constanst.isprofile = false;
      pref.setString('userImage', res['profile_image']).toString();
      constanst.image_url = pref.getString('userImage').toString();
      _isloading1 = true;
    } else {
      _isloading1 = true;
      showCustomToast(res['message']);
    }
    return _isloading1;
  }

  showNatureOfBusiness(context) {
    return showModalBottomSheet(
        backgroundColor: const Color(0xFFFFFFFF),
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
              return const type();
            })).then(
      (value) {
        setState(() {
          _userbussnature.text = constanst.lstBussiness_nature.join(', ');
          _color2 = AppColors.greenWithShade;
        });
      },
    );
  }
}

class type extends StatefulWidget {
  const type({Key? key}) : super(key: key);

  @override
  State<type> createState() => _typeState();
}

class _typeState extends State<type> {
  //bool gender = false;

  @override
  void initState() {
    super.initState();
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
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.0), // Set the bottom border radius
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.1), // Optional shadow for elevation effect
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor:
                Colors.transparent, // Make AppBar's background transparent
            elevation: 0, // Remove the default AppBar shadow
            title: const Text(
              'Select Nature Of Business',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                fontFamily: 'assets/fonts/Metropolis-Black.otf',
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false, // Removes the default back icon
            actions: [
              IconButton(
                icon: Icon(Icons.clear,
                    color: Colors.black), // Cancel icon on the right side
                onPressed: () {
                  Navigator.of(context).pop(); // Close the current screen
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          10.sbh,
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shrinkWrap: true,
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
                if (constanst.lstBussiness_nature.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() {});
                  log("SELECTED NATURE === ${constanst.lstBussiness_nature}");
                  log("SELECTED NATURE === ${constanst.lstBussiness_nature.length}");
                } else {
                  showCustomToast('Select Minimum 1 Nature Of Business ');
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
      ),
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
