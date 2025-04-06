import 'package:json_annotation/json_annotation.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

part 'backend_types.g.dart';

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
  @JsonKey(fromJson: _parseDateTime, toJson: _serializeDateTime)
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

  static DateTime _parseDateTime(String json) => DateTime.parse(json);

  static String _serializeDateTime(DateTime dateTime) =>
      dateTime.toIso8601String();
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
  final String date;

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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
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
  final String date;

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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
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
  final String date;
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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
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
  final String date;
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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
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
  final List<GetMeterAndCorrectorFullReportResponseResultItem> results;

  factory GetMeterAndCorrectorFullReportResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMeterAndCorrectorFullReportResponseFromJson(json);

  const GetMeterAndCorrectorFullReportResponse({
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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
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
  final List<GetMonitoringFullReportResponseResultItem> results;

  factory GetMonitoringFullReportResponse.fromJson(Map<String, dynamic> json) =>
      _$GetMonitoringFullReportResponseFromJson(json);

  const GetMonitoringFullReportResponse({
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
  @JsonKey(name: 'registered_datetime')
  final String? registeredDatetime;
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
  final List<GetPressureAndTemperatureFullReportResponseResultItem> results;

  factory GetPressureAndTemperatureFullReportResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetPressureAndTemperatureFullReportResponseFromJson(json);

  const GetPressureAndTemperatureFullReportResponse({
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
  final String date;
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
  final String date;
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
  final List<GetMeterChangeEventResponse> results;

  factory GetMeterChangeEventsListResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetMeterChangeEventsListResponseFromJson(json);

  const GetMeterChangeEventsListResponse({
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
  final String date;
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
  final String date;
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
  final String date;
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
  final String date;
  final List<Ran3> rans;

  const PutUpdateCorrectorBulkRequest({required this.date, required this.rans});

  factory PutUpdateCorrectorBulkRequest.fromJson(Map<String, dynamic> json) =>
      _$PutUpdateCorrectorBulkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PutUpdateCorrectorBulkRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetCorrectorDataBulkLastActionResponse {
  final String date;
  final List<Ran4> rans;

  const GetCorrectorDataBulkLastActionResponse({
    required this.date,
    required this.rans,
  });

  factory GetCorrectorDataBulkLastActionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetCorrectorDataBulkLastActionResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GetCorrectorDataBulkLastActionResponseToJson(this);
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
  final String date;
  @JsonKey(name: 'registered_datetime')
  final String registeredDatetime;
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
  final List<Station2> results;

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
class Station2 {
  final String code;
  final List<Ran5> rans;
  final String type;
  final String name;
  final String district;
  final String area;
  final int capacity;

  const Station2({
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
  final List<StationType> results;

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
class StationType {
  @JsonKey(name: 'type_name')
  final String typeName;

  factory StationType.fromJson(Map<String, dynamic> json) =>
      _$StationTypeFromJson(json);

  const StationType({required this.typeName});

  Map<String, dynamic> toJson() => _$StationTypeToJson(this);
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

  const Station3({
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

@JsonSerializable(explicitToJson: true)
class StationType2 {
  @JsonKey(name: 'type_name')
  final String typeName;
  final int id;

  factory StationType2.fromJson(Map<String, dynamic> json) =>
      _$StationType2FromJson(json);

  const StationType2({required this.id, required this.typeName});

  Map<String, dynamic> toJson() => _$StationType2ToJson(this);
}

@JsonSerializable(explicitToJson: true)
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

  const PostCorrectorChangeEventRequest({
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

@JsonSerializable(explicitToJson: true)
class GetCorrectorChangeEventListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<GetCorrectorChangeEventResponse> results;

  factory GetCorrectorChangeEventListResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetCorrectorChangeEventListResponseFromJson(json);

  const GetCorrectorChangeEventListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() =>
      _$GetCorrectorChangeEventListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetUsersCustomStationGroupResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<StationGroup> results;

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
class StationGroup {
  @JsonKey(includeIfNull: false)
  final int? id;
  final String title;
  final String? user;
  final List<Station4> stations;

  factory StationGroup.fromJson(Map<String, dynamic> json) =>
      _$StationGroupFromJson(json);

  const StationGroup({
    this.id,
    required this.title,
    this.user,
    required this.stations,
  });

  Map<String, dynamic> toJson() => _$StationGroupToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Station4 {
  final int priority;
  final int station;

  factory Station4.fromJson(Map<String, dynamic> json) =>
      _$Station4FromJson(json);

  const Station4({required this.priority, required this.station});

  Map<String, dynamic> toJson() => _$Station4ToJson(this);
}

// FIXME
/// This is here for now because I want to visually test things too, but at some point it
/// has to be moved to the relevant test sections/files.
final class MockData {
  static const mockToken =
      "6b42ba81497dd6dcce0a4dd665f1619843bd460b031258ea7aee0316d5e019f5";
  static const mockUsername = "admin";
  static const mockPassword = "1234";
  static const mockFullname = "Administrator";
  static const mockIsStaff = true;
  static const mockStations = [
    Station(
      code: 123,
      rans: [
        Ran(code: 1, sequenceNumber: 1, station: 123),
        Ran(code: 2, sequenceNumber: 2, station: 123),
      ],
      typeName: "CGS",
      title: "مهدی شهر",
      district: "مهدی شهر",
      area: "Semnan",
      capacity: 1234,
      type: 1,
      activity: 1,
    ),
    Station(
      code: 142,
      rans: [
        Ran(code: 4, sequenceNumber: 1, station: 142),
        Ran(code: 5, sequenceNumber: 2, station: 142),
      ],
      typeName: "CGS",
      title: "سمنان",
      district: "سمنان",
      area: "Semnan",
      capacity: 1234,
      type: 1,
      activity: 2,
    ),
  ];
  static final mockExpiry = DateTime(2040);

  static const mockLoginRequest = LoginRequest(
    username: mockUsername,
    password: mockPassword,
  );

  static final mockLoginResponse = LoginResponse(
    user: LoginResponseUser(username: mockUsername, isStaff: mockIsStaff),
    token: mockToken,
    expiry: mockExpiry,
  );

  static const mockGetProfileResponse = GetProfileResponse(
    username: mockUsername,
    isStaff: mockIsStaff,
    stations: mockStations,
    fullname: mockFullname,
  );

  static final mockActiveUser = ActiveUser.fromLoginResponse(
    mockLoginResponse,
    mockGetProfileResponse,
    mockPassword,
  );

  // Same structure as the login request
  static const mockLogoutRequest = mockLoginRequest;

  static const mockCreateShiftDataRequest = CreateShiftDataRequest(
    station: 31141050000010,
    shift: "12",
    inputPressure: 100,
    outputPressure: 150,
    inputTemperature: 3000,
    outputTemperature: 2300,
    date: "1403-11-11",
  );

  static const mockCreateShiftDataResponse = CreateShiftDataResponse(
    date: "1403-11-11",
    registeredDatetime: "1403-11-11",
    shift: "12",
    inputPressure: 100,
    outputPressure: 150,
    inputTemperature: 3000,
    outputTemperature: 2300,
    station: 12345,
    user: null,
  );

  static const mockUpdateShiftDataRequest = UpdateShiftDataRequest(
    station: 31141050000010,
    shift: "12",
    inputPressure: 100,
    outputPressure: 150,
    inputTemperature: 3000,
    outputTemperature: 2300,
    date: "1403-11-11",
  );

  static const mockUpdateShiftDataResponse = UpdateShiftDataResponse(
    id: 3,
    date: "1403-11-11",
    registeredDatetime: "1403-11-11",
    shift: "12",
    inputPressure: 100,
    outputPressure: 150,
    inputTemperature: 3000,
    outputTemperature: 2300,
    station: 12345,
    user: null,
  );

  static const mockGetShiftLastActionResponse = GetShiftLastActionResponse(
    id: 3,
    date: "1403-11-11",
    registeredDatetime: "1403-11-11",
    shift: "12",
    inputPressure: 100,
    outputPressure: 150,
    inputTemperature: 3000,
    outputTemperature: 2300,
    station: 12345,
    user: null,
  );

  static const mockGetShiftDataResponse1 = GetShiftDataResponse(
    id: 3,
    date: "1403-11-11",
    registeredDatetime: "1403-11-11",
    shift: "12",
    inputPressure: 100,
    outputPressure: 150,
    inputTemperature: 3000,
    outputTemperature: 2300,
    station: 12345,
    user: null,
  );

  static const mockGetShiftDataResponse2 = GetShiftDataResponse(
    id: 3,
    date: "1403-11-11",
    registeredDatetime: "1403-11-11",
    shift: "12",
    inputPressure: 100,
    outputPressure: 150,
    inputTemperature: 3000,
    outputTemperature: 2300,
    station: 12345,
    user: null,
  );

  static const mockGetShiftsDataListResponse = GetShiftsDataListResponse(
    next: null,
    previous: null,
    count: 2,
    results: [mockGetShiftDataResponse1, mockGetShiftDataResponse2],
  );

  static const mockCreateCorrectorRequest = CreateCorrectorRequest(
    date: "1403-01-01",
    meterAmount: 50,
    correctionAmount: 51,
    ran: 1,
  );

  static const mockCreateCorrectorResponse = CreateCorrectorResponse(
    date: "1403-01-01",
    registeredDatetime: null,
    stationCode: 1234,
    meterAmount: 50,
    correctionAmount: 51,
    ran: 1,
    user: null,
  );

  static const mockUpdateCorrectorRequest = UpdateCorrectorRequest(
    date: "1403-01-01",
    meterAmount: 50,
    correctionAmount: 51,
    ran: 1,
  );

  static const mockUpdateCorrectorResponse = UpdateCorrectorResponse(
    id: 2,
    date: "1403-01-01",
    registeredDatetime: null,
    stationCode: 1234,
    meterAmount: 50,
    correctionAmount: 51,
    ran: 1,
    user: null,
  );

  static const mockGetCorrectorDataResponse = GetCorrectorDataResponse(
    id: 2,
    date: "1403-01-01",
    registeredDatetime: null,
    stationCode: 1234,
    meterAmount: 50,
    correctionAmount: 51,
    ran: 1,
    user: null,
  );

  static const mockGetCorrectorDataListResponse = GetCorrectorDataListResponse(
    count: 1,
    next: null,
    previous: null,
    results: [mockGetCorrectorDataResponse],
  );

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
}
