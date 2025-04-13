// TODO
// Constants related to assets defined in pubspec.yaml
// const robotoFontFamily = 'Roboto';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

const iconAssetPath = "assets/images/logo.png";
const userIconAssetPath = "assets/images/user.jpg";

const iconAssetImage = AssetImage(iconAssetPath);
const userIconAssetImage = AssetImage(userIconAssetPath);

const dataTableHeaderRowColumnWidthMinimum = 150.0;

const offsetAll16p = EdgeInsets.all(16);
const offsetAll32p = EdgeInsets.all(32);

const trashcanIcon = Icon(Icons.delete);

final dateFormatterWithHour = DateFormat("HH:mm yyyy-MM-dd");
final dateFormatter = DateFormat("dd-MM-yyyy");

final jalaliFirstAcceptableDate = Jalali(1350);
