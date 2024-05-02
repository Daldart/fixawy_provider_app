class FinancialDataModel {
  final double netTotal;
  final double totalCommissions;
  final double totalWithdrawn;
  final double alreadyWithdrawn;
  final double readyToWithdrawal;
  final double pendingWithdrawal;
  final String? currency;

  FinancialDataModel({
    required this.netTotal,
    required this.totalCommissions,
    required this.totalWithdrawn,
    required this.alreadyWithdrawn,
    required this.readyToWithdrawal,
    required this.pendingWithdrawal,
    this.currency,
  });

  factory FinancialDataModel.fromJson(Map<String, dynamic> json) {
    return FinancialDataModel(
      netTotal: json['net_total']?.toDouble() ?? 0.0,
      totalCommissions: json['total_commissions']?.toDouble() ?? 0.0,
      totalWithdrawn: json['total_withdrawn']?.toDouble() ?? 0.0,
      alreadyWithdrawn: json['already_withdrawn']?.toDouble() ?? 0.0,
      readyToWithdrawal: json['ready_to_withdrawal']?.toDouble() ?? 0.0,
      pendingWithdrawal: json['pending_withdrawal']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
    );
  }
}
