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
      stations:
          (json['stations'] as List<dynamic>?)
              ?.map((e) => Station.fromJson(e as Map<String, dynamic>))
              .toList(),
      fullname: json['fullname'] as String?,
    );

Map<String, dynamic> _$LoginResponseUserToJson(LoginResponseUser instance) =>
    <String, dynamic>{
      'username': instance.username,
      'fullname': instance.fullname,
      'stations': instance.stations,
      'is_staff': instance.isStaff,
    };

Station _$StationFromJson(Map<String, dynamic> json) => Station(
  code: json['code'] as String,
  rans:
      (json['rans'] as List<dynamic>)
          .map((e) => Ran.fromJson(e as Map<String, dynamic>))
          .toList(),
  typeName: json['type_name'] as String,
  name: json['name'] as String,
  district: json['district'] as String,
  area: json['area'] as String,
  capacity: (json['capacity'] as num).toInt(),
  type: (json['type'] as num).toInt(),
);

Map<String, dynamic> _$StationToJson(Station instance) => <String, dynamic>{
  'code': instance.code,
  'rans': instance.rans,
  'type_name': instance.typeName,
  'name': instance.name,
  'district': instance.district,
  'area': instance.area,
  'capacity': instance.capacity,
  'type': instance.type,
};

Ran _$RanFromJson(Map<String, dynamic> json) => Ran(
  id: (json['id'] as num).toInt(),
  sequenceNumber: (json['sequence_number'] as num).toInt(),
  station: json['station'] as String,
);

Map<String, dynamic> _$RanToJson(Ran instance) => <String, dynamic>{
  'id': instance.id,
  'sequence_number': instance.sequenceNumber,
  'station': instance.station,
};
