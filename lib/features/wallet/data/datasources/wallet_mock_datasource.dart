import 'package:bazzone_driver/features/wallet/domain/entities/wallet_earned_details.dart';
import 'package:bazzone_driver/features/wallet/domain/entities/wallet_payment_card.dart';
import 'package:bazzone_driver/features/wallet/domain/entities/wallet_summary.dart';
import 'package:bazzone_driver/features/wallet/domain/entities/wallet_transaction.dart';

class WalletMockDataSource {
  static const _paymentCards = [
    WalletPaymentCard(
      id: 'visa_9495',
      label: 'Visa **** 9495',
      isDefault: true,
    ),
    WalletPaymentCard(
      id: 'mastercard_1234',
      label: 'Mastercard **** 1234',
      isDefault: false,
    ),
  ];

  Future<WalletSummary> fetchSummary({DateTime? month}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final selectedMonth = month ?? DateTime(2025, 10);

    return WalletSummary(
      balance: 200,
      monthlyEarned: 9000,
      selectedMonth: selectedMonth,
      transactions: [
        WalletTransaction(
          id: '1',
          type: WalletTransactionType.topUp,
          title: 'Пополнение баланса',
          amount: 250,
          dateTime: DateTime(2025, 9, 17, 23, 45),
        ),
        WalletTransaction(
          id: '2',
          type: WalletTransactionType.commission,
          title: 'Снятие комиссии',
          amount: -20,
          dateTime: DateTime(2025, 9, 17, 23, 45),
        ),
        WalletTransaction(
          id: '3',
          type: WalletTransactionType.topUp,
          title: 'Пополнение баланса',
          amount: 250,
          dateTime: DateTime(2025, 9, 17, 23, 45),
        ),
        WalletTransaction(
          id: '4',
          type: WalletTransactionType.commission,
          title: 'Снятие комиссии',
          amount: -20,
          dateTime: DateTime(2025, 9, 17, 23, 45),
        ),
      ],
    );
  }

  Future<WalletEarnedDetails> fetchEarnedDetails({DateTime? month}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final selectedMonth = month ?? DateTime(2025, 10);

    return WalletEarnedDetails(
      selectedMonth: selectedMonth,
      earnedAmount: 9000,
      paymentCards: _paymentCards,
      selectedPaymentCardId: _paymentCards.first.id,
      taxiParkName: 'BazZone Drivers',
      limit: 5,
      commission: 20,
      partnershipMonths: 3,
    );
  }
}
