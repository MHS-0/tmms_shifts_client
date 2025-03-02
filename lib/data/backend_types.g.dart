// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  username: json['username'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      expiry: LoginResponse._parseDateTime(json['expiry'] as String),
      token: json['token'] as String,
      user: LoginResponseUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'expiry': LoginResponse._serializeDateTime(instance.expiry),
      'token': instance.token,
      'user': instance.user,
    };

LoginResponseUser _$LoginResponseUserFromJson(Map<String, dynamic> json) =>
    LoginResponseUser(
      username: json['username'] as String,
      isStaff: json['is_staff'] as bool,
    );

Map<String, dynamic> _$LoginResponseUserToJson(LoginResponseUser instance) =>
    <String, dynamic>{
      'username': instance.username,
      'is_staff': instance.isStaff,
    };
