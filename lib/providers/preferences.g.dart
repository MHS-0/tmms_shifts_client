// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveUser _$ActiveUserFromJson(Map<String, dynamic> json) => ActiveUser(
  username: json['username'] as String,
  password: json['password'] as String,
  token: json['token'] as String,
  isStaff: json['isStaff'] as bool,
  expiry: DateTime.parse(json['expiry'] as String),
  stations:
      (json['stations'] as List<dynamic>)
          .map((e) => Station.fromJson(e as Map<String, dynamic>))
          .toList(),
  fullname: json['fullname'] as String?,
);

Map<String, dynamic> _$ActiveUserToJson(ActiveUser instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'fullname': instance.fullname,
      'stations': instance.stations,
      'token': instance.token,
      'isStaff': instance.isStaff,
      'expiry': instance.expiry.toIso8601String(),
    };
