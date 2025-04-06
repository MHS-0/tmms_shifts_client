import 'package:flutter/material.dart';

class SelectedStationsProvider extends ChangeNotifier {
  List<int> get selectedStations => _selectedStations;

  final List<int> _selectedStations = [];

  void addStation(int code) {
    _selectedStations.add(code);
    notifyListeners();
  }

  void removeStation(int code) {
    _selectedStations.remove(code);
    notifyListeners();
  }

  void clearStations() {
    _selectedStations.clear();
    notifyListeners();
  }
}
