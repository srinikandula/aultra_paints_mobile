class IndentCreation {
  String requestTypeValue = "consignment";
  String customerName = "Select a Customer";
  String customerCode = "";
  String customerId = "";
  String consignorName = "Select a consignor";
  String consignorCode = "";
  String consignorId = "";
  String consigneeName = "Select a consignee";
  String consigneeCode = "";
  String consigneeId = "";
  String serviceType = "Select a Service";
  String serviceId = "";
  String serviceOptionId = "";
  String productName = "Select a Product";
  String productId = "";
  String productQuantity = "";

  String email = "";
  String name = "";

  String phoneNumber = "";
  String incidentType = "";
  String natureOfOccurence = "";
  String damageType = "";
  String locationName = "";
  String siteType = "";
  String region = "";
  String service = "";
  late List<String> propertyDamage = [];

  IndentCreation();
  IndentCreation.fromMap(Map<String, dynamic> data) {
    print('@@@@@@@@@@@#########====>$data');

    requestTypeValue = data['requestTypeValue'];
    customerName = data['customerName'];
    customerCode = data['customerCode'];
    customerId = data['customerId'];
    consignorName = data['consignorName'];
    consignorCode = data['consignorCode'];
    consignorId = data['consignorId'];
    consigneeName = data['consigneeName'];
    consigneeCode = data['consigneeCode'];
    consigneeId = data['consigneeId'];
    serviceType = data['serviceType'];
    serviceId = data['serviceId'];
    serviceOptionId = data['serviceOptionId'];
    productName = data['productName'];
    productId = data['productId'];
    productQuantity = data['productQuantity'];
  }

  // get imagesList => null;

  Map<String, dynamic> toMap() {
    return {
      'requestTypeValue': requestTypeValue,
      'customerName': customerName,
      'customerCode': customerCode,
      'customerId': customerId,
      'consignorName': consignorName,
      'consignorCode': consignorCode,
      'consignorId': consignorId,
      'consigneeName': consigneeName,
      'consigneeCode': consigneeCode,
      'consigneeId': consigneeId,
      'serviceType': serviceType,
      'serviceId': serviceId,
      'serviceOptionId': serviceOptionId,
      'productName': productName,
      'productId': productId,
      'productQuantity': productQuantity
    };
  }
}
