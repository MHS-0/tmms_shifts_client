import 'package:flutter/material.dart';

class SelectedStationsProvider extends ChangeNotifier {
  List<int> get selectedStations => _selectedStations;
  int? get singleSelectedStation => _singleSelectedStation;

  List<int> _selectedStations = [];
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

  void setSelectedStations(List<int> list) {
    _selectedStations = list;
    notifyListeners();
  }
}
