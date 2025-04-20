import 'package:flutter/material.dart';

enum SortSelection {
  none,
  byDateAsc,
  byDateDesc,
  byUserAlphabetAsc,
  byUserAlphabetDesc,
}

class SortProvider extends ChangeNotifier {
  SortSelection get selectedSort => _selectedSort;

  SortSelection _selectedSort;

  SortProvider([SortSelection sort = SortSelection.none])
    : _selectedSort = sort;

  void setSelectedStations(SortSelection sort) {
    _selectedSort = sort;
    notifyListeners();
  }
}
