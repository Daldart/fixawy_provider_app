class WithdrawModel {
  final double amount;
  final String paymentMethod;
  final String notes;

  WithdrawModel({
    required this.amount,
    required this.paymentMethod,
    required this.notes,
  });

  factory WithdrawModel.fromJson(Map<String, dynamic> json) {
   return WithdrawModel(
      amount: json['amount'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['payment_method'] = this.paymentMethod;
    data['notes'] = this.notes;
    return data;
  }
}

