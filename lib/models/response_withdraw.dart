class WithdrawalResponse {
  final String message;

  WithdrawalResponse({required this.message});

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      message: json['message'],
    );
  }
}
