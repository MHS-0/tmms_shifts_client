import 'package:flutter/material.dart';

class SelectedRanProvider extends ChangeNotifier {
  int get selectedRan => _selectedRan;

  int _selectedRan = 1;

  void setSelectedRan(int ranCode) {
    _selectedRan = ranCode;
    notifyListeners();
  }
}
