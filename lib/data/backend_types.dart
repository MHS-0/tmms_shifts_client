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
