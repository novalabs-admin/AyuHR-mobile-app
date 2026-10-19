class CompanyModel {
  final int companyId;
  final String companyName;
  final int subscriptionPlanId;
  final DateTime subscriptionExpiredDate;
  final bool status;
  final String logoPath;
  final int maxUserCount;
  final String batchStockType;
  final String email;
  final String addressLine1;
  final String addressLine2;
  final String contactNo1;
  final String contactNo2;
  final String companyCode;

  CompanyModel({
    required this.companyId,
    required this.companyName,
    required this.subscriptionPlanId,
    required this.subscriptionExpiredDate,
    required this.status,
    required this.logoPath,
    required this.maxUserCount,
    required this.batchStockType,
    required this.email,
    required this.addressLine1,
    required this.addressLine2,
    required this.contactNo1,
    required this.contactNo2,
    required this.companyCode,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['companyId'] as int,
      companyName: json['companyName'] as String,
      subscriptionPlanId: json['subscriptionPlanId'] as int,
      subscriptionExpiredDate: DateTime.parse(
        json['subscriptionExpiredDate'] as String,
      ),
      status: json['status'] as bool,
      logoPath: json['logoPath'] as String,
      maxUserCount: json['maxUserCount'] as int,
      batchStockType: json['batchStockType'] as String,
      email: json['email'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      contactNo1: json['contactNo1'] as String,
      contactNo2: json['contactNo2'] as String,
      companyCode: json['companyCode'] as String,
    );
  }
}