class AddBusinessDirectory {
  String? userId;
  String? view_in_directory;
  String? userToken;
  String? businessName;
  String? partnername1;
  String? partnername2;
  String? businessType;
  String? designation;
  String? designation1;

  String? corebusiness;
  String? location;
  String? latitude;
  String? longitude;
  String? partner1businessmobile;
  String? partner2businessmobile;

  String? country;
  String? p1countryCode;
  String? p2countryCode;
  String? p1businesscountryCode;
  String? p2businesscountryCode;

  String? partner1mobile;
  String? partner2mobile;
  String? stepCounter;
  String? city;
  String? partner1email;
  String? partner2email;
  String? business1email;
  String? business2email;
  String? verifyemail;
  String? website;
  String? aboutBusiness;
  String? gstTaxVat;
  String? state;
  String? directory_post;
  String? directory_buypost;

  AddBusinessDirectory({
    this.userId,
    this.view_in_directory,
    this.userToken,
    this.businessName,
    this.partnername1,
    this.partnername2,
    this.businessType,
    this.designation,
    this.designation1,
    this.corebusiness,
    this.location,
    this.latitude,
    this.longitude,
    this.partner1businessmobile,
    this.partner2businessmobile,
    this.country,
    this.p1countryCode,
    this.p2countryCode,
    this.p1businesscountryCode,
    this.p2businesscountryCode,
    this.partner1mobile,
    this.partner2mobile,
    this.stepCounter,
    this.city,
    this.partner1email,
    this.partner2email,
    this.business1email,
    this.business2email,
    this.verifyemail,
    this.website,
    this.aboutBusiness,
    this.gstTaxVat,
    this.state,
    this.directory_post,
    this.directory_buypost,
  });

  AddBusinessDirectory.fromJson(Map<String, dynamic> json) {
    userId = json['userId'] as String? ?? '';
    view_in_directory = json['view_in_directory'] as String? ?? '';
    userToken = json['userToken'] as String? ?? '';
    businessName = json['business_name'] as String? ?? '';
    partnername1 = json['partner1_name'] as String? ?? '';
    partnername2 = json['partner2_name'] as String? ?? '';
    businessType = json['business_type'] as String? ?? '';
    designation = json['partner1_designation'] as String? ?? '';
    designation1 = json['partner2_designation'] as String? ?? '';

    corebusiness = json['core_businesses'] as String? ?? '';
    location = json['address'] as String? ?? '';
    latitude = json['latitude'] as String? ?? '';
    longitude = json['longitude'] as String? ?? '';
    partner1businessmobile = json['business_phone'] as String? ?? '';
    partner2businessmobile = json['partner2_business_mobile'] as String? ?? '';

    country = json['country'] as String? ?? '';
    p1countryCode = json['partner1_mobile_country_code'] as String? ?? '';
    p2countryCode = json['partner2_mobile_country_code'] as String? ?? '';
    p1businesscountryCode = json['countryCode'] as String? ?? '';
    p2businesscountryCode =
        json['partner2_business_mobile_country_code'] as String? ?? '';

    partner1mobile = json['partner1_mobilenumber'] as String? ?? '';
    partner2mobile = json['partner2_mobilenumber'] as String? ?? '';
    stepCounter = json['step_counter'] as String? ?? '';
    city = json['city'] as String? ?? '';
    partner1email = json['partner1_email'] as String? ?? '';
    partner2email = json['partner2_email'] as String? ?? '';
    business1email = json['other_email'] as String? ?? '';
    business2email = json['partner2_business_email'] as String? ?? '';
    verifyemail = json['partner1_listed_email'] as String? ?? '';

    website = json['website'] as String? ?? '';
    aboutBusiness = json['about_business'] as String? ?? '';
    gstTaxVat = json['gst_tax_vat'] as String? ?? '';
    state = json['state'] as String? ?? '';
    directory_post = json['directory_post'] as String? ?? '';
    directory_buypost = json['directory_buypost'] as String? ?? '';
  }

  Map<String, String> toJson() {
    final Map<String, String> data = {};

    data['userId'] = userId ?? '';
    data['view_in_directory'] = view_in_directory ?? '';
    data['userToken'] = userToken ?? '';
    data['business_name'] = businessName ?? '';
    data['partner1_name'] = partnername1 ?? '';
    data['partner2_name'] = partnername2 ?? '';
    data['business_type'] = businessType ?? '';
    data['partner1_designation'] = designation ?? '';
    data['partner2_designation'] = designation1 ?? '';
    data['core_businesses'] = corebusiness ?? '';
    data['address'] = location ?? '';
    data['latitude'] = latitude ?? '';
    data['longitude'] = longitude ?? '';
    data['business_phone'] = partner1businessmobile ?? '';
    data['partner2_business_mobile'] = partner2businessmobile ?? '';
    data['country'] = country ?? '';
    data['partner1_mobile_country_code'] = p1countryCode ?? '';
    data['partner2_mobile_country_code'] = p2countryCode ?? '';

    data['countryCode'] = p1businesscountryCode ?? '';
    data['partner2_business_mobile_country_code'] = p2businesscountryCode ?? '';

    data['partner1_mobilenumber'] = partner1mobile ?? '';
    data['partner2_mobilenumber'] = partner2mobile ?? '';
    data['step_counter'] = stepCounter ?? '';
    data['city'] = city ?? '';
    data['partner1_email'] = partner1email ?? '';
    data['partner2_email'] = partner2email ?? '';
    data['other_email'] = business1email ?? '';
    data['partner2_business_email'] = business2email ?? '';
    data['partner1_listed_email'] = verifyemail ?? '';

    data['website'] = website ?? '';
    data['about_business'] = aboutBusiness ?? '';
    data['gst_tax_vat'] = gstTaxVat ?? '';
    data['state'] = state ?? '';
    data['directory_post'] = directory_post ?? '';
    data['directory_buypost'] = directory_buypost ?? '';

    return data;
  }
}
