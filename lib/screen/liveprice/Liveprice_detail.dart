// ignore_for_file: camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, must_be_immutable, deprecated_member_use

import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/widget/customshimmer/custom_live_price_shimmer_loader.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../api/api_interface.dart';
import '../../model/DataPoint.dart';
import '../../model/get_graph.dart';
import '../../model/getcoderecord.dart';
import '../../utill/constant.dart';

class Liveprice_detail extends StatefulWidget {
  String? category,
      price,
      currency,
      sign,
      company,
      codeName,
      changed,
      priceDate,
      code_id,
      grade;

  Liveprice_detail(
      {Key? key,
      this.category,
      this.currency,
      this.sign,
      this.changed,
      this.codeName,
      this.price,
      this.priceDate,
      this.company,
      this.code_id,
      this.grade})
      : super(key: key);

  @override
  State<Liveprice_detail> createState() => _Liveprice_detailState();
}

class RadioModel {
  bool isSelected;
  final String buttonText;

  RadioModel(this.isSelected, this.buttonText);
}

class _Liveprice_detailState extends State<Liveprice_detail> {
  bool isgraph = false;
  final scrollercontroller = ScrollController();
  List<bool> show_graph_data = [];
  bool loadmore = false;
  bool isload = false;
  bool isLoading = true;
  int offset = 0;
  int count = 0;
  List<CoderecordResult> price_data = [];
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
  List<RadioModel> sampleData1 = <RadioModel>[];

