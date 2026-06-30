import 'package:bazzone_driver/features/wallet/domain/entities/wallet_payment_card.dart';

class WalletEarnedDetails {
  const WalletEarnedDetails({
    required this.selectedMonth,
    required this.earnedAmount,
    required this.paymentCards,
    required this.selectedPaymentCardId,
    required this.taxiParkName,
    required this.limit,
    required this.commission,
    required this.partnershipMonths,
  });

  final DateTime selectedMonth;
  final double earnedAmount;
  final List<WalletPaymentCard> paymentCards;
  final String selectedPaymentCardId;
  final String taxiParkName;
  final double limit;
  final double commission;
  final int partnershipMonths;

  WalletPaymentCard get selectedPaymentCard => paymentCards.firstWhere(
    (card) => card.id == selectedPaymentCardId,
  );

  WalletEarnedDetails copyWith({
    DateTime? selectedMonth,
    double? earnedAmount,
    List<WalletPaymentCard>? paymentCards,
    String? selectedPaymentCardId,
    String? taxiParkName,
    double? limit,
    double? commission,
    int? partnershipMonths,
  }) {
    return WalletEarnedDetails(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      earnedAmount: earnedAmount ?? this.earnedAmount,
      paymentCards: paymentCards ?? this.paymentCards,
      selectedPaymentCardId:
          selectedPaymentCardId ?? this.selectedPaymentCardId,
      taxiParkName: taxiParkName ?? this.taxiParkName,
      limit: limit ?? this.limit,
      commission: commission ?? this.commission,
      partnershipMonths: partnershipMonths ?? this.partnershipMonths,
    );
  }
}
