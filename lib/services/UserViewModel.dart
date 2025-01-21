import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier {
  String _parentDealerCode = '';

  String get parentDealerCode => _parentDealerCode;

  void setParentDealerCode(String value) {
    _parentDealerCode = value;
    notifyListeners(); // Notify listeners about the change
  }
}
