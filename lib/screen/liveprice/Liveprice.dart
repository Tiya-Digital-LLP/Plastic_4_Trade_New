// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names, prefer_typing_uninitialized_variables, deprecated_member_use

import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:Plastic4trade/model/GetProductName.dart';
import 'package:Plastic4trade/screen/dynamic_links.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/gtm_utils.dart';
import 'package:Plastic4trade/widget/Tutorial_Videos_dialog.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_live_price_shimmer_loader.dart';
import 'package:Plastic4trade/widget/custom_search_input.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import 'package:Plastic4trade/model/GetPriceList.dart' as price;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../api/api_interface.dart';
import '../../model/DataPoint.dart';
import '../../model/get_graph.dart';
import '../../utill/constant.dart';
import '../../widget/live_priceFilterScreen.dart';
import 'Liveprice_detail.dart';
import 'package:Plastic4trade/model/GetProductName.dart' as pnm;

class LivepriceScreen extends StatefulWidget {
  const LivepriceScreen({Key? key}) : super(key: key);

  @override
  State<LivepriceScreen> createState() => _LivepriceScreenState();
}

class RadioModel {
  bool isSelected;
  final String buttonText;

  RadioModel(this.isSelected, this.buttonText);
}

class _LivepriceScreenState extends State<LivepriceScreen> {
  PackageInfo? packageInfo;
  String? packageName;
  bool isgraph = false;
  final scrollercontroller = ScrollController();
  List<price.Result> price_data = [];
  List<bool> show_graph_data = [];
  bool loadmore = false;
  bool isload = false;
  int offset = 0;
  int count = 0;
  List<DataPoint> data1 = [];
  List<DataPoint> data2 = [];
  List<DataPoint> data3 = [];
  String type_post = "";
  String category_id = '',
      grade_id = '',
      company_id = '',
      state = '',
      country = '';
  int? selectedItemIndex;
  bool isLoading = true;
  List<RadioModel> sampleData1 = <RadioModel>[];
  final TextEditingController _search = TextEditingController();
  GlobalKey previewContainer = GlobalKey();
  String title = 'LivePrice';
  String? dynamikshortLink;
  List<String> _suggestions = [];
  String screen_id = "0";

  @override
  void initState() {
    GtmUtil.logScreenView(
      title,
      'liveprice',
    );
    super.initState();
    scrollercontroller.addListener(_scrollercontroller);
    sampleData1.add(RadioModel(true, 'Month'));
    sampleData1.add(RadioModel(false, 'Year'));
    sampleData1.add(RadioModel(false, 'All'));
    clear();
    checknetowork();
    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo!.packageName;
  }

