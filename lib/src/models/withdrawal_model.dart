class WithdrawalModel {
  final String id;
  final String vendorId;
  final double amount;
  final String bankName;
  final String accountNumber;
  final String status;
  final String requestedAt;

  WithdrawalModel({
    required this.id,
    required this.vendorId,
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    required this.status,
    required this.requestedAt,
  });

  factory WithdrawalModel.fromMap(Map<String, dynamic> map) {
    return WithdrawalModel(
      id: map["id"],
      vendorId: map["vendorId"],
      amount: (map["amount"] as num).toDouble(),
      bankName: map["bankName"],
      accountNumber: map["accountNumber"],
      status: map["status"],
      requestedAt: map["requestedAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "vendorId": vendorId,
      "amount": amount,
      "bankName": bankName,
      "accountNumber": accountNumber,
      "status": status,
      "requestedAt": requestedAt,
    };
  }
}