  @override
  void initState() {
    super.initState();
    scrollercontroller.addListener(_scrollercontroller);
    sampleData1.add(
      RadioModel(false, 'Month'),
    );
    sampleData1.add(
      RadioModel(true, 'Year'),
    );
    sampleData1.add(
      RadioModel(false, 'All'),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: const Text(
          'Live Price Detail ',
          softWrap: false,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: 'Metropolis',
          ),
        ),
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(10.5, 5.0, 10.5, 5.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...sampleData1.map((data) {
                    return Row(
                      children: [
                        GestureDetector(
                          child: data.isSelected == true
                              ? Icon(Icons.check_circle,
                                  color: AppColors.greenWithShade)
                              : const Icon(Icons.circle_outlined,
                                  color: Colors.black38),
                          onTap: () {
                            setState(() {
                              sampleData1.forEach(
                                  (element) => element.isSelected = false);
                              data.isSelected = true;
                              type_post = data.buttonText;
                            });
                          },
                        ),
                        Text(
                          data.buttonText,
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'assets/fonst/Metropolis-Black.otf',
                          ).copyWith(fontSize: 17),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: sampleData1[0].isSelected
                ? monthgraph(
                    widget.category,
                    widget.price,
                    widget.currency,
                    widget.sign,
                    widget.company,
                    widget.codeName,
                    widget.changed,
                    widget.priceDate,
                  )
                : sampleData1[1].isSelected
                    ? yearGraph(
                        widget.category,
                        widget.price,
                        widget.currency,
                        widget.sign,
                        widget.company,
                        widget.codeName,
                        widget.changed,
                        widget.priceDate,
                      )
                    : sampleData1[2].isSelected
                        ? allgraph(
                            widget.category,
                            widget.price,
                            widget.company,
                            widget.currency,
                            widget.sign,
                            widget.codeName,
                            widget.changed,
                            widget.priceDate,
                          )
                        : Container(),
          ),
          SliverToBoxAdapter(
            child:
                isLoading ? livePriceWithShimmerLoader(context) : pricelist(),
          ),
        ],
      ),
    );
  }

  Future<void> checknetowork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
    } else {
      get_graphmonthvalue(
        widget.code_id.toString(),
      ).then((fetchedData) {
        setState(() {
          data1 = fetchedData;
        });
      });
      get_graphyearvalue(
        widget.code_id.toString(),
      ).then((fetchedData) {
        setState(() {
          data2 = fetchedData;
        });
      });
      get_graphallvalue(
        widget.code_id.toString(),
      ).then((fetchedData) {
        setState(() {
          data3 = fetchedData;
        });
      });
      get_HomePost();
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
    }
  }

  Widget livePriceWithShimmerLoader(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 5,
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
    return ListView.builder(
      padding: const EdgeInsets.only(left: 7, right: 7, bottom: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: price_data.isEmpty ? 1 : price_data.length + 1,
      controller: scrollercontroller,
      itemBuilder: (context, index) {
        if (index == price_data.length) {
          if (allLiveDataToLoad() && !price_data.isNotEmpty) {
            return LivePriceShimmerLoader(
              width: 175,
              height: 80,
            );
          } else {
            return SizedBox();
          }
        } else {
          CoderecordResult result = price_data[index];
          return Column(
            children: [
              Container(
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                  shadows: [
                    BoxShadow(
                      color: AppColors.boxShadowforshimmer,
                      blurRadius: 16.32,
                      offset: Offset(0, 3.26),
                      spreadRadius: 0,
                    )
                  ],
                ),
                padding:
                    const EdgeInsets.only(top: 9, right: 6, left: 6, bottom: 6),
                child: Column(children: [
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.category.toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 0,
                                letterSpacing: -0.24,
                                fontFamily:
                                    'assets/fonst/Metropolis-Black.otf'),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            widget.codeName.toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 0,
                                letterSpacing: -0.24,
                                fontFamily:
                                    'assets/fonst/Metropolis-Black.otf'),
                            maxLines: 2,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Text(
                            widget.grade.toString(),
                            style: const TextStyle(
                                fontSize: 13.0,
                                letterSpacing: -0.24,
                                height: 0,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'assets/fonst/Metropolis-Black.otf',
                                color: Colors.black),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            result.currency.toString() +
                                double.parse(result.price ?? '0')
                                    .toStringAsFixed(2),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                height: 0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.24,
                                fontFamily:
                                    'assets/fonst/Metropolis-Black.otf'),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            (result.sign != null
                                    ? result.sign.toString()
                                    : '') +
                                result.currency.toString() +
                                double.parse(result.changed!
                                        .replaceFirst("-", "")
                                        .toString())
                                    .toStringAsFixed(2),
                            style: TextStyle(
                                color: result.sign == "+"
                                    ? AppColors.greenWithShade
                                    : result.sign == "-"
                                        ? AppColors.red
                                        : Colors.black,
                                fontSize: 13,
                                height: 0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.24,
                                fontFamily:
                                    'assets/fonst/Metropolis-Black.otf'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 1),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            DateFormat("dd MMM, yyyy").format(
                                DateFormat("yyyy-MM-dd")
                                    .parse(result.priceDate.toString())),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontWeight: FontWeight.w400,
                              height: 0,
                              letterSpacing: -0.24,
                            )),
                        Text(
                            '${widget.company} - ${result.state}${result.country}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontFamily: 'assets/fonst/Metropolis-Black.otf',
                              fontWeight: FontWeight.w400,
                              height: 0,
                              letterSpacing: -0.24,
                            )),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 13),
            ],
          );
        }
      },
    );
  }

  Widget monthgraph(
    String? category,
    String? price,
    String? currency,
    String? sign,
    String? company,
    String? codeName,
    String? changed,
    String? priceDate,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10.5, 5.0, 10.5, 5.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Colors.white,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SfCartesianChart(
          trackballBehavior: TrackballBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            lineColor: Colors.black,
            lineWidth: 2,
            markerSettings: TrackballMarkerSettings(
              markerVisibility: TrackballVisibilityMode.visible,
              width: 10,
              height: 10,
              borderWidth: 2,
              borderColor: Colors.white,
              color: Colors.black,
            ),
            tooltipSettings: InteractiveTooltip(
              enable: false, // Disable default tooltip for custom rendering.
            ),
            builder: (BuildContext context, TrackballDetails trackballDetails) {
              final int? pointIndex = trackballDetails.pointIndex;
              final data = pointIndex != null ? data1[pointIndex] : null;

              if (data != null) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: ${currency ?? ''}${data.price}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Date: ${data.price_date}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Company: ${company ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Product: ${category ?? ''} (${codeName ?? ''})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            labelRotation: 45,
          ),
          primaryYAxis: NumericAxis(
            majorGridLines: const MajorGridLines(width: 0),
          ),
          title: ChartTitle(
            text: 'Monthly Data',
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          legend: Legend(isVisible: false),
          series: <AreaSeries<DataPoint, String>>[
            AreaSeries<DataPoint, String>(
              borderColor: AppColors.primaryColor,
              borderWidth: 3,
              borderDrawMode: BorderDrawMode.top,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.2),
                  AppColors.primaryColor.withOpacity(0.1),
                ],
                stops: const [0.1, 0.3, 0.6],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              dataSource: data1,
              xValueMapper: (DataPoint data, _) => data.price_date,
              yValueMapper: (DataPoint data, _) => double.tryParse(data.price),
              markerSettings: MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                width: 8,
                height: 8,
                color: Colors.black,
                borderColor: Colors.black,
                borderWidth: 1,
              ),
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
                textStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget yearGraph(
    String? category,
    String? price,
    String? currency,
    String? sign,
    String? company,
    String? codeName,
    String? changed,
    String? priceDate,
  ) {
    // Reverse the order of the data.
    final reversedData = List<DataPoint>.from(data2.reversed);

    return Container(
      margin: const EdgeInsets.fromLTRB(10.5, 5.0, 10.5, 5.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        color: Colors.white,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SfCartesianChart(
          trackballBehavior: TrackballBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            lineColor: Colors.black,
            lineWidth: 2,
            markerSettings: TrackballMarkerSettings(
              markerVisibility: TrackballVisibilityMode.visible,
              width: 10,
              height: 10,
              borderWidth: 2,
              borderColor: Colors.white,
              color: Colors.black,
            ),
            tooltipSettings: InteractiveTooltip(
              enable: false, // Disable default tooltip to use the builder.
            ),
            builder: (BuildContext context, TrackballDetails trackballDetails) {
              final int? pointIndex = trackballDetails.pointIndex;
              final data = pointIndex != null ? reversedData[pointIndex] : null;

              if (data != null) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: ${currency ?? ''}${data.price}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Date: ${data.price_date}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Company: ${company ?? ''}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Product: ${category ?? ''} (${codeName})',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            labelRotation: 45,
          ),
          primaryYAxis: NumericAxis(
            majorGridLines: const MajorGridLines(width: 0),
          ),
          title: ChartTitle(
            text: 'Year Data',
            textStyle: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'assets/fonts/Metropolis-Black.otf')
                .copyWith(fontSize: 17),
          ),
          legend: Legend(isVisible: false),
          series: <AreaSeries<DataPoint, String>>[
            AreaSeries(
              borderColor: AppColors.primaryColor,
              borderWidth: 3,
              borderDrawMode: BorderDrawMode.top,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.2),
                  AppColors.primaryColor.withOpacity(0.1)
                ],
                stops: const [0.1, 0.3, 0.6],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              dataSource: reversedData, // Use the reversed data.
              xValueMapper: (DataPoint data, _) => data.price_date,
              yValueMapper: (DataPoint data, _) => double.tryParse(data.price),
              markerSettings: MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                width: 8,
                height: 8,
                color: Colors.black,
                borderColor: Colors.black,
                borderWidth: 1,
              ),
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
                textStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget allgraph(
    String? category,
    String? price,
    String? company,
    String? currency,
    String? sign,
    String? codeName,
    String? changed,
    String? priceDate,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10.5, 5.0, 10.5, 5.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        color: Colors.white,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SfCartesianChart(
          trackballBehavior: TrackballBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            lineColor: Colors.black,
            lineWidth: 2,
            markerSettings: TrackballMarkerSettings(
              markerVisibility: TrackballVisibilityMode.visible,
              width: 10,
              height: 10,
              borderWidth: 2,
              borderColor: Colors.white,
              color: Colors.black,
            ),
            tooltipSettings: InteractiveTooltip(
              enable: false, // Disable default tooltip to use the builder.
            ),
            builder: (BuildContext context, TrackballDetails trackballDetails) {
              final int? pointIndex = trackballDetails.pointIndex;
              final data = pointIndex != null
                  ? data3.reversed.toList()[pointIndex]
                  : null;

              if (data != null) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: ${currency ?? ''}${data.price}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Date: ${data.price_date}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Company: ${company ?? ''}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Product: ${category ?? ''} (${codeName})',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          primaryXAxis: CategoryAxis(
            isVisible: true,
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            labelRotation: 45,
          ),
          primaryYAxis: NumericAxis(
            majorGridLines: const MajorGridLines(width: 0),
          ),
          title: ChartTitle(
            text: 'All Data',
            textStyle: const TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'assets/fonts/Metropolis-Black.otf',
            ).copyWith(fontSize: 17),
          ),
          legend: Legend(isVisible: false),
          series: <AreaSeries<DataPoint, String>>[
            AreaSeries<DataPoint, String>(
              borderColor: AppColors.primaryColor,
              borderWidth: 3,
              borderDrawMode: BorderDrawMode.top,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.2),
                  AppColors.primaryColor.withOpacity(0.1),
                ],
                stops: const [0.1, 0.3, 0.6],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              dataSource: data3.reversed.toList(),
              xValueMapper: (DataPoint data, _) => data.price_date,
              yValueMapper: (DataPoint data, _) => double.tryParse(data.price),
              markerSettings: MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                width: 8,
                height: 8,
                color: Colors.black,
                borderColor: Colors.black,
                borderWidth: 1,
              ),
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
                textStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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

  get_HomePost() async {
    var res = await get_coderecord(
      widget.code_id.toString(),
      offset.toString(),
    );
    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        jsonArray = res['result'];

        for (var data in jsonArray) {
          CoderecordResult record = CoderecordResult(
              priceDate: data['price_date'],
              price: data['price'],
              changed: data['changed'],
              currency: data['currency'],
              state: data['state'],
              country: data['country'],
              id: data['id'],
              categoryId: data['category_id'],
              codeId: data['code_id'],
              companyId: data['company_id'],
              productgradeId: data['productgrade_id'],
              sign: data['sign']);
          price_data.add(record);
        }
        for (int i = 0; i < price_data.length; i++) {
          show_graph_data.add(false);
        }
        isload = true;
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      isload = true;
    }
    return jsonArray;
  }

  get_graphmonthvalue(String string) async {
    var res = await get_databytimeduration(string);
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');

      get_graph graph = get_graph.fromJson(res);
      if (graph.lastMonthRecord != null) {}
      return graph.lastMonthRecord!
          .map(
            (data) => DataPoint(
              data.priceDate.toString(),
              data.price.toString(),
            ),
          )
          .toList();
    }
  }

  get_graphyearvalue(String string) async {
    var res = await get_databytimeduration(string);
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      get_graph graph = get_graph.fromJson(res);
      if (graph.lastYearRecord != null) {}
      return graph.lastYearRecord!
          .map(
            (data) => DataPoint(
              data.priceDate.toString(),
              data.price.toString(),
            ),
          )
          .toList();
    }
  }

  get_graphallvalue(String string) async {
    var res = await get_databytimeduration(string);
    if (res['status'] == 1) {
      // Compress JSON data using Gzip compression
      List<int> compressedData =
          GZipCodec().encode(utf8.encode(jsonEncode(res)));

      int sizeInBytes = compressedData.length;
      print('Size of compressed data: $sizeInBytes bytes');
      get_graph graph = get_graph.fromJson(res);
      if (graph.allRecord != null) {}
      return graph.allRecord!
          .map(
            (data) => DataPoint(
              data.priceDate.toString(),
              data.price.toString(),
            ),
          )
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
    // Calculate old price as the difference between the new price and the change
    var old = double.tryParse(price)! - double.tryParse(changed)!;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display new and old prices
          Row(
            children: [
              Text(
                'New Price: $price',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                ' Old Price: $old',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          // Display change, company, and other details
          Text(
            'Change: $changed',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Company: $company',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Category/Code Name: $category/$codeName',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Price Date: $priceDate',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
