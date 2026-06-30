enum WalletTransactionType {
  topUp,
  commission,
  payout,
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.dateTime,
  });

  final String id;
  final WalletTransactionType type;
  final String title;
  final double amount;
  final DateTime dateTime;

  bool get isCredit => amount >= 0;
}
