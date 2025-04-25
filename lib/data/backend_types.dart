import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';

part 'backend_types.g.dart';

const fromDateKey = "from_date";
const toDateKey = "to_date";
const sortByKey = "sort_by";
const customSortKey = "custom_sort";
const stationCodesKey = "station_codes";
const stationCodeKey = "station_code";

@JsonSerializable(explicitToJson: true)
class ToFromDateStationsQuery {
  @JsonKey(name: toDateKey, includeIfNull: false)
  final String? toDate;
  @JsonKey(name: fromDateKey, includeIfNull: false)
  final String? fromDate;
  @JsonKey(
    name: stationCodesKey,
    includeIfNull: false,
    toJson: Helpers.serializeIntListIntoCommaSeperatedString,
  )
  final List<int>? stationCodes;

  const ToFromDateStationsQuery({
    this.toDate,
    this.fromDate,
    this.stationCodes,
  });

  factory ToFromDateStationsQuery.fromContext(BuildContext context) {
    final datePickerState = context.read<DatePickerProvider>();
    final selectedStationsState = context.read<SelectedStationsProvider>();
    final selectedStations = selectedStationsState.selectedStations;

    final String? fromDateParam;
    final String? toDateParam;
    {
      final fromDate = datePickerState.fromDate;
      final toDate = datePickerState.toDate;
      fromDateParam =
          fromDate != null ? Helpers.jalaliToDashDate(fromDate) : null;
      toDateParam = toDate != null ? Helpers.jalaliToDashDate(toDate) : null;
    }

    return ToFromDateStationsQuery(
      fromDate: fromDateParam,
      toDate: toDateParam,
      stationCodes: selectedStations,
    );
  }

