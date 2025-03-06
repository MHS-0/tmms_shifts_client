import 'package:dio/dio.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

const authHeaderKey = "Authorization";

class NetworkInterface {
  static final dio = Dio(
    BaseOptions(
      baseUrl: "localhost:8000",
      extra: {"withCredentials": true},
      preserveHeaderCase: true,
    ),
  );

  /// Private constructor to use when instantiating an instance inside the file.
  NetworkInterface._privateConstructor();

  static Map<String, dynamic> authHeaderEmpty() => {authHeaderKey: ""};
  static Map<String, dynamic> authHeaderWithToken() => {
    authHeaderKey: "Token ${Preferences.instance().activeUser?.token}",
  };

  /// The singleton instance of this class
  static final NetworkInterface _interface =
      NetworkInterface._privateConstructor();

  Future<LoginResponse> login(LoginRequest loginInfo) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/user/login",
      options: Options(headers: authHeaderEmpty()),
      data: loginInfo.toJson(),
    );
    final finalResp = LoginResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<void> logout() async {
    await dio.post(
      "/user/logout",
      options: Options(headers: authHeaderWithToken()),
    );
  }

  Future<CreateShiftDataResponse> createShiftData(
    CreateShiftDataRequest data,
  ) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/pressure_and_temperature/shift/",
      options: Options(headers: authHeaderWithToken()),
      data: data.toJson(),
    );
    final finalResp = CreateShiftDataResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<UpdateShiftDataResponse> updateShiftData(
    UpdateShiftDataRequest data,
  ) async {
    final Response<Map<String, dynamic>> resp = await dio.put(
      "/pressure_and_temperature/shift/3/",
      options: Options(headers: authHeaderWithToken()),
      data: data.toJson(),
    );
    final finalResp = UpdateShiftDataResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetShiftDataResponse> getShiftData() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/pressure_and_temperature/shift/12",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = GetShiftDataResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetShiftLastActionResponse> getShiftLastAction({
    int? stationCode,
  }) async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/pressure_and_temperature/last-action",
      options: Options(headers: authHeaderWithToken()),
      queryParameters:
          stationCode != null ? {"station_code": stationCode} : null,
    );
    final finalResp = GetShiftLastActionResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<void> destroyShiftData() async {
    await dio.delete(
      "/pressure_and_temperature/shift/3",
      options: Options(headers: authHeaderWithToken()),
    );
  }

  Future<GetShiftDataListResponse> getShiftDataList({
    String? fromDate,
    String? toDate,
    int? stationCodes,
  }) async {
    final Map<String, dynamic>? queries;
    if (fromDate == null && toDate == null && stationCodes == null) {
      queries = null;
    } else {
      queries = {
        if (fromDate != null) "from_date": fromDate,
        if (toDate != null) "to_date": toDate,
        if (stationCodes != null) "station_codes": stationCodes,
      };
    }

    final Response<Map<String, dynamic>> resp = await dio.get(
      "/pressure_and_temperature/shift",
      options: Options(headers: authHeaderWithToken()),
      queryParameters: queries,
    );
    final finalResp = GetShiftDataListResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<CreateCorrectorResponse> createCorrector(
    CreateCorrectorRequest data,
  ) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/meter_and_corrector/shift/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = CreateCorrectorResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<UpdateCorrectorResponse> updateCorrector(
    UpdateCorrectorRequest data,
  ) async {
    final Response<Map<String, dynamic>> resp = await dio.put(
      "/meter_and_corrector/shift/1/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = UpdateCorrectorResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetCorrectorDataListResponse> getCorrectorDataList({
    String? fromDate,
    String? toDate,
  }) async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/meter_and_corrector/shift",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = GetCorrectorDataListResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetCorrectorDataResponse> getCorrectorData() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/meter_and_corrector/shift/1/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = GetCorrectorDataResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<void> deleteCorrectorData() async {
    await dio.delete(
      "/meter_and_corrector/shift/1/",
      options: Options(headers: authHeaderWithToken()),
    );
  }

  Future<GetMeterAndCorrectorFullReportResponse>
  getMeterAndCorrectorFullReport({
    String? fromDate,
    String? toDate,
    int? stationCode,
  }) async {
    final Map<String, dynamic>? queries;
    if (fromDate == null && toDate == null && stationCode == null) {
      queries = null;
    } else {
      queries = {
        if (fromDate != null) "from_date": fromDate,
        if (toDate != null) "to_date": toDate,
        if (stationCode != null) "station_codes": stationCode,
      };
    }
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/reports/meter_and_corrector/full_report",
      options: Options(headers: authHeaderWithToken()),
      queryParameters: queries,
    );
    final finalResp = GetMeterAndCorrectorFullReportResponse.fromJson(
      resp.data!,
    );
    return finalResp;
  }

  /// The factory that returns the singleton instance.
  factory NetworkInterface.instance() => _interface;
}
