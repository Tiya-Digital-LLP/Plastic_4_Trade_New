class RazorpayOrderResponse {
  final int status;
  final String razorpayOrderId;
  final int paisa;

  RazorpayOrderResponse({
    required this.status,
    required this.razorpayOrderId,
    required this.paisa,
  });

  // Factory method to create an instance from JSON
  factory RazorpayOrderResponse.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderResponse(
      status: json['status'],
      razorpayOrderId: json['razorpayOrderId'],
      paisa: json['paisa'],
    );
  }
}
