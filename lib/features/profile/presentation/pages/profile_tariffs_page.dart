import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/app/router/app_router.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/presentation/utils/profile_state.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_back_app_bar.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'ProfileTariffsRoute')
class ProfileTariffsPage extends StatelessWidget {
  const ProfileTariffsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.lightGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileBackAppBar(
              title: LocaleKeys.profile_page_tariffs.tr(),
              onBack: () => context.router.maybePop(),
            ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: ProfileState.isDiagnosticsCompleted,
                builder: (context, isCompleted, _) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTariffCard(
                          title: LocaleKeys.profile_tariffs_page_economy.tr(),
                          description: LocaleKeys.profile_tariffs_page_economy_desc.tr(),
                          isLocked: !isCompleted,
                        ),
                        const SizedBox(height: 12),
                        _buildTariffCard(
                          title: LocaleKeys.profile_tariffs_page_comfort.tr(),
                          description: LocaleKeys.profile_tariffs_page_comfort_desc.tr(),
                          isLocked: !isCompleted,
                        ),
                        const SizedBox(height: 12),
                        _buildTariffCard(
                          title: LocaleKeys.profile_tariffs_page_comfort_plus.tr(),
                          description: LocaleKeys.profile_tariffs_page_comfort_plus_desc.tr(),
                          isLocked: !isCompleted,
                        ),
                        if (!isCompleted) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ColorConst.grey,
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: LocaleKeys.profile_tariffs_page_unlock_instruction.tr().split('проведите диагностику').first,
                                  ),
                                  TextSpan(
                                    text: 'проведите диагностику',
                                    style: const TextStyle(
                                      color: ColorConst.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.router.push(const ProfileCarDiagnosticsRoute());
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorConst.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: ProfileState.isDeliveryEnabled,
                                builder: (context, isDeliveryEnabled, _) {
                                  return _buildSettingsTile(
                                    icon: Icons.inventory_2_outlined,
                                    title: LocaleKeys.profile_tariffs_page_delivery.tr(),
                                    subtitle: LocaleKeys.profile_tariffs_page_delivery_sub.tr(),
                                    trailing: Switch(
                                      value: isCompleted ? isDeliveryEnabled : false,
                                      onChanged: (value) {
                                        if (!isCompleted) {
                                          _showDiagnosticsAlert(context);
                                        } else {
                                          ProfileState.isDeliveryEnabled.value = value;
                                        }
                                      },
                                      activeThumbColor: ColorConst.primary,
                                    ),
                                    onTap: () {
                                      if (!isCompleted) {
                                        _showDiagnosticsAlert(context);
                                      } else {
                                        ProfileState.isDeliveryEnabled.value = !ProfileState.isDeliveryEnabled.value;
                                      }
                                    },
                                  );
                                },
                              ),
                              const Divider(height: 1, indent: 64, color: ColorConst.lightGrey),
                              _buildSettingsTile(
                                icon: Icons.settings_outlined,
                                title: LocaleKeys.profile_tariffs_page_additional.tr(),
                                subtitle: LocaleKeys.profile_tariffs_page_additional_sub.tr(),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: ColorConst.grey,
                                ),
                                onTap: () => context.router.push(const ProfileTariffsAdditionRoute()),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTariffCard({
    required String title,
    required String description,
    required bool isLocked,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isLocked ? ColorConst.black.withValues(alpha: 0.6) : ColorConst.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: isLocked ? ColorConst.grey.withValues(alpha: 0.6) : ColorConst.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isLocked)
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF8C9BFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: ColorConst.white,
                size: 18,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorConst.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                LocaleKeys.profile_tariffs_page_commission_badge.tr(),
                style: const TextStyle(
                  color: ColorConst.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F2F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: ColorConst.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorConst.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorConst.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showDiagnosticsAlert(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Чтобы разблокировать данный тариф, пожалуйста, пройдите диагностику авто.',
          style: TextStyle(color: ColorConst.white),
        ),
        backgroundColor: ColorConst.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Пройти',
          textColor: ColorConst.white,
          onPressed: () {
            context.router.push(const ProfileCarDiagnosticsRoute());
          },
        ),
      ),
    );
  }
}
