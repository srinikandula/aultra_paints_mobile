class InboundPDIRequest {
  int id = 0;
  int productId = 0;
  int defectId = 0;
  String qty = "";
  List<dynamic> images;

  InboundPDIRequest({required this.id, required this.productId, required this.defectId, required this.qty,  required this.images});

  factory InboundPDIRequest.fromJson(Map<String, dynamic> json) {
    return InboundPDIRequest(
      id: json['pridoductId'],
      productId: json['productId'],
      defectId: json['defectId'],
      qty: json['qty'],
      images: json['images'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'defectId': defectId,
      'qty': qty,
      'images': images,
    };
  }
}
