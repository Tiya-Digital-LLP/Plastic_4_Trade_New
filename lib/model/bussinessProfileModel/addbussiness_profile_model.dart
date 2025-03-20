class AddBussinessProfileRequest {
  String? userId;
  String? userToken;
  String? businessName;
  String? businessType;
  String? corebusiness;

  String? location;
  String? latitude;
  String? longitude;
  String? otherMobile1;
  String? country;
  String? countryCode;
  String? businessPhone;
  String? stepCounter;
  String? city;
  String? email;
  String? website;
  String? aboutBusiness;
  String? gstTaxVat;
  String? state;

  AddBussinessProfileRequest(
      {this.userId,
      this.userToken,
      this.businessName,
      this.businessType,
      this.corebusiness,
      this.location,
      this.latitude,
      this.longitude,
      this.otherMobile1,
      this.country,
      this.countryCode,
      this.businessPhone,
      this.stepCounter,
      this.city,
      this.email,
      this.website,
      this.aboutBusiness,
      this.gstTaxVat,
      this.state});

  AddBussinessProfileRequest.fromJson(Map<String, String> json) {
    userId = json['userId'];
    userToken = json['userToken'];
    businessName = json['business_name'];
    businessType = json['business_type'];
    corebusiness = json['core_businesses'];

    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    otherMobile1 = json['other_mobile1'];
    country = json['country'];
    countryCode = json['countryCode'];
    businessPhone = json['business_phone'];
    stepCounter = json['step_counter'];
    city = json['city'];
    email = json['email'];
    website = json['website'];
    aboutBusiness = json['about_business'];
    gstTaxVat = json['gst_tax_vat'];
    state = json['state'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = new Map<String, String>();
    data['userId'] = this.userId!;
    data['userToken'] = this.userToken!;
    data['business_name'] = this.businessName!;
    data['business_type'] = this.businessType!;
    data['core_businesses'] = this.corebusiness!;
    data['location'] = this.location!;
    data['latitude'] = this.latitude!;
    data['longitude'] = this.longitude!;
    data['other_mobile1'] = this.otherMobile1!;
    data['country'] = this.country!;
    data['countryCode'] = this.countryCode!;
    data['business_phone'] = this.businessPhone!;
    data['step_counter'] = this.stepCounter!;
    data['city'] = this.city!;
    data['email'] = this.email!;
    data['website'] = this.website!;
    data['about_business'] = this.aboutBusiness!;
    data['gst_tax_vat'] = this.gstTaxVat!;
    data['state'] = this.state!;
    return data;
  }
}
