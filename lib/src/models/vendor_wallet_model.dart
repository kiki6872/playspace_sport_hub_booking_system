class VendorWalletModel {
  final String vendorId;
  final double balance;
  final double totalRevenue;
  final double totalWithdrawn;

  VendorWalletModel({
    required this.vendorId,
    required this.balance,
    required this.totalRevenue,
    required this.totalWithdrawn,
  });

  factory VendorWalletModel.fromMap(Map<String, dynamic> map) {
    return VendorWalletModel(
      vendorId: map["vendorId"],
      balance: (map["balance"] as num).toDouble(),
      totalRevenue: (map["totalRevenue"] as num).toDouble(),
      totalWithdrawn: (map["totalWithdrawn"] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "vendorId": vendorId,
      "balance": balance,
      "totalRevenue": totalRevenue,
      "totalWithdrawn": totalWithdrawn,
    };
  }
}
