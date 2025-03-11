import 'package:logislink_driver_flutter/common/config_url.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart' ;

part 'rest.g.dart';

@RestApi(baseUrl: SERVER_URL)
abstract class Rest {
  factory Rest(Dio dio,{String baseUrl}) = _Rest;


  /**
   * 공통코드
   */
  @FormUrlEncoded()
  @POST(URL_CODE_LIST)
  Future<HttpResponse> getCodeList(
        @Field("gcode") String gcode,
        { @Field("filter1") String? filter1 }
      );

  /**
   * 버전코드
   */
  @FormUrlEncoded()
  @POST(URL_VERSION_CODE)
  Future<HttpResponse> getVersion(@Field("versionKind") String versionKind);


  /**
   * 로그 저장
   */
  @FormUrlEncoded()
  @POST(URL_EVENT_LOG)
  Future<HttpResponse> setEventLog(
      @Field("userId") String? userId,
      @Field("menu_url") String? menu_url,
      @Field("menu_name") String? menu_name,
      @Field("mobile_type") String? mobile_type,
      @Field("app_version") String? app_version,
      @Field("loginYn") String? loginYn
   );

  /**
   * 스마트로 MID
   */
  @FormUrlEncoded()
  @POST(URL_SMARTRO_MID)
  Future<HttpResponse> sendSmartroMid(@Header("Authorization") String? Authorization,
      @Field("custId") String? custId,
      @Field("deptId") String? deptId,
      @Field("driverId") String? driverId,
      @Field("vehicId") String? vehicId,

      @Field("ceo") String? ceo,
      @Field("mobile") String? mobile,
      @Field("socNo") String? socNo,
      @Field("driverEmail") String? driverEmail,
      @Field("bizNum") String? bizNum,
      @Field("bizName") String? bizName,
      @Field("bankCode") String? bankCode,
      @Field("bankAccount") String? bankAccount,
      @Field("bankCnnm") String? bankCnnm,
      @Field("bizAddr") String? bizAddr,
      @Field("bizAddrDetail") String? bizAddrDetail,
      @Field("bizPost") String? bizPost,
      );

  /**
   * 로그인
   */
  @FormUrlEncoded()
  @POST(URL_USER_LOGIN)
  Future<HttpResponse> login(@Field("cid") String cid);

  /**
   * IOS 로그인
   */
  @FormUrlEncoded()
  @POST(URL_USER_IOS_LOGIN)
  Future<HttpResponse> iosLogin(@Field("driverName") String driverName, @Field("cid") String cid);

  /**
   * 차주 정보
   */
  @FormUrlEncoded()
  @POST(URL_USER_INFO)
  Future<HttpResponse> getUserInfo(@Header("Authorization") String? Authorization,
      @Field("vehicId") String? vehicId);

  /**
   * 차주 차량 정보
   */
  @POST(URL_USER_CAR_INFO)
  Future<HttpResponse> getUserCarInfo(@Header("Authorization") String? Authorization);

  /**
   * 차주 정보 업데이트
   */
  @FormUrlEncoded()
  @POST(URL_UPDATE_USER)
  Future<HttpResponse> updateUser(@Header("Authorization") String? Authorization,
      @Field("vehicId") String? vehicId,
      @Field("bizName") String? bizName,
      @Field("bizNum") String? bizNum,
      @Field("subBizNum") String? subBizNum,
      @Field("ceo") String? ceo,
      @Field("bizPost") String? bizPost,
      @Field("bizAddr") String? bizAddr,
      @Field("bizAddrDetail") String? bizAddrDetail,
      @Field('socNo') String? socNo,
      @Field("bizCond") String? bizCond,
      @Field("bizKind") String? bizKind,
      @Field("driverEmail") String? driverEmail,
      @Field("carTypeCode") String? carTypeCode,
      @Field("carTonCode") String? carTonCode,
      @Field("cargoBox") String? cargoBox,
      @Field("dangerGoodsYn") String? dangerGoodsYn,
      @Field("chemicalsYn") String? chemicalsYn,
      @Field("foreignLicenseYn") String? foreignLicenseYn,
      @Field("forkliftYn") String? forkliftYn);

  /**
   * 차주 계좌 정보 업데이트
   */
  @FormUrlEncoded()
  @POST(URL_UPDATE_BANK)
  Future<HttpResponse> updateBank(@Header("Authorization") String? Authorization,
      @Field("bankCode") String? bankCode,
      @Field("bankCnnm") String? bankCnnm,
      @Field("bankAccount") String? bankAccount);

