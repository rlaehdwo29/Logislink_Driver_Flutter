// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _Rest implements Rest {
  _Rest(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'http://211.252.86.30:806';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<HttpResponse<dynamic>> getCodeList(gcode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'gcode': gcode};
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cmm/code/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getVersion(versionKind) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'versionKind': versionKind};
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/cmm/version/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> login(cid) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'cid': cid};
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/login',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getUserInfo(
    Authorization,
    vehicId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'vehicId': vehicId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/user/info',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getUserCarInfo(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/drv/vehic/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> updateUser(
    Authorization,
    vehicId,
    bizName,
    bizNum,
    subBizNum,
    ceo,
    bizPost,
    bizAddr,
    bizAddrDetail,
    bizCond,
    bizKind,
    driverEmail,
    carTypeCode,
    carTonCode,
    cargoBox,
    dangerGoodsYn,
    chemicalsYn,
    foreignLicenseYn,
    forkliftYn,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'vehicId': vehicId,
      'bizName': bizName,
      'bizNum': bizNum,
      'subBizNum': subBizNum,
      'ceo': ceo,
      'bizPost': bizPost,
      'bizAddr': bizAddr,
      'bizAddrDetail': bizAddrDetail,
      'bizCond': bizCond,
      'bizKind': bizKind,
      'driverEmail': driverEmail,
      'carTypeCode': carTypeCode,
      'carTonCode': carTonCode,
      'cargoBox': cargoBox,
      'dangerGoodsYn': dangerGoodsYn,
      'chemicalsYn': chemicalsYn,
      'foreignLicenseYn': foreignLicenseYn,
      'forkliftYn': forkliftYn,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/user/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> updateBank(
    Authorization,
    bankCode,
    bankCnnm,
    bankAccount,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'bankCode': bankCode,
      'bankCnnm': bankCnnm,
      'bankAccount': bankAccount,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/bank/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> deviceUpdate(
    Authorization,
    pushYn,
    talkYn,
    pushId,
    deviceModel,
    deviceOs,
    appVersion,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'pushYn': pushYn,
      'talkYn': talkYn,
      'pushId': pushId,
      'deviceModel': deviceModel,
      'deviceOs': deviceOs,
      'appVersion': appVersion,
    };
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/device/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> locationUpdate(
    Authorization,
    lat,
    lon,
    allocId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'lat': lat,
      'lon': lon,
      'allocId': allocId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/location/update',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getOrder(
    Authorization,
    vehicId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'vehicId': vehicId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/order/list/v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getOrderDetail(
    Authorization,
    allocId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'allocId': allocId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/order/list/v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getOrderList2(
    Authorization,
    allocId,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'allocId': allocId,
      'orderId': orderId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/order/list/v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setOrderState(
    Authorization,
    orderId,
    allocId,
    allocState,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'allocId': allocId,
      'allocState': allocState,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/order/alloc/state',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setOrderState2(
    Authorization,
    orderId,
    allocId,
    allocState,
    nx,
    ny,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'allocId': allocId,
      'allocState': allocState,
      'nx': nx,
      'ny': ny,
    };
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/order/allocState/v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> setDriverClick(
    Authorization,
    orderId,
    orderState,
    addr,
    auto,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'orderState': orderState,
      'addr': addr,
      'auto': auto,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/order/click',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getReceipt(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/orderfile/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> removeReceipt(
    Authorization,
    orderId,
    allocId,
    fileSeq,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'allocId': allocId,
      'fileSeq': fileSeq,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/orderfile/delete',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getStopPoint(
    Authorization,
    orderId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'orderId': orderId};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/orderstop/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getStopPointGps(
    Authorization,
    vehicId,
    driverId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'vehicId': vehicId,
      'driverId': driverId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/orderstopgps/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> beginStartPoint(
    Authorization,
    orderId,
    stopSeq,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'stopSeq': stopSeq,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/orderstop/begin',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> finishStopPoint(
    Authorization,
    orderId,
    stopSeq,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'stopSeq': stopSeq,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/orderstop/finish',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getHistory(
    Authorization,
    fromDate,
    toDate,
    vehicId,
    receiptYn,
    taxYn,
    payType,
    payYn,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'fromDate': fromDate,
      'toDate': toDate,
      'vehicId': vehicId,
      'receiptYn': receiptYn,
      'taxYn': taxYn,
      'payType': payType,
      'payYn': payYn,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/history/list/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getCar(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/drv/carMain/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> carReg(
    Authorization,
    carName,
    carNum,
    mainYn,
    accMileage,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'carName': carName,
      'carNum': carNum,
      'mainYn': mainYn,
      'accMileage': accMileage,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/carMain/write',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> carEdit(
    Authorization,
    carSeq,
    carName,
    carNum,
    mainYn,
    accMileage,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'carSeq': carSeq,
      'carName': carName,
      'carNum': carNum,
      'mainYn': mainYn,
      'accMileage': accMileage,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/carMain/edit',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> carDel(
    Authorization,
    carSeq,
    useYn,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'carSeq': carSeq,
      'useYn': useYn,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/carMain/edit',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getCarBook(
    Authorization,
    carSeq,
    fromDate,
    toDate,
    itemCode,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'carSeq': carSeq,
      'fromDate': fromDate,
      'toDate': toDate,
      'itemCode': itemCode,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/carBook/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> carBookReg(
    Authorization,
    carSeq,
    itemCode,
    bookDate,
    price,
    mileage,
    refuelAmt,
    unitPrice,
    memo,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'carSeq': carSeq,
      'itemCode': itemCode,
      'bookDate': bookDate,
      'price': price,
      'mileage': mileage,
      'refuelAmt': refuelAmt,
      'unitPrice': unitPrice,
      'memo': memo,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/carBook/write',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> carBookEdit(
    Authorization,
    bookSeq,
    itemCode,
    bookDate,
    price,
    mileage,
    refuelAmt,
    unitPrice,
    memo,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'bookSeq': bookSeq,
      'itemCode': itemCode,
      'bookDate': bookDate,
      'price': price,
      'mileage': mileage,
      'refuelAmt': refuelAmt,
      'unitPrice': unitPrice,
      'memo': memo,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/carBook/edit',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> carBookDel(
    Authorization,
    bookSeq,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'bookSeq': bookSeq};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/carBook/delete',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getMonitorOrder(
    Authorization,
    fromDate,
    toDate,
    vehicId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'fromDate': fromDate,
      'toDate': toDate,
      'vehicId': vehicId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/monitor/list/v1',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getNotice(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/drv/notice/board/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getNotice2(
    Authorization,
    isNew,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'isNew': isNew};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/notice/board/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getNotification(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/drv/notice/push/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> writeTax(
    Authorization,
    orderId,
    allocId,
    pubform,
    supplierVehicId,
    writeDate,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'orderId': orderId,
      'allocId': allocId,
      'pubform': pubform,
      'supplierVehicId': supplierVehicId,
      'writeDate': writeDate,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/tax/write',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> issueTax(
    Authorization,
    invId,
    vehicId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'invId': invId,
      'vehicId': vehicId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/tax/issue',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTaxDetail(
    Authorization,
    invId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'invId': invId};
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/tax/detail',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> checkTaxMember(
    Authorization,
    email,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'email': email};
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/tax/sbmember',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> checkTaxMember2(
    Authorization,
    email,
    bizNum,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'email': email,
      'bizNum': bizNum,
    };
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/tax/sbmember/v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> joinTaxMember(
    Authorization,
    vehicId,
    sendType,
    orderId,
    allocId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'vehicId': vehicId,
      'sendType': sendType,
      'orderId': orderId,
      'allocId': allocId,
    };
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/cmm/send/talk',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> sendPay(
    Authorization,
    vehicId,
    orderId,
    allocId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'vehicId': vehicId,
      'orderId': orderId,
      'allocId': allocId,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/order/request/Pay',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> checkAccNm(
    Authorization,
    vehicId,
    bankCd,
    acctNo,
    acctNm,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'vehicId': vehicId,
      'bankCd': bankCd,
      'acctNo': acctNo,
      'acctNm': acctNm,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/user/checkAccNm',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getIaccNm(
    Authorization,
    vehicId,
    bankCd,
    acctNo,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'vehicId': vehicId,
      'bankCd': bankCd,
      'acctNo': acctNo,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/user/checkAccNm2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getDeadLine(
    Authorization,
    stdDate,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'stdDate': stdDate};
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/tax/closingDate',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getWeather(
    serviceKey,
    pageNo,
    numOfRows,
    dataType,
    base_date,
    base_time,
    nx,
    ny,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'serviceKey': serviceKey,
      r'pageNo': pageNo,
      r'numOfRows': numOfRows,
      r'dataType': dataType,
      r'base_date': base_date,
      r'base_time': base_time,
      r'nx': nx,
      r'ny': ny,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'getUltraSrtNcst',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getOilAvgSidoPrice(
    code,
    out,
    sido,
    prodcd,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'code': code,
      r'out': out,
      r'sido': sido,
      r'prodcd': prodcd,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'api/avgSidoPrice.do',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getOilAvgSigunPrice(
    code,
    out,
    sido,
    sigun,
    prodcd,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'code': code,
      r'out': out,
      r'sido': sido,
      r'sigun': sigun,
      r'prodcd': prodcd,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'api/avgSigunPrice.do',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTermsUserAgree(
    Authorization,
    userId,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'userId': userId};
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/terms/AgreeUserIndex',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getTermsTelAgree(
    Authorization,
    tel,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'tel': tel};
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/terms/AgreeTelIndex',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> insertTermsAgree(
    Authorization,
    tel,
    userName,
    necessary,
    selective,
    termsVersion,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'tel': tel,
      'userId': userName,
      'necessary': necessary,
      'selective': selective,
      'version': termsVersion,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/terms/insertTermsAgree',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> updateTermsAgree(
    Authorization,
    userId,
    necessary,
    selective,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'userId': userId,
      'necessary': necessary,
      'selective': selective,
    };
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/terms/updateTermsAgree',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getSalesManageList(
    Authorization,
    fromDate,
    toDate,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'fromDate': fromDate,
      'toDate': toDate,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/SalesManage/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> insertSalesManage(
    Authorization,
    DriveDate,
    StartDate,
    EndDate,
    StartLoc,
    EndLoc,
    OrderComp,
    truckNetwork,
    GoodsName,
    Money,
    ReceiptMethod,
    ReceiptDate,
    TaxMethod,
    TaxDate,
    Memo,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'driveDate': DriveDate,
      'startDate': StartDate,
      'endDate': EndDate,
      'startLoc': StartLoc,
      'endLoc': EndLoc,
      'orderComp': OrderComp,
      'truckNetwork': truckNetwork,
      'goodsName': GoodsName,
      'money': Money,
      'receiptMethod': ReceiptMethod,
      'receiptDate': ReceiptDate,
      'taxMethod': TaxMethod,
      'taxDate': TaxDate,
      'memo': Memo,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/SalesManage/insert',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> udpateSalesManage(
    Authorization,
    WorkId,
    DriveDate,
    StartDate,
    EndDate,
    StartLoc,
    EndLoc,
    OrderComp,
    truckNetwork,
    GoodsName,
    Money,
    ReceiptMethod,
    ReceiptDate,
    TaxMethod,
    TaxDate,
    Memo,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'workId': WorkId,
      'driveDate': DriveDate,
      'startDate': StartDate,
      'endDate': EndDate,
      'startLoc': StartLoc,
      'endLoc': EndLoc,
      'orderComp': OrderComp,
      'truckNetwork': truckNetwork,
      'goodsName': GoodsName,
      'money': Money,
      'receiptMethod': ReceiptMethod,
      'receiptDate': ReceiptDate,
      'taxMethod': TaxMethod,
      'taxDate': TaxDate,
      'memo': Memo,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/SalesManage/edit',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> invisibleSalesManage(
    Authorization,
    WorkId,
    Visible,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'workId': WorkId,
      'visible': Visible,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/SalesManage/delete',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> depositSalesManage(
    Authorization,
    WorkId,
    Deposit,
    depoDate,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'workId': WorkId,
      'deposit': Deposit,
      'depoDate': depoDate,
    };
    _data.removeWhere((k, v) => v == null);
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/SalesManage/deposit',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> orderSalesManage(Authorization) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': Authorization};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'application/x-www-form-urlencoded',
    )
            .compose(
              _dio.options,
              '/drv/SalesManage/order',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
