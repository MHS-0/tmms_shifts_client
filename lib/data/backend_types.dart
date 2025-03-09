import 'package:json_annotation/json_annotation.dart';

part 'backend_types.g.dart';

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(fromJson: _parseDateTime, toJson: _serializeDateTime)
  final DateTime expiry;
  final String token;
  final LoginResponseUser user;

  LoginResponse({
    required this.expiry,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  static DateTime _parseDateTime(String json) => DateTime.parse(json);

  static String _serializeDateTime(DateTime dateTime) =>
      dateTime.toIso8601String();
}

@JsonSerializable()
class LoginResponseUser {
  final String? username;
  @JsonKey(name: 'is_staff')
  final bool isStaff;

  LoginResponseUser({this.username, required this.isStaff});

  factory LoginResponseUser.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseUserToJson(this);
}

@JsonSerializable()
class GetProfileResponse {
  final String username;
  final String? fullname;
  final List<Station>? stations;
  @JsonKey(name: 'is_staff')
  final bool isStaff;

  GetProfileResponse({
    required this.username,
    required this.isStaff,
    this.stations,
    this.fullname,
  });

  factory GetProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$GetProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetProfileResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Station {
  final String code;
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

@JsonSerializable()
class CreateShiftDataRequest {
  final String station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  final String date;

  factory CreateShiftDataRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateShiftDataRequestFromJson(json);

  CreateShiftDataRequest({
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

@JsonSerializable()
class CreateShiftDataResponse {
  final String station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final String? user;

  factory CreateShiftDataResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateShiftDataResponseFromJson(json);

  CreateShiftDataResponse({
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

@JsonSerializable()
class UpdateShiftDataRequest {
  final String station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  final String date;

  factory UpdateShiftDataRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateShiftDataRequestFromJson(json);

  UpdateShiftDataRequest({
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

@JsonSerializable()
class UpdateShiftDataResponse {
  final int id;
  final String station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final String? user;

  factory UpdateShiftDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateShiftDataResponseFromJson(json);

  UpdateShiftDataResponse({
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

@JsonSerializable()
class GetShiftDataResponse {
  final int id;
  final String station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final String? user;

  factory GetShiftDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetShiftDataResponseFromJson(json);

  GetShiftDataResponse({
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

@JsonSerializable()
class GetShiftLastActionResponse {
  final int id;
  final String station;
  final String shift;
  @JsonKey(name: 'input_pressure')
  final int inputPressure;
  @JsonKey(name: 'output_pressure')
  final int outputPressure;
  @JsonKey(name: 'input_temperature')
  final int inputTemperature;
  @JsonKey(name: 'output_temperature')
  final int outputTemperature;
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final String? user;

  factory GetShiftLastActionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetShiftLastActionResponseFromJson(json);

  GetShiftLastActionResponse({
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

@JsonSerializable()
class GetShiftsDataListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<GetShiftDataResponse> results;

  factory GetShiftsDataListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetShiftsDataListResponseFromJson(json);

  GetShiftsDataListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() => _$GetShiftsDataListResponseToJson(this);
}

@JsonSerializable()
class CreateCorrectorRequest {
  final String date;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;

  factory CreateCorrectorRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCorrectorRequestFromJson(json);

  CreateCorrectorRequest({
    required this.date,
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
  });

  Map<String, dynamic> toJson() => _$CreateCorrectorRequestToJson(this);
}

@JsonSerializable()
class CreateCorrectorResponse {
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;
  @JsonKey(name: 'station_code')
  final String stationCode;
  final String? user;

  factory CreateCorrectorResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateCorrectorResponseFromJson(json);

  CreateCorrectorResponse({
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

@JsonSerializable()
class UpdateCorrectorRequest {
  final String date;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;

  factory UpdateCorrectorRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCorrectorRequestFromJson(json);

  UpdateCorrectorRequest({
    required this.date,
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
  });

  Map<String, dynamic> toJson() => _$UpdateCorrectorRequestToJson(this);
}

@JsonSerializable()
class UpdateCorrectorResponse {
  final int id;
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
  @JsonKey(name: 'station_code')
  final String stationCode;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;
  final String? user;

  factory UpdateCorrectorResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateCorrectorResponseFromJson(json);

  UpdateCorrectorResponse({
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

@JsonSerializable()
class GetCorrectorDataListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<GetCorrectorDataResponse> results;

  factory GetCorrectorDataListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCorrectorDataListResponseFromJson(json);

  GetCorrectorDataListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() => _$GetCorrectorDataListResponseToJson(this);
}

@JsonSerializable()
class GetCorrectorDataResponse {
  final int id;
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
  @JsonKey(name: 'station_code')
  final String stationCode;
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  final int ran;
  final String? user;

  factory GetCorrectorDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCorrectorDataResponseFromJson(json);

  GetCorrectorDataResponse({
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

@JsonSerializable()
class GetMeterAndCorrectorFullReportResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<GetMeterAndCorrectorFullReportResponseResultItem> results;

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

@JsonSerializable()
class GetMeterAndCorrectorFullReportResponseResultItem {
  @JsonKey(name: 'station_code')
  final int stationCode;
  final String? user;
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
  final List<Ran2> rans;

  factory GetMeterAndCorrectorFullReportResponseResultItem.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMeterAndCorrectorFullReportResponseResultItemFromJson(json);

  GetMeterAndCorrectorFullReportResponseResultItem({
    required this.stationCode,
    this.user,
    required this.date,
    this.registeredDatetime,
    required this.rans,
  });

  Map<String, dynamic> toJson() =>
      _$GetMeterAndCorrectorFullReportResponseResultItemToJson(this);
}

@JsonSerializable()
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

  Ran2({
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
  final List<GetMonitoringFullReportResponseResultItem> results;

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
  final String date;
  final List<Shift> shifts;
  final int? consumption;
  @JsonKey(name: 'average_consumption')
  final int? averageConsumption;

  factory GetMonitoringFullReportResponseResultItem.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMonitoringFullReportResponseResultItemFromJson(json);

  GetMonitoringFullReportResponseResultItem({
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
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
  final String? user;
  final String shift;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  Shift({
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

@JsonSerializable()
class GetPressureAndTemperatureFullReportResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<GetPressureAndTemperatureFullReportResponseResultItem> results;

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

@JsonSerializable()
class GetPressureAndTemperatureFullReportResponseResultItem {
  @JsonKey(name: 'station_code')
  final int stationCode;
  final String date;
  final List<Shift> shifts;

  factory GetPressureAndTemperatureFullReportResponseResultItem.fromJson(
    Map<String, dynamic> json,
  ) => _$GetPressureAndTemperatureFullReportResponseResultItemFromJson(json);

  GetPressureAndTemperatureFullReportResponseResultItem({
    required this.stationCode,
    required this.date,
    required this.shifts,
  });

  Map<String, dynamic> toJson() =>
      _$GetPressureAndTemperatureFullReportResponseResultItemToJson(this);
}

@JsonSerializable()
class GetMeterChangeEventResponse {
  final int id;
  final String date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final int ran;
  final String? user;

  factory GetMeterChangeEventResponse.fromJson(Map<String, dynamic> json) =>
      _$GetMeterChangeEventResponseFromJson(json);

  GetMeterChangeEventResponse({
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

@JsonSerializable()
class CreateMeterChangeEventRequest {
  final String date;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  final int ran;

  factory CreateMeterChangeEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMeterChangeEventRequestFromJson(json);

  CreateMeterChangeEventRequest({
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.ran,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$CreateMeterChangeEventRequestToJson(this);
}

@JsonSerializable()
class CreateMeterChangeEventResponse {
  final int id;
  final String date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final int ran;
  final String? user;

  factory CreateMeterChangeEventResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateMeterChangeEventResponseFromJson(json);

  CreateMeterChangeEventResponse({
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

@JsonSerializable()
class GetMeterChangeEventsListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<GetMeterChangeEventResponse> results;

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

@JsonSerializable()
class UpdateMeterChangeEventRequest {
  final String date;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  final int ran;

  factory UpdateMeterChangeEventRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMeterChangeEventRequestFromJson(json);

  UpdateMeterChangeEventRequest({
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.ran,
    required this.date,
  });

  Map<String, dynamic> toJson() => _$UpdateMeterChangeEventRequestToJson(this);
}

@JsonSerializable()
class UpdateMeterChangeEventResponse {
  final int id;
  final String date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final int ran;
  final String? user;

  factory UpdateMeterChangeEventResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateMeterChangeEventResponseFromJson(json);

  UpdateMeterChangeEventResponse({
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

@JsonSerializable()
class GetMeterChangeEventLastActionResponse {
  final int id;
  final String date;
  @JsonKey(name: 'station_code')
  final int stationCode;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final int ran;
  final String? user;

  factory GetMeterChangeEventLastActionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMeterChangeEventLastActionResponseFromJson(json);

  GetMeterChangeEventLastActionResponse({
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

@JsonSerializable()
class PostCreateCorrectorBulkRequest {
  final String date;
  final List<Ran3> rans;

  PostCreateCorrectorBulkRequest({required this.date, required this.rans});

  factory PostCreateCorrectorBulkRequest.fromJson(Map<String, dynamic> json) =>
      _$PostCreateCorrectorBulkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PostCreateCorrectorBulkRequestToJson(this);
}

@JsonSerializable()
class Ran3 {
  @JsonKey(name: 'meter_amount')
  final String meterAmount;
  @JsonKey(name: 'correction_amount')
  final String correctionAmount;
  final String ran;

  Ran3({
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
  });

  factory Ran3.fromJson(Map<String, dynamic> json) => _$Ran3FromJson(json);

  Map<String, dynamic> toJson() => _$Ran3ToJson(this);
}

@JsonSerializable()
class PostCreateCorrectorBulkResponse {
  final int station;
  final String date;
  final List<Ran4> rans;

  PostCreateCorrectorBulkResponse({
    required this.station,
    required this.date,
    required this.rans,
  });

  factory PostCreateCorrectorBulkResponse.fromJson(Map<String, dynamic> json) =>
      _$PostCreateCorrectorBulkResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PostCreateCorrectorBulkResponseToJson(this);
}

@JsonSerializable()
class Ran4 {
  @JsonKey(name: 'meter_amount')
  final int meterAmount;
  @JsonKey(name: 'correction_amount')
  final int correctionAmount;
  @JsonKey(name: 'ran_sequence')
  final int ranSequence;
  final int ran;

  Ran4({
    required this.ranSequence,
    required this.meterAmount,
    required this.correctionAmount,
    required this.ran,
  });

  factory Ran4.fromJson(Map<String, dynamic> json) => _$Ran4FromJson(json);

  Map<String, dynamic> toJson() => _$Ran4ToJson(this);
}

@JsonSerializable()
class PutUpdateCorrectorBulkRequest {
  final String date;
  final List<Ran3> rans;

  PutUpdateCorrectorBulkRequest({required this.date, required this.rans});

  factory PutUpdateCorrectorBulkRequest.fromJson(Map<String, dynamic> json) =>
      _$PutUpdateCorrectorBulkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PutUpdateCorrectorBulkRequestToJson(this);
}

@JsonSerializable()
class GetCorrectorDataBulkLastActionResponse {
  final String date;
  final List<Ran4> rans;

  GetCorrectorDataBulkLastActionResponse({
    required this.date,
    required this.rans,
  });

  factory GetCorrectorDataBulkLastActionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetCorrectorDataBulkLastActionResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GetCorrectorDataBulkLastActionResponseToJson(this);
}

@JsonSerializable()
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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final String? user;

  factory GetShiftDataBulkLastActionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetShiftDataBulkLastActionResponseFromJson(json);

  GetShiftDataBulkLastActionResponse({
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

@JsonSerializable()
class GetStationDataListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<Station2> results;

  factory GetStationDataListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetStationDataListResponseFromJson(json);

  GetStationDataListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() => _$GetStationDataListResponseToJson(this);
}

@JsonSerializable()
class Station2 {
  final String code;
  final List<Ran5> rans;
  final String type;
  final String name;
  final String district;
  final String area;
  final int capacity;

  Station2({
    required this.name,
    required this.code,
    required this.rans,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
  });

  factory Station2.fromJson(Map<String, dynamic> json) =>
      _$Station2FromJson(json);

  Map<String, dynamic> toJson() => _$Station2ToJson(this);
}

@JsonSerializable()
class Ran5 {
  final int id;
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber;
  final String station;

  Ran5({required this.id, required this.sequenceNumber, required this.station});

  factory Ran5.fromJson(Map<String, dynamic> json) => _$Ran5FromJson(json);

  Map<String, dynamic> toJson() => _$Ran5ToJson(this);
}

@JsonSerializable()
class GetStationTypeDataListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<StationType> results;

  factory GetStationTypeDataListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetStationTypeDataListResponseFromJson(json);

  GetStationTypeDataListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() => _$GetStationTypeDataListResponseToJson(this);
}

@JsonSerializable()
class StationType {
  @JsonKey(name: 'type_name')
  final String typeName;

  factory StationType.fromJson(Map<String, dynamic> json) =>
      _$StationTypeFromJson(json);

  StationType({required this.typeName});

  Map<String, dynamic> toJson() => _$StationTypeToJson(this);
}

@JsonSerializable()
class PostCreateStationRequest {
  final int code;
  final String name;
  final String district;
  final String area;
  final int capacity;
  final int type;

  factory PostCreateStationRequest.fromJson(Map<String, dynamic> json) =>
      _$PostCreateStationRequestFromJson(json);

  PostCreateStationRequest({
    required this.code,
    required this.name,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
  });

  Map<String, dynamic> toJson() => _$PostCreateStationRequestToJson(this);
}

@JsonSerializable()
class Station3 {
  final String code;
  final List<Ran> rans;
  @JsonKey(name: 'type_name')
  final String typeName;
  final String name;
  final String district;
  final String area;
  final int capacity;
  final int type;

  Station3({
    required this.code,
    required this.rans,
    required this.typeName,
    required this.name,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
  });

  factory Station3.fromJson(Map<String, dynamic> json) =>
      _$Station3FromJson(json);

  Map<String, dynamic> toJson() => _$Station3ToJson(this);
}

@JsonSerializable()
class StationType2 {
  @JsonKey(name: 'type_name')
  final String typeName;
  final int id;

  factory StationType2.fromJson(Map<String, dynamic> json) =>
      _$StationType2FromJson(json);

  StationType2({required this.id, required this.typeName});

  Map<String, dynamic> toJson() => _$StationType2ToJson(this);
}

@JsonSerializable()
class GetCorrectorChangeEventResponse {
  final int id;
  final String date;
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
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
  final int ran;
  final String? user;

  factory GetCorrectorChangeEventResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCorrectorChangeEventResponseFromJson(json);

  GetCorrectorChangeEventResponse({
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

@JsonSerializable()
class PostCorrectorChangeEventRequest {
  final String date;
  @JsonKey(name: 'old_meter_amount')
  final int oldMeterAmount;
  @JsonKey(name: 'new_meter_amount')
  final int newMeterAmount;
  @JsonKey(name: 'old_corrector_amount')
  final int oldCorrectorAmount;
  @JsonKey(name: 'new_corrector_amount')
  final int newCorrectorAmount;
  @JsonKey(name: 'registered_datetime')
  final int ran;

  factory PostCorrectorChangeEventRequest.fromJson(Map<String, dynamic> json) =>
      _$PostCorrectorChangeEventRequestFromJson(json);

  PostCorrectorChangeEventRequest({
    required this.oldCorrectorAmount,
    required this.newCorrectorAmount,
    required this.oldMeterAmount,
    required this.newMeterAmount,
    required this.ran,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      _$PostCorrectorChangeEventRequestToJson(this);
}

@JsonSerializable()
class GetCorrectorChangeEventListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<GetCorrectorChangeEventResponse> results;

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

@JsonSerializable()
class GetUsersCustomStationGroupResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<StationGroup> results;

  factory GetUsersCustomStationGroupResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetUsersCustomStationGroupResponseFromJson(json);

  GetUsersCustomStationGroupResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() =>
      _$GetUsersCustomStationGroupResponseToJson(this);
}

@JsonSerializable()
class StationGroup {
  @JsonKey(includeIfNull: false)
  final int? id;
  final String title;
  final String? user;
  final List<Station4> stations;

  factory StationGroup.fromJson(Map<String, dynamic> json) =>
      _$StationGroupFromJson(json);

  StationGroup({
    this.id,
    required this.title,
    this.user,
    required this.stations,
  });

  Map<String, dynamic> toJson() => _$StationGroupToJson(this);
}

@JsonSerializable()
class Station4 {
  final int priority;
  final int station;

  factory Station4.fromJson(Map<String, dynamic> json) =>
      _$Station4FromJson(json);

  Station4({required this.priority, required this.station});

  Map<String, dynamic> toJson() => _$Station4ToJson(this);
}
