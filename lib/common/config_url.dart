 //public static String SERVER_URL = "http://ec2-13-124-193-78.ap-northeast-2.compute.amazonaws.com:8080";     // DEV URL

  //public static String SERVER_URL = "https://app.logis-link.co.kr";   // PRO URL

  const String m_ServerRelease = "https://app.logis-link.co.kr";    // 실 서버

  const String m_ServerDebug = "http://192.168.68.70:8080";         // localhost
  //const String m_ServerDebug = "http://172.30.1.89:8080";
  //const String m_ServerDebug = "http://192.168.0.2:8080";

  const String m_ServerTest = "http://211.252.86.30:806";           // Test 서버
  //const String m_ServerTest = "http://211.252.86.30:8005";
  const String SERVER_URL = m_ServerRelease;

  const String RECEIPT_PATH = "/files/receipt/";

  const String m_Release = "https://abt.logis-link.co.kr";
  const String m_Debug = "http://172.30.1.89:8080";
  //const String m_Debug = "http://192.168.0.2:8080";
  const String m_Setting = m_ServerTest;

  const String JUSO_URL = "https://www.juso.go.kr";
  const String WEATHER_URL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/";
  const String OPINET_URL = "http://www.opinet.co.kr/";

  const String URL_JUSO = "/addrlink/addrLinkApi.do";
  const String URL_WEATHER = "getUltraSrtNcst";

  const String URL_OPINET_SIDO = "api/avgSidoPrice.do";
  const String URL_OPINET_SIGUN = "api/avgSigunPrice.do";

  // 공통코드
  const String URL_CODE_LIST = "/cmm/code/list";
  // 버전코드
  const String URL_VERSION_CODE = "/cmm/version/list";

  // 로그인
  const String URL_USER_LOGIN = "/drv/login";
  // 차주 정보
  const String URL_USER_INFO = "/drv/user/info";
  // 차주 차량 정보
  const String URL_USER_CAR_INFO = "/drv/vehic/list";
  // 차주 정보 업데이트
  const String URL_UPDATE_USER = "/drv/user/update";
  // 차주 계좌 정보 업데이트
  const String URL_UPDATE_BANK = "/drv/bank/update";
  // 기기 정보 업데이트
  const String URL_DEVICE_UPDATE = "/drv/device/update";
  // 위치 정보 업데이트
  const String URL_LOCATION_UPDATE = "/drv/location/update";
  // 배차 목록
  const String URL_ORDER_LIST = "/drv/order/list/v2";
  // 배차 상태 변경
  const String URL_ORDER_STATE = "/drv/order/alloc/state";
  // 배차 상태 변경_v2
  const String URL_ORDER_STATE_V2 = "/drv/order/allocState/v2";
  // 차주 출, 도착, 경유지 출,도착 Click 수집
  const String URL_ORDER_DRIVER_CLICK = "/drv/order/click";
  // 운송실적 목록
  const String URL_ORDER_HISTORY_LIST = "/drv/history/list/v1";
  // 인수증 목록
  const String URL_RECEIPT_LIST = "/drv/orderfile/list";
  // 인수증 업로드
  const String URL_RECEIPT_UPLOAD = "/drv/order/file/upload/v2";
  // 인수증 삭제
  const String URL_RECEIPT_REMOVE = "/drv/orderfile/delete";
  // 경유지 목록
  const String URL_STOP_POINT_LIST = "/drv/orderstop/list";
  // 경유지 GPS 받아오는 목록
  const String URL_STOP_POINT_GPS_LIST = "/drv/orderstopgps/list";
  // 경유지 출발
  const String URL_STOP_POINT_BEGIN = "/drv/orderstop/begin";
  // 경유지 도착
  const String URL_STOP_POINT_FINISH = "/drv/orderstop/finish";
  // 차계부 - 차량목록
  const String URL_CAR_LIST = "/drv/carMain/list";
  // 차계부 - 차량등록
  const String URL_CAR_REG = "/drv/carMain/write";
  // 차계부 - 차량수정/삭제
  const String URL_CAR_EDIT = "/drv/carMain/edit";
  // 차계부 - 목록
  const String URL_CAR_BOOK_LIST = "/drv/carBook/list";
  // 차계부 - 등록
  const String URL_CAR_BOOK_REG = "/drv/carBook/write";
  // 차계부 - 수정
  const String URL_CAR_BOOK_EDIT = "/drv/carBook/edit";
  // 차계부 - 삭제
  const String URL_CAR_BOOK_DEL = "/drv/carBook/delete";
  // 공지사항
  const String URL_NOTICE = "/drv/notice/board/list";
  // 공지사항 상세
  const String URL_NOTICE_DETAIL = "/notice/board/detail?boardSeq=";
  // 알림
  const String URL_NOTIFICATION = "/drv/notice/push/list";
  // 세금계산서 저장
  const String URL_TAX_WRITE = "/drv/tax/write";
  // 세금계산서 발행
  const String URL_TAX_ISSUE = "/drv/tax/issue";
  // 세금계산서 확인
  const String URL_TAX_DETAIL = "/drv/tax/detail";
  // 스마트빌 회원 확인
  const String URL_TAX_MEMBER_CHECK = "/drv/tax/sbmember";
  // 스마트빌 회원 확인_v2
  const String URL_TAX_MEMBER_CHECK_V2 = "/drv/tax/sbmember/v2";
  // 스마트빌 회원가입 요청
  const String URL_TAX_MEMBER_JOIN = "/drv/cmm/send/talk";
  // 빠른지급신청
  const String URL_PAY_REQ = "/drv/order/request/Pay";
  // 예금주 확인
  const String URL_CHECK_ACC_NM = "/drv/user/checkAccNm";
  // 예금주 조회
  const String URL_GET_IACC_NM = "/drv/user/checkAccNm2";
  // 세금계산서 마감일
  const String URL_DEAD_LINE = "/drv/tax/closingDate";
  // 실적현황(오더)
  const String URL_MONITOR_ORDER = "/drv/monitor/list/v1";

  // Junghwan.hwang Update
  // 약관 동의 확인(ID)
  const String URL_TERMS_ID = "/terms/AgreeUserIndex";
  // 약관 동의 확인(전화번호)
  const String URL_TERMS_TEL = "/terms/AgreeTelIndex";
  // 약관 동의 업데이트(필수, 선택항목)
  const String URL_TERMS_INSERT = "/terms/insertTermsAgree";
  // 약관 동의 기록 DB 저장(insert)
  const String URL_TERMS_UPDATE = "/terms/updateTermsAgree";

  // 구 버전
  // 서비스 이용약관
  //const String URL_SERVICE_TERMS = "https://abt.logis-link.co.kr/terms/service.do";
  // 개인정보 처리방침
  //const String URL_PRIVACY_TERMS = "https://abt.logis-link.co.kr/terms/privacy.do";
  // 위치기반 서비스 이용약관
  //const String URL_LBS_TERMS = "https://abt.logis-link.co.kr/terms/lbs.do";

  // 2022.10.01 버전
  // 이용약관
  const String URL_AGREE_TERMS = m_Setting +"/terms/agree.do";
  // 개인정보수집이용동의
  const String URL_PRIVACY_TERMS = m_Setting +"/terms/privacy.do";
  // 개인정보처리방침
  const String URL_PRIVATE_INFO_TERMS = m_Setting +"/terms/privateInfo.do";
  // 데이터보안서약
  const String URL_DATA_SECURE_TERMS = m_Setting +"/terms/dataSecure.do";
  // 마케팅정보수신동의
  const String URL_MARKETING_TERMS = m_Setting +"/terms/marketing.do";

  // 2022.12.22 버전
  // 범용성 매출관리 리스트 출력
  const String URL_SALES_MANAGE_LIST = "/drv/SalesManage/list";
  // 범용성 매출관리 데이터 입력
  const String URL_SALES_MANAGE_WRITE = "/drv/SalesManage/insert";
  // 범용성 매출관리 데이터 수정
  const String URL_SALES_MANAGE_EDIT = "/drv/SalesManage/edit";
  // 범용성 매출관리 데이터 삭제
  const String URL_SALES_MANAGE_DELETE = "/drv/SalesManage/delete";
  // 범용성 매출관리 입금관리 설정
  const String URL_SALES_DEPOSIT = "/drv/SalesManage/deposit";
  // 범용성 매출관리 기존 Order 데이터 DB에 넣기
  const String URL_SALES_ORDER = "/drv/SalesManage/order";

  /*
    * Junghwan.Hwang Memo
    * 현재 개인 약관 내용은 URL로 연결되어 HTML 웹 페이지 띄우는 방식으로 설정
    * 추가된 개인 약관 및 선택할 수 있도록 하는 XML 파일 수정 후 URL 연결 진행
    *
    * 백엔드 웹 페이지 어떻게 진행 될 것인지 논의 후 웹 페이지 게시 처리 진행
    * 2022-09-02
    */
  // 도움말
  const String URL_MANUAL = SERVER_URL + "/manual/D/list";

