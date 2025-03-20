import 'dart:io';

import 'package:Plastic4trade/api/api_interface.dart';
import 'package:Plastic4trade/common/popUpDailog.dart';
import 'package:Plastic4trade/screen/buyer_seller/Buyer_sell_detail.dart';
import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:Plastic4trade/widget/HomeAppbar.dart';
import 'package:Plastic4trade/widget/custom_lottie_animation.dart';
import 'package:Plastic4trade/widget/customshimmer/custome_shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Plastic4trade/model/GetFavoriteList.dart' as fav;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductInterested extends StatefulWidget {
  const ProductInterested({super.key});

  @override
  State<ProductInterested> createState() => _ProductInterestedState();
}

class _ProductInterestedState extends State<ProductInterested> {
  List<fav.Result> favlist = [];
  bool isload = false;
  bool isLoading = true;
  int offset = 0;
  int count = 0;

  Future? getRalSavedpostFuture;
  final scrollercontroller = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollercontroller.addListener(_scrollercontroller);

    loadData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    get_Product_Interest();
  }

  Future<void> _refreshData() async {
    setState(() {
      favlist.clear();
      offset = 0;
    });

    await get_Product_Interest();

    setState(() {
      isLoading = true;
    });

    showCustomToast('Data Refreshed');

    scrollercontroller.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    return null;
  }

  void _scrollercontroller() {
    if ((scrollercontroller.position.pixels - 50) ==
        (scrollercontroller.position.maxScrollExtent - 50)) {
      if (favlist.isNotEmpty) {
        count++;
        if (count == 1) {
          offset = offset + 21;
        } else {
          offset = offset + 20;
        }
        getRalSavedpostFuture = get_Product_Interest();
      }
    }
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: CustomeApp('Product Interested'),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        backgroundColor: AppColors.primaryColor,
        color: AppColors.backgroundColor,
        child: SingleChildScrollView(
          controller: scrollercontroller,
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                isload == true
                    ? category()
                    : productInterestWithShimmerLoader(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget productInterestWithShimmerLoader(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).size.width / 620,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 2,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return CustomShimmerLoader(width: 175, height: 200);
      },
    );
  }

  Widget category() {
    return FutureBuilder(
      future: getRalSavedpostFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('No Data Found'));
        }
        if (snapshot.connectionState == ConnectionState.none &&
            // ignore: unnecessary_null_comparison
            snapshot.hasData == null) {
          return Center(
            child: CustomLottieContainer(
              child: Lottie.asset(
                'assets/loading_animation.json',
              ),
            ),
          );
        } else {
          return SizedBox(
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 0.0,
                childAspectRatio: MediaQuery.of(context).size.width / 610,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favlist.isEmpty ? 1 : favlist.length + 2,
              itemBuilder: (context, index) {
                if (index < favlist.length) {
                  fav.Result record = favlist[index];
                  return GestureDetector(
                    onTap: (() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Buyer_sell_detail(
                            prod_id: record.productId.toString(),
                            post_type: record.postType.toString(),
                          ),
                        ),
                      );
                    }),
                    child: Card(
                      color: const Color(0xFFFFFFFF),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.05),
                      ),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(
                              fit: StackFit.passthrough,
                              children: <Widget>[
                                Container(
                                  height: 170,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: record.isPaidPost == 'Paid'
                                          ? Colors.red
                                          : Colors.transparent,
                                      width:
                                          record.isPaidPost == 'Paid' ? 2.5 : 0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          record.mainproductImage.toString(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Container(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 5.0),
                                    decoration: BoxDecoration(
                                        color: AppColors.greenWithShade,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0))),
                                    child: Text(
                                        '${record.currency}${record.productPrice}',
                                        style: const TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w800,
                                            fontFamily:
                                                'assets/fonst/Metropolis-Black.otf',
                                            color: AppColors.backgroundColor)),
                                  ),
                                ),
                                if (record.isPaidPost == 'Paid')
                                  Positioned(
                                    top: -20,
                                    left: -25,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Image.asset(
                                        'assets/PaidPost.png',
                                        height: 90,
                                      ),
                                    ),
                                  )
                              ]),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(record.productName.toString(),
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.blackColor,
                                          fontFamily:
                                              'assets/fonst/Metropolis-SemiBold.otf'),
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                3.sbh,
                                Text(
                                    '${record.productType} | ${record.productGrade}',
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                      color: AppColors.gray,
                                      fontFamily: 'Metropolis',
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                3.sbh,
                                Text('${record.state},${record.country}',
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                      color: AppColors.gray,
                                      fontFamily: 'Metropolis',
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                3.sbh,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      record.postType.toString(),
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontFamily: 'Metropolis',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.greenWithShade,
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Icon(Icons.thumb_up,
                                          color: AppColors.primaryColor),
                                      onTap: () {
                                        setState(() {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return CommanDialog(
                                                  title: "Product Interested",
                                                  content:
                                                      "Do you want to UnInterested",
                                                  onPressed: () {
                                                    setState(() {
                                                      getremove_product_interest(
                                                          record.productId
                                                              .toString());
                                                      favlist.removeAt(index);
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              });
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ]),
                    ),
                  );
                } else if (index == favlist.length ||
                    index == favlist.length + 1) {
                  if (categorySavedToLoad()) {
                    print('Empty CustomShimmerLoader triggered1');

                    return CustomShimmerLoader(
                      width: 175,
                      height: 200,
                    );
                  } else {
                    print('Empty else branch triggered');
                    return SizedBox.shrink();
                  }
                } else {
                  print('Empty CustomShimmerLoader triggered2');

                  return CustomShimmerLoader(
                    width: 175,
                    height: 200,
                  );
                }
              },
            ),
          );
        }
      },
    );
  }

  bool categorySavedToLoad() {
    int itemsPerPage = 20;
    return favlist.length % itemsPerPage == 0 && favlist.isNotEmpty;
  }

  Future<void> get_Product_Interest() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');

    var res = await interestedListProduct(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      device,
      offset.toString(),
    );

    var jsonArray;
    if (res['status'] == 1) {
      if (res['result'] != null) {
        jsonArray = res['result'];

        for (var data in jsonArray) {
          fav.Result record = fav.Result(
            productName: data['ProductName'],
            categoryName: data['CategoryName'],
            productGrade: data['ProductGrade'],
            currency: data['Currency'],
            productPrice: data['ProductPrice'],
            postType: data['PostType'],
            productType: data['ProductType'],
            country: data['Country'],
            city: data['City'],
            productId: data['productId'],
            mainproductImage: data['mainproductImage'],
            state: data['State'],
            isPaidPost: data['is_paid_post'],
          );

          favlist.add(record);
        }
        isload = true;

        if (mounted) {
          setState(() {});
        }
      }
    } else {
      showCustomToast(res['message']);
    }
    setState(() {});
    return jsonArray;
  }

  getremove_product_interest(String prodId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String device = '';
    if (Platform.isAndroid) {
      device = 'android';
    } else if (Platform.isIOS) {
      device = 'ios';
    }
    print('Device Name: $device');
    var res = await removeProductInterest(
      pref.getString('user_id').toString(),
      pref.getString('userToken').toString(),
      prodId.toString(),
      device,
    );
    var jsonArray;

    if (res['status'] == 1) {
      showCustomToast('Product Interested Remove');
      jsonArray = res['result'];
      setState(() {});
    } else {
      showCustomToast(res['message']);
    }
    setState(() {});
    return jsonArray;
  }
}
