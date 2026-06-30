import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:bazzone_driver/features/profile/domain/entities/taxi_park_details.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_back_app_bar.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_taxi_park_card.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'ProfileTaxiParkRoute')
class ProfileTaxiParkPage extends StatefulWidget {
  const ProfileTaxiParkPage({super.key});

  @override
  State<ProfileTaxiParkPage> createState() => _ProfileTaxiParkPageState();
}

class _ProfileTaxiParkPageState extends State<ProfileTaxiParkPage> {
  final ProfileMockDataSource _dataSource = ProfileMockDataSource();

  TaxiParkDetails? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    final details = await _dataSource.fetchTaxiParkDetails();

    if (!mounted) return;

    setState(() {
      _details = details;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.lightGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileBackAppBar(
              title: LocaleKeys.profile_taxi_park_page_title.tr(),
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ProfileTaxiParkCard(
              details: _details!,
              onMoreTap: () {},
              onWithdrawalTermsTap: () {},
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorConst.primary,
                side: const BorderSide(color: ColorConst.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                LocaleKeys.profile_taxi_park_page_change_park.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
