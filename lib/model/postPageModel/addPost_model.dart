class AddPostRequest {
  String? userId;
  String? userToken;
  String? producttypeId;
  String? productgradeId;
  String? currency;
  String? productPrice;
  String? unit;
  String? unitOfPrice;
  String? location;
  String? productQty;
  String? colorId;
  String? description;
  String? latitude;
  String? longitude;
  String? imageCounter;
  String? city;
  String? state;
  String? country;
  String? stepCounter;
  String? productName;
  String? categoryId;

  AddPostRequest(
      {this.userId,
        this.userToken,
        this.producttypeId,
        this.productgradeId,
        this.currency,
        this.productPrice,
        this.unit,
        this.unitOfPrice,
        this.location,
        this.productQty,
        this.colorId,
        this.description,
        this.latitude,
        this.longitude,
        this.imageCounter,
        this.city,
        this.state,
        this.country,
        this.stepCounter,
        this.productName,
        this.categoryId});

  AddPostRequest.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userToken = json['userToken'];
    producttypeId = json['producttype_id'];
    productgradeId = json['productgrade_id'];
    currency = json['currency'];
    productPrice = json['product_price'];
    unit = json['unit'];
    unitOfPrice = json['unit_of_price'];
    location = json['location'];
    productQty = json['product_qty'];
    colorId = json['color_id'];
    description = json['description'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    imageCounter = json['image_counter'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    stepCounter = json['step_counter'];
    productName = json['product_name'];
    categoryId = json['category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['userToken'] = this.userToken;
    data['producttype_id'] = this.producttypeId;
    data['productgrade_id'] = this.productgradeId;
    data['currency'] = this.currency;
    data['product_price'] = this.productPrice;
    data['unit'] = this.unit;
    data['unit_of_price'] = this.unitOfPrice;
    data['location'] = this.location;
    data['product_qty'] = this.productQty;
    data['color_id'] = this.colorId;
    data['description'] = this.description;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['image_counter'] = this.imageCounter;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['step_counter'] = this.stepCounter;
    data['product_name'] = this.productName;
    data['category_id'] = this.categoryId;
    return data;
  }
}