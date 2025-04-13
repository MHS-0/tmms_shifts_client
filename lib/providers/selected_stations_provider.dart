import 'package:flutter/material.dart';

class SelectedStationsProvider extends ChangeNotifier {
  List<int> get selectedStations => _selectedStations;
  int? get singleSelectedStation => _singleSelectedStation;

  late final List<int> _selectedStations;
  int? _singleSelectedStation;

  SelectedStationsProvider({
    List<int>? selectedStationsParam,
    int? singleSelectedStationParam,
  }) : _selectedStations = selectedStationsParam ?? [],
       _singleSelectedStation = singleSelectedStationParam;

  void setSingleSelectedStation(int? code) {
    _singleSelectedStation = code;
    notifyListeners();
  }

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
