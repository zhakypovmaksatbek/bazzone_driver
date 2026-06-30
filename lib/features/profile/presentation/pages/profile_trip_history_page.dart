import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:bazzone_driver/features/profile/domain/entities/trip_history_item.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_back_app_bar.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_trip_tile.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'ProfileTripHistoryRoute')
class ProfileTripHistoryPage extends StatefulWidget {
  const ProfileTripHistoryPage({super.key});

  @override
  State<ProfileTripHistoryPage> createState() => _ProfileTripHistoryPageState();
}

class _ProfileTripHistoryPageState extends State<ProfileTripHistoryPage> {
  final ProfileMockDataSource _dataSource = ProfileMockDataSource();

  List<TripHistorySection> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final sections = await _dataSource.fetchTripHistory();

    if (!mounted) return;

    setState(() {
      _sections = sections;
      _isLoading = false;
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
            ProfileBackAppBar(
              title: LocaleKeys.profile_trip_history_page_title.tr(),
              onBack: () => context.router.maybePop(),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: ColorConst.black,
                ),
              ),
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
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = _sections[sectionIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                section.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorConst.grey.withValues(alpha: 0.9),
                ),
              ),
            ),
            Container(
              color: ColorConst.white,
              child: Column(
                children: [
                  for (var i = 0; i < section.trips.length; i++)
                    ProfileTripTile(
                      trip: section.trips[i],
                      showDivider: i != section.trips.length - 1,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
