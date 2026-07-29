class BankAccountModel {
  final String bankName;
  final String accountHolderName;
  final String accountNumber;
  final bool autoWithdraw;
  final String withdrawFrequency;
  final int withdrawDay;

  BankAccountModel({
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.autoWithdraw,
    required this.withdrawFrequency,
    required this.withdrawDay,
  });

  Map<String, dynamic> toMap() {
    return {
      "bankName": bankName,
      "accountHolderName": accountHolderName,
      "accountNumber": accountNumber,
      "autoWithdraw": autoWithdraw,
      "withdrawFrequency": withdrawFrequency,
      "withdrawDay": withdrawDay,
    };
  }

  factory BankAccountModel.fromMap(Map<String, dynamic> map) {
    return BankAccountModel(
      bankName: map["bankName"] ?? "",
      accountHolderName: map["accountHolderName"] ?? "",
      accountNumber: map["accountNumber"] ?? "",
      autoWithdraw: map["autoWithdraw"] ?? false,
      withdrawFrequency: map["withdrawFrequency"] ?? "monthly",
      withdrawDay: map["withdrawDay"] ?? 25,
    );
  }
}
