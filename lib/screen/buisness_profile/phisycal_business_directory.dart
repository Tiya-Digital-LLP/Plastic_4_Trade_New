// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:Plastic4trade/utill/custom_api_google_plac_api.dart';
import 'package:Plastic4trade/utill/custom_text_field.dart';
import 'package:Plastic4trade/utill/text_capital.dart';
import 'package:Plastic4trade/widget/HomeAppbar.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:Plastic4trade/model/GetProductName.dart' as pnm;

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/common/bottomSheetList.dart';
import 'package:Plastic4trade/constroller/GetBussinessTypeController.dart';
import 'package:Plastic4trade/model/add_business_directory.dart';
import 'package:Plastic4trade/model/core_business_model.dart';
import 'package:Plastic4trade/model/get_designation_model.dart';
import 'package:Plastic4trade/screen/buisness_profile/phisical_directory_details.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/constant.dart';
import 'package:Plastic4trade/utill/custom_dot_loader.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:Plastic4trade/model/GetBusinessType.dart' as bt;
import 'package:http/http.dart' as http;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:image_cropper/image_cropper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../model/GetProductName.dart';

class PhisycalBusinessDirectory extends StatefulWidget {
  const PhisycalBusinessDirectory({super.key});

  @override
  State<PhisycalBusinessDirectory> createState() =>
      _PhisycalBusinessDirectoryState();
}

class _PhisycalBusinessDirectoryState extends State<PhisycalBusinessDirectory> {
  String screen_id = "0";

  final TextEditingController _bussname = TextEditingController();
  final TextEditingController _partner1Username = TextEditingController();
  final TextEditingController _partner2Username = TextEditingController();

  final TextEditingController _partner1mobile = TextEditingController();
  final TextEditingController _partner2mobile = TextEditingController();

  final TextEditingController _business1mobile = TextEditingController();
  final TextEditingController _business2mobile = TextEditingController();

  final TextEditingController _business1email = TextEditingController();

  final TextEditingController _partner1email = TextEditingController();
  final TextEditingController _partner2email = TextEditingController();

  final TextEditingController _loc = TextEditingController();
  final TextEditingController _gstno = TextEditingController();
  final TextEditingController _website = TextEditingController();
  final TextEditingController _aboutbuess = TextEditingController();
  final TextEditingController _userbussnature = TextEditingController();
  final TextEditingController _usercorebusiness = TextEditingController();
  final TextEditingController _designation = TextEditingController();
  final TextEditingController _designationpartner2 = TextEditingController();

  int selectedPartner = 1;
  String? _selectedEmail = "partner";
  Country? _selectedCountry;
  Country? _selectedCountryPartner2;
  Country? _selectedCountryPartner1Business;
  Country? _selectedCountryPartner2Business;

  String? country_code;
  String? country_code_partner_2;
  String? country_code_partner_1_Business;
  String? country_code_partner_2_Business;

  Color _color1 = Colors.black26; //name
  Color _color2 = Colors.black26;
  Color _color3 = Colors.black26;
  Color _color4 = Colors.black26;
  Color _color5 = Colors.black26;
  Color _color6 = Colors.black26;
  Color _color7 = Colors.black26;
  Color _color8 = Colors.black26;
  Color _color9 = Colors.black26;
  Color _color10 = Colors.black26;
  Color _color11 = Colors.black26;
  Color _color12 = Colors.black26;
  Color _color13 = Colors.black26;
  Color _color14 = Colors.black26;
  Color _color15 = Colors.black26;
  // ignore: unused_field
  Color _color16 = Colors.black26;
  Color _color17 = Colors.black26;
  Color _color19 = Colors.black26;

  String crown_color = '';
  String plan_name = '';

  int? gst_verification_status;

  File? _imagefiles;
  io.File? file, file1, file2;
  final ImagePicker _picker = ImagePicker();

  late double lat = 0.0;
  late double log = 0.0;
  String state = '', city = '', country = '';
  CameraPosition? cameraPosition;
  LatLng startLocation = const LatLng(0, 0);
  String location = "Search Location";
  String defaultCountryCode = 'IN';
  String buss_type = "";
  BuildContext? dialogContext;
  bool _isloading1 = false;

  bool isLoading = true;
  Designation? selectedDesignation;
  Designation? selectedDesignationpartner2;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _initializeGoogleApiKey();

    super.initState();
    constanst.Bussiness_nature_name = "";
    _isloading1 = false;
    initCountryPartner1();
    initCountryBusinessPartner1();
    initCountryBusinessPartner2();
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

  void _onPressedShow1country() async {
    final countrypartner2 = await showCountryPickerSheet(
      context,
      cornerRadius: BorderSide.strokeAlignInside,
    );
    if (countrypartner2 != null) {
      setState(() {
        _selectedCountryPartner2 = countrypartner2;
        country_code_partner_2 = countrypartner2.callingCode.toString();
      });
    }
  }

  void _onPressedShowBusiness1country() async {
    final countrybusinesspartner1 = await showCountryPickerSheet(
      context,
      cornerRadius: BorderSide.strokeAlignInside,
    );
    if (countrybusinesspartner1 != null) {
      setState(() {
        _selectedCountryPartner1Business = countrybusinesspartner1;
        country_code_partner_1_Business =
            countrybusinesspartner1.callingCode.toString();
      });
    }
  }

  void _onPressedShowBusiness2country() async {
    final countrybusinesspartner2 = await showCountryPickerSheet(
      context,
      cornerRadius: BorderSide.strokeAlignInside,
    );
    if (countrybusinesspartner2 != null) {
      setState(() {
        _selectedCountryPartner2Business = countrybusinesspartner2;
        country_code_partner_2_Business =
            countrybusinesspartner2.callingCode.toString();
      });
    }
  }

