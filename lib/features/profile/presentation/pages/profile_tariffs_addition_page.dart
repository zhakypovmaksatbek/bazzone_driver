import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/presentation/utils/profile_state.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_back_app_bar.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'ProfileTariffsAdditionRoute')
class ProfileTariffsAdditionPage extends StatelessWidget {
  const ProfileTariffsAdditionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.lightGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileBackAppBar(
              title: LocaleKeys.profile_tariffs_addition_page_title.tr(),
              onBack: () => context.router.maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorConst.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: ProfileState.isChildSeatEnabled,
                        builder: (context, value, _) {
                          return _buildToggleTile(
                            title: LocaleKeys.profile_tariffs_addition_page_child_seat.tr(),
                            value: value,
                            onChanged: (newValue) => ProfileState.isChildSeatEnabled.value = newValue,
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 16, color: ColorConst.lightGrey),
                      ValueListenableBuilder<bool>(
                        valueListenable: ProfileState.isPetTransportEnabled,
                        builder: (context, value, _) {
                          return _buildToggleTile(
                            title: LocaleKeys.profile_tariffs_addition_page_pet_transport.tr(),
                            value: value,
                            onChanged: (newValue) => ProfileState.isPetTransportEnabled.value = newValue,
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 16, color: ColorConst.lightGrey),
                      ValueListenableBuilder<bool>(
                        valueListenable: ProfileState.isFoodDeliveryEnabled,
                        builder: (context, value, _) {
                          return _buildToggleTile(
                            title: LocaleKeys.profile_tariffs_addition_page_food_delivery.tr(),
                            value: value,
                            onChanged: (newValue) => ProfileState.isFoodDeliveryEnabled.value = newValue,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorConst.black,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: ColorConst.primary,
          ),
        ],
      ),
    );
  }
}
