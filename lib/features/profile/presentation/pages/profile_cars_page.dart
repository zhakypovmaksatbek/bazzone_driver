import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:bazzone_driver/features/profile/domain/entities/driver_car.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_back_app_bar.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_car_card.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'ProfileCarsRoute')
class ProfileCarsPage extends StatefulWidget {
  const ProfileCarsPage({super.key});

  @override
  State<ProfileCarsPage> createState() => _ProfileCarsPageState();
}

class _ProfileCarsPageState extends State<ProfileCarsPage> {
  final ProfileMockDataSource _dataSource = ProfileMockDataSource();

  List<DriverCar> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);
    final cars = await _dataSource.fetchCars();

    if (!mounted) return;

    setState(() {
      _cars = cars;
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
              title: LocaleKeys.profile_page_your_cars.tr(),
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _cars.length,
      separatorBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: ColorConst.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.profile_page_photo_diagnostics.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        return ProfileCarCard(car: _cars[index]);
      },
    );
  }
}
