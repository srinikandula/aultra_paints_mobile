
import 'dart:convert';

class EPOD {
  String LR_NUMBER = "";

  String CONSIGNER = "";
  String CONSIGNER_ADDRESS = "";

  String CONSIGNEE = "";
  String CONSIGNEE_ADDRESS = "";

  String BA_CODE = "";
  String FROM_LOCATION = "";
  String TO_LOCATION = "";

  String LR_VOLUME = "";

  String VEHICLE_NO = "";
  String VEHICLE_TYPE_NAME = "";
  String Dispatch_Date = "";
  String Delivery_Date = "";

  String file = "";
  bool isSignaturesDone = false;


  EPOD();
  EPOD.fromMap(Map<String, dynamic> map) {
    if (map['LR_NUMBER'] != null) {LR_NUMBER = map['LR_NUMBER'];}

    if (map['CONSIGNER'] != null) {CONSIGNER = map['CONSIGNER'];}

    if (map['CONSIGNER_ADDRESS'] != null) {CONSIGNER_ADDRESS = map['CONSIGNER_ADDRESS'];}

    if (map['CONSIGNEE'] != null) {CONSIGNEE = map['CONSIGNEE'];}

    if (map['CONSIGNEE_ADDRESS'] != null) {CONSIGNEE_ADDRESS = map['CONSIGNEE_ADDRESS'];}

    if (map['BA_CODE'] != null) {BA_CODE = map['BA_CODE'];}

    if (map['FROM_LOCATION'] != null) {FROM_LOCATION = map['FROM_LOCATION'];}

    if (map['TO_LOCATION'] != null) {TO_LOCATION = map['TO_LOCATION'];}

    if (map['LR_VOLUME'] != null) {LR_VOLUME = map['LR_VOLUME'];}

    if (map['VEHICLE_NO'] != null) {VEHICLE_NO = map['VEHICLE_NO'];}

    if (map['VEHICLE_TYPE_NAME'] != null) {VEHICLE_TYPE_NAME = map['VEHICLE_TYPE_NAME'];}

    if (map['Dispatch_Date'] != null) {Dispatch_Date = map['Dispatch_Date'];}

    if (map['Delivery_Date'] != null) {Delivery_Date = map['Delivery_Date'];}

    if (map['file'] != null) {file = map['file'];}

    if (map['isSignaturesDone'] != null) {isSignaturesDone = map['isSignaturesDone'];}
  }

  Map<String, dynamic> toMap() {
    return {
      'LR_NUMBER': LR_NUMBER,
      'CONSIGNER': CONSIGNER,
      'CONSIGNER_ADDRESS': CONSIGNER_ADDRESS,
      'CONSIGNEE': CONSIGNEE,
      'CONSIGNEE_ADDRESS': CONSIGNEE_ADDRESS,
      'BA_CODE': BA_CODE,
      'FROM_LOCATION': FROM_LOCATION,
      'TO_LOCATION': TO_LOCATION,
      'LR_VOLUME': LR_VOLUME,
      'VEHICLE_NO': VEHICLE_NO,
      'VEHICLE_TYPE_NAME': VEHICLE_TYPE_NAME,
      'Dispatch_Date': Dispatch_Date,
      'Delivery_Date': Delivery_Date,
      'file': file,
      'isSignaturesDone': isSignaturesDone,
    };
  }
}