  Future<void> checkNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      initCountry();
      get_data();
      get_product_name();
      getProfiless();
    }
  }

  void initCountry() async {
    final country = await getCountryByCountryCode(context, defaultCountryCode);
    setState(() {
      _selectedCountry = country;
    });
  }

  void initCountryPartner1() async {
    print('Country test: $defaultCountryCode');
    final countrypartner2 =
        await getCountryByCountryCode(context, defaultCountryCode);

    setState(() {
      _selectedCountryPartner2 = countrypartner2;
    });
  }

  void initCountryBusinessPartner1() async {
    print('Country Business_partner_1: $defaultCountryCode');
    final countrybusinesspartner1 =
        await getCountryByCountryCode(context, defaultCountryCode);
    setState(() {
      _selectedCountryPartner1Business = countrybusinesspartner1;
    });
  }

  void initCountryBusinessPartner2() async {
    print('Country Business_partner_2: $defaultCountryCode');

    final countrybusinesspartner2 =
        await getCountryByCountryCode(context, defaultCountryCode);
    setState(() {
      _selectedCountryPartner2Business = countrybusinesspartner2;
    });
  }

  List<String> _selectedProducts = [];
  List<String> _suggestions = [];
  String title = 'PhysicalBusinessDirectory';
  List<String> selectedCoreBusinessIds = [];
  List<String> selectedCoreBusinessNames = [];

  Future get_product_name() async {
    GetProductName getdir = GetProductName();
    var res = await get_productname();
    getdir = GetProductName.fromJson(res);
    List<pnm.Result>? results = getdir.result;

    if (results != null) {
      _suggestions = [];
      _suggestions = results.map((result) => result.productName ?? "").toList();
      return _suggestions;
    } else {
      return [];
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
    constanst.core_business.clear();
    constanst.designation.clear();

    constanst.selectbusstype_id.clear();
    constanst.selectcore_id.clear();
    constanst.selectdesignation_id.clear();

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
    final country2 = _selectedCountryPartner2;
    final country3 = _selectedCountryPartner1Business;
    final country4 = _selectedCountryPartner2Business;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text('Physical Business Directory',
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
        actions: [
          GestureDetector(
              onTap: () {
                showTutorial_Video(
                  context,
                  title,
                  screen_id,
                );
              },
              child: SizedBox(
                  width: 40,
                  child: Image.asset(
                    'assets/Play.png',
                  ))),
          const SizedBox(
            width: 10,
          )
        ],
      ),
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
                  Column(
                    children: [
                      imageprofile(context),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 3.0),
                        child: CustomTextField(
                          controller: _bussname,
                          labelText: "Company Name *",
                          readOnly: gst_verification_status == 1,

                          borderColor:
                              _color1, // Customize the border color here
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r"[a-zA-Z\s]+")), // Allow only alphabets and spaces
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
                            final capitalizedValue =
                                value.split(' ').map((word) {
                              if (word.isNotEmpty) {
                                return word[0].toUpperCase() +
                                    word.substring(1).toLowerCase();
                              }
                              return word;
                            }).join(' ');

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
                              showCustomToast('Please Enter Company Name');
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
                            readOnly: true,
                            suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                            borderColor: _color2,
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

                            if (connectivityResult == ConnectivityResult.none) {
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
                          readOnly: true,
                          borderColor: _color5,
                          inputFormatters: [],
                          validator: (value) {
                            if (value!.isEmpty) {
                              _color5 = AppColors.red;
                            } else {}
                            return null;
                          },
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
                                apiHeaders:
                                    await GoogleApiHeaders().getHeaders(),
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
                          onChanged: (String) {},
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                        child: CustomTextField(
                          controller: _gstno,
                          readOnly: gst_verification_status == 1,
                          labelText: "GST/Tax/VAT Number",
                          borderColor: _color3,
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
                          onChanged: (value) {
                            if (value.isEmpty) {
                              if (value.isEmpty) {
                                setState(() {
                                  _color3 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color3 = AppColors.greenWithShade;
                                });
                              }
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: 1,
                              groupValue: selectedPartner,
                              onChanged: (int? value) {
                                setState(() {
                                  selectedPartner = value!;
                                });
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPartner = 1;
                                });
                              },
                              child: Text("Partner 1"),
                            ),
                            Radio<int>(
                              value: 2,
                              groupValue: selectedPartner,
                              onChanged: (int? value) {
                                setState(() {
                                  selectedPartner = value!;
                                });
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPartner = 2;
                                });
                              },
                              child: Text("Partner 2"),
                            ),
                          ],
                        ),
                      ),
                      if (selectedPartner == 1) ...[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _partner1Username,
                            labelText: "Your Name *",
                            borderColor: _color10,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(
                                  r"[a-zA-Z\s]+")), // Allow only alphabets and spaces
                              LengthLimitingTextInputFormatter(50),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                _color10 = AppColors.red;
                              } else {
                                _color10 = AppColors.greenWithShade;
                              }
                              return null;
                            },
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
                                _partner1Username.value = TextEditingValue(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(
                                      offset: capitalizedValue.length),
                                );
                              }
                              if (value.isEmpty) {
                                if (value.isEmpty) {
                                  showCustomToast(
                                      'Please Enter Bussiness Name');
                                  setState(() {
                                    _color10 = AppColors.red;
                                  });
                                } else {
                                  setState(() {
                                    _color10 = AppColors.greenWithShade;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _designation,
                            labelText: "Select Designation *",
                            readOnly: true,
                            suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                            borderColor: _color16,
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
                                showDesignation(context);
                              }
                            },
                            onChanged: (value) {
                              if (value.isEmpty) {
                                showCustomToast('Please Select Designation');
                                setState(() {
                                  _color16 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color16 = AppColors.greenWithShade;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                showCustomToast('Please Select Designation');
                                setState(() {
                                  _color16 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color16 = AppColors.greenWithShade;
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
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        )),
                                  ],
                                )),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 0.0, right: 25, bottom: 5.0),
                                child: CustomTextField(
                                  controller: _partner1mobile,
                                  labelText: "Mobile Number",
                                  readOnly: true,
                                  borderColor: _color8,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(11),
                                  ],
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
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                                height: 55,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white),
                                margin: const EdgeInsets.fromLTRB(
                                    28.0, 5.0, 5.0, 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                            _onPressedShowBusiness1country();
                                          },
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Image.asset(
                                                country3!.flag,
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
                                                country_code_partner_1_Business ??
                                                    country3.callingCode,
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
                                  controller: _business1mobile,
                                  keyboardType: TextInputType.phone,
                                  labelText: "Business Mobile Number",
                                  borderColor: _color14,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        _color14 = Colors.black26;
                                      });
                                    } else {
                                      setState(() {
                                        _color14 = AppColors.greenWithShade;
                                      });
                                    }
                                  },
                                  onFieldSubmitted: (value) {
                                    var numValue = value.length;
                                    if (numValue >= 6 && numValue < 12) {
                                      _color14 = AppColors.greenWithShade;
                                    } else {
                                      _color14 = AppColors.red;
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
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _partner1email,
                            keyboardType: TextInputType.emailAddress,
                            labelText: "Email Id",
                            readOnly: true,
                            borderColor: _color4,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            suffixIcon: Radio<String>(
                              value: "partner",
                              groupValue: _selectedEmail,
                              onChanged: (value) {
                                // Validation after selecting the radio button
                                if (_partner1email.text.isEmpty) {
                                  showCustomToast('Please Fill Partner Email');
                                  print("Error: Partner1 Email is empty.");
                                  setState(() {
                                    _color4 =
                                        AppColors.red; // Set red color if empty
                                  });
                                } else {
                                  setState(() {
                                    _selectedEmail = value;
                                    _color4 = AppColors
                                        .greenWithShade; // Set green if valid
                                  });
                                  showCustomToast(
                                      'Only the selected email will be displayed in the directory');
                                  print("Partner Email is Valid.");
                                }
                              },
                            ),
                            onChanged: (value) {
                              setState(() {
                                _color4 = value.isEmpty
                                    ? Colors.black26
                                    : AppColors.greenWithShade;
                              });
                              if (value.isNotEmpty) {
                                showCustomToast(
                                    'Only the selected email will be displayed in the directory');
                              }
                            },
                            onFieldSubmitted: (value) {
                              setState(() {
                                if (!EmailValidator.validate(value)) {
                                  _color4 = AppColors.red;
                                  showCustomToast('Please enter a valid email');
                                } else {
                                  _color4 = value.isNotEmpty
                                      ? AppColors.greenWithShade
                                      : Colors.black26;
                                }
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _business1email,
                            labelText: "Business Email",
                            borderColor: _color17,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            suffixIcon: Radio<String>(
                              value: "business",
                              groupValue: _selectedEmail,
                              onChanged: (value) {
                                // Validation after selecting the radio button
                                if (_business1email.text.isEmpty) {
                                  showCustomToast('Please Fill Business Email');
                                  print("Error: Business Email is empty.");
                                  setState(() {
                                    _color17 =
                                        AppColors.red; // Set red color if empty
                                  });
                                } else {
                                  setState(() {
                                    _selectedEmail = value;
                                    _color17 = AppColors
                                        .greenWithShade; // Set green if valid
                                  });
                                  showCustomToast(
                                      'Only the selected email will be displayed in the directory');
                                  print("Business Email is Valid.");
                                }
                              },
                            ),
                            onChanged: (value) {
                              setState(() {
                                _color17 = value.isEmpty
                                    ? Colors.black26
                                    : AppColors.greenWithShade;
                              });
                              if (value.isNotEmpty) {
                                showCustomToast(
                                    'Only the selected email will be displayed in the directory');
                              }
                            },
                            onFieldSubmitted: (value) {
                              setState(() {
                                if (!EmailValidator.validate(value)) {
                                  _color17 = AppColors.red;
                                  showCustomToast('Please enter a valid email');
                                } else {
                                  _color17 = value.isNotEmpty
                                      ? AppColors.greenWithShade
                                      : Colors.black26;
                                }
                              });
                            },
                          ),
                        ),
                      ] else if (selectedPartner == 2) ...[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _partner2Username,
                            labelText: "Partner 2 Name *",
                            borderColor:
                                _color11, // Customize the border color here
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(
                                  r"[a-zA-Z\s]+")), // Allow only alphabets and spaces
                              LengthLimitingTextInputFormatter(50),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                _color11 = AppColors.red;
                              } else {
                                _color11 = AppColors.greenWithShade;
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
                                _partner2Username.value = TextEditingValue(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(
                                      offset: capitalizedValue.length),
                                );
                              }
                              if (value.isEmpty) {
                                showCustomToast('Please Add Your Company Name');
                                setState(() {
                                  _color11 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color11 = AppColors.greenWithShade;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                showCustomToast('Please Enter Bussiness Name');
                                setState(() {
                                  _color11 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color11 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _designationpartner2,
                            labelText: "Select Designation *",
                            readOnly: true,
                            suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                            borderColor: _color19,
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
                                showDesignationpartner2(context);
                              }
                            },
                            onChanged: (value) {
                              if (value.isEmpty) {
                                showCustomToast('Please Select Designation');
                                setState(() {
                                  _color19 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color19 = AppColors.greenWithShade;
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                showCustomToast('Please Select Designation');
                                setState(() {
                                  _color19 = AppColors.red;
                                });
                              } else {
                                setState(() {
                                  _color19 = AppColors.greenWithShade;
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
                                            _onPressedShow1country();
                                          },
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Image.asset(
                                                country2!.flag,
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
                                                country_code_partner_2 ??
                                                    country2.callingCode,
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
                                  controller: _partner2mobile,
                                  labelText: "Partner 2 Mobile Number",
                                  keyboardType: TextInputType.phone,
                                  borderColor: _color12,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      _color12 = AppColors.red;
                                    } else {
                                      _color12 = AppColors.greenWithShade;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        _color12 = Colors.black26;
                                      });
                                    } else {
                                      setState(() {
                                        _color12 = AppColors.greenWithShade;
                                      });
                                    }
                                  },
                                  onFieldSubmitted: (value) {
                                    var numValue = value.length;
                                    if (numValue >= 6 && numValue < 12) {
                                      _color12 = AppColors.greenWithShade;
                                    } else {
                                      _color12 = AppColors.red;
                                      showCustomToast(
                                          'Please Enter Correct Number');
                                    }
                                  },
                                ),
                              ),
                            )
                          ],
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
                                            _onPressedShowBusiness2country();
                                          },
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Image.asset(
                                                country4!.flag,
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
                                                country_code_partner_2_Business ??
                                                    country4.callingCode,
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
                                  controller: _business2mobile,
                                  labelText: "Partner 2 Other Mobile Number",
                                  keyboardType: TextInputType.phone,
                                  borderColor: _color15,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      _color15 = AppColors.red;
                                    } else {
                                      _color15 = AppColors.greenWithShade;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        _color15 = Colors.black26;
                                      });
                                    } else {
                                      setState(() {
                                        _color15 = AppColors.greenWithShade;
                                      });
                                    }
                                  },
                                  onFieldSubmitted: (value) {
                                    var numValue = value.length;
                                    if (numValue >= 6 && numValue < 12) {
                                      _color15 = AppColors.greenWithShade;
                                    } else {
                                      _color15 = AppColors.red;
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
                              const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                          child: CustomTextField(
                            controller: _partner2email,
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
                            labelText: "Partner 2 EmailId",
                            borderColor: _color13,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _color13 = Colors.black26;
                                });
                              } else if (EmailValidator.validate(value)) {
                                setState(() {
                                  _color13 = AppColors.greenWithShade;
                                });
                              } else {
                                setState(() {
                                  _color13 = AppColors.red;
                                  showCustomToast('Please enter a valid email');
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _color13 = Colors.black26;
                                });
                                showCustomToast(
                                    'Please enter an email address');
                              } else if (!EmailValidator.validate(value)) {
                                setState(() {
                                  _color13 = AppColors.red;
                                });
                                showCustomToast('Please enter a valid email');
                              } else {
                                setState(() {
                                  _color13 = AppColors.greenWithShade;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                        child: CustomTextField(
                          controller: _website,
                          keyboardType: TextInputType.text,
                          labelText: "Website",
                          borderColor: _color6,
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
                            const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
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
                              minLines: 4,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: _aboutbuess,
                              readOnly: true,
                              style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily:
                                      'assets/fonst/Metropolis-Black.otf'),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  WidgetsBinding
                                      .instance.focusManager.primaryFocus
                                      ?.unfocus();
                                  showCustomToast(
                                      'Please Add Your Product Name');
                                  _color7 = AppColors.red;
                                } else {}
                              },
                              onFieldSubmitted: (value) {
                                if (value.isEmpty) {
                                  _color7 = AppColors.red;
                                  setState(() {});
                                } else if (value.isNotEmpty) {
                                  _color7 = AppColors.greenWithShade;
                                  setState(() {});
                                }
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                labelText: "Product Name *",
                                labelStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              onTap: () async {
                                _openBottomSheet();
                                await Future.delayed(
                                    Duration(milliseconds: 50));
                                await get_product_name();
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(50.0),
                          color: AppColors.primaryColor,
                        ),
                        child: TextButton(
                          onPressed: _isloading1
                              ? null
                              : () async {
                                  setState(() {
                                    _isloading1 = true;
                                  });

                                  final connectivityResult =
                                      await Connectivity().checkConnectivity();
                                  if (connectivityResult ==
                                      ConnectivityResult.none) {
                                    showCustomToast(
                                        'Net Connection not available');
                                    setState(() {
                                      _isloading1 = false;
                                    });
                                  } else {
                                    bool result = await add_businessdirectory();
                                    setState(() {
                                      _isloading1 = result;
                                    });
                                  }
                                },
                          child: _isloading1
                              ? CustomDotLoader(
                                  child: Lottie.asset(
                                    'assets/Dot_Lottie.json',
                                  ),
                                )
                              : const Text(
                                  'View Listing',
                                  style: TextStyle(
                                    fontSize: 19.0,
                                    color: Colors.white,
                                    fontFamily:
                                        'assets/fonst/Metropolis-Black.otf',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      10.sbh,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _profileImageUrl;

  Widget imageprofile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => bottomsheet(),
        );
      },
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              key: _imagefiles != null ? ValueKey(_imagefiles!.path) : null,
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 238, 238),
                image: _imagefiles != null
                    ? DecorationImage(
                        image: FileImage(_imagefiles!),
                        fit: BoxFit.fill,
                      )
                    : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_profileImageUrl!),
                            fit: BoxFit.fill,
                          )
                        : null),
              ),
              child: (_imagefiles == null &&
                      (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -6),
                          child: Text(
                            'Logo',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 3.0,
            right: 22.0,
            child: SizedBox(
              width: 40,
              height: 33,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => bottomsheet(),
                  );
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
    );
  }

  List<String> _getFilteredSuggestions(String query) {
    List<String> matches = [];
    matches.addAll(_suggestions);

    matches.retainWhere(
        (suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()));

    matches.sort((a, b) {
      if (a.toLowerCase().startsWith(query.toLowerCase())) {
        return -1;
      } else if (b.toLowerCase().startsWith(query.toLowerCase())) {
        return 1;
      }
      return a.compareTo(b);
    });

    return matches;
  }

  // Open BottomSheet for product selection
  Future<void> _openBottomSheet() async {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setStateModal) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          'Select Products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),
                    SizedBox(height: 10),

                    TextField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          40,
                        ),
                      ],
                      controller: _searchController,
                      onChanged: (text) {
                        _searchController.value = TextEditingValue(
                          text: text.toUpperCase(),
                          selection:
                              TextSelection.collapsed(offset: text.length),
                        );
                        if (text.isEmpty) {
                          FocusScope.of(context).unfocus();
                        }
                        setStateModal(() {});
                      },
                      decoration: InputDecoration(
                        hintText: "Search Products",
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setStateModal(() {
                                    if (!_selectedProducts.contains(
                                        _searchController.text.trim())) {
                                      _selectedProducts
                                          .add(_searchController.text.trim());
                                    }
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                    10.sbh,

                    // Display selected products as chips
                    if (_selectedProducts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Wrap(
                          spacing: 8.0,
                          children: _selectedProducts.map((product) {
                            return Chip(
                              label: Text(
                                product,
                                style: TextStyle(color: Colors.white),
                              ),
                              deleteIcon: Icon(
                                Icons.clear,
                                size: 16,
                                color: Colors.white,
                              ),
                              onDeleted: () {
                                setStateModal(() {
                                  _selectedProducts.remove(product);
                                });
                              },
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Set corner radius to 10
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            _getFilteredSuggestions(_searchController.text)
                                .length,
                        itemBuilder: (context, index) {
                          String product = _getFilteredSuggestions(
                              _searchController.text)[index];
                          bool isSelected = _selectedProducts.contains(product);
                          return InkWell(
                            onTap: () {
                              setStateModal(() {
                                if (isSelected) {
                                  _selectedProducts.remove(product);
                                } else {
                                  _selectedProducts.add(product);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (isSelected) Icon(Icons.check, size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Center(
                        child: ElevatedButton(
                      onPressed: () {
                        if (_selectedProducts.isEmpty) {
                          showCustomToast(
                              "Please select at least one product.");
                        } else {
                          _aboutbuess.text = _selectedProducts.join(", ");
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        "Update Selected Products",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    )),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                    takePhoto(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera, color: AppColors.primaryColor),
                  label: const Text(
                    'Camera',
                    style: TextStyle(color: AppColors.primaryColor),
                  )),
              TextButton.icon(
                  onPressed: () {
                    takePhoto(ImageSource.gallery);
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

  Future<void> takePhoto(ImageSource imageSource) async {
    try {
      final pickedFile =
          await _picker.pickImage(source: imageSource, imageQuality: 100);
      if (pickedFile == null) {
        Fluttertoast.showToast(msg: "Please select an image.");
        return;
      }

      io.File imageFile = io.File(pickedFile.path);

      int fileSizeInBytes = imageFile.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024;
      print("Original image size: $fileSizeInKB KB");

      if (fileSizeInKB >= 5000) {
        Fluttertoast.showToast(msg: "Please select an image below 5 MB.");
        Navigator.pop(context);
        return;
      }

      io.File? processedFile = imageFile;

      processedFile = await _cropImage(processedFile);
      if (processedFile == null) {
        Fluttertoast.showToast(msg: "Failed to crop image.");
        print("Cropping failed or was canceled.");
        return;
      }

      double processedFileSizeInKB = processedFile.lengthSync() / 1024;
      print("Processed image size: $processedFileSizeInKB KB");

      setState(() {
        if (_imagefiles != null) {
          FileImage(_imagefiles!).evict();
        }
        _imagefiles = processedFile;
      });

      print("Image successfully processed.");
      Navigator.pop(context);
    } catch (e) {
      print("Error during photo processing: $e");
      Fluttertoast.showToast(msg: "An error occurred. Please try again.");
    }
  }

  Future<io.File?> _cropImage(io.File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile == null) {
        print("Cropping canceled by user.");
        return null;
      }

      print("Cropped file path: ${croppedFile.path}");
      return io.File(croppedFile.path);
    } catch (e) {
      print("Error during cropping: $e");
      return null;
    }
  }

  Future<bool> add_businessdirectory() async {
    FocusScope.of(context).unfocus();
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Validate required fields and print errors
    if (pref.getString('user_id') == null ||
        pref.getString('user_id')!.isEmpty) {
      print("Error: User ID is null or empty.");
      return false;
    }

    if (pref.getString('userToken') == null ||
        pref.getString('userToken')!.isEmpty) {
      print("Error: User Token is null or empty.");
      return false;
    }

    if (_bussname.text.isEmpty) {
      showCustomToast('Please Select Company Name');
      print("Error: Company Name is empty.");
      setState(() {
        _color1 = AppColors.red;
      });
      return false;
    } else {
      setState(() {
        _color1 = AppColors.greenWithShade;
      });
      print('Company Name is Valid');
    }

    if (constanst.selectbusstype_id.isEmpty) {
      print("Error: Business Type is empty.");
      showCustomToast('Please Select Nature Of Business');
      setState(() {
        _color2 = AppColors.red;
      });
      return false;
    } else {
      setState(() {
        _color2 = AppColors.greenWithShade;
      });
      print("Business Type is valid.");
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
      print("Error: Location is empty.");
      showCustomToast('Please Select Location');
      setState(() {
        _color5 = AppColors.red;
      });
      return false;
    } else {
      setState(() {
        _color5 = AppColors.greenWithShade;
      });
      print("Location is Valid");
    }

    if (_partner1Username.text.isEmpty) {
      showCustomToast('Please Fill Partner Name');
      setState(() {
        _color10 = AppColors.red;
      });
      return false;
    } else {
      setState(() {
        _color10 = AppColors.greenWithShade;
      });
      print("Partner Name 1 is Valid.");
    }

    if (_designation.text.isEmpty) {
      print("Error: Designation is empty.");
      showCustomToast('Please Select Designation');
      setState(() {
        _color16 = AppColors.red;
      });
      return false;
    } else {
      setState(() {
        _color16 = AppColors.greenWithShade;
      });
      print("Designation is valid.");
    }

    if (_partner1mobile.text.isEmpty) {
      showCustomToast('Please Fill Partner Mobile');
      print("Error: Partner1 Mobile is empty.");
      setState(() {
        _color8 = AppColors.red;
      });
      return false;
    } else {
      setState(() {
        _color8 = AppColors.greenWithShade;
      });
      print("Partner Mobile 1 is Valid.");
    }

    // Partner Email Validation
    if (_selectedEmail == null || _selectedEmail == '') {
      if (_partner1email.text.isNotEmpty) {
        setState(() {
          _color4 = AppColors.greenWithShade;
        });
        print("Partner Email is Valid.");
      }
    } else {
      if (_partner1email.text.isEmpty) {
        showCustomToast('Please Fill Partner Email');
        print("Error: Partner1 Email is empty.");
        setState(() {
          _color4 = AppColors.red;
        });
        return false;
      } else {
        setState(() {
          _color4 = AppColors.greenWithShade;
        });
        print("Partner Email is Valid.");
      }
    }

    if (_selectedEmail == "partner") {
      if (_business1email.text.isNotEmpty) {
        setState(() {
          _color17 = AppColors.greenWithShade;
        });
        print("Business Email is Valid.");
      }
    } else {
      if (_business1email.text.isEmpty) {
        showCustomToast('Please Fill Business Email');
        print("Error: Business Email is empty.");
        setState(() {
          _color17 = AppColors.red;
        });
        return false;
      } else {
        setState(() {
          _color17 = AppColors.greenWithShade;
        });
        showCustomToast(
            'Only the selected email will be displayed in the directory');
        print("Business Email is Valid.");
      }
    }

    if (_partner2email.text.isNotEmpty) {
      // Regular expression for validating email
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

      if (!emailRegex.hasMatch(_partner2email.text)) {
        showCustomToast('Invalid Business Email');
        print("Error: Invalid Business Email.");
        setState(() {
          _color13 = AppColors.red;
        });
        return false;
      } else {
        setState(() {
          _color13 = AppColors.greenWithShade;
        });
        print("Business Email is Valid.");
      }
    }

    if (_aboutbuess.text.isEmpty) {
      showCustomToast("Please add your product");
      setState(() {
        _color7 = AppColors.red;
      });
      return false;
    } else {
      setState(() {
        _color7 = AppColors.greenWithShade;
      });
      print("Partner Email is Valid.");
    }

    var request = AddBusinessDirectory(
      userId: pref.getString('user_id') ?? "",
      userToken: pref.getString('userToken') ?? "",
      corebusiness: selectedCoreBusinessIds.join(","),
      location: _loc.text.isNotEmpty ? _loc.text : "",
      city: city.isNotEmpty ? city : "",
      state: state.isNotEmpty ? state : "",
      country: country.isNotEmpty ? country : "",

      p1countryCode: country_code ?? '',
      p2countryCode: (country_code_partner_2?.isEmpty ?? true)
          ? '+91'
          : country_code_partner_2,
      p1businesscountryCode: (country_code_partner_1_Business?.isEmpty ?? true)
          ? '+91'
          : country_code_partner_1_Business,
      p2businesscountryCode: (country_code_partner_2_Business?.isEmpty ?? true)
          ? '+91'
          : country_code_partner_2_Business,

      partnername1: (selectedPartner == 1 || selectedPartner == 2)
          ? (_partner1Username.text.isNotEmpty ? _partner1Username.text : "")
          : "",

      designation: (selectedPartner == 1 || selectedPartner == 2)
          ? constanst.selectdesignation_id.isNotEmpty
              ? constanst.selectdesignation_id.join(",")
              : ""
          : "",

      partner1mobile: (selectedPartner == 1 || selectedPartner == 2)
          ? (_partner1mobile.text.isNotEmpty ? _partner1mobile.text : "")
          : "",
      partner1businessmobile: (selectedPartner == 1 || selectedPartner == 2)
          ? (_business1mobile.text.isNotEmpty ? _business1mobile.text : "")
          : "",
      partner1email: (selectedPartner == 1 || selectedPartner == 2)
          ? (_selectedEmail == "partner"
              ? (_partner1email.text.isNotEmpty ? _partner1email.text : "")
              : (_business1email.text.isNotEmpty ? _business1email.text : ""))
          : "",

      business1email: (selectedPartner == 1 || selectedPartner == 2)
          ? (_selectedEmail == "partner" || _selectedEmail == "business")
              ? (_business1email.text.isNotEmpty ? _business1email.text : "")
              : ""
          : "",

// Only fill in Partner 2 fields if selectedPartner is 2 or both are selected
      partnername2: (selectedPartner == 2 || selectedPartner == 1)
          ? (_partner2Username.text.isNotEmpty ? _partner2Username.text : "")
          : "",

      designation1: (selectedPartner == 2 || selectedPartner == 1)
          ? constanst.selectdesignatiopartner2_id.isNotEmpty
              ? constanst.selectdesignatiopartner2_id.join(",")
              : ""
          : "",
      partner2mobile: (selectedPartner == 2 || selectedPartner == 1)
          ? (_partner2mobile.text.isNotEmpty ? _partner2mobile.text : "")
          : "",
      partner2businessmobile: (selectedPartner == 2 || selectedPartner == 1)
          ? (_business2mobile.text.isNotEmpty ? _business2mobile.text : "")
          : "",
      partner2email: (selectedPartner == 2 || selectedPartner == 1)
          ? (_partner2email.text.isNotEmpty ? _partner2email.text : "")
          : "",

      gstTaxVat: _gstno.text.isNotEmpty ? _gstno.text : "",
      website: _website.text.isNotEmpty ? _website.text : "",
      businessType: constanst.selectbusstype_id.join(","),
      view_in_directory: '0',
      businessName: _bussname.text.isNotEmpty ? _bussname.text : "",
      latitude: lat.toString(),
      longitude: log.toString(),
      directory_post: _aboutbuess.text,
    );

    print("Request Data: ${request.toJson()}");

    try {
      var res = await addBusinessDirectory(
        add_business_directory: request,
        file: _imagefiles ??
            (_profileImageUrl != null && _profileImageUrl!.startsWith('http')
                ? await downloadImageAsFile(_profileImageUrl!)
                : null),
      );

      print("Image Files: $file");
      print("addBusinessDirectory Response: $res");

      if (res != null && res['status'] == 1) {
        _profileImageUrl =
            res['profile']?['business_logo_url'] ?? _profileImageUrl;

        showCustomToast(res['message']);
        print("Success: ${res['message']}");

        constanst.isprofile = false;
        constanst.image_url = _profileImageUrl ?? "";
        _isloading1 = true;

        Map<String, dynamic> businessData = {
          'userId': pref.getString('user_id'),
          'userToken': pref.getString('userToken'),
          'business_name': _bussname.text,
          'business_type': constanst.lstBussiness_nature.join(","),
          'core_businesses': selectedCoreBusinessNames.join(","),
          'address': _loc.text,
          'partner1_name': _partner1Username.text,
          'partner2_name': _partner2Username.text,
          'partner1_email': _selectedEmail == "partner"
              ? (_partner1email.text.isNotEmpty ? _partner1email.text : "")
              : "",
          'partner2_email': _partner2email.text,
          'partner1_business_email': _selectedEmail == "business"
              ? (_business1email.text.isNotEmpty ? _business1email.text : "")
              : "",
          'partner1_mobilenumber': _partner1mobile.text,
          'partner1_mobilenumber_country_code': country_code,
          'partner2_mobilenumber': _partner2mobile.text,
          'partner2_mobilenumber_country_code': country_code_partner_2,
          'partner1_business_mobile': _business1mobile.text,
          'partner1_business_mobile_country_code':
              country_code_partner_1_Business,
          'partner2_business_mobile': _business2mobile.text,
          'partner2_business_mobile_country_code':
              country_code_partner_2_Business,
          'website': _website.text,
          'partner1_designation': constanst.designation.isNotEmpty
              ? constanst.designation.join(",")
              : "",
          'partner2_designation': constanst.designationpartner2.isNotEmpty
              ? constanst.designationpartner2.join(",")
              : "",
          'gst_tax_vat': _gstno.text,
          'state': state,
          'city': city,
          'country': country,
          'latitude': lat.toString(),
          'longitude': log.toString(),
          'products': _aboutbuess.text,
        };

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BusinessDetailsDialog(
              businessData: businessData,
              imagePath: _imagefiles != null
                  ? _imagefiles!.path
                  : _profileImageUrl?.startsWith('http') ?? false
                      ? _profileImageUrl
                      : null,
              onClose: () {
                Navigator.of(context).pop();
                setState(() {
                  _isloading1 = false;
                });
              },
            );
          },
        );
      } else {
        _isloading1 = false;
        String errorMessage =
            res != null ? res['message'] : "Unknown error occurred.";
        print("Error in addBusinessDirectory: $errorMessage");
        showCustomToast(errorMessage);
      }
    } catch (e) {
      print("Error during addBusinessDirectory call: $e");
      _isloading1 = false;
      showCustomToast("An error occurred while adding business directory.");
    }

    return _isloading1;
  }

  Future<File> downloadImageAsFile(String url) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getTemporaryDirectory();

    final file = File('${documentDirectory.path}/temp_image.jpg');
    file.writeAsBytesSync(response.bodyBytes);

    return file;
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
        _bussname.text = res['profile']['business_name'] ?? "";
        _aboutbuess.text = res['profile']['directory_post'] ?? "";

        if (res['profile']['directory_post'] != null) {
          _selectedProducts = res['profile']['directory_post']
              .toString()
              .split(',')
              .map((item) => item.trim())
              .toList();
        } else {
          _selectedProducts = [];
        }

        _partner1email.text =
            res['profile']['partner1_email'] ?? res['user']['email'] ?? '';
        _partner2email.text = res['profile']['partner2_email'] ?? "";

        _business1email.text = res['profile']['other_email'] ?? "";

        _gstno.text = res['profile']['gst_tax_vat'] ?? "";
        _website.text = res['profile']['website'] ?? "";
        _partner1mobile.text = res['profile']['partner1_mobilenumber'] ??
            res['user']['phoneno'] ??
            "";

        _partner2mobile.text = res['profile']['partner2_mobilenumber'] ?? "";

        _business1mobile.text = res['profile']['business_phone'] ?? '';
        _business2mobile.text =
            res['profile']['partner2_business_mobile'] ?? "";

        _loc.text = res['profile']['address'] ?? "";
        country_code = res['profile']['partner1_mobile_country_code'] ??
            res['user']['countryCode'] ??
            '';
        country_code_partner_2 =
            res['profile']['partner2_mobile_country_code'] ?? "";

        country_code_partner_1_Business = res['profile']['countryCode'] ?? "";
        print(
            'partner1_business_mobile_country_code: ${res['profile']['partner1_business_mobile_country_code']}');
        country_code_partner_2_Business =
            res['profile']['partner2_business_mobile_country_code'] ?? "";
        _partner1Username.text =
            res['profile']['partner1_name'] ?? res['user']['username'];
        _partner2Username.text = res['profile']['partner2_name'] ?? '';

        _profileImageUrl = res['profile']['business_logo_url'] ?? '';
        gst_verification_status = res['profile']['gst_verification_status'];

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

        constanst.selectbusstype_id =
            res['profile']['business_type'].split(',');
        constanst.lstBussiness_nature =
            res['profile']['business_type_name'].split(',');
        _userbussnature.text = constanst.lstBussiness_nature.join(', ');

        constanst.selectdesignation_id =
            res['profile']['partner1_designation'] != null &&
                    res['profile']['partner1_designation'] is String
                ? res['profile']['partner1_designation'].split(',')
                : (res['profile']['partner1_designation']?.toString() ?? '')
                    .split(',');

        constanst.designation = res['profile']['partner1_designation_name'] !=
                    null &&
                res['profile']['partner1_designation_name'] is String
            ? res['profile']['partner1_designation_name'].split(',')
            : (res['profile']['partner1_designation_name']?.toString() ?? '')
                .split(',');

        _designation.text = constanst.designation.join(', ');

        constanst.selectdesignatiopartner2_id =
            res['profile']['partner2_designation'] != null &&
                    res['profile']['partner2_designation'] is String
                ? res['profile']['partner2_designation'].split(',')
                : (res['profile']['partner2_designation']?.toString() ?? '')
                    .split(',');

        constanst.designationpartner2 = res['profile']
                        ['partner2_designation_name'] !=
                    null &&
                res['profile']['partner2_designation_name'] is String
            ? res['profile']['partner2_designation_name'].split(',')
            : (res['profile']['partner2_designation_name']?.toString() ?? '')
                .split(',');

        _designationpartner2.text = constanst.designationpartner2.join(', ');

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
      });
    } else {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      showCustomToast(res['message']);
    }
    return res;
  }

  showDesignation(context) {
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
              return const Designation1();
            })).then(
      (value) {
        setState(() {
          _designation.text = constanst.designation.join(', ');
          _color16 = AppColors.greenWithShade;
        });
      },
    );
  }

  showDesignationpartner2(context) {
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
              return const Designation2();
            })).then(
      (value) {
        setState(() {
          _designationpartner2.text = constanst.designationpartner2.join(', ');
          _color19 = AppColors.greenWithShade;
        });
      },
    );
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
              top: Radius.circular(30.0),
            ),
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
              'Select Nature Of Business',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                fontFamily: 'assets/fonts/Metropolis-Black.otf',
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

class Designation1 extends StatefulWidget {
  const Designation1({Key? key}) : super(key: key);

  @override
  State<Designation1> createState() => _Designation1State();
}

class _Designation1State extends State<Designation1> {
  bool isLoading = true;

  List<Designation> designationList = [];

  @override
  void initState() {
    super.initState();
    fetchDesignation();
  }

  Future<void> fetchDesignation() async {
    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    var res = await getDesignation();
    if (res != null && res.status == 1) {
      setState(() {
        designationList = res.designation;
        isLoading = false;
      });
    } else {
      print('error: ${res?.message}');
      showCustomToast(res?.message ?? 'An error occurred');
      setState(() {
        isLoading = false;
      });
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
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.0),
            ),
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
              'Select Designation',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                fontFamily: 'assets/fonts/Metropolis-Black.otf',
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
      body: Column(
        children: [
          10.sbh,
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shrinkWrap: true,
                itemCount: designationList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final designation = designationList[index];
                  return CommanBottomSheet(
                    onTap: () {
                      setState(() {
                        if (constanst.selectdesignation_id
                            .contains(designation.id.toString())) {
                          constanst.designation
                              .remove(designation.name.toString());
                          constanst.selectdesignation_id
                              .remove(designation.id.toString());
                        } else {
                          constanst.designation.clear();
                          constanst.selectdesignation_id.clear();

                          constanst.designation
                              .add(designation.name.toString());
                          constanst.selectdesignation_id
                              .add(designation.id.toString());
                        }
                      });
                    },
                    checked: constanst.selectdesignation_id
                        .contains(designation.id.toString()),
                    title: designation.name,
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
                if (constanst.designation.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() {});
                } else {
                  showCustomToast('Select Minimum 1 Designation ');
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

class Designation2 extends StatefulWidget {
  const Designation2({Key? key}) : super(key: key);

  @override
  State<Designation2> createState() => _Designation2State();
}

class _Designation2State extends State<Designation2> {
  bool isLoading = true;

  List<Designation> designationList = [];

  @override
  void initState() {
    super.initState();
    fetchDesignation();
  }

  Future<void> fetchDesignation() async {
    String device = Platform.isAndroid ? 'android' : 'ios';
    print('Device Name: $device');

    var res = await getDesignation();
    if (res != null && res.status == 1) {
      setState(() {
        designationList = res.designation;
        isLoading = false;
      });
    } else {
      print('error: ${res?.message}');
      showCustomToast(res?.message ?? 'An error occurred');
      setState(() {
        isLoading = false;
      });
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
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.0),
            ),
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
              'Select Designation',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                fontFamily: 'assets/fonts/Metropolis-Black.otf',
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
      body: Column(
        children: [
          10.sbh,
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shrinkWrap: true,
                itemCount: designationList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final designation = designationList[index];
                  return CommanBottomSheet(
                    onTap: () {
                      setState(() {
                        if (constanst.selectdesignatiopartner2_id
                            .contains(designation.id.toString())) {
                          constanst.designationpartner2
                              .remove(designation.name.toString());
                          constanst.selectdesignatiopartner2_id
                              .remove(designation.id.toString());
                        } else {
                          constanst.designationpartner2.clear();
                          constanst.selectdesignatiopartner2_id.clear();

                          constanst.designationpartner2
                              .add(designation.name.toString());
                          constanst.selectdesignatiopartner2_id
                              .add(designation.id.toString());
                        }
                      });
                    },
                    checked: constanst.selectdesignatiopartner2_id
                        .contains(designation.id.toString()),
                    title: designation.name,
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
                if (constanst.designationpartner2.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() {});
                } else {
                  showCustomToast('Select Minimum 1 Designation ');
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
