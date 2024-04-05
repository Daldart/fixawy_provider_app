class FinancialDataModel {
  final int netTotal;
  final int totalCommissions;
  final int totalWithdrawn;
  final int alreadyWithdrawn;
  final int readyToWithdrawal;
  final int pendingWithdrawal;

  FinancialDataModel({
    required this.netTotal,
    required this.totalCommissions,
    required this.totalWithdrawn,
    required this.alreadyWithdrawn,
    required this.readyToWithdrawal,
    required this.pendingWithdrawal,
  });

  factory FinancialDataModel.fromJson(Map<String, dynamic> json) {
    return FinancialDataModel(
      netTotal: json['net_total'] ?? 0,
      totalCommissions: json['total_commissions'] ?? 0,
      totalWithdrawn: json['total_withdrawn'] ?? 0,
      alreadyWithdrawn: json['already_withdrawn'] ?? 0,
      readyToWithdrawal: json['ready_to_withdrawal'] ?? 0,
      pendingWithdrawal: json['pending_withdrawal'] ?? 0,
    );
  }
}