  factory ToFromDateStationsQuery.fromJson(Map<String, dynamic> json) =>
      _$ToFromDateStationsQueryFromJson(json);
  Map<String, dynamic> toJson() => _$ToFromDateStationsQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ToFromDateQuery {
  @JsonKey(name: toDateKey, includeIfNull: false)
  final String? toDate;
  @JsonKey(name: fromDateKey, includeIfNull: false)
  final String? fromDate;

  const ToFromDateQuery({this.toDate, this.fromDate});

  factory ToFromDateQuery.fromJson(Map<String, dynamic> json) =>
      _$ToFromDateQueryFromJson(json);
  Map<String, dynamic> toJson() => _$ToFromDateQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StationsQuery {
  @JsonKey(
    name: stationCodesKey,
    includeIfNull: false,
    toJson: Helpers.serializeIntListIntoCommaSeperatedString,
  )
  final List<int>? stationCodes;

  const StationsQuery({this.stationCodes});

  factory StationsQuery.fromJson(Map<String, dynamic> json) =>
      _$StationsQueryFromJson(json);
  Map<String, dynamic> toJson() => _$StationsQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SingleStationQuery {
  @JsonKey(name: stationCodeKey)
  final int stationCode;

  const SingleStationQuery(this.stationCode);

  factory SingleStationQuery.fromJson(Map<String, dynamic> json) =>
      _$SingleStationQueryFromJson(json);
  Map<String, dynamic> toJson() => _$SingleStationQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({required this.username, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LoginResponse {
  final DateTime expiry;
  final String token;
  final LoginResponseUser user;

  const LoginResponse({
    required this.expiry,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LoginResponseUser {
  final String? username;
  @JsonKey(name: 'is_staff')
  final bool isStaff;

  const LoginResponseUser({this.username, required this.isStaff});

  factory LoginResponseUser.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseUserToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetProfileResponse {
  final String username;
  final String? fullname;
  final List<Station> stations;
  @JsonKey(name: 'is_staff')
  final bool isStaff;

  const GetProfileResponse({
    required this.username,
    required this.isStaff,
    required this.stations,
    this.fullname,
  });

  factory GetProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$GetProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetProfileResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Station {
  final int code;
  final List<Ran> rans;
  @JsonKey(name: 'type_name')
  final String typeName;
  final String title;
  final String district;
  final String area;
  final int capacity;
  final int type;
  final int activity;

  const Station({
    required this.code,
    required this.rans,
    required this.typeName,
    required this.title,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
    required this.activity,
  });

  factory Station.fromJson(Map<String, dynamic> json) =>
      _$StationFromJson(json);

  Map<String, dynamic> toJson() => _$StationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Ran {
  final int code;
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber;
  final int station;

  const Ran({
    required this.code,
    required this.sequenceNumber,
    required this.station,
  });

  factory Ran.fromJson(Map<String, dynamic> json) => _$RanFromJson(json);

  Map<String, dynamic> toJson() => _$RanToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateShiftDataRequest {
  final int station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;

  factory CreateShiftDataRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateShiftDataRequestFromJson(json);

  const CreateShiftDataRequest({
    required this.station,
    required this.shift,
    required this.inputPressure,
    required this.outputPressure,
    required this.inputTemperature,
    required this.outputTemperature,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$CreateShiftDataRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateShiftDataResponse {
  final int station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601NullAware,
    toJson: Helpers.serializeJalaliIntoIso8601NullAware,
  )
  final Jalali? registeredDatetime;
  final String? user;

  factory CreateShiftDataResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateShiftDataResponseFromJson(json);

  const CreateShiftDataResponse({
    required this.registeredDatetime,
    required this.station,
    required this.shift,
    required this.inputPressure,
    required this.outputPressure,
    required this.inputTemperature,
    required this.outputTemperature,
    required this.date,
    required this.user,
  });

  Map<String, dynamic> toJson() => _$CreateShiftDataResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateShiftDataRequest {
  final int station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;

  factory UpdateShiftDataRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateShiftDataRequestFromJson(json);

  const UpdateShiftDataRequest({
    required this.station,
    required this.shift,
    required this.inputPressure,
    required this.outputPressure,
    required this.inputTemperature,
    required this.outputTemperature,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$UpdateShiftDataRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateShiftDataResponse {
  final int id;
  final int station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final String? user;

  factory UpdateShiftDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateShiftDataResponseFromJson(json);

  const UpdateShiftDataResponse({
    required this.id,
    this.user,
    required this.station,
    required this.registeredDatetime,
    required this.shift,
    required this.inputPressure,
    required this.outputPressure,
    required this.inputTemperature,
    required this.outputTemperature,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$UpdateShiftDataResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetShiftDataResponse {
  final int id;
  final int station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final String? user;

  factory GetShiftDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetShiftDataResponseFromJson(json);

  const GetShiftDataResponse({
    required this.id,
    this.user,
    required this.station,
    required this.shift,
    required this.inputPressure,
    required this.outputPressure,
    required this.inputTemperature,
    required this.registeredDatetime,
    required this.outputTemperature,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$GetShiftDataResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetShiftLastActionResponse {
  final int id;
  final int station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final String? user;

  factory GetShiftLastActionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetShiftLastActionResponseFromJson(json);

  const GetShiftLastActionResponse({
    required this.id,
    this.user,
    required this.station,
    required this.shift,
    required this.inputPressure,
    required this.outputPressure,
    required this.inputTemperature,
    required this.outputTemperature,
    required this.registeredDatetime,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$GetShiftLastActionResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetShiftsDataListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<GetShiftDataResponse> results;

  factory GetShiftsDataListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetShiftsDataListResponseFromJson(json);

  const GetShiftsDataListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() => _$GetShiftsDataListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateCorrectorRequest {
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;

  factory CreateCorrectorRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCorrectorRequestFromJson(json);

  const CreateCorrectorRequest({
    required this.date,
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
  });

  Map<String, dynamic> toJson() => _$CreateCorrectorRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateCorrectorResponse {
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601NullAware,
    toJson: Helpers.serializeJalaliIntoIso8601NullAware,
  )
  final Jalali? registeredDatetime;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;
  @JsonKey(name: 'station_code')
  final int stationCode;
  final String? user;

  factory CreateCorrectorResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateCorrectorResponseFromJson(json);

  const CreateCorrectorResponse({
    required this.date,
    this.registeredDatetime,
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
    required this.stationCode,
    this.user,
  });

  Map<String, dynamic> toJson() => _$CreateCorrectorResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateCorrectorRequest {
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;

  factory UpdateCorrectorRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCorrectorRequestFromJson(json);

  const UpdateCorrectorRequest({
    required this.date,
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
  });

  Map<String, dynamic> toJson() => _$UpdateCorrectorRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateCorrectorResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601NullAware,
    toJson: Helpers.serializeJalaliIntoIso8601NullAware,
  )
  final Jalali? registeredDatetime;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;
  final String? user;

  factory UpdateCorrectorResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateCorrectorResponseFromJson(json);

  const UpdateCorrectorResponse({
    required this.id,
    required this.date,
    this.registeredDatetime,
    required this.stationCode,
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
    this.user,
  });

  Map<String, dynamic> toJson() => _$UpdateCorrectorResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetCorrectorDataListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<GetCorrectorDataResponse> results;

  factory GetCorrectorDataListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCorrectorDataListResponseFromJson(json);

  const GetCorrectorDataListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() => _$GetCorrectorDataListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetCorrectorDataResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601NullAware,
    toJson: Helpers.serializeJalaliIntoIso8601NullAware,
  )
  final Jalali? registeredDatetime;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;
  final String? user;

  factory GetCorrectorDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCorrectorDataResponseFromJson(json);

  const GetCorrectorDataResponse({
    required this.id,
    required this.date,
    this.registeredDatetime,
    required this.stationCode,
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
    this.user,
  });

  Map<String, dynamic> toJson() => _$GetCorrectorDataResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetMeterAndCorrectorFullReportResponse {
  final int count;
  final String? next;
  final String? previous;
  List<GetMeterAndCorrectorFullReportResponseResultItem> results;

  factory GetMeterAndCorrectorFullReportResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMeterAndCorrectorFullReportResponseFromJson(json);

  GetMeterAndCorrectorFullReportResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() =>
      _$GetMeterAndCorrectorFullReportResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetMeterAndCorrectorFullReportResponseResultItem {
  @JsonKey(name: 'station_code')
  final int stationCode;
  final String? user;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601NullAware,
    toJson: Helpers.serializeJalaliIntoIso8601NullAware,
  )
  final Jalali? registeredDatetime;
  final List<Ran2> rans;

  factory GetMeterAndCorrectorFullReportResponseResultItem.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMeterAndCorrectorFullReportResponseResultItemFromJson(json);

  const GetMeterAndCorrectorFullReportResponseResultItem({
    required this.stationCode,
    this.user,
    required this.date,
    this.registeredDatetime,
    required this.rans,
  });

  Map<String, dynamic> toJson() =>
      _$GetMeterAndCorrectorFullReportResponseResultItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Ran2 {
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'corrector_amount')
  final int correctorAmount;
  @JsonKey(name: 'corrector_meter_amount')
  final int correctorMeterAmount;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  final int ran;

  const Ran2({
    required this.meterAmount,
    required this.correctorAmount,
    required this.correctorMeterAmount,
    required this.ranSequence,
    required this.ran,
  });

  factory Ran2.fromJson(Map<String, dynamic> json) => _$Ran2FromJson(json);

  Map<String, dynamic> toJson() => _$Ran2ToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetMonitoringFullReportResponse {
  final int count;
  final String? next;
  final String? previous;
  List<GetMonitoringFullReportResponseResultItem> results;

  factory GetMonitoringFullReportResponse.fromJson(Map<String, dynamic> json) =>
      _$GetMonitoringFullReportResponseFromJson(json);

  GetMonitoringFullReportResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() =>
      _$GetMonitoringFullReportResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetMonitoringFullReportResponseResultItem {
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  final List<Shift> shifts;
  final int? consumption;
  @JsonKey(name: 'average_consumption')
  final int? averageConsumption;

  factory GetMonitoringFullReportResponseResultItem.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMonitoringFullReportResponseResultItemFromJson(json);

  const GetMonitoringFullReportResponseResultItem({
    required this.stationCode,
    required this.date,
    required this.shifts,
    this.consumption,
    this.averageConsumption,
  });

  Map<String, dynamic> toJson() =>
      _$GetMonitoringFullReportResponseResultItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Shift {
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601NullAware,
    toJson: Helpers.serializeJalaliIntoIso8601NullAware,
  )
  final Jalali? registeredDatetime;
  final String? user;
  final String shift;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  const Shift({
    required this.inputPressure,
    required this.outputPressure,
    required this.inputTemperature,
    required this.outputTemperature,
    this.registeredDatetime,
    this.user,
    required this.shift,
  });

  Map<String, dynamic> toJson() => _$ShiftToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetPressureAndTemperatureFullReportResponse {
  final int count;
  final String? next;
  final String? previous;
  List<GetPressureAndTemperatureFullReportResponseResultItem> results;

  factory GetPressureAndTemperatureFullReportResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetPressureAndTemperatureFullReportResponseFromJson(json);

  GetPressureAndTemperatureFullReportResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() =>
      _$GetPressureAndTemperatureFullReportResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetPressureAndTemperatureFullReportResponseResultItem {
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  final List<Shift> shifts;

  factory GetPressureAndTemperatureFullReportResponseResultItem.fromJson(
    Map<String, dynamic> json,
  ) => _$GetPressureAndTemperatureFullReportResponseResultItemFromJson(json);

  const GetPressureAndTemperatureFullReportResponseResultItem({
    required this.stationCode,
    required this.date,
    required this.shifts,
  });

  Map<String, dynamic> toJson() =>
      _$GetPressureAndTemperatureFullReportResponseResultItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetMeterChangeEventResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final int ran;
  final String? user;

  factory GetMeterChangeEventResponse.fromJson(Map<String, dynamic> json) =>
      _$GetMeterChangeEventResponseFromJson(json);

  const GetMeterChangeEventResponse({
    required this.id,
    required this.ranSequence,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.registeredDatetime,
    required this.ran,
    this.user,
    required this.stationCode,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$GetMeterChangeEventResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateMeterChangeEventRequest {
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  final int ran;

  factory CreateMeterChangeEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMeterChangeEventRequestFromJson(json);

  const CreateMeterChangeEventRequest({
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.ran,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$CreateMeterChangeEventRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateMeterChangeEventResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final int ran;
  final String? user;

  factory CreateMeterChangeEventResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateMeterChangeEventResponseFromJson(json);

  const CreateMeterChangeEventResponse({
    required this.id,
    required this.ranSequence,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.registeredDatetime,
    required this.ran,
    this.user,
    required this.stationCode,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$CreateMeterChangeEventResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetMeterChangeEventsListResponse {
  final int count;
  final String? next;
  final String? previous;
  List<GetMeterChangeEventResponse> results;

  factory GetMeterChangeEventsListResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMeterChangeEventsListResponseFromJson(json);

  GetMeterChangeEventsListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() =>
      _$GetMeterChangeEventsListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateMeterChangeEventRequest {
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  final int ran;

  factory UpdateMeterChangeEventRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMeterChangeEventRequestFromJson(json);

  const UpdateMeterChangeEventRequest({
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.ran,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$UpdateMeterChangeEventRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateMeterChangeEventResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final int ran;
  final String? user;

  factory UpdateMeterChangeEventResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateMeterChangeEventResponseFromJson(json);

  const UpdateMeterChangeEventResponse({
    required this.id,
    required this.ranSequence,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.registeredDatetime,
    required this.ran,
    this.user,
    required this.stationCode,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$UpdateMeterChangeEventResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetMeterChangeEventLastActionResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final int ran;
  final String? user;

  factory GetMeterChangeEventLastActionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMeterChangeEventLastActionResponseFromJson(json);

  const GetMeterChangeEventLastActionResponse({
    required this.id,
    required this.ranSequence,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.registeredDatetime,
    required this.ran,
    this.user,
    required this.stationCode,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      _$GetMeterChangeEventLastActionResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateCorrectorBulkRequest {
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  final List<Ran3> rans;

  const PostCreateCorrectorBulkRequest({
    required this.date,
    required this.rans,
  });

  factory PostCreateCorrectorBulkRequest.fromJson(Map<String, dynamic> json) =>
      _$PostCreateCorrectorBulkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PostCreateCorrectorBulkRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Ran3 {
  @JsonKey(name: 'meter_amount')
  final String meterAmount;
  @JsonKey(name: 'correction_amount')
  final String correctionAmount;
  final String ran;

  const Ran3({
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
  });

  factory Ran3.fromJson(Map<String, dynamic> json) => _$Ran3FromJson(json);

  Map<String, dynamic> toJson() => _$Ran3ToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateCorrectorBulkResponse {
  final int station;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  final List<Ran4> rans;

  const PostCreateCorrectorBulkResponse({
    required this.station,
    required this.date,
    required this.rans,
  });

  factory PostCreateCorrectorBulkResponse.fromJson(Map<String, dynamic> json) =>
      _$PostCreateCorrectorBulkResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PostCreateCorrectorBulkResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Ran4 {
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  final int ran;

  const Ran4({
    required this.ranSequence,
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
  });

  factory Ran4.fromJson(Map<String, dynamic> json) => _$Ran4FromJson(json);

  Map<String, dynamic> toJson() => _$Ran4ToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PutUpdateCorrectorBulkRequest {
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  final List<Ran3> rans;

  const PutUpdateCorrectorBulkRequest({required this.date, required this.rans});

  factory PutUpdateCorrectorBulkRequest.fromJson(Map<String, dynamic> json) =>
      _$PutUpdateCorrectorBulkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PutUpdateCorrectorBulkRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PutUpdateCorrectorBulkResponse {
  final int station;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  final List<Ran4> rans;
  final String? user;

  const PutUpdateCorrectorBulkResponse({
    required this.station,
    required this.date,
    required this.rans,
    this.user,
  });

  factory PutUpdateCorrectorBulkResponse.fromJson(Map<String, dynamic> json) =>
      _$PutUpdateCorrectorBulkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PutUpdateCorrectorBulkResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetCorrectorDataBulkLastActionResponse {
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  final List<Ran2> rans;
  final String? user;

  const GetCorrectorDataBulkLastActionResponse({
    required this.stationCode,
    required this.date,
    required this.rans,
    this.user,
  });

  factory GetCorrectorDataBulkLastActionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetCorrectorDataBulkLastActionResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GetCorrectorDataBulkLastActionResponseToJson(this);
}

/// IMPORTANT: The response is a list and not a json object that can be
/// parsed into Map\<String, dynamic\>
@JsonSerializable(explicitToJson: true)
class GetCorrectorDataBulkLastActionResponseListItem {
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  final List<Ran4> rans;

  const GetCorrectorDataBulkLastActionResponseListItem({
    required this.date,
    required this.rans,
  });

  factory GetCorrectorDataBulkLastActionResponseListItem.fromJson(
    Map<String, dynamic> json,
  ) => _$GetCorrectorDataBulkLastActionResponseListItemFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GetCorrectorDataBulkLastActionResponseListItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetShiftDataBulkLastActionResponse {
  final int id;
  final int station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final String? user;

  factory GetShiftDataBulkLastActionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetShiftDataBulkLastActionResponseFromJson(json);

  const GetShiftDataBulkLastActionResponse({
    required this.id,
    this.user,
    required this.station,
    required this.registeredDatetime,
    required this.shift,
    required this.inputPressure,
    required this.outputPressure,
    required this.inputTemperature,
    required this.outputTemperature,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      _$GetShiftDataBulkLastActionResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetStationDataListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<GetStationDataResponse> results;

  factory GetStationDataListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetStationDataListResponseFromJson(json);

  const GetStationDataListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() => _$GetStationDataListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetStationDataResponse {
  final String code;
  final List<Ran5> rans;
  final String type;
  final String name;
  final String district;
  final String area;
  final int capacity;

  const GetStationDataResponse({
    required this.name,
    required this.code,
    required this.rans,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
  });

  factory GetStationDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetStationDataResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetStationDataResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Ran5 {
  final int id;
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber;
  final String station;

  const Ran5({
    required this.id,
    required this.sequenceNumber,
    required this.station,
  });

  factory Ran5.fromJson(Map<String, dynamic> json) => _$Ran5FromJson(json);

  Map<String, dynamic> toJson() => _$Ran5ToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetStationTypeDataListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<GetStationTypeDataResponse> results;

  factory GetStationTypeDataListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetStationTypeDataListResponseFromJson(json);

  const GetStationTypeDataListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() => _$GetStationTypeDataListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetStationTypeDataResponse {
  @JsonKey(name: 'type_name')
  final String typeName;

  factory GetStationTypeDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetStationTypeDataResponseFromJson(json);

  const GetStationTypeDataResponse({required this.typeName});

  Map<String, dynamic> toJson() => _$GetStationTypeDataResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateStationRequest {
  final int code;
  final String name;
  final String district;
  final String area;
  final int capacity;
  final int type;

  factory PostCreateStationRequest.fromJson(Map<String, dynamic> json) =>
      _$PostCreateStationRequestFromJson(json);

  const PostCreateStationRequest({
    required this.code,
    required this.name,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
  });

  Map<String, dynamic> toJson() => _$PostCreateStationRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateStationResponse {
  final String code;
  final List<Ran> rans;
  @JsonKey(name: 'type_name')
  final String typeName;
  final String name;
  final String district;
  final String area;
  final int capacity;
  final int type;

  const PostCreateStationResponse({
    required this.code,
    required this.rans,
    required this.typeName,
    required this.name,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
  });

  factory PostCreateStationResponse.fromJson(Map<String, dynamic> json) =>
      _$PostCreateStationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PostCreateStationResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateStationTypeRequest {
  @JsonKey(name: 'type_name')
  final String typeName;

  factory PostCreateStationTypeRequest.fromJson(Map<String, dynamic> json) =>
      _$PostCreateStationTypeRequestFromJson(json);

  const PostCreateStationTypeRequest({required this.typeName});

  Map<String, dynamic> toJson() => _$PostCreateStationTypeRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateStationTypeResponse {
  @JsonKey(name: 'type_name')
  final String typeName;

  factory PostCreateStationTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$PostCreateStationTypeResponseFromJson(json);

  const PostCreateStationTypeResponse({required this.typeName});

  Map<String, dynamic> toJson() => _$PostCreateStationTypeResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PutUpdateStationDataRequest {
  final int code;
  final String name;
  final String district;
  final String area;
  final int capacity;
  final int type;

  factory PutUpdateStationDataRequest.fromJson(Map<String, dynamic> json) =>
      _$PutUpdateStationDataRequestFromJson(json);

  const PutUpdateStationDataRequest({
    required this.code,
    required this.name,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
  });

  Map<String, dynamic> toJson() => _$PutUpdateStationDataRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PutUpdateStationDataResponse {
  final String code;
  final List<Ran> rans;
  @JsonKey(name: 'type_name')
  final String typeName;
  final String name;
  final String district;
  final String area;
  final int capacity;
  final int type;

  const PutUpdateStationDataResponse({
    required this.code,
    required this.rans,
    required this.typeName,
    required this.name,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
  });

  factory PutUpdateStationDataResponse.fromJson(Map<String, dynamic> json) =>
      _$PutUpdateStationDataResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PutUpdateStationDataResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PutUpdateStationTypeDataRequest {
  @JsonKey(name: 'type_name')
  final String typeName;

  factory PutUpdateStationTypeDataRequest.fromJson(Map<String, dynamic> json) =>
      _$PutUpdateStationTypeDataRequestFromJson(json);

  const PutUpdateStationTypeDataRequest({required this.typeName});

  Map<String, dynamic> toJson() =>
      _$PutUpdateStationTypeDataRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PutUpdateStationTypeDataResponse {
  @JsonKey(name: 'type_name')
  final String typeName;
  final int id;

  factory PutUpdateStationTypeDataResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$PutUpdateStationTypeDataResponseFromJson(json);

  const PutUpdateStationTypeDataResponse({
    required this.id,
    required this.typeName,
  });

  Map<String, dynamic> toJson() =>
      _$PutUpdateStationTypeDataResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetCorrectorChangeEventResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'old_corrector_amount')
  final int oldCorrectorAmount;
  @JsonKey(name: 'new_corrector_amount')
  final int newCorrectorAmount;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final int ran;
  final String? user;

  factory GetCorrectorChangeEventResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCorrectorChangeEventResponseFromJson(json);

  const GetCorrectorChangeEventResponse({
    required this.oldCorrectorAmount,
    required this.newCorrectorAmount,
    required this.id,
    required this.ranSequence,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.registeredDatetime,
    required this.ran,
    this.user,
    required this.stationCode,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      _$GetCorrectorChangeEventResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateCorrectorChangeEventRequest {
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'old_corrector_amount')
  final int oldCorrectorAmount;
  @JsonKey(name: 'new_corrector_amount')
  final int newCorrectorAmount;
  final int ran;

  factory PostCreateCorrectorChangeEventRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$PostCreateCorrectorChangeEventRequestFromJson(json);

  const PostCreateCorrectorChangeEventRequest({
    required this.oldCorrectorAmount,
    required this.newCorrectorAmount,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.ran,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      _$PostCreateCorrectorChangeEventRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateCorrectorChangeEventResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'old_corrector_amount')
  final int oldCorrectorAmount;
  @JsonKey(name: 'new_corrector_amount')
  final int newCorrectorAmount;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final int ran;
  final String? user;

  factory PostCreateCorrectorChangeEventResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$PostCreateCorrectorChangeEventResponseFromJson(json);

  const PostCreateCorrectorChangeEventResponse({
    required this.oldCorrectorAmount,
    required this.newCorrectorAmount,
    required this.id,
    required this.ranSequence,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.registeredDatetime,
    required this.ran,
    this.user,
    required this.stationCode,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      _$PostCreateCorrectorChangeEventResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetCorrectorChangeEventListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  List<GetCorrectorChangeEventResponse> results;

  factory GetCorrectorChangeEventListResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetCorrectorChangeEventListResponseFromJson(json);

  GetCorrectorChangeEventListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() =>
      _$GetCorrectorChangeEventListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PutUpdateCorrectorChangeEventRequest {
  final int id;
  @JsonKey(
    fromJson: Helpers.dashDateToJalaliNonNull,
    toJson: Helpers.jalaliToDashDate,
  )
  final Jalali date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'old_corrector_amount')
  final int oldCorrectorAmount;
  @JsonKey(name: 'new_corrector_amount')
  final int newCorrectorAmount;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final int ran;
  final String? user;

  factory PutUpdateCorrectorChangeEventRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$PutUpdateCorrectorChangeEventRequestFromJson(json);

  const PutUpdateCorrectorChangeEventRequest({
    required this.oldCorrectorAmount,
    required this.newCorrectorAmount,
    required this.id,
    required this.ranSequence,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.registeredDatetime,
    required this.ran,
    this.user,
    required this.stationCode,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      _$PutUpdateCorrectorChangeEventRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PutUpdateCorrectorChangeEventResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'old_corrector_amount')
  final int oldCorrectorAmount;
  @JsonKey(name: 'new_corrector_amount')
  final int newCorrectorAmount;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final int ran;
  final String? user;

  factory PutUpdateCorrectorChangeEventResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$PutUpdateCorrectorChangeEventResponseFromJson(json);

  const PutUpdateCorrectorChangeEventResponse({
    required this.oldCorrectorAmount,
    required this.newCorrectorAmount,
    required this.id,
    required this.ranSequence,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.registeredDatetime,
    required this.ran,
    this.user,
    required this.stationCode,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      _$PutUpdateCorrectorChangeEventResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetCorrectorChangeEventLastActionResponse {
  final int id;
  @JsonKey(
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'old_corrector_amount')
  final int oldCorrectorAmount;
  @JsonKey(name: 'new_corrector_amount')
  final int newCorrectorAmount;
  @JsonKey(
    name: 'registered_datetime',
    fromJson: Helpers.parseJalaliFromIso8601,
    toJson: Helpers.serializeJalaliIntoIso8601,
  )
  final Jalali registeredDatetime;
  final int ran;
  final String? user;

  factory GetCorrectorChangeEventLastActionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetCorrectorChangeEventLastActionResponseFromJson(json);

  const GetCorrectorChangeEventLastActionResponse({
    required this.oldCorrectorAmount,
    required this.newCorrectorAmount,
    required this.id,
    required this.ranSequence,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.registeredDatetime,
    required this.ran,
    this.user,
    required this.stationCode,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      _$GetCorrectorChangeEventLastActionResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetUsersCustomStationGroupResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<GetUsersCustomStationGroupResponseResultItem> results;

  factory GetUsersCustomStationGroupResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetUsersCustomStationGroupResponseFromJson(json);

  const GetUsersCustomStationGroupResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() =>
      _$GetUsersCustomStationGroupResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetUsersCustomStationGroupResponseResultItem {
  // @JsonKey(includeIfNull: false)
  final int id;
  final String title;
  final String user;
  final List<StationGroupDataStructure> stations;

  factory GetUsersCustomStationGroupResponseResultItem.fromJson(
    Map<String, dynamic> json,
  ) => _$GetUsersCustomStationGroupResponseResultItemFromJson(json);

  const GetUsersCustomStationGroupResponseResultItem({
    required this.id,
    required this.title,
    required this.user,
    required this.stations,
  });

  Map<String, dynamic> toJson() =>
      _$GetUsersCustomStationGroupResponseResultItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateNewStationGroupRequest {
  final String title;
  final String user;
  final List<StationGroupDataStructure> stations;

  factory PostCreateNewStationGroupRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$PostCreateNewStationGroupRequestFromJson(json);

  const PostCreateNewStationGroupRequest({
    required this.title,
    required this.user,
    required this.stations,
  });

  Map<String, dynamic> toJson() =>
      _$PostCreateNewStationGroupRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCreateNewStationGroupResponse {
  final String title;
  final String user;
  final List<StationGroupDataStructure> stations;

  factory PostCreateNewStationGroupResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$PostCreateNewStationGroupResponseFromJson(json);

  const PostCreateNewStationGroupResponse({
    required this.title,
    required this.user,
    required this.stations,
  });

  Map<String, dynamic> toJson() =>
      _$PostCreateNewStationGroupResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StationGroupDataStructure {
  final int priority;
  final int station;

  factory StationGroupDataStructure.fromJson(Map<String, dynamic> json) =>
      _$StationGroupDataStructureFromJson(json);

  const StationGroupDataStructure({
    required this.priority,
    required this.station,
  });

  Map<String, dynamic> toJson() => _$StationGroupDataStructureToJson(this);
}

// FIXME
/// This is here for now because I want to visually test things too, but at some point it
/// has to be moved to the relevant test sections/files.
final class MockData {
  static final mockLoginRequest = LoginRequest.fromJson({
    "username": "admin",
    "password": "abc123!@#",
  });

  static final mockLoginResponse = LoginResponse.fromJson({
    "expiry": "2026-12-09T10:47:26.243088+03:30",
    "token": "6b42ba81497dd6dcce0a4dd665f1619843bd460b031258ea7aee0316d5e019f5",
    "user": {"username": "admin", "is_staff": true},
  });

  static final mockGetProfileResponse = GetProfileResponse.fromJson({
    "username": "test1",
    "fullname": "کاربر سمنان",
    "stations": [
      {
        "code": 31141050000010,
        "rans": [
          {
            "code": 311410500000101,
            "sequence_number": 1,
            "station": 31141050000010,
          },
          {
            "code": 311410500000102,
            "sequence_number": 2,
            "station": 31141050000010,
          },
          {
            "code": 311410500000103,
            "sequence_number": 3,
            "station": 31141050000010,
          },
        ],
        "type_name": "CGS",
        "title": "مهدیشهر",
        "district": "مهدی شهر",
        "area": "منطقه ۳",
        "capacity": 30000,
        "type": 3,
        "activity": 1,
      },
      {
        "code": 31101050000142,
        "rans": [
          {
            "code": 311010500001421,
            "sequence_number": 1,
            "station": 31101050000142,
          },
          {
            "code": 311010500001422,
            "sequence_number": 2,
            "station": 31101050000142,
          },
          {
            "code": 311010500001423,
            "sequence_number": 3,
            "station": 31101050000142,
          },
        ],
        "type_name": "CGS",
        "title": "شهرک صنعتی سمنان",
        "district": "سمنان",
        "area": "منطقه ۳",
        "capacity": 50000,
        "type": 3,
        "activity": 1,
      },
    ],
    "is_staff": false,
  });

  static final mockActiveUser = ActiveUser.fromLoginResponse(
    mockLoginResponse,
    mockGetProfileResponse,
  );

  // Same structure as the login request
  static final mockLogoutRequest = mockLoginRequest;

  static final mockCreateShiftDataRequest = CreateShiftDataRequest.fromJson({
    "station": 31141050000010,
    "shift": "12",
    "input_pressure": 100,
    "output_pressure": 150,
    "input_temperature": 3000,
    "output_temperature": 2300,
    "date": "1403-11-11",
  });

  static final mockCreateShiftDataResponse = CreateShiftDataResponse.fromJson({
    "date": "1403-11-11",
    "registered_datetime": null,
    "shift": "12",
    "input_pressure": 100,
    "output_pressure": 150,
    "input_temperature": 3000,
    "output_temperature": 2300,
    "station": 12345,
    "user": null,
  });

  static final mockUpdateShiftDataRequest = UpdateShiftDataRequest.fromJson({
    "station": 12345,
    "shift": "24",
    "input_pressure": 10,
    "output_pressure": 10,
    "input_temperature": 30,
    "output_temperature": 23,
    "date": "1403-11-09",
  });

  static final mockUpdateShiftDataResponse = UpdateShiftDataResponse.fromJson({
    "id": 3,
    "date": "1403-11-09",
    "registered_datetime": " 1403-09-11 10:35:56",
    "shift": "24",
    "input_pressure": 10,
    "output_pressure": 10,
    "input_temperature": 30,
    "output_temperature": 23,
    "station": 12345,
    "user": "test",
  });

  static final mockGetShiftDataResponse = GetShiftDataResponse.fromJson({
    "id": 3,
    "date": "1403-11-09",
    "registered_datetime": "1403-09-11 10:35:56",
    "shift": "24",
    "input_pressure": 10,
    "output_pressure": 10,
    "input_temperature": 30,
    "output_temperature": 23,
    "station": 12345,
    "user": "test",
  });

  static final mockGetShiftLastActionResponse =
      GetShiftLastActionResponse.fromJson({
        "id": 5,
        "date": "1402-11-23",
        "registered_datetime": "1403-09-18 11:03:33",
        "shift": "06",
        "input_pressure": 1,
        "output_pressure": 1,
        "input_temperature": 1,
        "output_temperature": 1,
        "station": 12346,
        "user": "admin",
      });

  static final mockGetShiftsDataListResponse =
      GetShiftsDataListResponse.fromJson({
        "count": 2,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 2,
            "date": "1403-04-20",
            "registered_datetime": "1403-09-10 17:43:49",
            "shift": "06",
            "input_pressure": 1,
            "output_pressure": 3,
            "input_temperature": 4,
            "output_temperature": 5,
            "station": 12345,
            "user": "admin",
          },
          {
            "id": 3,
            "date": "1403-11-09",
            "registered_datetime": "1403-09-11 10:35:56",
            "shift": "24",
            "input_pressure": 10,
            "output_pressure": 10,
            "input_temperature": 30,
            "output_temperature": 23,
            "station": 12345,
            "user": "test",
          },
        ],
      });

  static final mockCreateCorrectorRequest = CreateCorrectorRequest.fromJson({
    "date": "1403-01-05",
    "meter_amount": 50,
    "correction_amount": 50,
    "ran": 1,
  });

  static final mockCreateCorrectorResponse = CreateCorrectorResponse.fromJson({
    "date": "1403-01-05",
    "registered_datetime": null,
    "station_code": 12345,
    "meter_amount": 50,
    "correction_amount": 50,
    "ran": 1,
    "user": null,
  });

  static final mockUpdateCorrectorRequest = UpdateCorrectorRequest.fromJson({
    "date": "1403-09-13",
    "meter_amount": 15.0,
    "correction_amount": 25.0,
    "ran": 1,
  });

  static final mockUpdateCorrectorResponse = UpdateCorrectorResponse.fromJson({
    "id": 1,
    "date": "1403-09-13",
    "registered_datetime": "1403-09-11 10:40:50",
    "station_code": 12345,
    "meter_amount": 15,
    "correction_amount": 25,
    "ran": 1,
    "user": "test",
  });

  static final mockGetCorrectorDataListResponse =
      GetCorrectorDataListResponse.fromJson({
        "count": 1,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 1,
            "date": "1403-01-05",
            "registered_datetime": "1403-09-11 10:40:50",
            "station_code": 12345,
            "meter_amount": 50,
            "correction_amount": 50,
            "ran": 1,
            "user": "test",
          },
        ],
      });

  static final mockGetCorrectorDataResponse =
      GetCorrectorDataResponse.fromJson({
        "id": 1,
        "date": "1403-01-05",
        "registered_datetime": "1403-09-11 10:40:50",
        "station_code": 12345,
        "meter_amount": 50,
        "correction_amount": 50,
        "ran": 1,
        "user": "test",
      });

  static final mockGetMeterAndCorrectorFullReportResponse =
      GetMeterAndCorrectorFullReportResponse.fromJson({
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
          {
            "station_code": 31141050000010,
            "user": "admin",
            "date": "1403-04-20",
            "registered_datetime": "1403-12-05 18:26:32.219415+0330",
            "rans": [
              {
                "meter_amount": 1,
                "corrector_amount": 1,
                "corrector_meter_amount": 1,
                "ran_sequence": 1,
                "ran": 311410500000101,
              },
              {
                "meter_amount": 1,
                "corrector_amount": 1,
                "corrector_meter_amount": 1,
                "ran_sequence": 2,
                "ran": 311410500000102,
              },
              {
                "meter_amount": 1,
                "corrector_amount": 1,
                "corrector_meter_amount": 1,
                "ran_sequence": 3,
                "ran": 311410500000103,
              },
            ],
          },
          {
            "station_code": 31141050000010,
            "user": "admin",
            "date": "1403-04-21",
            "registered_datetime": "1403-12-12 16:36:43.577097+0330",
            "rans": [
              {
                "meter_amount": 4,
                "corrector_amount": 4,
                "corrector_meter_amount": 4,
                "ran_sequence": 1,
                "ran": 311410500000101,
              },
              {
                "meter_amount": 4,
                "corrector_amount": 4,
                "corrector_meter_amount": 4,
                "ran_sequence": 2,
                "ran": 311410500000102,
              },
              {
                "meter_amount": 4,
                "corrector_amount": 4,
                "corrector_meter_amount": 4,
                "ran_sequence": 3,
                "ran": 311410500000103,
              },
            ],
          },
          {
            "station_code": 31141050000010,
            "user": "admin",
            "date": "1403-04-22",
            "registered_datetime": "1403-12-12 16:37:17.67951+0330",
            "rans": [
              {
                "meter_amount": 8,
                "corrector_amount": 8,
                "corrector_meter_amount": 8,
                "ran_sequence": 1,
                "ran": 311410500000101,
              },
              {
                "meter_amount": 8,
                "corrector_amount": 8,
                "corrector_meter_amount": 8,
                "ran_sequence": 2,
                "ran": 311410500000102,
              },
              {
                "meter_amount": 8,
                "corrector_amount": 8,
                "corrector_meter_amount": 8,
                "ran_sequence": 3,
                "ran": 311410500000103,
              },
            ],
          },
        ],
      });

  static final mockGetPressureAndTemperatureFullReportResponse =
      GetPressureAndTemperatureFullReportResponse.fromJson({
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
          {
            "station_code": 31141050000010,
            "date": "1403-04-20",
            "shifts": [
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:28:53.119717+0330",
                "user": "admin",
                "shift": "06",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:29:10.423568+0330",
                "user": "admin",
                "shift": "12",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:29:27.630016+0330",
                "user": "admin",
                "shift": "18",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:31:31.54086+0330",
                "user": "admin",
                "shift": "24",
              },
            ],
          },
          {
            "station_code": 31141050000010,
            "date": "1403-04-21",
            "shifts": [
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:39:57.23025+0330",
                "user": "admin",
                "shift": "06",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:40:19.502577+0330",
                "user": "admin",
                "shift": "12",
              },
            ],
          },
          {
            "station_code": 31141050000010,
            "date": "1403-11-11",
            "shifts": [
              {
                "input_pressure": 100,
                "output_pressure": 150,
                "input_temperature": 3000,
                "output_temperature": 2300,
                "registered_datetime": "1403-12-08 12:08:50.738588+0330",
                "user": "test1",
                "shift": "12",
              },
            ],
          },
        ],
      });

  static final mockGetMonitoringFullReportResponse =
      GetMonitoringFullReportResponse.fromJson({
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
          {
            "station_code": 31141050000010,
            "date": "1403-04-20",
            "shifts": [
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:28:53.119717+0330",
                "user": "admin",
                "shift": "06",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:29:10.423568+0330",
                "user": "admin",
                "shift": "12",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:29:27.630016+0330",
                "user": "admin",
                "shift": "18",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:31:31.54086+0330",
                "user": "admin",
                "shift": "24",
              },
            ],
            "consumption": null,
            "average_consumption": null,
          },
          {
            "station_code": 31141050000010,
            "date": "1403-04-21",
            "shifts": [
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:39:57.23025+0330",
                "user": "admin",
                "shift": "06",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:40:19.502577+0330",
                "user": "admin",
                "shift": "12",
              },
            ],
            "consumption": 9,
            "average_consumption": 9,
          },
          {
            "station_code": 31141050000010,
            "date": "1403-11-11",
            "shifts": [
              {
                "input_pressure": 100,
                "output_pressure": 150,
                "input_temperature": 3000,
                "output_temperature": 2300,
                "registered_datetime": "1403-12-08 12:08:50.738588+0330",
                "user": "test1",
                "shift": "12",
              },
            ],
            "consumption": null,
            "average_consumption": null,
          },
        ],
      });

  static final mockGetMeterChangeEventResponse =
      GetMeterChangeEventResponse.fromJson({
        "id": 1,
        "date": "1403-01-04",
        "station_code": 31101050000142,
        "ran_sequence": 1,
        "old_meter_amount": 102,
        "new_meter_amount": 100,
        "registered_datetime": "1403-12-04T17:31:47.503064+0330",
        "ran": 311010500001421,
        "user": null,
      });

  static final mockCreateMeterChangeEventRequest =
      CreateMeterChangeEventRequest.fromJson({
        "date": "1403-01-07",
        "ran": 311010500001421,
        "old_meter_amount": 50,
        "new_meter_amount": 100,
      });

  static final mockCreateMeterChangeEventResponse =
      CreateMeterChangeEventRequest.fromJson({
        "id": 3,
        "date": "1403-01-07",
        "station_code": 31101050000142,
        "ran_sequence": 1,
        "old_meter_amount": 50,
        "new_meter_amount": 100,
        "registered_datetime": "1403-12-04T17:51:42.794933+0330",
        "ran": 311010500001421,
        "user": "admin",
      });

  static final mockGetMeterChangeEventsList =
      GetMeterChangeEventsListResponse.fromJson({
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 1,
            "date": "1403-01-04",
            "station_code": 31101050000142,
            "ran_sequence": 1,
            "old_meter_amount": 50,
            "new_meter_amount": 100,
            "registered_datetime": "1403-12-04T17:31:47.503064+0330",
            "ran": 311010500001421,
            "user": null,
          },
          {
            "id": 2,
            "date": "1403-01-05",
            "station_code": 31101050000142,
            "ran_sequence": 1,
            "old_meter_amount": 50,
            "new_meter_amount": 100,
            "registered_datetime": "1403-12-04T17:46:27.479274+0330",
            "ran": 311010500001421,
            "user": "admin",
          },
          {
            "id": 3,
            "date": "1403-01-07",
            "station_code": 31101050000142,
            "ran_sequence": 1,
            "old_meter_amount": 50,
            "new_meter_amount": 100,
            "registered_datetime": "1403-12-04T17:51:42.794933+0330",
            "ran": 311010500001421,
            "user": "admin",
          },
        ],
      });

  static final mockUpdateMeterChangeEventRequest =
      UpdateMeterChangeEventRequest.fromJson({
        "date": "1403-01-04",
        "ran": 311010500001421,
        "old_meter_amount": 102,
        "old_correction_amount": 103,
        "new_meter_amount": 100,
        "new_correction_amount": 120,
      });

  static final mockUpdateMeterChangeEventResponse =
      UpdateMeterChangeEventResponse.fromJson({
        "id": 1,
        "date": "1403-01-04",
        "station_code": 31101050000142,
        "ran_sequence": 1,
        "old_meter_amount": 102,
        "new_meter_amount": 100,
        "registered_datetime": "1403-12-04T17:31:47.503064+0330",
        "ran": 311010500001421,
        "user": null,
      });

  static final mockGetMeterChangeEventLastActionResponse =
      GetMeterChangeEventLastActionResponse.fromJson({
        "id": 3,
        "date": "1403-01-07",
        "station_code": 31101050000142,
        "ran_sequence": 1,
        "old_meter_amount": 50,
        "new_meter_amount": 100,
        "registered_datetime": "1403-12-04T17:51:42.794933+0330",
        "ran": 311010500001421,
        "user": "admin",
      });

  static final mockCreateCorrectorBulkRequest =
      PostCreateCorrectorBulkRequest.fromJson({
        "date": "1405-02-07",
        "rans": [
          {
            "ran": 311410500000101,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
          {
            "ran": 311410500000102,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
          {
            "ran": 311410500000103,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
        ],
      });

  static final mockCreateCorrectorBulkResponse =
      PostCreateCorrectorBulkResponse.fromJson({
        "station": 12346,
        "date": "1403-02-05",
        "rans": [
          {
            "meter_amount": 120,
            "correction_amount": 120,
            "ran_sequence": 1,
            "ran": 123461,
          },
          {
            "meter_amount": 7,
            "correction_amount": 7,
            "ran_sequence": 2,
            "ran": 123462,
          },
        ],
      });

  static final mockUpdateCorrectorBulkRequest =
      PutUpdateCorrectorBulkRequest.fromJson({
        "date": "1405-02-07",
        "rans": [
          {
            "ran": 311410500000101,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
          {
            "ran": 311410500000102,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
          {
            "ran": 311410500000103,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
        ],
      });

  static final mockUpdateCorrectorBulkResponse =
      PutUpdateCorrectorBulkResponse.fromJson({
        "station_code": 31141050000010,
        "date": "1405-02-07",
        "rans": [
          {
            "meter_amount": 1000,
            "corrector_amount": 1200,
            "corrector_meter_amount": 1000,
            "ran_sequence": 1,
            "ran": 311410500000101,
          },
          {
            "meter_amount": 1000,
            "corrector_amount": 1200,
            "corrector_meter_amount": 1000,
            "ran_sequence": 2,
            "ran": 311410500000102,
          },
          {
            "meter_amount": 1000,
            "corrector_amount": 1200,
            "corrector_meter_amount": 1000,
            "ran_sequence": 3,
            "ran": 311410500000103,
          },
        ],
        "user": null,
      });

  static final mockGetCorrectorDataBulkLastAction = [
    GetCorrectorDataBulkLastActionResponseListItem.fromJson({
      "date": "1403-01-01",
      "rans": [
        {
          "meter_amount": 1,
          "correction_amount": 1,
          "ran_sequence": 1,
          "ran": 123451,
        },
        {
          "meter_amount": 1,
          "correction_amount": 1,
          "ran_sequence": 2,
          "ran": 123452,
        },
        {
          "meter_amount": 1,
          "correction_amount": 1,
          "ran_sequence": 3,
          "ran": 123453,
        },
      ],
    }),
    GetCorrectorDataBulkLastActionResponseListItem.fromJson({
      "date": "1403-01-02",
      "rans": [
        {
          "meter_amount": 3,
          "correction_amount": 3,
          "ran_sequence": 1,
          "ran": 123451,
        },
        {
          "meter_amount": 3,
          "correction_amount": 3,
          "ran_sequence": 2,
          "ran": 123452,
        },
        {
          "meter_amount": 3,
          "correction_amount": 3,
          "ran_sequence": 3,
          "ran": 123453,
        },
      ],
    }),
  ];

  static final mockGetShiftDataBulkLastAction =
      GetShiftDataBulkLastActionResponse.fromJson({
        "id": 18,
        "date": "1403-11-11",
        "registered_datetime": " 1403-12-08 12:08:50",
        "shift": "12",
        "input_pressure": 100,
        "output_pressure": 150,
        "input_temperature": 3000,
        "output_temperature": 2300,
        "station": 31141050000010,
        "user": "test1",
      });

  static final mockGetStationDataList = GetStationDataListResponse.fromJson({
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
      {
        "code": "12345",
        "rans": [
          {"id": 1, "sequence_number": 1, "station": "12345"},
          {"id": 2, "sequence_number": 2, "station": "12345"},
          {"id": 3, "sequence_number": 3, "station": "12345"},
        ],
        "type": "CGS",
        "name": "رجایی",
        "district": "سمنان",
        "area": "گرمسار",
        "capacity": 1500,
      },
    ],
  });

  static final mockGetStationTypeDataListResponse =
      GetStationTypeDataListResponse.fromJson({
        "count": 1,
        "next": null,
        "previous": null,
        "results": [
          {"type_name": "CGS"},
        ],
      });

  static final mockGetStationDataResponse = GetStationDataResponse.fromJson({
    "code": "12345",
    "rans": [
      {"id": 1, "sequence_number": 1, "station": "12345"},
      {"id": 2, "sequence_number": 2, "station": "12345"},
      {"id": 3, "sequence_number": 3, "station": "12345"},
    ],
    "type": "CGS",
    "name": "رجایی",
    "district": "سمنان",
    "area": "گرمسار",
    "capacity": 1500,
  });

  static final mockGetStationTypeDataResponse =
      GetStationTypeDataResponse.fromJson({"type_name": "CGS"});

  static final mockPostCreateStationRequest =
      PostCreateStationRequest.fromJson({
        "code": 12347,
        "name": "بهشتی",
        "district": "سمنان",
        "area": "سمنان",
        "capacity": 1800,
        "type": 1,
      });

  static final mockPostCreateStationResponse =
      PostCreateStationResponse.fromJson({
        "code": "12347",
        "rans": [],
        "type_name": "CGS",
        "name": "بهشتی",
        "district": "سمنان",
        "area": "سمنان",
        "capacity": 1800,
        "type": 1,
      });
  static final mockPostCreateStationTypeRequest =
      PostCreateStationTypeRequest.fromJson({"type_name": "LPG"});

  static final mockPostCreateStationTypeResponse =
      PostCreateStationTypeResponse.fromJson({"type_name": "CNG"});

  static final mockPutUpdateStationDataRequest =
      PutUpdateStationDataRequest.fromJson({
        "code": 12347,
        "name": "بهشتی",
        "district": "سمنان",
        "area": "سمنان",
        "capacity": 2100,
        "type": 1,
      });

  static final mockPutUpdaateStationDataResponse =
      PutUpdateStationDataResponse.fromJson({
        "code": "12347",
        "rans": [],
        "type_name": "CGS",
        "name": "بهشتی",
        "district": "سمنان",
        "area": "سمنان",
        "capacity": 2100,
        "type": 1,
      });

  static final mockPutUpdateStationTypeDataRequest =
      PutUpdateStationTypeDataRequest.fromJson({"type_name": "GPG"});

  static final mockPutUpdateStationTypeDataResponse =
      PutUpdateStationTypeDataResponse.fromJson({"id": 2, "type_name": "GPG"});

  static final mockGetCorrectoChangeEventRequest =
      GetCorrectorChangeEventResponse.fromJson({
        "id": 1,
        "date": "1403-04-20",
        "station_code": 31141050000010,
        "ran_sequence": 2,
        "old_corrector_amount": 12,
        "new_corrector_amount": 17,
        "old_meter_amount": 25,
        "new_meter_amount": 40,
        "registered_datetime": "1403-12-05T11:14:02.437544+0330",
        "ran": 311410500000102,
        "user": "admin",
      });

  static final mockPostCreateCorrectorChangeEventRequest =
      PostCreateCorrectorChangeEventRequest.fromJson({
        "date": "1403-05-21",
        "old_corrector_amount": 12.0,
        "new_corrector_amount": 17.0,
        "old_meter_amount": 25.0,
        "new_meter_amount": 40.0,
        "ran": 311410500000102,
      });

  static final mockPostCreateCorrectorChangeEventResponse =
      PostCreateCorrectorChangeEventResponse.fromJson({
        "id": 2,
        "date": "1403-05-21",
        "station_code": 31141050000010,
        "ran_sequence": 2,
        "old_corrector_amount": 12,
        "new_corrector_amount": 17,
        "old_meter_amount": 25,
        "new_meter_amount": 40,
        "registered_datetime": "1403-12-05T11:17:00.912392+0330",
        "ran": 311410500000102,
        "user": "admin",
      });

  static final mockGetCorrectorChangeEventsList =
      GetCorrectorChangeEventListResponse.fromJson({
        "count": 2,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 1,
            "date": "1403-04-20",
            "station_code": 31141050000010,
            "ran_sequence": 2,
            "old_corrector_amount": 12,
            "new_corrector_amount": 17,
            "old_meter_amount": 25,
            "new_meter_amount": 40,
            "registered_datetime": "1403-12-05T11:14:02.437544+0330",
            "ran": 311410500000102,
            "user": "admin",
          },
          {
            "id": 2,
            "date": "1403-05-21",
            "station_code": 31141050000010,
            "ran_sequence": 2,
            "old_corrector_amount": 12,
            "new_corrector_amount": 17,
            "old_meter_amount": 25,
            "new_meter_amount": 40,
            "registered_datetime": "1403-12-05T11:17:00.912392+0330",
            "ran": 311410500000102,
            "user": "admin",
          },
        ],
      });

  static final mockPutUpdateCorrectorChangeEventRequest =
      PutUpdateCorrectorChangeEventRequest.fromJson({
        "id": 1,
        "date": "1403-04-20",
        "old_corrector_amount": 12,
        "new_corrector_amount": 17,
        "old_meter_amount": 26,
        "new_meter_amount": 41,
        "ran": 311410500000102,
        "user": "admin",
      });

  static final mockPutUpdateCorrectorChangeEventResponse =
      PutUpdateCorrectorChangeEventResponse.fromJson({
        "id": 1,
        "date": "1403-10-17",
        "station_code": "12345",
        "ran_sequence": 1,
        "old_meter_amount": 102,
        "old_correction_amount": 103,
        "new_meter_amount": 100,
        "new_correction_amount": 120,
        "ran": 1,
      });

  static final mockGetCorrectorChangeEventLastActionResponse =
      GetCorrectorChangeEventLastActionResponse.fromJson({
        "id": 2,
        "date": "1403-05-21",
        "station_code": 31141050000010,
        "ran_sequence": 2,
        "old_corrector_amount": 12,
        "new_corrector_amount": 17,
        "old_meter_amount": 25,
        "new_meter_amount": 40,
        "registered_datetime": "1403-12-05T11:17:00.912392+0330",
        "ran": 311410500000102,
        "user": "admin",
      });

  static final mockGetUsersCustomStationsGroupResponse =
      GetUsersCustomStationGroupResponse.fromJson({
        "count": 1,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 1,
            "title": "گروهبندی منطقه یکم",
            "user": "admin",
            "stations": [
              {"priority": 1, "station": 31141050000010},
              {"priority": 2, "station": 31121050000064},
            ],
          },
        ],
      });

  static final mockPostCreateNewStationGroupRequest =
      PostCreateNewStationGroupRequest.fromJson({
        "title": "گروهبندی منطقه",
        "user": "admin",
        "stations": [
          {"priority": 1, "station": 31141050000010},
          {"priority": 2, "station": 31121050000064},
        ],
      });

  static final mockPostCreateNewStationGroupResponse =
      PostCreateNewStationGroupResponse.fromJson({
        "title": "گروهبندی منطقه",
        "user": "admin",
        "stations": [
          {"priority": 1, "station": 31141050000010},
          {"priority": 2, "station": 31121050000064},
        ],
      });
}