  Future<void> _captureSocialPng() {
    List<String> imagePaths = [];
    final RenderBox box = context.findRenderObject() as RenderBox;
    return Future.delayed(const Duration(milliseconds: 20), () async {
      if (previewContainer.currentContext != null) {
        RenderRepaintBoundary? boundary = previewContainer.currentContext!
            .findRenderObject() as RenderRepaintBoundary?;
        ui.Image image = await boundary!.toImage();
        final directory = (await getApplicationDocumentsDirectory()).path;
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();
        File imgFile = File('$directory/screenshot.png');
        imagePaths.add(imgFile.path);
        imgFile.writeAsBytes(pngBytes).then((value) async {
          final dynamicLink = await createDynamicLink(
              'https://plastic4trade.com/', 'LivePrice', 'LivePriceShare');
          await Share.shareFiles(imagePaths,
              subject: 'Share',
              text: "Live Price\t\n\n"
                      'Plastic4trade is a B2B Plastic Business App, Buy & Sale your Products, Raw Material, Recycle Plastic Scrap, Plastic Machinery, Polymer Price, News, Update for Manufacturers, Traders, Exporters, Importers...' +
                  "\n" +
                  '\n' +
                  'Download App' +
                  '\n' +
                  dynamicLink,
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
        }).catchError((onError) {
          print(onError);
        });
      } else {
        print("context:- ${previewContainer.currentContext}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          title: const Text('Live Price',
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
                  showTutorial_Video(context, title, screen_id);
                },
                child: SizedBox(
                    width: 40,
                    child: Image.asset(
                      'assets/Play.png',
                    ))),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
                onTap: _captureSocialPng,
                child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset(
                      'assets/share1.png',
                    ))),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: RefreshIndicator(
          backgroundColor: AppColors.primaryColor,
          color: AppColors.backgroundColor,
          onRefresh: () async {
            await get_HomePost();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40.0)),
                        color: Colors.white,
                      ),
                      height: 40,
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: CustomSearchInput(
                          onClear: () {
                            _search.clear();
                            setState(() {});
                            count = 0;
                            offset = 0;
                            price_data.clear();
                            get_HomePost();
                          },
                          controller: _search,
                          onSubmitted: (value) {
                            WidgetsBinding.instance.focusManager.primaryFocus
                                ?.unfocus();
                            price_data.clear();
                            count = 0;
                            offset = 0;
                            get_HomePost();
                            setState(() {});
                          },
                          onChanged: (value) {
                            if (value.isEmpty) {
                              WidgetsBinding.instance.focusManager.primaryFocus
                                  ?.unfocus();
                              _search.clear();
                              count = 0;
                              offset = 0;
                              price_data.clear();
                              get_HomePost();
                              setState(() {});
                            }
                          },
                          suggestionsCallback: (pattern) {
                            return _getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width / 1.5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        suggestion,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                          fontFamily:
                                              'assets/fonst/Metropolis-Black.otf',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          onSuggestionSelected: (suggestion) async {
                            if (suggestion.length > 40) {
                              showCustomToast(
                                  'Product name cannot exceed 40 characters');
                              _search.text =
                                  suggestion.substring(0, 40).toUpperCase();
                            } else {
                              _search.text = suggestion.toUpperCase();
                            }
                            WidgetsBinding.instance.focusManager.primaryFocus
                                ?.unfocus();
                            price_data.clear();
                            count = 0;
                            offset = 0;
                            await get_HomePost();
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    isgraph
                        ? GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 40,
                              width: 40,
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: Image.asset(
                                'assets/list_data.png',
                                width: 20,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 40,
                              width: 40,
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: Image.asset(
                                'assets/diagram.png',
                                width: 20,
                              ),
                            ),
                          ),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        ViewItem(context);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.filter_alt,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RepaintBoundary(
                  key: previewContainer,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Category',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.24,
                                )),
                            Text('Code',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.24,
                                )),
                            Text('Grade',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.24,
                                )),
                            Text('Price',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.24,
                                )),
                            Text('+/-',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.24,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      isLoading
                          ? livePriceWithShimmerLoader(context)
                          : pricelist()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<List<String>> _getSuggestions(String query) async {
    if (query.isEmpty) {
      return Future.value(_suggestions);
    }

    List<String> matches = _suggestions.where((suggestion) {
      return suggestion.toLowerCase().contains(query.toLowerCase());
    }).toList();

    matches.sort((a, b) {
      bool aStartsWithQuery = a.toLowerCase().startsWith(query.toLowerCase());
      bool bStartsWithQuery = b.toLowerCase().startsWith(query.toLowerCase());

      if (aStartsWithQuery && !bStartsWithQuery) return -1;
      if (bStartsWithQuery && !aStartsWithQuery) return 1;

      String aLastWord = a.split(' ').last;
      String bLastWord = b.split(' ').last;

      bool aLastWordStartsWithQuery =
          aLastWord.toLowerCase().startsWith(query.toLowerCase());
      bool bLastWordStartsWithQuery =
          bLastWord.toLowerCase().startsWith(query.toLowerCase());

      if (aLastWordStartsWithQuery && !bLastWordStartsWithQuery) return -1;
      if (bLastWordStartsWithQuery && !aLastWordStartsWithQuery) return 1;

      bool aEndsWithQuery = a.toLowerCase().endsWith(query.toLowerCase());
      bool bEndsWithQuery = b.toLowerCase().endsWith(query.toLowerCase());

      if (aEndsWithQuery && !bEndsWithQuery) return -1;
      if (bEndsWithQuery && !aEndsWithQuery) return 1;

      if (a.length == 1 && b.length > 1) return -1;
      if (b.length == 1 && a.length > 1) return 1;

      return a.compareTo(b);
    });

    return Future.value(matches);
  }

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

  Future<void> showTutorial_Video(
      BuildContext context, String title, String screenId) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Tutorial_Videos_dialog(title, screenId);
      },
    );
  }

  Future<List<LastMonthRecord>> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://www.plastic4trade.com/api/getdatabytimeduration?code_id=34'));
    List<LastMonthRecord> lastMonthRecords = [];
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      get_graph graph = get_graph.fromJson(res);
      if (graph.lastMonthRecord != null) {
        lastMonthRecords = graph.lastMonthRecord!;
      }
      return lastMonthRecords;
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  ViewItem(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        )),
        builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            builder: (BuildContext context, ScrollController scrollController) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return const live_priceFilterScreen();
                },
              );
            })).then(
      (value) {
        category_id = constanst.select_categotyId.join(",");
        company_id = constanst.select_typeId.join(",");
        country = constanst.select_country.join(",");
        state = constanst.select_state.join(",");

        price_data.clear();

        get_HomePost();
        constanst.select_categotyId.clear();
        constanst.select_typeId.clear();
        constanst.select_gradeId.clear();
        constanst.selectbusstype_id.clear();
        constanst.select_categotyType.clear();
        constanst.select_state.clear();
        constanst.select_country.clear();
        constanst.date = "";

        setState(() {});
      },
    );
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      getPackage();
      get_HomePost();
      get_product_name();
    }
  }

  void _scrollercontroller() {
    if (scrollercontroller.position.pixels ==
        scrollercontroller.position.maxScrollExtent) {
      loadmore = false;
      count++;
      if (count == 1) {
        offset = offset + 21;
      } else {
        offset = offset + 20;
      }
      get_HomePost();
    }
  }

  Widget livePriceWithShimmerLoader(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 9,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return LivePriceShimmerLoader(width: 175, height: 80);
      },
    );
  }

  bool allLiveDataToLoad() {
    int itemsPerPage = 20;
    return price_data.length % itemsPerPage == 0;
  }

  Widget pricelist() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 7, right: 7, bottom: 10),
        shrinkWrap: false,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: price_data.isEmpty ? 1 : price_data.length + 1,
        controller: scrollercontroller,
        itemBuilder: (context, index) {
          if (index == price_data.length) {
            if (allLiveDataToLoad() && !price_data.isEmpty) {
              return LivePriceShimmerLoader(
                width: 175,
                height: 80,
              );
            } else {
              return SizedBox();
            }
          } else {
            price.Result result = price_data[index];
            return Column(
              children: [
                Container(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    shadows: [
                      BoxShadow(
                        color: AppColors.boxShadowforshimmer,
                        blurRadius: 16.32,
                        offset: Offset(0, 3.26),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Liveprice_detail(
                            category: result.category.toString(),
                            currency: result.currency.toString(),
                            sign: result.sign.toString(),
                            changed: result.changed.toString(),
                            codeName: result.codeName.toString(),
                            price: result.price.toString(),
                            priceDate: result.priceDate.toString(),
                            company: result.company.toString(),
                            code_id: result.codeId.toString(),
                            grade: result.grade.toString(),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 80, // Adjust the width as needed
                                child: Text(
                                  result.category.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                    letterSpacing: -0.24,
                                    fontFamily: 'Metropolis-Black',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80, // Adjust the width as needed
                                child: Text(
                                  result.codeName.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                    letterSpacing: -0.24,
                                    fontFamily: 'Metropolis-Black',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60, // Adjust the width as needed
                                child: Text(
                                  result.grade.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                    letterSpacing: -0.24,
                                    fontFamily: 'Metropolis-Black',
                                  ),
                                ),
                              ),
                              Text(
                                result.currency.toString() +
                                    double.parse(result.price ?? '0')
                                        .toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                  letterSpacing: -0.24,
                                  fontFamily: 'Metropolis-Black',
                                ),
                              ),
                              Text(
                                (result.sign != null
                                        ? result.sign.toString()
                                        : '') +
                                    result.currency.toString() +
                                    double.parse(result.changed!
                                            .replaceFirst("-", "")
                                            .toString())
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                  letterSpacing: -0.24,
                                  color: result.sign == "+"
                                      ? AppColors.greenWithShade
                                      : result.sign == "-"
                                          ? AppColors.red
                                          : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.grey, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat("dd MMM, yyyy").format(
                                  DateFormat("dd-MM-yyyy")
                                      .parse(result.priceDate.toString()),
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontFamily: 'Metropolis-Black',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                  letterSpacing: -0.24,
                                ),
                              ),
                              Text(
                                '${result.company} - ${result.state}, ${result.country}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontFamily: 'Metropolis',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            );
          }
        },
      ),
    );
  }

  Widget monthgraph(String? category, String? price, String? company,
      String? codeName, String? changed, String? priceDate) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1,
        child: SfCartesianChart(
            tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (dynamic data, dynamic point, dynamic series,
                    int pointIndex, int seriesIndex) {
                  return CustomTooltip(
                    category: category.toString(),
                    price: point.y.toString(),
                    company: company.toString(),
                    codeName: codeName.toString(),
                    changed: changed.toString(),
                    priceDate: priceDate.toString(),
                  );
                }),
            primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelRotation: 45),
            primaryYAxis:
                NumericAxis(majorGridLines: const MajorGridLines(width: 0)),
            title: ChartTitle(text: 'Month data'),
            legend: Legend(isVisible: false),
            series: <AreaSeries<DataPoint, String>>[
              AreaSeries(
                  borderColor: const Color.fromARGB(255, 176, 159, 255),
                  borderWidth: 3,
                  borderDrawMode: BorderDrawMode.top,
                  gradient: LinearGradient(colors: [
                    const Color.fromARGB(255, 176, 159, 255).withOpacity(0.4),
                    const Color.fromARGB(255, 176, 159, 255).withOpacity(0.2),
                    const Color.fromARGB(255, 176, 159, 255).withOpacity(0.1)
                  ], stops: const [
                    0.1,
                    0.3,
                    0.6
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  dataSource: data1,
                  xValueMapper: (DataPoint data, _) => data.price_date,
                  yValueMapper: (DataPoint data, _) =>
                      double.tryParse(data.price))
            ]),
      ),
    );
  }

  Widget yeargraph(String? category, String? price, String? company,
      String? codeName, String? changed, String? priceDate) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1,
        child: SfCartesianChart(
            tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  return CustomTooltip(
                    category: category.toString(),
                    price: price.toString(),
                    company: company.toString(),
                    codeName: codeName.toString(),
                    changed: changed.toString(),
                    priceDate: priceDate.toString(),
                  );
                }),
            primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelRotation: 45),
            primaryYAxis:
                NumericAxis(majorGridLines: const MajorGridLines(width: 0)),
            title: ChartTitle(text: 'year data'),
            legend: Legend(isVisible: false),
            series: <AreaSeries<DataPoint, String>>[
              AreaSeries(
                  borderColor: const Color.fromARGB(255, 176, 159, 255),
                  borderWidth: 3,
                  borderDrawMode: BorderDrawMode.top,
                  gradient: LinearGradient(colors: [
                    const Color.fromARGB(255, 176, 159, 255).withOpacity(0.4),
                    const Color.fromARGB(255, 176, 159, 255).withOpacity(0.2),
                    const Color.fromARGB(255, 176, 159, 255).withOpacity(0.1)
                  ], stops: const [
                    0.1,
                    0.3,
                    0.6
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  dataSource: data2,
                  xValueMapper: (DataPoint data, _) => data.price_date,
                  yValueMapper: (DataPoint data, _) =>
                      double.tryParse(data.price))
            ]),
      ),
    );
  }

  findcartItem(productId) {
    var found = false;
    for (var i = 0; i < price_data.length; i++) {
      if (price_data[i].codeId == (productId)) {
        found = true;
      }
    }
    return found;
  }

  Widget allgraph(String? category, String? price, String? company,
      String? codeName, String? changed, String? priceDate) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1,
        child: SfCartesianChart(
            tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  return CustomTooltip(
                    category: category.toString(),
                    price: price.toString(),
                    company: company.toString(),
                    codeName: codeName.toString(),
                    changed: changed.toString(),
                    priceDate: priceDate.toString(),
                  );
                }),
            primaryXAxis: CategoryAxis(
                isVisible: true,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelRotation: 45),
            primaryYAxis:
                NumericAxis(majorGridLines: const MajorGridLines(width: 0)),
            title: ChartTitle(text: 'All data'),
            legend: Legend(isVisible: false),
            series: <AreaSeries<DataPoint, String>>[
              AreaSeries(
                  borderColor: const Color.fromARGB(255, 176, 159, 255),
                  borderWidth: 3,
                  borderDrawMode: BorderDrawMode.top,
                  gradient: LinearGradient(colors: [
                    const Color.fromARGB(255, 176, 159, 255).withOpacity(0.4),
                    const Color.fromARGB(255, 176, 159, 255).withOpacity(0.2),
                    const Color.fromARGB(255, 176, 159, 255).withOpacity(0.1)
                  ], stops: const [
                    0.1,
                    0.3,
                    0.6
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  dataSource: data3,
                  xValueMapper: (DataPoint data, _) => data.price_date,
                  yValueMapper: (DataPoint data, _) =>
                      double.tryParse(data.price))
            ]),
      ),
    );
  }

  clear() {
    constanst.select_categotyId.clear();
    constanst.select_typeId.clear();
    constanst.select_gradeId.clear();
    constanst.selectbusstype_id.clear();
    constanst.select_categotyType.clear();
    constanst.select_state.clear();
    constanst.select_country.clear();
    constanst.date = "";
  }

  Future<void> get_HomePost() async {
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    // Before fetching data, ensure loading state is set
    setState(() {
      isload = false; // Reset loading state to false before fetching
    });

    var res = await getlive_price(
      offset.toString(),
      '20',
      _search.text,
      category_id,
      company_id,
      country,
      state,
      constanst.date,
      device,
    );

    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        jsonArray = res['result'];

        // Compress JSON data using Gzip compression
        List<int> compressedData =
            GZipCodec().encode(utf8.encode(jsonEncode(jsonArray)));

        int sizeInBytes = compressedData.length;
        print('Size of compressed data: $sizeInBytes bytes');

        // Clear previous data before adding new
        show_graph_data.clear();

        for (var data in jsonArray) {
          price.Result record = price.Result(
            codeId: data['codeId'],
            codeName: data['CodeName'],
            priceId: data['priceId'],
            category: data['Category'],
            grade: data['Grade'],
            priceDate: data['PriceDate'],
            price: data['Price'],
            changed: data['Changed'],
            currency: data['Currency'],
            state: data['State'],
            company: data['Company'],
            country: data['Country'],
            sign: data['sign'],
            dynamicLink: data['full_url'],
          );

          price_data.add(record);
        }

        for (int i = 0; i < price_data.length; i++) {
          show_graph_data.add(false);
        }

        // Set loading state to true after fetching
        setState(() {
          isload = true;
        });
      }
      print('Live Price Data: $res');
    } else {
      // Handle failure state, ensure UI is updated accordingly
      setState(() {
        isload = true;
      });
    }
    return jsonArray;
  }

  get_graphmonthvalue(String string) async {
    var res = await get_databytimeduration(string);
    if (res['status'] == 1) {
      get_graph graph = get_graph.fromJson(res);
      if (graph.lastMonthRecord != null) {}
      return graph.lastMonthRecord!
          .map((data) =>
              DataPoint(data.priceDate.toString(), data.price.toString()))
          .toList();
    }
  }

  get_graphyearvalue(String string) async {
    var res = await get_databytimeduration(string);
    if (res['status'] == 1) {
      get_graph graph = get_graph.fromJson(res);
      if (graph.lastYearRecord != null) {}
      return graph.lastYearRecord!
          .map((data) =>
              DataPoint(data.priceDate.toString(), data.price.toString()))
          .toList();
    }
  }

  get_graphallvalue(String string) async {
    var res = await get_databytimeduration(string);
    if (res['status'] == 1) {
      get_graph graph = get_graph.fromJson(res);
      if (graph.allRecord != null) {}
      return graph.allRecord!
          .map((data) =>
              DataPoint(data.priceDate.toString(), data.price.toString()))
          .toList();
    }
  }
}

class CustomTooltip extends StatelessWidget {
  final String category, price, company, codeName, changed, priceDate;

  const CustomTooltip({
    required this.category,
    required this.price,
    required this.company,
    required this.codeName,
    required this.changed,
    required this.priceDate,
  });

  @override
  Widget build(BuildContext context) {
    var old = double.tryParse(price)! - double.tryParse(changed)!;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'New Price:$price',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'old Price:$old',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Align(
              alignment: Alignment.topLeft,
              child: Text(
                'change:$changed',
                style: const TextStyle(color: Colors.white),
              )),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              company,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "$category/$codeName",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Align(
              alignment: Alignment.topLeft,
              child: Text(
                priceDate,
                style: const TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }
}
