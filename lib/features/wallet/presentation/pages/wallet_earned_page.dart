import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/wallet/data/datasources/wallet_mock_datasource.dart';
import 'package:bazzone_driver/features/wallet/domain/entities/wallet_earned_details.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_earned_balance_card.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_earned_details_card.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

@RoutePage(name: 'WalletEarnedRoute')
class WalletEarnedPage extends StatefulWidget {
  const WalletEarnedPage({
    super.key,
    this.initialMonth,
  });

  final DateTime? initialMonth;

  @override
  State<WalletEarnedPage> createState() => _WalletEarnedPageState();
}

class _WalletEarnedPageState extends State<WalletEarnedPage> {
  final WalletMockDataSource _dataSource = WalletMockDataSource();

  WalletEarnedDetails? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru');
    _loadDetails();
  }

  Future<void> _loadDetails({DateTime? month}) async {
    setState(() => _isLoading = true);

    final details = await _dataSource.fetchEarnedDetails(
      month: month ?? widget.initialMonth,
    );

    if (!mounted) return;

    setState(() {
      _details = details;
      _isLoading = false;
    });
  }

  Future<void> _pickMonth() async {
    final current = _details?.selectedMonth ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      locale: const Locale('ru'),
    );

    if (picked == null || !mounted) return;

    await _loadDetails(month: DateTime(picked.year, picked.month));
  }

  Future<void> _pickPaymentCard() async {
    final details = _details;
    if (details == null) return;

    final selectedId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ColorConst.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: ColorConst.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  LocaleKeys.wallet_earned_page_select_card.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorConst.black,
                  ),
                ),
                const SizedBox(height: 12),
                ...details.paymentCards.map((card) {
                  final isSelected = card.id == details.selectedPaymentCardId;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.credit_card_rounded,
                      color: isSelected
                          ? ColorConst.primary
                          : ColorConst.grey,
                    ),
                    title: Text(
                      card.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: ColorConst.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(card.id),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selectedId == null || !mounted) return;

    setState(() {
      _details = details.copyWith(selectedPaymentCardId: selectedId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WalletEarnedAppBar(
              onBack: () => context.router.maybePop(),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final details = _details!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          WalletEarnedBalanceCard(
            details: details,
            onMonthTap: _pickMonth,
            onPaymentCardTap: _pickPaymentCard,
          ),
          const SizedBox(height: 12),
          WalletEarnedDetailsCard(details: details),
        ],
      ),
    );
  }
}

class _WalletEarnedAppBar extends StatelessWidget {
  const _WalletEarnedAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: ColorConst.black,
            ),
          ),
          Text(
            LocaleKeys.wallet_page_earned.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ColorConst.black,
            ),
          ),
        ],
      ),
    );
  }
}