  /**
   * 기기 정보 업데이트
   */
  @FormUrlEncoded()
  @POST(URL_DEVICE_UPDATE)
  Future<HttpResponse> deviceUpdate(@Header("Authorization") String? Authorization,
      @Field("pushYn") String pushYn,
      @Field("talkYn") String talkYn,
      @Field("pushId") String pushId,
      @Field("deviceModel") String deviceModel,
      @Field("deviceOs") String deviceOs,
      @Field("appVersion") String appVersion);

  /**
   * 차주 위치 정보 업데이트
   */
  @FormUrlEncoded()
  @POST(URL_LOCATION_UPDATE)
  Future<HttpResponse> locationUpdate(@Header("Authorization") String? Authorization,
      @Field("lat") String? lat,
      @Field("lon") String? lon,
      @Field("allocId") String? allocId);

  /**
   * 오더 목록
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_LIST)
  Future<HttpResponse> getOrder(@Header("Authorization") String? Authorization,
      @Field("vehicId") String? vehicId);

  /**
   * 오더 상세
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_LIST)
  Future<HttpResponse> getOrderDetail(@Header("Authorization") String? Authorization,
      @Field("allocId") String? allocId);


  /*
     *  오더 상세(allocId, orderId)
     */
  @FormUrlEncoded()
  @POST(URL_ORDER_LIST)
  Future<HttpResponse> getOrderList2(@Header("Authorization") String? Authorization,
      @Field("allocId") String? allocId,
      @Field("orderId") String? orderId);


  /**
   * 배차 상태 변경
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_STATE)
  Future<HttpResponse> setOrderState(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("allocId") String? allocId,
      @Field("allocState") String? allocState);

  /**
   * 배차 상태 변경
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_STATE_V2)
  Future<HttpResponse> setOrderState2(@Header("Authorization") String? Authorization,
      @Field("orderId") String orderId,
      @Field("allocId") String allocId,
      @Field("allocState") String allocState,
      @Field("nx") String nx,
      @Field("ny") String ny);
  /**
   * 출도착, 경유지 출도착 기록 (수동)
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_DRIVER_CLICK)
  Future<HttpResponse> setDriverClick(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("orderState") String? orderState,
      @Field("addr") String? addr,
      @Field("auto") String? auto);

  /**
   * 인수증 목록
   */
  @FormUrlEncoded()
  @POST(URL_RECEIPT_LIST)
  Future<HttpResponse> getReceipt(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);

  /**
   * 인수증 업로드
   */
  /*@FormUrlEncoded()
  @POST(URL_RECEIPT_UPLOAD)
  Future<HttpResponse> uploadReceipt(@Header("Authorization") String? Authorization,
      @Part() String? orderId,
      @Part() String?  allocId,
      @Part() String? fileTypeCode,
      @Part() MultipartFile uploadFile);*/

  /**
   * 인수증 삭제
   */
  @FormUrlEncoded()
  @POST(URL_RECEIPT_REMOVE)
  Future<HttpResponse> removeReceipt(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("allocId") String? allocId,
      @Field("fileSeq") int? fileSeq);

  /**
   * 경유지 목록
   */
  @FormUrlEncoded()
  @POST(URL_STOP_POINT_LIST)
  Future<HttpResponse> getStopPoint(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId);
  /**
   * 경유지 GPS 목록
   */
  @FormUrlEncoded()
  @POST(URL_STOP_POINT_GPS_LIST)
  Future<HttpResponse> getStopPointGps(@Header("Authorization") String? Authorization,
      @Field("vehicId") String? vehicId,
      @Field("driverId") String? driverId);

  /**
   * 경유지 출발
   */
  @FormUrlEncoded()
  @POST(URL_STOP_POINT_BEGIN)
  Future<HttpResponse> beginStartPoint(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("stopSeq") String? stopSeq);

  /**
   * 경유지 도착
   */
  @FormUrlEncoded()
  @POST(URL_STOP_POINT_FINISH)
  Future<HttpResponse> finishStopPoint(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("stopSeq") String? stopSeq);

  /**
   * 운송실적 목록
   */
  @FormUrlEncoded()
  @POST(URL_ORDER_HISTORY_LIST)
  Future<HttpResponse> getHistory(@Header("Authorization") String? Authorization,
      @Field("fromDate") String? fromDate,
      @Field("toDate") String? toDate,
      @Field("vehicId") String? vehicId,
      @Field("receiptYn") String? receiptYn,
      @Field("taxYn") String? taxYn,
      @Field("payType") String? payType,
      @Field("payYn") String? payYn);

