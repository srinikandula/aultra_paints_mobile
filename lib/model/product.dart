import 'dart:convert';

class Product {
  int id = 0;
  int productId = 0;
  String productName = "";
  String qty = "";
  int qtyP = 0;
  String uom = "";
  String doNumber = "";

  Product();
  Product.fromMap(Map<String, dynamic> map) {
    if (map['id'] != null) {
      id = map['id'];
    }

    if (map['productId'] != null) {
      productId = map['productId'];
    }

    if (map['productName'] != null) {
      productName = map['productName'];
    }

    if (map['qty'] != null && map['qty'] is String) {
      qty = map['qty'];
    }

    if (map['qty'] != null && map['qty'] is int) {
      qtyP = map['qty'];
    }

    if (map['uom'] != null) {
      uom = map['uom'];
    }

    if (map['doNumber'] != null) {
      doNumber = map['doNumber'];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'qty': qty,
      'uom': uom,
      'doNumber': doNumber
    };
  }
}
