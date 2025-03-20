// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:Plastic4trade/utill/extension_classes.dart';
import 'package:flutter/material.dart';

class BusinessDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> businessData;
  final String? imagePath;
  final VoidCallback onClose;

  const BusinessDetailsDialog({
    Key? key,
    required this.businessData,
    required this.imagePath,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Physical Business Directory"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null)
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imagePath!.startsWith('http')
                        ? NetworkImage(imagePath!) as ImageProvider
                        : FileImage(File(imagePath!)) as ImageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            15.sbh,
            Text("${businessData['business_name']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                )),
            _buildInfoRow(
              "Business Type",
              businessData['business_type']?.replaceAll(',', ', ') ?? '',
            ),
            4.sbh,
            _buildInfoRow("Core Businesses",
                businessData['core_businesses']?.replaceAll(',', ', ') ?? ''),
            4.sbh,
            _buildInfoRow("Address", businessData['address']),
            4.sbh,
            _buildInfoRow("Website", businessData['website']),
            4.sbh,
            _buildInfoRow("GST Tax/VAT", businessData['gst_tax_vat']),
            _buildPartnerSection("Contact Person 1", businessData, 1),
            _buildPartnerSection("Contact Person 2", businessData, 2),
            4.sbh,
            _buildInfoRow("Products", businessData['products']),
            4.sbh,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text("Close"),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return SizedBox();
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: "$value",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerSection(
      String partnerLabel, Map<String, dynamic> data, int partnerIndex) {
    bool isMobileEmpty =
        ((data['partner${partnerIndex}_mobilenumber_country_code']?.isEmpty ??
                    true) ||
                (data['partner${partnerIndex}_mobilenumber']?.isEmpty ??
                    true)) &&
            ((data['partner${partnerIndex}_business_mobile_country_code']
                        ?.isEmpty ??
                    true) ||
                (data['partner${partnerIndex}_business_mobile']?.isEmpty ??
                    true));

    if (isMobileEmpty) {
      return const SizedBox();
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(partnerLabel,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 14,
          )),
      _buildInfoRow(
        partnerIndex == 2 ? "Partner Name" : "Your Name",
        "${data['partner${partnerIndex}_name'] ?? 'N/A'}" +
            (data['partner${partnerIndex}_designation']?.isNotEmpty ?? false
                ? ' (${data['partner${partnerIndex}_designation']})'
                : ''),
      ),
      _buildInfoRow(
        "Email",
        [
          if (data['partner${partnerIndex}_email'] != null &&
              data['partner${partnerIndex}_email'] != '')
            data['partner${partnerIndex}_email'],
          if (data['partner${partnerIndex}_business_email'] != null &&
              data['partner${partnerIndex}_business_email'] != '')
            data['partner${partnerIndex}_business_email']
        ].join(' | '),
      ),
      4.sbh,
      _buildInfoRow(
        "Mobile",
        [
          if ((data['partner${partnerIndex}_mobilenumber_country_code'] ?? '')
                  .isNotEmpty &&
              (data['partner${partnerIndex}_mobilenumber'] ?? '').isNotEmpty)
            "${data['partner${partnerIndex}_mobilenumber_country_code']} ${data['partner${partnerIndex}_mobilenumber']}",
          if ((data['partner${partnerIndex}_business_mobile_country_code'] ??
                      '')
                  .isNotEmpty &&
              (data['partner${partnerIndex}_business_mobile'] ?? '').isNotEmpty)
            "${data['partner${partnerIndex}_business_mobile_country_code']} ${data['partner${partnerIndex}_business_mobile']}",
        ].where((item) => item.isNotEmpty).join(' | '),
      ),
    ]);
  }
}
