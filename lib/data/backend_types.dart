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
  final String username;
  final String? fullname;
  final List<Station>? stations;
  @JsonKey(name: 'is_staff')
  final bool isStaff;

  LoginResponseUser({
    required this.username,
    required this.isStaff,
    this.stations,
    this.fullname,
  });

  factory LoginResponseUser.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseUserToJson(this);
}

@JsonSerializable()
class Station {
  final String code;
  final List<Ran> rans;
  @JsonKey(name: 'type_name')
  final String typeName;
  final String name;
  final String district;
  final String area;
  final int capacity;
  final int type;

  Station({
    required this.code,
    required this.rans,
    required this.typeName,
    required this.name,
    required this.district,
    required this.area,
    required this.capacity,
    required this.type,
  });

  factory Station.fromJson(Map<String, dynamic> json) =>
      _$StationFromJson(json);

  Map<String, dynamic> toJson() => _$StationToJson(this);
}

@JsonSerializable()
class Ran {
  final int id;
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber;
  final String station;

  Ran({required this.id, required this.sequenceNumber, required this.station});

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
class GetShiftDataListResponse {
  final int count;
  final Object? next;
  final Object? previous;
  final List<GetShiftDataResponse> results;

  factory GetShiftDataListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetShiftDataListResponseFromJson(json);

  GetShiftDataListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  Map<String, dynamic> toJson() => _$GetShiftDataListResponseToJson(this);
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
