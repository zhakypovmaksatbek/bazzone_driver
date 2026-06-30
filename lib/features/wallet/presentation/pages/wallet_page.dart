import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/app/app.dart';
import 'package:bazzone_driver/app/router/app_router.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/wallet/data/datasources/wallet_mock_datasource.dart';
import 'package:bazzone_driver/features/wallet/domain/entities/wallet_summary.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_action_buttons.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_balance_section.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_header.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

@RoutePage(name: 'WalletRoute')
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletMockDataSource _dataSource = WalletMockDataSource();

  WalletSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru');
    _loadSummary();
  }

  Future<void> _loadSummary({DateTime? month}) async {
    setState(() => _isLoading = true);

    final summary = await _dataSource.fetchSummary(month: month);

    if (!mounted) return;

    setState(() {
      _summary = summary;
      _isLoading = false;
    });
  }

  Future<void> _pickMonth() async {
    final current = _summary?.selectedMonth ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      locale: const Locale('ru'),
    );

    if (picked == null || !mounted) return;

    await _loadSummary(month: DateTime(picked.year, picked.month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.lightGrey,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final summary = _summary!;

    return RefreshIndicator(
      onRefresh: () => _loadSummary(month: summary.selectedMonth),
      color: ColorConst.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: WalletHeader(
                selectedMonth: summary.selectedMonth,
                monthlyEarned: summary.monthlyEarned,
                onMonthTap: _pickMonth,
                onEarnedTap: () {
                  router.push(
                    WalletEarnedRoute(initialMonth: summary.selectedMonth),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: WalletBalanceSection(balance: summary.balance),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
              child: WalletActionButtons(
                onTopUpTap: () {},
                onCardsTap: () {},
                onMoreTap: () {},
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              child: WalletTransactionList(transactions: summary.transactions),
            ),
          ),
        ],
      ),
    );
  }
}
