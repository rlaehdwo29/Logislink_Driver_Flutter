class Const {
// 로그 개발 true, 운영 false
 static final bool logEnable = false;

 // 디버그 모드 개발 true, 운영 false
 static final bool debugEnable = false;
 static final bool userDebugger = true;

 // 버전명
 static final APP_VERSION = "1.1.79";

 //스토어 주소
 static final ANDROID_STORE = "https://play.google.com/store/apps/details?id=com.logislink.driver";
 static final IOS_STORE = "https://apps.apple.com/app/id6467700597";

 static final int CONNECT_TIMEOUT = 15;
 static final int WRITE_TIMEOUT = 15;
 static final int READ_TIMEOUT = 15;

 static final List<String> first_screen = ["기본", "운송실적", "실적현황", "차계부"];
 static final List<String> navi_setting = ["카카오내비", "T map"];

 /**
  * PUSH SERVICE
  */
 static final PUSH_SERVICE_CHANNEL_ID = "CHANNEL_LOGISLINK_INNOVATION";

 /**
  * GPS SERVICE CHANNEL, SETTING
  */
 static const int LOCATION_INTERVAL = 5000; //30000; //20000;
 static const int LOCATION_FAST_INTERVAL = 4000; //20000; // 10000;
 static const int LOCATION_SMALLEST_DISPLACEMENT = 150;
 static const LOCATION_SERVICE_CHANNEL_ID = "LOCATION_SERVICE";
 static const LOCATION_SERVICE_CHANNEL_NAME = "위치 전송 서비스";
 static const int LOCATION_SERVICE_ID = 9999;

 // GPS 주기 반영 Const
 static final int gpsLapTime = 6;

 /**
  * Deep Link OR Dynamic Link
  */
 static const String DEEP_LINK_ORDER = "order";
 static const String DEEP_LINK_TAX = "tax";
 static const String DEEP_LINK_RECEIPT = "receipt";


 /**
  * Geofence
  */
 static const int GEOFENCE_RADIUS_IN_METERS = 150;

 /**
  * Intent key
  */
 static final CODE = "code";

 // 오더 Vo
 static final ORDER_VO = "order_vo";

 // 공지사항 Vo
 static final NOTICE_VO = "notice_vo";

 // 차량 VO
 static final CAR_VO = "car_vo";

 // 차계부 VO
 static final CAR_BOOK_VO = "car_book_vo";

 // 범용성 매출관리 VO
 static final SALES_MANAGE_VO = "sales_manage_vo";

 /**
  * SP key 값
  */
 // 약관동의
 static final KEY_TERMS = "key_terms";

 // 유저정보
 static final KEY_USER_INFO = "key_user_info";

 // 차량정보
 static final KEY_CAR_INFO = "key_car_info";

 // 푸쉬 ID
 static final KEY_PUSH_ID = "key_push_id";

 // 진행중인 오더
 static final KEY_ALLOC_ID = "key_alloc_id";

 // 마지막 위치
 static final KEY_LAT = "key_lat",
     KEY_LON = "key_lon";

 // 환경설정 - 화면 꺼짐 방지
 static final KEY_SETTING_WAKE = "key_setting_wake";

 // 환경설정 - 길안내 설정
 static final KEY_SETTING_NAVI = "key_setting_navi";

 // 환경설정 - 푸시
 static final KEY_SETTING_PUSH = "key_setting_push";

 // 환경설정 - 알림톡
 static final KEY_SETTING_TALK = "key_setting_talk";

 // 환경설정 - 퇴근 설정
 static final KEY_SETTING_WORK = "key_setting_work";

 // 환경설정 - 시작 화면 설정
 static final KEY_SETTING_SCREEN = "key_setting_screen";

 // 최근 공지 읽음처리
 static final KEY_READ_NOTICE = "key_read_notice";

 // Guest 모드
 static final KEY_GUEST_MODE = "key_guest";

 /**
  * Intent Filter
  */
 static final INTENT_ORDER_REFRESH = "com.logislink.driver.INTENT_ORDER_REFRESH";
 static final INTENT_GEOFENCE = "com.logislink.driver.INTENT_GEOFENCE";
 static final INTENT_DETAIL_REFRESH = "com.logislink.driver.INTENT_DETAIL_REFRESH";

 /**
  * Intent Filter
  * Deposit - 매출관리(입금확인 부분)
  */
 static final INTENT_DEPOSIT = "com.logislink.driver.adapter.DEPOSIT";

 /**
  * 공통코드 key
  */
 static List<String> codeList = [
  SELL_BUY_SCTN,
  SHIPMENT_PROG_CD,
  QTY_UNIT_CD,
  WGT_UNIT_CD,
  CAR_SPEC_CD,
  ITEM_CD,
  CARGO_TRAN_CAR_SCTN_CD,
  CUST_TYPE_CD,
  SIDO,
  TM_CAR_TYPE_CD,
  IN_OUT_SCTN,
  TRUCK_TYPE_CD,
  CAR_BOOK_ITEM_CD,
  BIZ_TYPE_CD,
  BANK_CD,
  ORDER_STATE_CD,
  ALLOC_STATE_CD,
  WAY_TYPE_CD,
  MIX_SIZE_CD,
  CAR_TYPE_CD,
  CAR_TON_CD,
  CAR_MNG_CD,
  URGENT_CODE,
  LINK_CD,
  RECEIPT_KIND
 ];

 static getCodeList() {
  return codeList;
 }

 // 공통코드 버전
 static final CD_VERSION = "CD_VERSION";

 // 매출입구분
 static final SELL_BUY_SCTN = "SELL_BUY_SCTN";

 // 배차진행상태
 static final SHIPMENT_PROG_CD = "SHIPMENT_PROG_CD";

 // 수량단위
 static final QTY_UNIT_CD = "QTY_UNIT_CD";

 // 중량단위
 static final WGT_UNIT_CD = "WGT_UNIT_CD";

 // 차량규격(톤수)
 static final CAR_SPEC_CD = "CAR_SPEC_CD";

 // 대분류품목군
 static final ITEM_CD = "ITEM_CD";

 // 차량구분
 static final CARGO_TRAN_CAR_SCTN_CD = "CARGO_TRAN_CAR_SCTN_CD";

 // 거래처구분
 static final CUST_TYPE_CD = "CUST_TYPE_CD";

 // 시/도
 static final SIDO = "SIDO";

 // 차량유형(차종)
 static final TM_CAR_TYPE_CD = "TM_CAR_TYPE_CD";

 // 수출입구분
 static final IN_OUT_SCTN = "IN_OUT_SCTN";

 // 운송유형
 static final TRUCK_TYPE_CD = "TRUCK_TYPE_CD";

 // 차계부항목
 static final CAR_BOOK_ITEM_CD = "CAR_BOOK_ITEM_CD";

 // 사업자구분
 static final BIZ_TYPE_CD = "BIZ_TYPE_CD";

 // 은행
 static final BANK_CD = "BANK_CD";

 // 오더상태
 static final ORDER_STATE_CD = "ORDER_STATE_CD";

 // 배차상태
 static final ALLOC_STATE_CD = "ALLOC_STATE_CD";

 // 상하차방법
 static final WAY_TYPE_CD = "WAY_TYPE_CD";

 // 혼적길이
 static final MIX_SIZE_CD = "MIX_SIZE_CD";

 // 차종
 static final CAR_TYPE_CD = "CAR_TYPE_CD";

 // 톤수
 static final CAR_TON_CD = "CAR_TON_CD";

 // 차량관리코드
 static final CAR_MNG_CD = "CAR_MNG_CD";

 // 긴급대응상태
 static final URGENT_CODE = "URGENT_CODE";

 // 화물정보망그룹코드
 static final LINK_CD = "LINK_CD";

 // 접수 방법
 static final RECEIPT_KIND = "RECEIPT_KIND";

 // 매출 수정, 등록, 정보
 static final SALES_MANAGE_MODE = "SALES_MANAGE_MODE";

 // 범용성 매출관리 Enable 버튼 처리
 static final SALES_MANAGE_ENABLE = "SALES_MANAGE_ENABLE";

 // 차주 팝업 체크
 static final DRIVER_POPUP_CHECK = "MOBILE_POPUP";

 /**
  * 날짜/시간 포맷(2) : "MM.dd"
  */
 static final dateFormat2 = "MM.dd";

 /**
  * 날짜/시간 포맷(3) : yyyy-MM-dd HH:mm:ss
  */
 static final dateFormat3 = "yyyy-MM-dd HH:mm:ss";

 /**
  * 날짜/시간 포맷(4) : yyyy-MM-dd HH:mm:ss.SSS"
  */
 static final dateFormat4 = "yyyy-MM-dd HH:mm:ss.SSS";

 /**
  * 날짜/시간 포맷(6) : yyyy-MM-dd
  */
 static final dateFormat6 = "yyyy-MM-dd";

 /**
  * 앱 코드 key
  */
 // Y, N 선택
 static final YN_SEL = "YN_SEL";

 // 카카오 API KEY
 static const KAKAO_NATIVE_APP_KEY = "9c7cb4fd9cdd9bc998a4f30370322033";

 // T맵 API KEY
 static const TMAP_NATIVE_APP_KEY = "l7xx9363c407318b4b04910193a57d19242a";

 // 주소 API KEY
 static const JUSU_KEY = "U01TX0FVVEgyMDIxMDcyODEyNTg0MzExMTQ2MjA=";

 // 날씨 API KEY
 static const WEATHER_KEY = "QJMBTjy1C2mHYXaYNHs7no9pVZ7HnzZqgzzdqP6c0ePNuxw5b9TEEYR3vaQ5SkFLIsd4R+3GTY0zZ4KqwrbDbw==";

 // 유가 API KEY
 static const OPINET_KEY = "F211007202";

}

/*
    * 기본 Enum 및 연산 도구
    */

enum TERMS {
 INSERT, UPDATE, DONE
}

enum SALES{
 INFORM_ACCOUNT ,
 INFORM_BASIC ,
 INFORM_BUISNESS,
 MAIN,
 MODIFY,
 ORDER_BASIC,
 LANDING,
 ORDER_TAX
}

enum SALES_MANAGE{
 INFORMATION,
 REGISTER,
 MODIFY
}