  /**
   * 차량 목록
   */
  @POST(URL_CAR_LIST)
  Future<HttpResponse> getCar(@Header("Authorization") String? Authorization);

  /**
   * 차량 등록
   */
  @FormUrlEncoded()
  @POST(URL_CAR_REG)
  Future<HttpResponse> carReg(@Header("Authorization") String? Authorization,
      @Field("carName") String? carName,
      @Field("carNum") String? carNum,
      @Field("mainYn") String? mainYn,
      @Field("accMileage") int? accMileage);

  /**
   * 차량 수정
   */
  @FormUrlEncoded()
  @POST(URL_CAR_EDIT)
  Future<HttpResponse> carEdit(@Header("Authorization") String? Authorization,
      @Field("carSeq") int? carSeq,
      @Field("carName") String? carName,
      @Field("carNum") String? carNum,
      @Field("mainYn") String? mainYn,
      @Field("accMileage") int? accMileage);

  /**
   * 차량 삭제
   */
  @FormUrlEncoded()
  @POST(URL_CAR_EDIT)
  Future<HttpResponse> carDel(@Header("Authorization") String? Authorization,
      @Field("carSeq") int? carSeq,
      @Field("useYn") String? useYn);

  /**
   * 차계부 목록
   */
  @FormUrlEncoded()
  @POST(URL_CAR_BOOK_LIST)
  Future<HttpResponse> getCarBook(@Header("Authorization") String? Authorization,
      @Field("carSeq") int? carSeq,
      @Field("fromDate") String? fromDate,
      @Field("toDate") String? toDate,
      @Field("itemCode") String? itemCode);

  /**
   * 차계부 등록
   */
  @FormUrlEncoded()
  @POST(URL_CAR_BOOK_REG)
  Future<HttpResponse> carBookReg(@Header("Authorization") String? Authorization,
      @Field("carSeq") int? carSeq,
      @Field("itemCode") String? itemCode,
      @Field("bookDate") String ?bookDate,
      @Field("price") int? price,
      @Field("mileage") int? mileage,
      @Field("refuelAmt") int? refuelAmt,
      @Field("unitPrice") int? unitPrice,
      @Field("memo") String? memo);

  /**
   * 차계부 수정
   */
  @FormUrlEncoded()
  @POST(URL_CAR_BOOK_EDIT)
  Future<HttpResponse> carBookEdit(@Header("Authorization") String? Authorization,
      @Field("bookSeq") String? bookSeq,
      @Field("itemCode") String? itemCode,
      @Field("bookDate") String? bookDate,
      @Field("price") int? price,
      @Field("mileage") int? mileage,
      @Field("refuelAmt") int? refuelAmt,
      @Field("unitPrice") int? unitPrice,
      @Field("memo") String? memo);

  /**
   * 차계부 삭제
   */
  @FormUrlEncoded()
  @POST(URL_CAR_BOOK_DEL)
  Future<HttpResponse> carBookDel(@Header("Authorization") String? Authorization,
      @Field("bookSeq") String? bookSeq);

  /**
   * 실적현황
   */
  @FormUrlEncoded()
  @POST(URL_MONITOR_ORDER)
  Future<HttpResponse> getMonitorOrder(@Header("Authorization") String? Authorization,
      @Field("fromDate") String? fromDate,
      @Field("toDate") String? toDate,
      @Field("vehicId") String? vehicId);

  /**
   * 공지사항
   */
  @POST(URL_NOTICE)
  Future<HttpResponse> getNotice(@Header("Authorization") String? Authorization);

  /**
   * 공지사항 최신
   */
  @FormUrlEncoded()
  @POST(URL_NOTICE)
  Future<HttpResponse> getNotice2(@Header("Authorization") String? Authorization,
      @Field("isNew") String? isNew);

  /**
   * 알림
   */
  @POST(URL_NOTIFICATION)
  Future<HttpResponse> getNotification(@Header("Authorization") String? Authorization);

  /**
   * 세금계산서 저장
   */
  @FormUrlEncoded()
  @POST(URL_TAX_WRITE)
  Future<HttpResponse> writeTax(@Header("Authorization") String? Authorization,
      @Field("orderId") String? orderId,
      @Field("allocId") String? allocId,
      @Field("pubform") String? pubform,
      @Field("supplierVehicId") String? supplierVehicId,
      @Field("writeDate") String? writeDate);

