class PaymentRequestModel {
  final String siteCd;
  final String kcpCertInfo;
  final String ordrIdxx;
  final String payMethod;
  final String goodName;
  final String goodMny;
  final String retUrl;

  PaymentRequestModel({
    required this.siteCd,
    required this.kcpCertInfo,
    required this.ordrIdxx,
    required this.payMethod,
    required this.goodName,
    required this.goodMny,
    required this.retUrl,
  });

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) {
    return PaymentRequestModel(
      siteCd: json['site_cd'],
      kcpCertInfo: json['kcp_cert_info'],
      ordrIdxx: json['ordr_idxx'],
      payMethod: json['pay_method'],
      goodName: json['good_name'],
      goodMny: json['good_mny'],
      retUrl: json['Ret_URL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'site_cd': siteCd,
      'kcp_cert_info': kcpCertInfo,
      'ordr_idxx': ordrIdxx,
      'pay_method': payMethod,
      'good_name': goodName,
      'good_mny': goodMny,
      'Ret_URL': retUrl,
    };
  }
}