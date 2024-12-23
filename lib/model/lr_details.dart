
import 'dart:convert';

class LRDetails {
  String LrNumber = "";
  String Vin = "";
  String ShipmentID = "";
  String Response = "";
  String cleanpod = "";
  String vehicleReceived = "";
  String PDIStatus = "";
  String PdiEntered = "";
  String Url = "";
  String EPODStatus = "";
  String epodfilename = "";
  String invoiceNumber = "";
  String doNumber = "";


  LRDetails();
  LRDetails.fromMap(Map<String, dynamic> map) {
    if (map['LrNumber'] != null) {LrNumber = map['LrNumber'];}
    if (map['lrNumber'] != null) {LrNumber = map['lrNumber'];}
    if (map['Vin'] != null) {Vin = map['Vin'];}
    if (map['ShipmentID'] != null) {ShipmentID = map['ShipmentID'];}
    if (map['Response'] != null) {Response = map['Response'];}
    if (map['cleanpod'] != null) {cleanpod = map['cleanpod'];}
    if (map['vehicleReceived'] != null) {vehicleReceived = map['vehicleReceived'];}
    if (map['PDIStatus'] != null) {PDIStatus = map['PDIStatus'];}
    if (map['invoiceNumber'] != null) {invoiceNumber = map['invoiceNumber'];}
    if (map['doNumber'] != null) {doNumber = map['doNumber'];}
  }

  Map<String, dynamic> toMap() {
    return {
      'LrNumber': LrNumber,
      'ShipmentID': ShipmentID,
      'Response': Response,
      'cleanpod': cleanpod,
      'vehicleReceived': vehicleReceived,
      'PDIStatus': PDIStatus,
      'invoiceNumber': invoiceNumber,
      'doNumber': doNumber,
    };
  }
}
