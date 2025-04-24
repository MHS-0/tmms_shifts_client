import 'package:flutter/material.dart';

const byDateAscQueryValue = "by_date_asc";
const byDateDescQueryValue = "by_date_desc";
const byStationAscQueryValue = "by_station_asc";
const byStationDescQueryValue = "by_station_desc";

enum SortSelection {
  byDateAsc,
  byDateDesc,
  byStationAlphabeticAsc,
  byStationAlphabeticDesc,
}

class SortProvider extends ChangeNotifier {
  SortSelection get selectedSort => _selectedSort;
  int? get selectedCustomSort => _selectedCustomSort;

  SortSelection _selectedSort;
  int? _selectedCustomSort;

  static String sortSelectionToString(SortSelection sort) {
    final String result;
    switch (sort) {
      case SortSelection.byDateAsc:
        result = byDateAscQueryValue;
        break;
      case SortSelection.byStationAlphabeticAsc:
        result = byStationAscQueryValue;
        break;
      case SortSelection.byStationAlphabeticDesc:
        result = byStationDescQueryValue;
        break;
      default:
        result = byDateDescQueryValue;
        break;
    }
    return result;
  }

  static SortSelection stringToSortSelection(String sort) {
    final SortSelection result;
    switch (sort) {
      case byDateAscQueryValue:
        result = SortSelection.byDateAsc;
        break;
      case byStationAscQueryValue:
        result = SortSelection.byStationAlphabeticAsc;
        break;
      case byStationDescQueryValue:
        result = SortSelection.byStationAlphabeticDesc;
        break;
      default:
        result = SortSelection.byDateDesc;
        break;
    }
    return result;
  }

  SortProvider([SortSelection sort = SortSelection.byDateDesc, int? customSort])
    : _selectedSort = sort,
      _selectedCustomSort = customSort;

  factory SortProvider.fromQuery(String? query, String? customSortQuery) {
    final sort = query ?? byDateDescQueryValue;
    return SortProvider(
      stringToSortSelection(sort),
      int.tryParse(customSortQuery ?? ""),
    );
  }

  void setSelectedSort(SortSelection sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void setSelectedCustomSort(int? id) {
    _selectedCustomSort = id;
    notifyListeners();
  }
}
