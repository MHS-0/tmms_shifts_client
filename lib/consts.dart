// TODO
// Constants related to assets defined in pubspec.yaml
// const robotoFontFamily = 'Roboto';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

const iconAssetPath = "assets/images/logo.png";
const userIconAssetPath = "assets/images/user.jpg";

const iconAssetImage = AssetImage(iconAssetPath);
const userIconAssetImage = AssetImage(userIconAssetPath);

const dataTableHeaderRowColumnWidthMinimum = 150.0;

const titleRowsFontSize = 18.0;

const boldTextStyle = TextStyle(fontWeight: FontWeight.bold);
const titleRowTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: titleRowsFontSize,
);

const offsetAll8p = EdgeInsets.all(8);
const offsetAll16p = EdgeInsets.all(16);
const offsetAll32p = EdgeInsets.all(32);

const trashcanIcon = Icon(Icons.delete);
const selectedCheckIcon = Icon(Icons.check_circle, color: Colors.lightGreen);
const unselectedCheckIcon = Icon(Icons.circle_outlined, color: Colors.red);

const centeredCircularProgressIndicator = Center(
  child: CircularProgressIndicator(),
);

final sharedLogger = Logger("Shared Logger");

const cancelledMessage = "CANCELLED";

final dateFormatterWithHour = DateFormat("HH:mm yyyy-MM-dd");
final dateFormatter = DateFormat("dd-MM-yyyy");

final jalaliFirstAcceptableDate = Jalali(1350);
