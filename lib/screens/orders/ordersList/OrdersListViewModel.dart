import 'package:flutter/material.dart';

class OrdersListViewModel with ChangeNotifier {
  bool? _isCheckedDriver = false;
  bool? get isCheckedDriver => _isCheckedDriver;

  bool? _isCheckedVehicle = false;
  bool? get isCheckedVehicle => _isCheckedVehicle;

  void isCheckedDriverFunc(bool? value) {
    _isCheckedDriver = value;
    notifyListeners();
  }

  void isCheckedVehicleFunc(bool? value) {
    _isCheckedVehicle = value;
    notifyListeners();
  }
}
