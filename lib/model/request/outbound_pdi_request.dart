class OutboundPDIRequest {
  int defectId = 0;
  String remark = "";
  String severity = "";
  List<dynamic> images;
  String defectSubLocation = "";
  String defectLocation = "";


  OutboundPDIRequest({required this.defectId, required this.remark, required this.severity,
  required this.images , required this.defectSubLocation, required this.defectLocation});

  factory OutboundPDIRequest.fromJson(Map<String, dynamic> json) {
    return OutboundPDIRequest(
      defectId: json['defectId'],
      remark: json['remark'],
      severity: json['severity'],
      images: json['images'],
      defectSubLocation: json['defectSubLocation'],
      defectLocation: json['defectLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defectId': defectId,
      'remark': remark,
      'severity': severity,
      'images': images,
      'defectSubLocation': defectSubLocation,
      'defectLocation': defectLocation,
    };
  }
}