  /**
   * 세금계산서 발행
   */
  @FormUrlEncoded()
  @POST(URL_TAX_ISSUE)
  Future<HttpResponse> issueTax(@Header("Authorization") String? Authorization,
      @Field("invId") String? invId,
      @Field("vehicId") String? vehicId);

  /**
   * 세금계산서 확인
   */
  @FormUrlEncoded()
  @POST(URL_TAX_DETAIL)
  Future<HttpResponse> getTaxDetail(@Header("Authorization") String Authorization,
      @Field("invId") String invId);

  /**
   * 세금계산서 회원 체크(스마트빌)
   */
  @FormUrlEncoded()
  @POST(URL_TAX_MEMBER_CHECK)
  Future<HttpResponse> checkTaxMember(@Header("Authorization") String Authorization,
      @Field("email") String email);

  /**
   * 세금계산서 회원 체크(스마트빌)_V2
   */
  @FormUrlEncoded()
  @POST(URL_TAX_MEMBER_CHECK_V2)
  Future<HttpResponse> checkTaxMember2(@Header("Authorization") String Authorization,
      @Field("email") String email,
      @Field("bizNum") String bizNum);

  /**
   * 세금계산서 회원가입 요청(스마트빌)
   */
  @FormUrlEncoded()
  @POST(URL_TAX_MEMBER_JOIN)
  Future<HttpResponse> joinTaxMember(@Header("Authorization") String Authorization,
      @Field("vehicId") String vehicId,
      @Field("sendType") String sendType,
      @Field("orderId") String orderId,
      @Field("allocId") String allocId);

  /**
   * 빠른지급 신청
   */
  @FormUrlEncoded()
  @POST(URL_PAY_REQ)
  Future<HttpResponse> sendPay(@Header("Authorization") String? Authorization,
      @Field("vehicId") String? vehicId,
      @Field("orderId") String? orderId,
      @Field("allocId") String? allocId);

  /**
   * 예금주 확인
   */
  @FormUrlEncoded()
  @POST(URL_CHECK_ACC_NM)
  Future<HttpResponse> checkAccNm(@Header("Authorization") String? Authorization,
      @Field("vehicId") String? vehicId,
      @Field("bankCd") String? bankCd,
      @Field("acctNo") String? acctNo,
      @Field("acctNm") String? acctNm);

  /**
   * 예금주 조회
   */
  @FormUrlEncoded()
  @POST(URL_GET_IACC_NM)
  Future<HttpResponse> getIaccNm(@Header("Authorization") String? Authorization,
      @Field("vehicId") String? vehicId,
      @Field("bankCd") String? bankCd,
      @Field("acctNo") String? acctNo);

  /**
   * 세금계산서 마감일
   */
  @FormUrlEncoded()
  @POST(URL_DEAD_LINE)
  Future<HttpResponse> getDeadLine(@Header("Authorization") String? Authorization,
      @Field("stdDate") String? stdDate);


  /**
   * 날씨정보 호출
   */
  @GET(URL_WEATHER)
  Future<HttpResponse> getWeather(@Query("serviceKey") String serviceKey,
      @Query("pageNo") String pageNo,
      @Query("numOfRows") String numOfRows,
      @Query("dataType") String dataType,
      @Query("base_date") String base_date,
      @Query("base_time") String base_time,
      @Query("nx") String nx,
      @Query("ny") String ny);

  /**
   * 유가정보 호출 (시도)
   */
  @GET(URL_OPINET_SIDO)
  Future<HttpResponse> getOilAvgSidoPrice(
      @Query("code") String code,
      @Query("out") String out,
      @Query("sido") String sido,
      @Query("prodcd") String prodcd);

  /**
   * 유가정보 호출 (시군)
   */
  @GET(URL_OPINET_SIGUN)
  Future<HttpResponse> getOilAvgSigunPrice(
      @Query("code") String code,
      @Query("out") String out,
      @Query("sido") String sido,
      @Query("sigun") String sigun,
      @Query("prodcd") String prodcd);

  ///////////////////////////////////////////////////////////////////////
  // 추후 확인
  ///////////////////////////////////////////////////////////////////////

  /**
   * 약관 동의 확인(ID)
   */
  @FormUrlEncoded()
  @POST(URL_TERMS_ID)
  Future<HttpResponse> getTermsUserAgree(
      @Header("Authorization") String Authorization,
      @Field("userId") String userId);

