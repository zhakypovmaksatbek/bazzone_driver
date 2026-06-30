import 'package:bazzone_driver/features/wallet/domain/entities/wallet_transaction.dart';

class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.monthlyEarned,
    required this.selectedMonth,
    required this.transactions,
  });

  final double balance;
  final double monthlyEarned;
  final DateTime selectedMonth;
  final List<WalletTransaction> transactions;
}
