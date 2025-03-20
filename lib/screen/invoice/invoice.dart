// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/HomeAppbar.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Invoice extends StatefulWidget {
  const Invoice({super.key});

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  List<dynamic> purchasedPlans = [];
  bool isLoading = true;
  bool hasMore = true; // To check if there is more data to load
  String errorMessage = '';
  String offset = '0'; // Initial offset value
  String limit = '10'; // Number of items to fetch

  @override
  void initState() {
    super.initState();
    checkNetwork();
  }

  Future<void> checkNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showCustomToast('Internet Connection not available');
      setState(() {
        isLoading = false;
      });
    } else {
      await fetchPurchasedPlans();
    }
  }

  Future<void> fetchPurchasedPlans() async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String device = Platform.isAndroid ? 'android' : 'ios';

      print('Device Name: $device');
      print('User ID: ${_pref.getString('user_id')}');
      print('API Token: ${_pref.getString('userToken')}');

      var res = await getpurchasedplan(
        _pref.getString('user_id').toString(),
        _pref.getString('userToken').toString(),
        offset,
        limit,
      );

      print('Full Response: $res');

      if (res != null && res['status'] == 1) {
        setState(() {
          purchasedPlans.addAll(res['purchased']);
          isLoading = false;
          offset = (int.parse(offset) + int.parse(limit)).toString();
          hasMore = res['purchased'].length == int.parse(limit);
        });
      } else {
        setState(() {
          errorMessage = res?['message'] ?? 'Unknown error';
          isLoading = false;
        });
        showCustomToast(errorMessage);
      }
    } catch (error, stacktrace) {
      print('Error: $error');
      print('Stacktrace: $stacktrace');
      setState(() {
        errorMessage = 'An error occurred';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: CustomeApp('Subscription'),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!isLoading &&
              hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            fetchPurchasedPlans();
            return true;
          }
          return false;
        },
        child: isLoading
            ? Center(
                child: Center(
                child: CustomLottieContainer(
                  child: Lottie.asset(
                    'assets/loading_animation.json',
                  ),
                ),
              ))
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : purchasedPlans.isEmpty // Check if no data is found
                    ? Center(
                        child: Text(
                          'No subscription found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: purchasedPlans.length,
                        itemBuilder: (context, index) {
                          var plan = purchasedPlans[index];
                          DateTime createdAt =
                              DateTime.parse(plan['start_date']);
                          String formattedDateissued =
                              DateFormat('MMM d, yyyy').format(createdAt);

                          DateTime createdAtDue =
                              DateTime.parse(plan['end_date']);
                          String formattedDateDue =
                              DateFormat('MMM d, yyyy').format(createdAtDue);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Card(
                              elevation: 9,
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, top: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Invoice No: ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${plan['invoice_no']}',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  3.sbh,
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, top: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Payement Id: ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                text: plan['transection_id']));
                                            showCustomToast(
                                                'Copied to clipboard!');
                                          },
                                          child: Text(
                                            '${plan['transection_id']}',
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        6.sbw,
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                text: plan['transection_id']));
                                            showCustomToast(
                                                'Copied to clipboard!');
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                      color: AppColors.gray.withOpacity(0.5)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Start Date:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.gray,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'End Date:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.gray,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formattedDateissued,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.blackColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        48.sbw,
                                        Text(
                                          formattedDateDue,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.blackColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  10.sbh,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    child: Text(
                                      'Invoice Items',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 0),
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Plan Name',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'Price',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  8.sbh,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 34),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          plan['plan_name'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.blackColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${plan['paid_amount_currency'] == 'USD' ? '\$' : plan['paid_amount_currency'] == 'INR' ? '₹' : ''}${plan['paid_amount']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.blackColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  15.sbh,
                                  Divider(
                                      color: AppColors.gray.withOpacity(0.5)),
                                  if (plan['pdf_url'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.picture_as_pdf),
                                            onPressed: () async {
                                              if (await canLaunch(
                                                  plan['pdf_url'])) {
                                                await launch(plan['pdf_url'],
                                                    forceSafariVC: false);
                                              } else {
                                                showCustomToast(
                                                    'Could not launch URL');
                                              }
                                            },
                                          ),
                                          InkWell(
                                              onTap: () async {
                                                if (await canLaunch(
                                                    plan['pdf_url'])) {
                                                  await launch(plan['pdf_url'],
                                                      forceSafariVC: false);
                                                } else {
                                                  showCustomToast(
                                                      'Could not launch URL');
                                                }
                                              },
                                              child: Text('Invoice Download'))
                                        ],
                                      ),
                                    )
                                  else
                                    SizedBox.shrink(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
