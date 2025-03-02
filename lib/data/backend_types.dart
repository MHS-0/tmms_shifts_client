import 'package:json_annotation/json_annotation.dart';

part 'backend_types.g.dart'; // Generated file

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  // Generated methods
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

  @JsonKey(name: 'is_staff')
  final bool isStaff;

  LoginResponseUser({required this.username, required this.isStaff});

  factory LoginResponseUser.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseUserToJson(this);
}
