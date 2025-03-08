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

  Future<GetProfileResponse> getProfile() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/user/profile/",
      options: Options(headers: authHeaderEmpty()),
    );
    final finalResp = GetProfileResponse.fromJson(resp.data!);
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

  Future<GetShiftsDataListResponse> getShiftsDataList({
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
    final finalResp = GetShiftsDataListResponse.fromJson(resp.data!);
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
    final Map<String, dynamic>? queries;
    if (fromDate == null && toDate == null) {
      queries = null;
    } else {
      queries = {
        if (fromDate != null) "from_date": fromDate,
        if (toDate != null) "to_date": toDate,
      };
    }

    final Response<Map<String, dynamic>> resp = await dio.get(
      "/meter_and_corrector/shift",
      options: Options(headers: authHeaderWithToken()),
      queryParameters: queries,
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
        if (stationCode != null) "station_code": stationCode,
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

  Future<GetMonitoringFullReportResponse> getMonitoringFullReport({
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
        if (stationCode != null) "station_code": stationCode,
      };
    }
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/reports/monitoring/full_report",
      options: Options(headers: authHeaderWithToken()),
      queryParameters: queries,
    );
    final finalResp = GetMonitoringFullReportResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetPressureAndTemperatureFullReportResponse>
  getPressureAndTemperatureFullReport({
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
        if (stationCode != null) "station_code": stationCode,
      };
    }
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/reports/pressure_and_temperature/full_report",
      options: Options(headers: authHeaderWithToken()),
      queryParameters: queries,
    );
    final finalResp = GetPressureAndTemperatureFullReportResponse.fromJson(
      resp.data!,
    );
    return finalResp;
  }

  Future<GetMeterChangeEventResponse> getMeterChangeEventResponse() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/equipment_replacement_events/meter/4/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = GetMeterChangeEventResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<CreateMeterChangeEventResponse> createMeterChangeEventResponse(
    CreateMeterChangeEventRequest data,
  ) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/equipment_replacement_events/meter/",
      options: Options(headers: authHeaderWithToken()),
      data: data.toJson(),
    );
    final finalResp = CreateMeterChangeEventResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetMeterChangeEventsListResponse> getMeterChangeEventsList({
    String? fromDate,
    String? toDate,
    List<int>? stationCodes,
  }) async {
    final Map<String, dynamic>? queries;
    if (fromDate == null && toDate == null && stationCodes == null) {
      queries = null;
    } else {
      queries = {
        if (fromDate != null) "from_date": fromDate,
        if (toDate != null) "to_date": toDate,
        if (stationCodes != null) "station_codes": stationCodes.join(","),
      };
    }
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/equipment_replacement_events/meter",
      options: Options(headers: authHeaderWithToken()),
      queryParameters: queries,
    );
    final finalResp = GetMeterChangeEventsListResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<UpdateMeterChangeEventResponse> updateMeterChangeEventResponse(
    UpdateMeterChangeEventRequest data,
  ) async {
    final Response<Map<String, dynamic>> resp = await dio.put(
      "/equipment_replacement_events/meter/1/",
      options: Options(headers: authHeaderWithToken()),
      data: data.toJson(),
    );
    final finalResp = UpdateMeterChangeEventResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<void> deleteMeterChangeEventResponse() async {
    await dio.delete(
      "/equipment_replacement_events/meter/1/",
      options: Options(headers: authHeaderWithToken()),
    );
  }

  Future<GetMeterChangeEventLastActionResponse> getMeterChangeLastAction({
    int? stationCode,
    int? ranId,
  }) async {
    final Map<String, dynamic>? queries;
    if (stationCode == null && ranId == null) {
      queries = null;
    } else {
      queries = {
        if (stationCode != null) "station_code": stationCode,
        if (ranId != null) "ran_id": ranId,
      };
    }
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/equipment_replacement_events/last-action/meter",
      options: Options(headers: authHeaderWithToken()),
      queryParameters: queries,
    );
    final finalResp = GetMeterChangeEventLastActionResponse.fromJson(
      resp.data!,
    );
    return finalResp;
  }

  Future<PostCreateCorrectorBulkResponse> createCorrectorBulk(
    PostCreateCorrectorBulkRequest data,
  ) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/meter_and_corrector/bulk/",
      options: Options(headers: authHeaderWithToken()),
      data: data.toJson(),
    );
    final finalResp = PostCreateCorrectorBulkResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<void> putUpdateCorrectorBulk(
    PutUpdateCorrectorBulkRequest data,
  ) async {
    await dio.post(
      "/meter_and_corrector/bulk/",
      options: Options(headers: authHeaderWithToken()),
      data: data.toJson(),
    );
  }

  // FIX
  // Could return something that's not a list maybe...?
  Future<List<GetCorrectorDataBulkLastActionResponse>>
  getCorrectorDataBulkLastAction(
    String? fromDate,
    String? toDate,
    int? stationCode,
  ) async {
    final Response<List<dynamic>> resp = await dio.get(
      "/meter_and_corrector/bulk/last-action",
      options: Options(headers: authHeaderWithToken()),
    );
    final data = resp.data!;
    final List<GetCorrectorDataBulkLastActionResponse> list = [];
    for (final item in data) {
      final tempItem = GetCorrectorDataBulkLastActionResponse.fromJson(
        item as Map<String, dynamic>,
      );
      list.add(tempItem);
    }
    return list;
  }

  Future<GetShiftDataBulkLastActionResponse> getShiftDataBulkLastAction({
    int? stationCode,
  }) async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/pressure_and_temperature/last-action",
      options: Options(headers: authHeaderWithToken()),
      queryParameters:
          stationCode != null ? {"station_code": stationCode} : null,
    );
    final finalResp = GetShiftDataBulkLastActionResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetStationDataListResponse> getStationDataBulk() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/organization/station/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = GetStationDataListResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetStationTypeDataListResponse> getStationTypeDataBulk() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/organization/station-type/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = GetStationTypeDataListResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<Station2> getStationData() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/organization/station/12345/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = Station2.fromJson(resp.data!);
    return finalResp;
  }

  Future<StationType> getStationTypeData() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/organization/station-type/2/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = StationType.fromJson(resp.data!);
    return finalResp;
  }

  Future<Station3> createStation(PostCreateStationRequest data) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/organization/station/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = Station3.fromJson(resp.data!);
    return finalResp;
  }

  Future<StationType> createStationType(StationType data) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/organization/station-type/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = StationType.fromJson(resp.data!);
    return finalResp;
  }

  Future<Station3> updateStationData(PostCreateStationRequest data) async {
    final Response<Map<String, dynamic>> resp = await dio.put(
      "/organization/station/12347/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = Station3.fromJson(resp.data!);
    return finalResp;
  }

  Future<StationType2> updateStationTypeData(StationType data) async {
    final Response<Map<String, dynamic>> resp = await dio.put(
      "/organization/station-type/2",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = StationType2.fromJson(resp.data!);
    return finalResp;
  }

  Future<void> deleteStation() async {
    await dio.delete(
      "/organization/station/12346/",
      options: Options(headers: authHeaderWithToken()),
    );
  }

  Future<void> deleteStationType() async {
    await dio.delete(
      "/organization/station-type/2",
      options: Options(headers: authHeaderWithToken()),
    );
  }

  Future<GetCorrectorChangeEventResponse> getCorrectorChangeEvent() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "equipment_replacement_events/corrector/1/",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = GetCorrectorChangeEventResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetCorrectorChangeEventResponse> createCorrectorChangeEvent(
    PostCorrectorChangeEventRequest data,
  ) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/equipment_replacement_events/corrector/",
      options: Options(headers: authHeaderWithToken()),
      data: data.toJson(),
    );
    final finalResp = GetCorrectorChangeEventResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetCorrectorChangeEventListResponse>
  getCorrectorChangeEventListResponse({
    String? fromDate,
    String? toDate,
  }) async {
    final Map<String, dynamic>? queries;
    if (fromDate == null && toDate == null) {
      queries = null;
    } else {
      queries = {
        if (fromDate != null) "from_date": fromDate,
        if (toDate != null) "to_date": toDate,
      };
    }

    final Response<Map<String, dynamic>> resp = await dio.get(
      "/equipment_replacement_events/corrector",
      options: Options(headers: authHeaderWithToken()),
      queryParameters: queries,
    );
    final finalResp = GetCorrectorChangeEventListResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<GetCorrectorChangeEventResponse> updateCorrectorChangeEvent(
    PostCorrectorChangeEventRequest data,
  ) async {
    final Response<Map<String, dynamic>> resp = await dio.put(
      "/equipment_replacement_events/corrector/1/",
      options: Options(headers: authHeaderWithToken()),
      data: data.toJson(),
    );
    final finalResp = GetCorrectorChangeEventResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<void> deleteCorrectorChangeEvent() async {
    await dio.delete(
      "/equipment_replacement_events/corrector/1/",
      options: Options(headers: authHeaderWithToken()),
    );
  }

  Future<GetCorrectorChangeEventResponse> getCorrectorChangeEventLastAction({
    int? stationCode,
  }) async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/equipment_replacement_events/last-action/corrector",
      options: Options(headers: authHeaderWithToken()),
      queryParameters:
          stationCode != null ? {"station_code": stationCode} : null,
    );
    final finalResp = GetCorrectorChangeEventResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<void> removeCustomStationGroup() async {
    await dio.delete(
      "/reports/station_groups/3/",
      options: Options(headers: authHeaderWithToken()),
    );
  }

  Future<GetUsersCustomStationGroupResponse>
  getUsersCustomStationsGroup() async {
    final Response<Map<String, dynamic>> resp = await dio.get(
      "/reports/station_groups",
      options: Options(headers: authHeaderWithToken()),
    );
    final finalResp = GetUsersCustomStationGroupResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<StationGroup> createNewStationsGroup(StationGroup data) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/reports/station_groups",
      options: Options(headers: authHeaderWithToken()),
      data: data.toJson(),
    );
    final finalResp = StationGroup.fromJson(resp.data!);
    return finalResp;
  }

  /// The factory that returns the singleton instance.
  factory NetworkInterface.instance() => _interface;
}