  /**
   * 약관 동의 확인(전화번호)
   */
  @FormUrlEncoded()
  @POST(URL_TERMS_TEL)
  Future<HttpResponse> getTermsTelAgree(
      @Header("Authorization") String? Authorization,
      @Field("tel") String? tel);

  /**
   * 약관 동의 업데이트(필수, 선택항목)
   */
  @FormUrlEncoded()
  @POST(URL_TERMS_INSERT)
  Future<HttpResponse> insertTermsAgree(
      @Header("Authorization") String? Authorization,
      @Field("tel") String? tel,
      @Field("userId") String? userName,
      @Field("necessary") String? necessary,
      @Field("selective") String? selective,
      @Field("version") String? termsVersion
      );

  /**
   * 약관 동의 업데이트
   */
  @FormUrlEncoded()
  @POST(URL_TERMS_UPDATE)
  Future<HttpResponse> updateTermsAgree(
      @Header("Authorization") String Authorization,
      @Field("userId") String userId,
      @Field("necessary") String necessary,
      @Field("selective") String selective
      );


  /*
     * 범용성 매출관리 리스트 출력
     */
  @FormUrlEncoded()
  @POST(URL_SALES_MANAGE_LIST)
  Future<HttpResponse>
  getSalesManageList(
      @Header("Authorization") String? Authorization,
      @Field("fromDate") String? fromDate,
      @Field("toDate") String? toDate
      );

  /*
     * 범용성 매출관리 데이터 입력
     */
  @FormUrlEncoded()
  @POST(URL_SALES_MANAGE_WRITE)
  Future<HttpResponse> insertSalesManage(
      @Header("Authorization") String? Authorization,
      @Field("driveDate") String? DriveDate,
      @Field("startDate") String? StartDate,
      @Field("endDate") String? EndDate,
      @Field("startLoc") String? StartLoc,
      @Field("endLoc") String? EndLoc,
      @Field("orderComp") String? OrderComp,
      @Field("truckNetwork") String? truckNetwork,
      @Field("goodsName") String? GoodsName,
      @Field("money") int? Money,
      @Field("receiptMethod") String? ReceiptMethod,
      @Field("receiptDate") String? ReceiptDate,
      @Field("taxMethod") String? TaxMethod,
      @Field("taxDate") String? TaxDate,
      @Field("memo") String? Memo
      );


  /*
     * 범용성 매출관리 데이터 수정
     */
  @FormUrlEncoded()
  @POST(URL_SALES_MANAGE_EDIT)
  Future<HttpResponse> udpateSalesManage(
      @Header("Authorization") String? Authorization,
      @Field("workId") String? WorkId,
      @Field("driveDate") String? DriveDate,
      @Field("startDate") String? StartDate,
      @Field("endDate") String? EndDate,
      @Field("startLoc") String? StartLoc,
      @Field("endLoc") String? EndLoc,
      @Field("orderComp") String? OrderComp,
      @Field("truckNetwork") String? truckNetwork,
      @Field("goodsName") String? GoodsName,
      @Field("money") int? Money,
      @Field("receiptMethod") String? ReceiptMethod,
      @Field("receiptDate") String? ReceiptDate,
      @Field("taxMethod") String? TaxMethod,
      @Field("taxDate") String? TaxDate,
      @Field("memo") String? Memo
      );

  /*
     * 범용성 매출관리 데이터 삭제 처리
     */
  @FormUrlEncoded()
  @POST(URL_SALES_MANAGE_DELETE)
  Future<HttpResponse> invisibleSalesManage(
      @Header("Authorization") String? Authorization,
      @Field("workId") String? WorkId,
      @Field("visible") String? Visible
      );

  /*
     * 범용성 매출관리 입금확인 처리
     */
  @FormUrlEncoded()
  @POST(URL_SALES_DEPOSIT)
  Future<HttpResponse> depositSalesManage(
      @Header("Authorization") String? Authorization,
      @Field("workId") String? WorkId,
      @Field("deposit") String? Deposit,
      @Field("depoDate") String? depoDate
      );

  /*
    * 범용성 매출관리 기존 Order 데이터 DB에 넣기
    */
  @FormUrlEncoded()
  @POST(URL_SALES_ORDER)
  Future<HttpResponse> orderSalesManage(
      @Header("Authorization") String Authorization
      );
// OrderVO 값이 들어갈 수 있도록 조정 진행

}