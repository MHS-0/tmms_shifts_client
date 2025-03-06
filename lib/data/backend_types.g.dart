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

CreateShiftDataRequest _$CreateShiftDataRequestFromJson(
  Map<String, dynamic> json,
) => CreateShiftDataRequest(
  station: json['station'] as String,
  shift: json['shift'] as String,
  inputPressure: (json['input_pressure'] as num).toInt(),
  outputPressure: (json['output_pressure'] as num).toInt(),
  inputTemperature: (json['input_temperature'] as num).toInt(),
  outputTemperature: (json['output_temperature'] as num).toInt(),
  date: json['date'] as String,
);

Map<String, dynamic> _$CreateShiftDataRequestToJson(
  CreateShiftDataRequest instance,
) => <String, dynamic>{
  'station': instance.station,
  'shift': instance.shift,
  'input_pressure': instance.inputPressure,
  'output_pressure': instance.outputPressure,
  'input_temperature': instance.inputTemperature,
  'output_temperature': instance.outputTemperature,
  'date': instance.date,
};

CreateShiftDataResponse _$CreateShiftDataResponseFromJson(
  Map<String, dynamic> json,
) => CreateShiftDataResponse(
  registeredDatetime: json['registered_datetime'] as String,
  station: json['station'] as String,
  shift: json['shift'] as String,
  inputPressure: (json['input_pressure'] as num).toInt(),
  outputPressure: (json['output_pressure'] as num).toInt(),
  inputTemperature: (json['input_temperature'] as num).toInt(),
  outputTemperature: (json['output_temperature'] as num).toInt(),
  date: json['date'] as String,
  user: json['user'] as String?,
);

Map<String, dynamic> _$CreateShiftDataResponseToJson(
  CreateShiftDataResponse instance,
) => <String, dynamic>{
  'station': instance.station,
  'shift': instance.shift,
  'input_pressure': instance.inputPressure,
  'output_pressure': instance.outputPressure,
  'input_temperature': instance.inputTemperature,
  'output_temperature': instance.outputTemperature,
  'date': instance.date,
  'registered_datetime': instance.registeredDatetime,
  'user': instance.user,
};

UpdateShiftDataRequest _$UpdateShiftDataRequestFromJson(
  Map<String, dynamic> json,
) => UpdateShiftDataRequest(
  station: json['station'] as String,
  shift: json['shift'] as String,
  inputPressure: (json['input_pressure'] as num).toInt(),
  outputPressure: (json['output_pressure'] as num).toInt(),
  inputTemperature: (json['input_temperature'] as num).toInt(),
  outputTemperature: (json['output_temperature'] as num).toInt(),
  date: json['date'] as String,
);

Map<String, dynamic> _$UpdateShiftDataRequestToJson(
  UpdateShiftDataRequest instance,
) => <String, dynamic>{
  'station': instance.station,
  'shift': instance.shift,
  'input_pressure': instance.inputPressure,
  'output_pressure': instance.outputPressure,
  'input_temperature': instance.inputTemperature,
  'output_temperature': instance.outputTemperature,
  'date': instance.date,
};

UpdateShiftDataResponse _$UpdateShiftDataResponseFromJson(
  Map<String, dynamic> json,
) => UpdateShiftDataResponse(
  id: (json['id'] as num).toInt(),
  user: json['user'] as String?,
  station: json['station'] as String,
  registeredDatetime: json['registered_datetime'] as String,
  shift: json['shift'] as String,
  inputPressure: (json['input_pressure'] as num).toInt(),
  outputPressure: (json['output_pressure'] as num).toInt(),
  inputTemperature: (json['input_temperature'] as num).toInt(),
  outputTemperature: (json['output_temperature'] as num).toInt(),
  date: json['date'] as String,
);

Map<String, dynamic> _$UpdateShiftDataResponseToJson(
  UpdateShiftDataResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'station': instance.station,
  'shift': instance.shift,
  'input_pressure': instance.inputPressure,
  'output_pressure': instance.outputPressure,
  'input_temperature': instance.inputTemperature,
  'output_temperature': instance.outputTemperature,
  'date': instance.date,
  'registered_datetime': instance.registeredDatetime,
  'user': instance.user,
};

GetShiftDataResponse _$GetShiftDataResponseFromJson(
  Map<String, dynamic> json,
) => GetShiftDataResponse(
  id: (json['id'] as num).toInt(),
  user: json['user'] as String?,
  station: json['station'] as String,
  shift: json['shift'] as String,
  inputPressure: (json['input_pressure'] as num).toInt(),
  outputPressure: (json['output_pressure'] as num).toInt(),
  inputTemperature: (json['input_temperature'] as num).toInt(),
  registeredDatetime: json['registered_datetime'] as String,
  outputTemperature: (json['output_temperature'] as num).toInt(),
  date: json['date'] as String,
);

Map<String, dynamic> _$GetShiftDataResponseToJson(
  GetShiftDataResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'station': instance.station,
  'shift': instance.shift,
  'input_pressure': instance.inputPressure,
  'output_pressure': instance.outputPressure,
  'input_temperature': instance.inputTemperature,
  'output_temperature': instance.outputTemperature,
  'date': instance.date,
  'registered_datetime': instance.registeredDatetime,
  'user': instance.user,
};

GetShiftLastActionResponse _$GetShiftLastActionResponseFromJson(
  Map<String, dynamic> json,
) => GetShiftLastActionResponse(
  id: (json['id'] as num).toInt(),
  user: json['user'] as String?,
  station: json['station'] as String,
  shift: json['shift'] as String,
  inputPressure: (json['input_pressure'] as num).toInt(),
  outputPressure: (json['output_pressure'] as num).toInt(),
  inputTemperature: (json['input_temperature'] as num).toInt(),
  outputTemperature: (json['output_temperature'] as num).toInt(),
  registeredDatetime: json['registered_datetime'] as String,
  date: json['date'] as String,
);

Map<String, dynamic> _$GetShiftLastActionResponseToJson(
  GetShiftLastActionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'station': instance.station,
  'shift': instance.shift,
  'input_pressure': instance.inputPressure,
  'output_pressure': instance.outputPressure,
  'input_temperature': instance.inputTemperature,
  'output_temperature': instance.outputTemperature,
  'date': instance.date,
  'registered_datetime': instance.registeredDatetime,
  'user': instance.user,
};

GetShiftDataListResponse _$GetShiftDataListResponseFromJson(
  Map<String, dynamic> json,
) => GetShiftDataListResponse(
  count: (json['count'] as num).toInt(),
  next: json['next'],
  previous: json['previous'],
  results:
      (json['results'] as List<dynamic>)
          .map((e) => GetShiftDataResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$GetShiftDataListResponseToJson(
  GetShiftDataListResponse instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};
