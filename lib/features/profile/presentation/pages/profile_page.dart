import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/app/app.dart';
import 'package:bazzone_driver/app/router/app_router.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:bazzone_driver/features/profile/domain/entities/driver_profile.dart';
import 'package:bazzone_driver/features/profile/domain/entities/profile_menu_item.dart';
import 'package:bazzone_driver/features/profile/domain/entities/profile_news_item.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_news_section.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_stats_row.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/image/user_avatar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'ProfileRoute')
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileMockDataSource _dataSource = ProfileMockDataSource();

  DriverProfile? _profile;
  List<ProfileMenuItem> _menuItems = [];
  List<ProfileNewsItem> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final profile = await _dataSource.fetchProfile();
    final news = await _dataSource.fetchNews();

    if (!mounted) return;

    setState(() {
      _profile = profile;
      _menuItems = _dataSource.fetchMenuItems(profile);
      _news = news;
      _isLoading = false;
    });
  }

  void _onMenuTap(ProfileMenuItem item) {
    switch (item.type) {
      case ProfileMenuType.tripHistory:
        router.push(const ProfileTripHistoryRoute());
      case ProfileMenuType.cars:
        router.push(const ProfileCarsRoute());
      case ProfileMenuType.taxiPark:
        router.push(const ProfileTaxiParkRoute());
      case ProfileMenuType.carDiagnostics:
      case ProfileMenuType.photoDiagnostics:
      case ProfileMenuType.tariffs:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final profile = _profile!;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ColorConst.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text(
                    LocaleKeys.profile_page_title.tr(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: ColorConst.black,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F1F4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: ColorConst.black,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConst.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    UserAvatarWidget(
                      userName: profile.fullName,
                      imageUrl: profile.avatarUrl,
                      size: UserAvatarSize.mediumLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.roleLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ColorConst.grey.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProfileStatsRow(profile: profile),
                    const SizedBox(height: 16),
                    if (_menuItems.isNotEmpty)
                      ProfileMenuTile(
                        item: _menuItems[0],
                        onTap: () => _onMenuTap(_menuItems[0]),
                        showDivider: false,
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorConst.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    if (_menuItems.length > 2) ...[
                      ProfileMenuTile(
                        item: _menuItems[1],
                        onTap: () => _onMenuTap(_menuItems[1]),
                        showDivider: true,
                      ),
                      ProfileMenuTile(
                        item: _menuItems[2],
                        onTap: () => _onMenuTap(_menuItems[2]),
                        showDivider: false,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorConst.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    if (_menuItems.length > 5) ...[
                      ProfileMenuTile(
                        item: _menuItems[3],
                        onTap: () => _onMenuTap(_menuItems[3]),
                        showDivider: true,
                      ),
                      ProfileMenuTile(
                        item: _menuItems[4],
                        onTap: () => _onMenuTap(_menuItems[4]),
                        showDivider: true,
                      ),
                      ProfileMenuTile(
                        item: _menuItems[5],
                        onTap: () => _onMenuTap(_menuItems[5]),
                        showDivider: false,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: ProfileNewsSection(items: _news),
            ),
          ),
        ],
      ),
    );
  }
}
